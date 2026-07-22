%%
%% This is file `osgdoc.cls',
%% generated with the docstrip utility.
%%
%% The original source files were:
%%
%% osgdoc.dtx  (with options: `cls')
%% 
%% ========================================================================
%%  osgdoc tools - support for documentation
%% 
%%  (C) 2022-2026 Matthias Werner
%%  E-mail: matthias.werner@informatik.tu-chemnitz.de
%% 
%%  Released under the LaTeX Project Public License v1.3c or later
%%  See http://www.latex-project.org/lppl.txt
%% ========================================================================
%% 
\ProvidesExplClass
{osgdoc}
{2026-06-11}
{0.0.7}
{A thin wrapper around cnltx-doc}
\AddToHook{class/scrartcl/after}{
  \NewCommandCopy{\originalAfterPackage}{\AfterPackage}
  \RenewDocumentCommand{\AfterPackage}{t! m m}{
    \IfBooleanTF{#1}{#3}{%
      \originalAfterPackage{#2}{#3}
    }
  }
}
\RequirePackage{multicol,ragged2e}
\RequirePackage{luatex85, shellesc}
\AddToHook{class/cnltx-doc/before}{
  \typeout{==>~First~Aid~for~cnltx-doc.cls~applied!}
}
\LoadClass{cnltx-doc}
\mdfdefinestyle{cnltxmdframed}{
  backgroundcolor = cnltxbg ,
  linecolor = cnltx ,
  roundcorner = 5pt
}
\setcnltx{
  color-scheme=blue
  }
\RequirePackage[hidelinks]{hyperref}
\RequirePackage{osgdoc}
\RequirePackage[oldstyle]{libertine}
\setmonofont[
 Scale = MatchLowercase ,
 Ligatures = {NoCommon,NoRequired,NoContextual}
]{DejaVu Sans Mono}
\RequirePackage{imakeidx}
\renewcommand{\packageformat}{\color{cnltxformalblue}\sffamily}
\renewcommand{\needpackage}[2][pkg]{
  \pkg{#2}\footnote{\CTANurl[#1]{#2}}
}
\renewcommand{\needclass}[2][pkg]{
  \cls{#2}\footnote{\CTANurl[#1]{#2}}
}
\renewcommand{\CTANurl}[2][pkg] {
  on~\ctan\ as~\cnltx@weblink@font{#2}:~\url{https://ctan.org/#1/#2/}
}
\def\gobble{\@gobble}
%% 
%%  This work is "maintained" (as per LPPL maintenance status) by
%%  Matthias Werner.
%%
%% End of file `osgdoc.cls'.

