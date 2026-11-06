emulate -R zsh
typeset operation=$1 unit_kind=$2 mb_option=$3 s found expected_text
integer size=$4 position=$5 start=$6 iterations=$7 expected=$8 prefix suffix
setopt $mb_option
case $unit_kind in
  ascii) typeset unit=x ;;
  unicode) typeset unit=é ;;
  nul) typeset unit=$'\0' ;;
  invalid) typeset unit=$'\377' ;;
  *) exit 2 ;;
esac
if (( position )); then
  prefix=position-1 suffix=size-position-5
  s=${(pl:$prefix::$unit:)}target${(pl:$suffix::$unit:)}
else
  s=${(pl:$size::$unit:)}
fi
run-search() {
  case $operation in
    index) repeat $iterations found=${s[(i)target]} ;;
    offset) repeat $iterations found=${s[(ib:start:)target]} ;;
    backward) repeat $iterations found=${s[(I)target]} ;;
    range) repeat $iterations found=${s[(r)target,(r)target]} ;;
    *) return 2 ;;
  esac
  if [[ $operation == range ]]; then
    [[ $found == target ]]
  else
    (( found == expected ))
  fi
}
run-search || exit 1
float -F 9 SECONDS=0
run-search || exit 1
float elapsed=$SECONDS
printf '%.9f\n' $elapsed
