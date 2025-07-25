-- Build configuration for seatingchart
module = "seatingchart"

unpackfiles = {}
sourcefiles= {
   "*.sty",
   "*.sc",
   "*.lua"
}
installfiles= {
   "*.sty",
   "*.sc",
   "*.lua"
}

typesetfiles = {
   "seatingchart-doc-en.tex",
   "seatingchart-doc-de.tex"
}

typesetopts="-interaction=nonstopmode -shell-escape"

docfiles = {
   "seatingchart-example.tex"
}

cleanfiles={
    "*-doc-*-cnltx*",
    "*.toc",
    "*.aux"
}

tagfiles = {
    "seatingchart.sty",
    "seatingchart.lua",
    "*.sc"
}

function update_tag(file,content,tagname,tagdate)
   if not tagname then
      local handle = io.popen("git describe --tags --abbrev=0")
      tagname = handle:read("*a"):match("[^\n]+")
      handle:close()
      print("Set tagname to '"..tagname.."'")
   end
   if string.match(file,"%.*") or string.match(file,"*.sc") then   
      local update, count = string.gsub(content,"Date:\n([%%%s]+)%d%d%d%d%-%d%d%-%d%d","Date:\n%1"..tagdate)
      update, count = string.gsub(update,"Version:\n([%%%s]+)v%d+%.%d+%.%d+","Version:\n%1"..tagname)
      return update
   end    
   return content
end
