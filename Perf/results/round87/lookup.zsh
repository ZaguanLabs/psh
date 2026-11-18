# Repeated indirect reads exercise the shell's parameter-name scanner.
emulate -R zsh
unsetopt posixidentifiers
zmodload zsh/datetime || exit 1

case $1 in
  short)     name=key ;;
  ascii)     name=${(l:64::x:)} ;;
  wide)      name=${(l:64::界:)} ;;
  mixed)     name=${(l:64::x界:)} ;;
  boundary)  name=${(l:63::x:)}界 ;;
  *) exit 2 ;;
esac
typeset -g "${name}=verified" || exit 1
[[ ${(P)name} == verified ]] || exit 1
float start=$EPOCHREALTIME
repeat 20000; do value=${(P)name}; done
float elapsed=$(( EPOCHREALTIME - start ))
[[ $value == verified ]] || exit 1
print -r -- "$elapsed"
print -r -- "$name=$value"
