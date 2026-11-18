# Exercise the byte boundary, self-reference and scoped environment updates.
emulate -R zsh
for width in 4095 4096 4097 65536; do
  for last in x 'λ' $'\0' $'\xff'; do
    prefix=${(l:$width::p:)}$last
    value=$prefix
    value+=""
    [[ $value == "$prefix" ]] || exit 1
    value+=$value
    [[ $value == "$prefix$prefix" ]] || exit 1
    value[-1]+='!'
    print -rNC1 -- "$value"
    value[1]+='?'
    print -rNC1 -- "$value"
  done
done
# Raw ASCII at either side of the exact cutoff.
for width in 4095 4096 4097; do
  prefix=${(l:$width::x:)}
  () {
    local -x PSH_APPEND_VALUE=$prefix
    PSH_APPEND_VALUE+=/end
    [[ $(/usr/bin/printenv PSH_APPEND_VALUE) == "$prefix/end" ]] || return 1
    print -rNC1 -- "$PSH_APPEND_VALUE"
  } || exit 1
  (( ! ${+PSH_APPEND_VALUE} )) || exit 1
done
setopt autonamedirs
typeset psh_append_dir=/${(l:4096::x:)}
if [[ -o interactive ]]; then
  zmodload zsh/parameter || exit 1
  hash -d psh_append_dir=/tmp || exit 1
  [[ ${nameddirs[psh_append_dir]} == /tmp ]] || exit 1
fi
psh_append_dir+=/end
if [[ -o interactive ]]; then
  (( ! ${+nameddirs[psh_append_dir]} )) || exit 1
fi
print -rNC1 -- "${(D)psh_append_dir}"
print -rNC1 -- "$psh_append_dir"
