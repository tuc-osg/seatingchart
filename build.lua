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

function update_tag(file, content, tagname, tagdate)
  if not tagname then
    local handle = io.popen("git describe --tags --abbrev=0")
    tagname = handle:read("*a"):match("[^\n]+")
    handle:close()
    print("Set tagname to '" .. tagname .. "'")
  end

  local updated = content:gsub(
    "Date:\n([%%%s]+)%d%d%d%d%-%d%d%-%d%d",
    "Date:\n%1" .. tagdate
  )
  updated = updated:gsub(
    "Version:\n([%%%s]+)v%d+%.%d+%.%d+",
    "Version:\n%1" .. tagname
  )
  return updated
end
