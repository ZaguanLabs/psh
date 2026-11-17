# Compare a function's arguments before, during and after nested mutation.
emulate -R zsh
if [[ -n $1 ]]; then
  module_path=("$1" $module_path)
  zmodload argv_probe || exit 1
  measure() { argv-storage }
  values=()
  for n in {0..16}; do
    measure "${values[@]}" || exit 1
    values+=("field $n")
  done
  zmodload -u argv_probe
  exit $?
fi

mutate() {
  print -r -- "enter:$0:$#"
  print -rNC1 -- "$@"
  if (( $# )); then shift; fi
  if (( $# )); then shift -p; fi
  argv+=('two words' '' $'\xff')
  print -rNC1 -- "$@"
  set -- ''
  print -r -- "reset:$#:$1"
}
outer() {
  local -a saved=("$@")
  mutate "$@" || return 1
  (( $# == ${#saved} )) || return 1
  local -i i
  for (( i=1; i <= $#; ++i )); do
    [[ "${@[i]}" == "${saved[i]}" ]] || return 1
  done
}
set -- caller ''
for setting in functionargzero nofunctionargzero; do
  setopt "$setting"
  outer || exit 1
  outer '' || exit 1
  outer 'λ' '' 'a b' $'\xff' || exit 1
  outer {1..1024} || exit 1
done
[[ $# == 2 && $1 == caller && -z $2 ]] || exit 1
