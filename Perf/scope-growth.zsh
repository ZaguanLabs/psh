# Exercise live scope-index generations across growth, removal and shadow reuse.
emulate -R zsh
module_path=("$1" "$2")
zmodload psh_scope_observer zsh/parameter || exit 1
[[ $(psh-scope-tracking) == "$3" ]] || exit 2
typeset psh_growth_shadow=outer
psh-growth-warm() { local psh_growth_temporary=warm; }
psh-growth-clear() {
  local psh_growth_shadow=deep
  [[ $psh_growth_data[2] == beta ]] || return 11
  psh_growth_map[one]=changed
  unset -m 'psh_growth_g_*'
}
psh-growth-run() {
  local psh_growth_shadow=inner
  local -a psh_growth_data=(alpha beta gamma)
  local -A psh_growth_map=(one original two preserved)
  local psh_growth_placeholder=before
  integer psh_growth_i psh_growth_n=$1
  psh-growth-warm
  for (( psh_growth_i=0; psh_growth_i<psh_growth_n; psh_growth_i++ )); do
    typeset -g "psh_growth_g_${psh_growth_i}=$psh_growth_i"
    if (( psh_growth_i % 97 == 0 )); then psh-growth-warm; fi
  done
  [[ $psh_growth_g_0 == 0 ]] || return 12
  psh-growth-clear || return
  [[ $psh_growth_shadow == inner && $psh_growth_map[one] == changed &&
     $psh_growth_map[two] == preserved ]] || return 13
  unset psh_growth_placeholder
  local psh_growth_placeholder=after
  psh-growth-warm
  [[ $psh_growth_placeholder == after ]] || return 14
}
psh-growth-warm
for psh_growth_size in 300 2000 6000 300; do
  psh-growth-run $psh_growth_size || exit
  [[ $psh_growth_shadow == outer && ${+psh_growth_placeholder} == 0 &&
     ${+psh_growth_i} == 0 && ${+psh_growth_data} == 0 &&
     ${+psh_growth_map} == 0 ]] || exit 15
  typeset -a psh_growth_remaining=( ${(k)parameters[(I)psh_growth_g_*]} )
  (( ${#psh_growth_remaining} == 0 )) || exit 16
done
[[ $(psh-scope-tracking) == "$3" ]] || exit 17
print -r -- SCOPE_GROWTH_OK
