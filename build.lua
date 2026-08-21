module = "seatingchart"

checkengines = { "luatex" }
stdengine = "luatex"

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

--[[ 
  Include the ready-to-install tree in the CTAN upload.  In particular, this
  carries the files generated from the dtx source (.sty, .lua, and .sc). 
]]
packtdszip = true



docfiles = {
  "seatingchart-en.pdf",
  "seatingchart-de.pdf",
  "seatingchart-example.pdf",
  "seatingchart-example.tex",
  "example-infile.csv"
}

--[[ 
  build.lua should be part of the release sources so that the unpacked CTAN archive
  can run the same documentation and regression-test targets. 
]]
textfiles = {
  "README.md",
  "build.lua"
}

excludefiles = {
  "*~",
  "config-*.lua"
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

--[[ 
  The documentation is maintained in one bilingual .dtx source,
  langselect obtains the target language from the second component of the job name. 
]]
function typeset(file, dir, cmd)
  dir = dir or "."
  local extension = file:match("%.([^.]*)$")
  local jobs

  if extension == "dtx" then
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

--[[ 
  l3build normally derives *one* PDF name from each typeset source.
  However, we use langselect. Thus, the dtx driver deliberately
  creates one PDF *per language* (in this case English and German).
  Thus, we publish both names explicitly where the CTAN collector
  expects documentation files. 
]]
  if extension == "dtx" then
    for _, job in ipairs(jobs) do
      local errorlevel = cp(job .. ".pdf", dir, docfiledir)
      if errorlevel ~= 0 then
        return errorlevel
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

--[[
  Include the support files required to rebuild the documentation from the
  CTAN source archive. Regression tests are intentionally not shipped.
]]
local l3build_copyctan = copyctan
function copyctan()
  local errorlevel = l3build_copyctan()
  if errorlevel and errorlevel ~= 0 then
    return errorlevel
  end

  local package_dir = ctandir .. "/" .. ctanpkg
  local release_dirs = {
    { source = supportdir, target = package_dir .. "/support",
      patterns = { "*.sty", "*.cls" } }
  }

  for _, directory in ipairs(release_dirs) do
    mkdir(directory.target)
    for _, pattern in ipairs(directory.patterns) do
      errorlevel = cp(pattern, directory.source, directory.target)
      if errorlevel ~= 0 then
        return errorlevel
      end
    end
  end

  return 0
end

--[[
  Collect all user-facing artifacts in build/result instead of leaving
  generated files in the package root.
]]
local l3build_ctan = ctan
function ctan()
  local errorlevel = l3build_ctan()
  if errorlevel ~= 0 then
    return errorlevel
  end

  mkdir(resultdir)
  local artifacts = {
    { name = "seatingchart-en.pdf", source = docfiledir },
    { name = "seatingchart-de.pdf", source = docfiledir },
    { name = "seatingchart-example.pdf", source = docfiledir },
    { name = ctanzip .. ".zip", source = ctandir },
    { name = ctanpkg .. ".tds.zip", source = tdsdir }
  }
  for _, artifact in ipairs(artifacts) do
    if fileexists(artifact.source .. "/" .. artifact.name) then
      rm(resultdir, artifact.name)
      cp(artifact.name, artifact.source, resultdir)
    end
    rm(currentdir, artifact.name)
  end

  return 0
end

-- target_list captures the original function before build.lua is loaded.
-- Point the public target explicitly at the wrapper above.
target_list.ctan.func = ctan

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

  --[[
    l3build passes --date through without validation or normalisation. 
    We accept both common input forms and derive the format required by each target.
  ]]
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

--[[
  Lua has no \Provides... declaration. Restrict its independent metadata
  update to the docstrip guard so that no other embedded file becomes a
  second source for the package version.
  NOTE: Has to be adapted in case of several lua files.
]]
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
