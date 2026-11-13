# Offline object kernels through the actual zjson library.
emulate -R zsh
typeset operation=$1 project_root=$2
integer iterations=$3
[[ $operation == zjson-object || $operation == zjson-encode-object ]] || exit 2
source "$project_root/zjson.zsh" || exit 1
integer items=2000 i
typeset key document
typeset -a elements
for ((i=0; i<items; ++i)); do elements+=("\"k$i\":$i"); done
document="{${(j:,:)elements}}"
if [[ $operation == zjson-object ]]; then
  run-workload() { repeat $iterations zjson_parse_object "$document" || return 1; }
else
  for ((i=0; i<items; ++i)); do
    ZJSON_OBJECT[k$i]=$i
    ZJSON_OBJECT_TYPES[k$i]=number
  done
  # Exercise the real library's manually built associative-object path.
  ZJSON_OBJECT_KEYS=()
  elements=()
  for key in "${(@k)ZJSON_OBJECT}"; do
    elements+=("\"$key\":${ZJSON_OBJECT[$key]}")
  done
  document="{${(j:,:)elements}}"
  run-workload() { repeat $iterations zjson_encode_object || return 1; }
fi

run-workload || exit 1
float -F 9 SECONDS=0
run-workload || exit 1
float elapsed=$SECONDS
printf '%.9f\n' $elapsed
(( ${#ZJSON_OBJECT} == items && ${#ZJSON_OBJECT_TYPES} == items )) || exit 1
for ((i=0; i<items; ++i)); do
  [[ ${ZJSON_OBJECT[k$i]} == $i && ${ZJSON_OBJECT_TYPES[k$i]} == number ]] || exit 1
done
[[ $operation != zjson-encode-object || $REPLY == "$document" ]] || exit 1
typeset -p ZJSON_OBJECT ZJSON_OBJECT_TYPES ZJSON_OBJECT_KEYS ZJSON_ERROR
[[ $operation != zjson-encode-object ]] || typeset -p REPLY

