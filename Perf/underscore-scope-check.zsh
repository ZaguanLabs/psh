emulate -R zsh
if [[ -n $1 ]]; then
  module_path=("$1" $module_path)
  zmodload underscore_probe || exit 1
  psh_wrap_pass() { print -r -- "pass-body:$_"; : body; }
  psh_wrap_delegate() { print -r -- "delegate-body:$_"; : body; }
  psh_wrap_skip() { print -r -- 'unexpected body'; return 9; }
  for caller in caller ${(l:4096::x:)}; do
    psh_wrap_pass "$caller" || exit 1
    print -r -- "pass-return:$_"
    psh_wrap_delegate "$caller" || exit 1
    print -r -- "delegate-return:$_"
    psh_wrap_skip "$caller" || exit 1
    print -r -- "skip-return:$_"
  done
  zmodload -u underscore_probe || exit 1
fi
leaf() {
  print -rNC1 -- "$_"
  : changed-in-leaf
  return 7
}
outer() {
  print -rNC1 -- "$_"
  leaf "$2"
  print -rNC1 -- "$?" "$_"
  : changed-in-outer
}
for width in 0 1 31 32 33 63 64 95 96 127 128 129 4096 65536; do
  payload=${(l:$width::x:)}
  outer before "$payload"
  print -rNC1 -- "$_"
done
for payload in 'two words' $'a\nb' 'λ' $'\x83\xff' $'a\0b'; do
  outer after "$payload"
  print -rNC1 -- "$_"
done
# Alternate small and large live values across nested frames.
descend() {
  [[ $_ == "$2" ]] || return 1
  local child
  if (( $1 )); then
    if (( $1 % 2 )); then child=$large; else child=short; fi
    descend $(( $1 - 1 )) "$child" || return 1
    [[ $_ == "$child" ]] || return 1
  fi
  : scratch
}
large=${(l:8192::y:)}
descend 100 top || exit 1
[[ $_ == top ]] || exit 1
trap '[[ $_ == $$ ]] || exit 1; print -rNC1 -- "trap saw pid"; : trap-change' USR1
interrupted() { : preceding; kill -USR1 $$; [[ $_ == $$ ]] || exit 1; print -rNC1 -- "resumed with pid"; }
interrupted trapped
print -rNC1 -- "returned:$_"
