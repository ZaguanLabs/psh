emulate -R zsh
integer calls=0
typeset callback=${(l:$2::f:)}
functions[$callback]='
  (( ++calls ))
  if (( calls == 4096 )); then
    print -r -- inside
    read -r REPLY || return 1
  fi
  return 0'
case $3 in
  native)
    module_path=("$1" $module_path)
    zmodload call_probe || exit 1 ;;
  chpwd)
    chpwd_functions=()
    repeat 4096; do chpwd_functions+=("$callback"); done ;;
  *) exit 2 ;;
esac
print -r -- ready
read -r REPLY || exit 1
if [[ $3 == native ]]; then
  call-probe-repeat "$callback" || exit 1
else
  builtin cd -- "$PWD" || exit 1
fi
(( calls == 4096 )) || exit 1
print -r -- returned
read -r REPLY || exit 1
if [[ $3 == native ]]; then zmodload -u call_probe || exit 1; fi
