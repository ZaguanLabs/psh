# Invoked by benchmark.py with a selected private build; never loads user rc files.
emulate -R zsh
typeset operation=$1
integer size=$2 iterations=$3 i index
typeset -a a
a=( ${(s::)${(l:$size::x:)}} )
case $operation in
  first) index=1 ;;
  middle) index=$((size / 2 + 1)) ;;
  last) index=$size ;;
  prefix) index=32 ;;
  past-prefix) index=33 ;;
  slice) index=1 ;;
  append) ;;
  scalar) typeset scalar=${(l:$size::x:)} ;;
  *) print -u2 'unknown workload'; exit 2 ;;
esac

run-workload() {
  case $operation in
    first|middle|last|prefix|past-prefix) repeat $iterations a[index]=y ;;
    slice) repeat $iterations a[1,2]=(y z) ;;
    append) repeat $iterations a+=(y) ;;
    scalar) repeat $iterations scalar[1]=y ;;
  esac
  return 0
}

# Prime dispatch and allocation before measuring; restore append's input.
run-workload
if [[ $operation == append ]]; then
  a=( ${(s::)${(l:$size::x:)}} )
fi
float -F 9 SECONDS=0
run-workload
float elapsed=$SECONDS
case $operation in
  first|middle|last|prefix|past-prefix) [[ ${#a} == $size && $a[index] == y ]] || exit 1 ;;
  slice) [[ ${#a} == $size && $a[1] == y && $a[2] == z ]] || exit 1 ;;
  append) (( ${#a} == size + iterations )) || exit 1 ;;
  scalar) [[ ${#scalar} == $size && $scalar[1] == y ]] || exit 1 ;;
esac
printf '%.9f\n' $elapsed
