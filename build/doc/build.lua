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
   "tucseating-doc-de.tex",
}

docfiles={
   "cnltx-doc.cls"
}

typesetopts="-interaction=nonstopmode -shell-escape"
