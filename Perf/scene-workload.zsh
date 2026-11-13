# Fresh construction of actual customer scenes; no cache or terminal launch.
emulate -R zsh
setopt no_aliases
typeset psh_scene_root=$1 psh_scene_entry=$2 psh_scene_profile=${3:-none}
if [[ -n ${PSH_SCENE_MODULE_DIR:-} ]]; then
  module_path=("$PSH_SCENE_MODULE_DIR" "${module_path[@]}")
fi
source "$psh_scene_root/$psh_scene_entry" || exit 1
if [[ $psh_scene_profile == zprof ]]; then
  zmodload zsh/zprof || exit 1
fi
typeset -F psh_scene_begin=$EPOCHREALTIME psh_scene_elapsed
scene-build || exit 1
((psh_scene_elapsed=EPOCHREALTIME-psh_scene_begin))
printf 'PSH_SCENE %.9f %d %d %d %d\n' $psh_scene_elapsed $art_w $art_h $triangles ${#rgb} >&2
if [[ $psh_scene_profile == zprof ]]; then zprof >&2; fi
# Complete palette and material/depth pixels, outside the construction timer.
print -rl -- "$art_w $art_h $triangles" "${rgb[@]}" "${pixels[@]}"
