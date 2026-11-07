emulate -R zsh
typeset operation=$1 found
integer size=$2 position=$3 iterations=$4 last
typeset -a a=( ${(s::)${(l:$size::x:)}} ) out
(( ${#a} == size )) || exit 1
case $operation in
  read)
    if (( position != 0 && position >= -size && position <= size )); then
      a[position]=target
      typeset expected=target
    else
      typeset expected=''
    fi
    ;;
  slice)
    last=$((position + 1))
    a[position]=target a[last]=tail
    ;;
  length) typeset expected=$size ;;
  *) exit 2 ;;
esac
run-workload() {
  case $operation in
    read) repeat $iterations found=$a[position] ;;
    slice) repeat $iterations out=( "${(@)a[position,last]}" ) ;;
    length) repeat $iterations found=${#a} ;;
  esac
}
check-result() {
  if [[ $operation == slice ]]; then
    (( ${#out} == 2 )) && [[ $out[1] == target && $out[2] == tail ]]
  else
    [[ $found == "$expected" ]]
  fi
}
run-workload || exit 1
check-result || exit 1
float -F 9 SECONDS=0
run-workload || exit 1
float elapsed=$SECONDS
check-result || exit 1
printf '%.9f\n' $elapsed
