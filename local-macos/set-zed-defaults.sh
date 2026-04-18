#!/usr/bin/env bash
# Sets Zed as the default macOS app for coding-related file extensions.
# Rerun after Antigravity/Cursor/VS Code updates re-claim defaults via LSHandlerRank.

set -euo pipefail

ZED_BUNDLE_ID="dev.zed.Zed"

if ! command -v duti >/dev/null 2>&1; then
  echo "duti not installed. Install with: brew install duti" >&2
  exit 1
fi

EXTS=(
  ascx asp aspx adp as asa ash bash bashrc bat bazel bib bowerrc bsh build bzl
  c capfile cc cfg cgi cjs cl clisp clj cljc cljs cljx clojure cls cmake cmd coffee config containerfile cp cpp cpy cs cshtml csproj css csv csx ctp cxx
  d dart ddl di diff dml dockerfile dot dpr dtd dtml
  ebuild eclass editorconfig edn el ent erb erbsql erl escript ex exs
  fasl fcgi fs fsi fsproj fsscript fsx
  gemspec git gitattributes gitconfig gitignore gitmodules go gradle groovy grv gv gyp gypi
  h haml handlebars hbs hh hpp hrl hs htc hxx
  ini inl ipp ipynb irbrc
  jade jav java jbuilder js jscsrc jshintrc jshtm json jsp jsx
  l less lisp lock log lsp ltx lua
  m mailmap mak make makefile markdn markdown matlab md mdoc mdown mdtext mdtxt mdwn mjs mk mkd mkdn ml mli mll mly mm mod mud
  opml
  p pas patch pc php php3 php4 php5 php7 phps phpt phtml pl pl6 pm pm6 pmc pod podspec pp prawn profile properties props ps1 psd1 psgi psm1 pug pxd pxi py py3 pyi pyw pyx
  r rabl rails rake rb rbx re rest rhistory rhtml rjs rkt rng rprofile rpy rs rss rst rt
  sass sbt sc scala scm sconscript sconstruct scss sh shtml simplecov snakefile sproj sql sqlproj ss sty svg
  t targets tcl tex textile thor tld toml ts tsx txt
  vb vbproj vcproj vcxproj vpy vue
  wscript wxi wxl wxs
  xaml xhtml xml xsd xslt
  yaml yaws yml
  zlogin zlogout zprofile zsh zshenv zshrc
)

ok=0
fail=0
for ext in "${EXTS[@]}"; do
  if duti -s "$ZED_BUNDLE_ID" ".$ext" all 2>/dev/null; then
    ok=$((ok + 1))
  else
    fail=$((fail + 1))
    echo "skip: .$ext"
  fi
done

echo ""
echo "Set: $ok  Skipped: $fail  Total: ${#EXTS[@]}"
