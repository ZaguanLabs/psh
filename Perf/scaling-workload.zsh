# Offline scaling probes through the actual zjson library.
emulate -R zsh
typeset operation=$1 project_root=$2
integer items=$3
source "$project_root/zjson.zsh" || exit 1
typeset -a elements=( ${(s::)${(l:$items::1:)}} )
typeset document="[${(j:,:)elements}]"
case $operation in
  validate) run-workload() { zjson_validate "$document"; } ;;
  encode)
    ZJSON_ARRAY=( "${elements[@]}" )
    ZJSON_ARRAY_TYPES=( ${elements//1/string} )
    elements=( ${elements//1/\"1\"} )
    document="[${(j:,:)elements}]"
    run-workload() { zjson_encode_array; }
    ;;
  *) exit 2 ;;
esac
run-workload || exit 1
float -F 9 SECONDS=0
run-workload || exit 1
float elapsed=$SECONDS
if [[ $operation == encode ]]; then
  [[ $REPLY == "$document" ]] || exit 1
else
  (( ZJSON_POS == ZJSON_LEN + 1 )) || exit 1
fi
printf '%.9f\n' $elapsed
print -r -- "$operation/$items/ok"
