emulate -R zsh
integer size=$1 position=$2 begin_at=$3 iterations=$4 expected=$5
typeset direction=$6 found
typeset -a a=( ${(s::)${(l:$size::x:)}} )
(( position > 0 )) && a[position]=target
run-search() {
  if [[ $direction == forward ]]; then
    repeat $iterations found=${a[(ib:begin_at:)target]}
  else
    repeat $iterations found=${a[(Ib:begin_at:)target]}
  fi
  (( found == expected ))
}
run-search || exit 1
float -F 9 SECONDS=0
run-search || exit 1
float elapsed=$SECONDS
printf '%.9f\n' $elapsed
