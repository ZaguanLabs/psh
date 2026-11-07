#!/usr/bin/env zsh
# Build in a private copy of public Zsh sources. Never install during a build.
emulate -R zsh
setopt errexit nounset pipefail
typeset project_root=${0:A:h:h}
typeset source_root=${ZSH_BUILD_ROOT:-$project_root/.build/sources/zsh-5.9.2}
source_root=${source_root:A}
typeset build_name=${ZMDOWN_BUILD_NAME:-}
typeset cache_root=$project_root/.build
if [[ -n $build_name ]]; then
  [[ $build_name != *[^a-zA-Z0-9_.-]* && $build_name != . && $build_name != .. ]] || {
    print -u2 -r -- 'ZMDOWN_BUILD_NAME must be a simple directory name.'
    exit 1
  }
  cache_root=$cache_root/$build_name
fi
typeset build_root=$cache_root/zsh
typeset make_command=${MAKE:-make}
[[ -f $source_root/configure && -f $source_root/Src/zsh.h ]] || {
  print -u2 -r -- 'Set ZSH_BUILD_ROOT to an extracted Zsh release. See README.md.'
  exit 1
}
[[ $source_root != $build_root && $source_root != $build_root/* && $build_root != $source_root/* ]] || {
  print -u2 -r -- 'ZSH_BUILD_ROOT must be separate from the private build directory.'
  exit 1
}
if [[ -f $source_root/config.status ]]; then
  awk '/^sdir[ \t]*=/ { if ($3 == ".") ok = 1 } END { exit !ok }' "$source_root/Makefile" || {
    print -u2 -r -- 'Configured sources must be an in-tree build using relative source paths.'
    exit 1
  }
fi
mkdir -p "$cache_root"
if [[ ! -d $build_root ]]; then
  cp -R -P -p "$source_root" "$build_root"
  print -r -- "$source_root" > "$cache_root/source-root"
fi
[[ -f $cache_root/source-root && $(<"$cache_root/source-root") == $source_root ]] || {
  print -u2 -r -- 'The cache uses a different source tree. Select a fresh ZMDOWN_BUILD_NAME or clean that cache.'
  exit 1
}
cp "$project_root/src/zmdown.c" "$project_root/src/zmdown.mdd" "$project_root/src/render.h" "$build_root/Src/Modules/"
cp "$project_root/src/"grapheme{,_data}.h "$build_root/Src/Modules/"
cp "$project_root/src/grapheme.c" "$build_root/Src/Modules/zmd_grapheme.c"
cp "$project_root/src/render.c" "$build_root/Src/Modules/zmd_render.c"
cp "$project_root/vendor/md4c/md4c.c" "$build_root/Src/Modules/zmd_md4c.c"
cp "$project_root/vendor/md4c/entity.c" "$build_root/Src/Modules/zmd_entity.c"
cp "$project_root/vendor/md4c/"{md4c,entity}.h "$build_root/Src/Modules/"
if [[ ! -f $build_root/config.status ]]; then
  (cd "$build_root"; ./configure --enable-dynamic)
elif ! awk '$1 == "name=zmdown" { found = 1 } END { exit !found }' "$build_root/config.modules"; then
  (cd "$build_root"; ./config.status --recheck; ./config.status)
fi
if ! awk '$1 == "name=zmdown" { for (i=2;i<=NF;i++) if ($i == "link=dynamic") ok=1 } END { exit !ok }' "$build_root/config.modules"; then
  print -u2 -r -- "zmdown dynamic module is disabled in $build_root/config.modules."
  print -u2 -r -- "Inspect $build_root/config.log and configure with --enable-dynamic."
  print -u2 -r -- 'For Zsh 5.8 with modern GCC, use the compatibility configure flags in docs/building.md, then a fresh build cache.'
  exit 1
fi
"$make_command" -C "$build_root/Src"
typeset module_extension
module_extension=$(awk '$1 == "DL_EXT" && $2 == "=" { print $3; exit }' "$build_root/Src/Makefile")
[[ -n $module_extension && -f $build_root/Src/Modules/zmdown.$module_extension ]] || {
  print -u2 -r -- "zmdown shared module was not produced in $build_root/Src/Modules."
  print -u2 -r -- "Check dynamic-link support in $build_root/config.log and config.modules; see docs/building.md."
  exit 1
}
mkdir -p "$cache_root/modules"
cp "$build_root/Src/Modules/zmdown.$module_extension" "$cache_root/modules/"
"$build_root/Src/zsh" -dfc 'module_path=("$1"); zmodload zmdown; zmdown --version' zmdown-build "$cache_root/modules"
