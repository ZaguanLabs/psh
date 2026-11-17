emulate -R zsh
if [[ $1 == storage ]]; then
  module_path=("$2" $module_path)
  zmodload argv_probe || exit 1
  for direction in front back; do
    set -- {1..32768}
    for keep in 32768 16384 1024 1 0; do
      if [[ $direction == front ]]; then
        shift "$(( $# - keep ))" || exit 1
      else
        shift -p "$(( $# - keep ))" || exit 1
      fi
      (( $# == keep )) || exit 1
      print -rn -- "$direction "
      argv-storage || exit 1
    done
  done
  zmodload -u argv_probe
  exit $?
fi
if [[ $1 == error ]]; then
  set -- a b
  shift '1/0'
  print -r -- "status:$?:$#:$*"
  exit
fi
probe() {
  local -i side=0
  shift 'side++' || return 1
  (( side == 1 )) || return 1
  print -rNC1 -- "$@"
  shift -p 'side-1' || return 1
  shift "$(( $# + 1 ))"
  print -r -- "overshift:$?:$#"
  shift '0-1'
  print -r -- "negative:$?:$#"
  if (( $# )); then shift; fi
  if (( $# )); then shift -p; fi
  argv+=('tail' '' 'extra value')
  print -rNC1 -- "$@"
  shift -p "$#" || return 1
  (( $# == 0 )) || return 1
  set -- 'head' $'\xff' '' 'λ' ''
  shift 2 || return 1
  print -rNC1 -- "$@"
  shift "$#" || return 1
  shift 0 && shift -p 0 && (( $# == 0 ))
}
for option in ksharrays noksharrays; do
  setopt "$option"
  set -- caller ''
  probe || exit 1
  probe ' ' || exit 1
  probe '' a b $'\xff' 'λ' '' || exit 1
  probe {1..1024} || exit 1
  [[ $# == 2 && $1 == caller && -z $2 ]] || exit 1
done
typeset -a first=(one two three) second=('' 'x y')
shift -p 0 first second || exit 1
shift 1 first second || exit 1
print -rNC1 -- "${first[@]}" "${second[@]}"
