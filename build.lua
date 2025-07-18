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
