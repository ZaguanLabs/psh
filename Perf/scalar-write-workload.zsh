emulate -R zsh
typeset operation=$1 unit=$2 base replacement s expected
integer initial=$3 supplied=$4 iterations=$5
case $unit in
  ascii) unit=x ;;
  unicode) unit=é ;;
  nul) unit=$'\0' ;;
  invalid) unit=$'\377' ;;
  byte) unit=x; setopt nomultibyte ;;
  *) exit 2 ;;
esac
base=${(pl:$initial::a:)}
replacement=${(pl:$supplied::$unit:)}
case $operation in
  replace) expected=${replacement}${base[2,-1]} ;;
  prepend) expected=${replacement}${base} ;;
  append) expected=${base}${replacement} ;;
  whole) expected=$replacement ;;
  *) exit 2 ;;
esac
run-workload() {
  case $operation in
    replace) repeat $iterations { s=$base; s[1,1]=$replacement; } ;;
    prepend) repeat $iterations { s=$base; s[1,0]=$replacement; } ;;
    append) repeat $iterations { s=$base; s+=$replacement; } ;;
    whole) repeat $iterations { s=$base; s=$replacement; } ;;
  esac
}
run-workload || exit 1
[[ $s == "$expected" ]] || exit 1
float -F 9 SECONDS=0
run-workload || exit 1
float elapsed=$SECONDS
[[ $s == "$expected" ]] || exit 1
printf '%.9f\n' $elapsed
