# Offline application kernels; explicit trusted project roots are supplied by
# applications.py. No UI, remote requests, or third-party native modules run.
emulate -R zsh
typeset operation=$1 project_root=$2
integer iterations=$3
case $operation in
  zjson|zjson-array|zjson-encode-array)
    source "$project_root/zjson.zsh" || exit 1
    integer items=2000
    [[ $operation == zjson-encode-array ]] && items=4000
    typeset -a elements=( ${(s::)${(l:$items::1:)}} )
    typeset document="[${(j:,:)elements}]"
    case $operation in
      zjson) run-workload() { repeat $iterations zjson_validate "$document" || return 1; } ;;
      zjson-array) run-workload() { repeat $iterations zjson_parse_array "$document" || return 1; } ;;
      zjson-encode-array)
        ZJSON_ARRAY=( "${elements[@]}" )
        ZJSON_ARRAY_TYPES=( ${elements//1/string} )
        elements=( ${elements//1/\"1\"} )
        document="[${(j:,:)elements}]"
        run-workload() { repeat $iterations zjson_encode_array || return 1; }
        ;;
    esac
    ;;
  navigation)
    zmodload zsh/mathfunc || exit 1
    source "$project_root/levels/relay.zsh" || exit 1
    source "$project_root/lib/engine.zsh" || exit 1
    game-reset
    run-workload() {
      repeat $iterations { nav_dirty=1; nav-build || return 1; }
    }
    ;;
  *) exit 2 ;;
esac
run-workload || exit 1
float -F 9 SECONDS=0
run-workload || exit 1
float elapsed=$SECONDS
printf '%.9f\n' $elapsed
case $operation in
  zjson) typeset -p ZJSON_POS ZJSON_LEN ZJSON_ERROR ;;
  zjson-array)
    (( ${#ZJSON_ARRAY} == items && ${#ZJSON_ARRAY_TYPES} == items )) || exit 1
    [[ $ZJSON_ARRAY[-1] == 1 && $ZJSON_ARRAY_TYPES[-1] == number ]] || exit 1
    typeset -p ZJSON_ARRAY ZJSON_ARRAY_TYPES ZJSON_ERROR ;;
  zjson-encode-array)
    [[ $REPLY == "$document" ]] || exit 1
    typeset -p REPLY ZJSON_ARRAY ZJSON_ARRAY_TYPES ZJSON_ERROR ;;
  navigation) typeset -p nav_distance nav_queue nav_origin nav_dirty ;;
esac
