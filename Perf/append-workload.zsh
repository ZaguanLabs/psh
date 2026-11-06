emulate -R zsh
typeset operation=$1 joined
integer initial=$2 iterations=$3 i expected
case $operation in
  unique|duplicates) typeset -aU a ;;
  tied) typeset -T joined a ;;
  *) typeset -a a ;;
esac
reset-array() { a=( ${(s::)${(l:$initial::x:)}} ); }
run-workload() {
  case $operation in
    list|tied) repeat $iterations a+=(x) ;;
    scalar) repeat $iterations a+=x ;;
    batch) repeat $iterations a+=(x y '' z) ;;
    unique) for ((i=1; i<=iterations; ++i)); do a+=("$i"); done ;;
    duplicates) repeat $iterations a+=(x x) ;;
    replace) repeat $iterations a[1]=y ;;
    *) return 2 ;;
  esac
  return 0
}
reset-array
run-workload || exit 1
reset-array
float -F 9 SECONDS=0
run-workload || exit 1
float elapsed=$SECONDS
case $operation in
  list|scalar) (( ${#a} == initial + iterations )) || exit 1 ;;
  tied)
    (( ${#a} == initial + iterations )) || exit 1
    [[ $joined == "${(j.:.)a}" ]] || exit 1 ;;
  batch)
    (( ${#a} == initial + 4 * iterations )) || exit 1
    [[ $a[-4] == x && $a[-3] == y && $a[-2] == '' && $a[-1] == z ]] || exit 1 ;;
  unique) (( ${#a} == iterations )) && [[ $a[-1] == $iterations ]] || exit 1 ;;
  duplicates) (( ${#a} == 1 )) && [[ $a[1] == x ]] || exit 1 ;;
  replace) (( ${#a} == initial )) && [[ $a[1] == y ]] || exit 1 ;;
esac
printf '%.9f\n' $elapsed
