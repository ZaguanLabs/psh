# Compare complete argument boundaries and bytes after parameter expansion.
emulate -R zsh
cd -- "$1" || exit 1
emit() {
  printf '%d\0' "$#"
  if (( $# )); then printf '%s\0' "$@"; fi
}

for mb in multibyte nomultibyte; do
  setopt "$mb"
  for size in 0 1 63 4096 50000; do
    text=${(l:$size::x:)}
    for tail in '' $'\0\203\377' 界 ' a ' '*' '\?'; do
      value=$text$tail
      members=('' "$value" mid "$value" '')
      right=(']' 'tail')
      emit "prefix${value}suffix" "${value}suffix" "prefix${value}" "$value"
      emit left"${members[@]}"right
      emit left${^members}${^right}
      emit ${(j.:.)members}suffix
      emit pre${(r:12:)value}post
      integer pos=0
      emit "${members[++pos]}.${members[++pos]}" "$pos"
    done
  done
done

# Match filenames after tokenizing the expansion. Adjacent quoted
# characters stay literal even when the value contains a pattern.
setopt globsubst nonomatch
for sh in shglob noshglob; do
  setopt "$sh"
  for wildcard in '*' '?' '[ab]' '\*' ''; do
    values=("$wildcard" '' "$wildcard")
    emit pre${wildcard}post
    emit 'pre'${wildcard}'*'
    emit pre${^values}post
  done
done
literal='$(print -rn -- inner)'
emit "start${(e)literal}end"
print -r -- joins-complete
