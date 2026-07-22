-- Build configuration for seatingchart
module = "seatingchart"

sourcefiles = { "*.dtx" }
unpackfiles = { "*.dtx" }
installfiles = {
  "*.sty",
  "*.lua",
  "*.sc"
}

typesetexe = "lualatex"
typesetopts = "-interaction=nonstopmode -shell-escape"
typesetruns = 3
typesetfiles = {
  "seatingchart.dtx",
  "seatingchart-example.tex"
}
typesetsuppfiles = {
  "*.sty",
  "*.cls"
}

docfiles = {
  "*.dtx",
  "*.pdf",
  "README.md",
  "seatingchart-example.tex",
  "example-infile.csv"
}

cleanfiles = {
  "*-cnltx*",
  "*.toc",
  "*.aux",
  "*.idx",
  "*.ilg",
  "*.ind"
}

tagfiles = { "seatingchart.dtx" }

-- The documentation is maintained in one bilingual .dtx source. langselect
-- obtains the target language from the second component of the job name.
function typeset(file, dir, cmd)
  dir = dir or "."
  local extension = file:match("%.([^.]*)$")
  local jobs

  if extension == "dtx" then
    cp("seatingchart-doc-*.tex", unpackdir, dir)
    jobs = { module .. "-en", module .. "-de" }
  else
    jobs = { file:match("([^/]+)%.[^.]+$") }
  end

  for _, job in ipairs(jobs) do
    local errorlevel
    for run = 1, typesetruns do
      errorlevel = tex(file, dir, cmd .. " -jobname=" .. job)
      if errorlevel ~= 0 then
        return errorlevel
      end

      if run == 1 and extension == "dtx" then
        makeindex(job, dir, ".idx", ".ind", ".ilg", indexstyle)
      end

      if run > 1 and not rerun_needed(job, dir) then
        break
      end
    end
  end

  return 0
end

function rerun_needed(job, dir)
  local logfile = io.open(dir .. "/" .. job .. ".log", "r")
  if not logfile then
    return false
  end
  local log = logfile:read("*all")
  logfile:close()

  return log:find("Rerun to get cross%-references right")
    or log:find("Label%(s%) may have changed")
    or log:find("There were undefined references")
    or log:find("Rerun LaTeX")
end

local function update_lua_tag(content, tagname, tagdate)
  local updated = content:gsub(
    "(Date:%s*\n%s*)%d%d%d%d%-%d%d%-%d%d",
    "%1" .. tagdate
  )
  updated = updated:gsub(
    "(Version:%s*\n%s*)v?[%w%.%-]+",
    "%1" .. tagname
  )
  return updated
end

function update_tag(file, content, tagname, tagdate)
  if not tagname then
    local handle = io.popen("git describe --tags --abbrev=0")
    tagname = handle:read("*a"):match("[^\n]+")
    handle:close()
    print("Set tagname to '" .. tagname .. "'")
  end

  -- l3build passes --date through without validation or normalisation. Accept
  -- both common input forms and derive the format required by each target.
  local iso_date = tagdate:gsub("/", "-")

  if file:match("%.lua$") then
    return update_lua_tag(content, tagname, iso_date)
  end

  if file:match("%.dtx$") then
    local package_date = iso_date:gsub("-", "/")
    local updated = content:gsub(
      "(\\ProvidesExplPackage%s*{seatingchart}%s*\n%s*{)"
        .. "%d%d%d%d/%d%d/%d%d"
        .. "(}%s*\n%s*{)[^}%s]+(})",
      "%1" .. package_date .. "%2" .. tagname .. "%3",
      1
    )

    -- Lua has no \Provides... declaration. Restrict its independent metadata
    -- update to the docstrip guard so that no other embedded file becomes a
    -- second source for the package version.
    updated = updated:gsub(
      "(%%<%*lua>\n)(.-)(\n%%</lua>)",
      function(opening, lua, closing)
        return opening .. update_lua_tag(lua, tagname, iso_date) .. closing
      end,
      1
    )
    return updated
  end

  return content
end
