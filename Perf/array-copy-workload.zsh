# Bounded array materialization, including full-copy and negative-index controls.
emulate -R zsh
typeset operation=$1
integer size=$2 iterations=$3 start=1 end=2 i
typeset -a a=( ${(s::)${(l:size::x:)}} ) out
case $operation in
  prefix) end=2 ;;
  middle) start=$(( size/2 + 1 )); end=$(( start+1 )) ;;
  full) end=$size ;;
  negative) start=-2; end=-1 ;;
  beyond) start=$(( size+5 )); end=$(( size+6 )) ;;
  *) exit 2 ;;
esac
run-copy() { repeat $iterations out=("${(@)a[start,end]}"); }
run-copy
float -F 9 SECONDS=0
run-copy
float elapsed=$SECONDS
printf '%.9f\n' $elapsed
integer want=2
[[ $operation == full ]] && want=$size
[[ $operation == beyond ]] && want=1
(( $#out == want )) || exit 3
if [[ $operation == beyond ]]; then
  [[ $out[1] == '' ]] || exit 4
else
  for (( i=1; i<=want; ++i )); do [[ $out[i] == x ]] || exit 4; done
fi
typeset -p out a start end
