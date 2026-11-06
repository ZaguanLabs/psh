emulate -R zsh
typeset operation=$1 project_root=$2 input_file=$3 output_file=$4
integer iterations=$5
typeset input REPLY
case $operation in
  html)
    source "$project_root/zhtml2md.zsh" || exit 1
    run-workload() {
      repeat $iterations { zhtml2md --strict -- "$input_file" > "$output_file" || return 1; }
    }
    ;;
  repair)
    source "$project_root/zjson.zsh" || exit 1
    input=$(< "$input_file")
    run-workload() { repeat $iterations { zjson_quote "$input" || return 1; }; }
    ;;
  clean)
    fpath=("$project_root/functions" $fpath)
    autoload -Uz zoup
    input=$(< "$input_file")
    run-workload() { repeat $iterations { zoup clean -- "$input" || return 1; }; }
    ;;
  *) exit 2 ;;
esac
run-workload || exit 1
float -F 9 SECONDS=0
run-workload || exit 1
float elapsed=$SECONDS
[[ $operation == html ]] || print -rn -- "$REPLY" > "$output_file"
printf '%.9f\n' $elapsed
