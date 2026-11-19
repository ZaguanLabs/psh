emulate -R zsh
module_path=("$1" $module_path)
zmodload matchlen || exit 1
setopt extendedglob

typeset fixed=${(l:5000::f:)}
eval 'cached() { [[ $1 == '$fixed' ]] }' || exit 1
for multibyte in on off; do
  if [[ $multibyte == on ]]; then setopt multibyte; else unsetopt multibyte; fi
  for size in 0 1 818 819 820 4094 4095 4096 4097 10000 50000; do
    prefix=${(l:$size::x:)}
    for suffix in x 界 $'\0' $'\x83' '*?['; do
      right=$prefix$suffix
      [[ $right == "$right" ]]
      match-result equal $?
      [[ ${prefix}z == "$right" ]]
      match-result differ $?
      [[ ${right}z != "$right" ]]
      match-result longer $?
      [[ $prefix == "$right" ]]
      match-result shorter $?
      [[ $right == ${prefix}* ]]
      match-result wildcard $?
      [[ $right == (#m)${prefix}* ]]
      match-result capture $?
      print -r -- "${#MATCH} $MBEGIN $MEND"
      [[ $right == "$MATCH" ]]
      match-result captured-text $?
      cached "$fixed"
      match-result cached $?
      cached "$right"
      match-result cached-miss $?
    done
    integer index=0
    values=("$prefix" "$prefix" unused)
    [[ ${values[++index]} == "${values[++index]}" ]]
    match-result expanded $?
    print -r -- "expansions $index"
    [[ ${prefix}Z == (#i)${prefix}z ]]
    match-result folded $?
  done
done
bad='['
( [[ z == ${~bad} ]] )
match-result malformed $?
