-- Build configuration for tucseating
module = "tucseating"

unpackfiles = {}
sourcefiles= {
   "*.sty",
   "*.tsr",
   "*.lua"
}
installfiles= {
   "*.sty",
   "*.tsr",
   "*.lua"
}

typesetfiles = {
   "tucseating-doc-en.tex",
   "tucseating-doc-de.tex"
}

typesetopts="-interaction=nonstopmode -shell-escape"

cleanfiles={
    "*-doc-*-cnltx*",
    "*.toc",
    "*.aux"
}

tagfiles={
    "tucseating.sty",
    "tucseating.lua",
    "*.tsr"
}

function update_tag(file,content,tagname,tagdate)
   if not tagname then
      local handle = io.popen("git describe --tags --abbrev=0")
      tagname = handle:read("*a"):match("[^\n]+")
      handle:close()
      print("Set tagname to '"..tagname.."'")
   end
   if string.match(file,"%.*") or string.match(file,"*.tsr") then   
      local update, count = string.gsub(content,"Date:\n([%%%s]+)%d%d%d%d%-%d%d%-%d%d","Date:\n%1"..tagdate)
      update, count = string.gsub(update,"Version:\n([%%%s]+)v%d+.%d+","Version:\n%1"..tagname)
      return update
   end    
   return content
end
