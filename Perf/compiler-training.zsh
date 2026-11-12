# Offline compiler training. No personal startup files, services or terminal UI.
emulate -R zsh
setopt extendedglob
zmodload zsh/mathfunc zsh/parameter zsh/datetime || exit 1
typeset -a psh_values=() psh_copy=()
typeset -A psh_map=()
typeset psh_text='plain café 界 text * ? []'
integer psh_i psh_j psh_sum=0 psh_counter=0
typeset -F psh_float=0
psh-training-scope() {
  emulate -L zsh
  local -i value=$1
  local -a items=(alpha beta gamma)
  ((psh_counter++, value+=${#items}))
  [[ $items[2] == beta && $value -gt 3 ]]
}
for ((psh_i=1;psh_i<=5000;psh_i++)); do
  psh_values+=("value:$psh_i:$psh_text")
  psh_map[$psh_i]=$psh_i
  ((psh_sum+=psh_i, psh_float+=sqrt(psh_i)+sin(psh_i/7.0)))
  psh-training-scope $psh_i || exit 1
  [[ $psh_values[psh_i] == value:* ]] || exit 1
  [[ ${psh_text//plain/inert} == inert* ]] || exit 1
  [[ ${psh_text[(i)界]} -gt 1 ]] || exit 1
done
((psh_sum==12502500 && psh_counter==5000 && ${#psh_map}==5000)) || exit 1
psh_copy=("${psh_values[@]}")
[[ $psh_copy[-1] == "value:5000:$psh_text" && $psh_map[4999] == 4999 ]] || exit 1
for psh_i in {1..500}; do unset "psh_map[$psh_i]"; done
(( ${#psh_map}==4500 )) || exit 1
print -r -- "checked:$psh_sum:$psh_counter:${#psh_copy}:${#psh_map}"
