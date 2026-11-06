emulate -R zsh
setopt nomultibyte
typeset operation=$1 s out expected
integer size=$2 iterations=$3 first last
case $operation in
  unicode) setopt multibyte; s=${(l:$size::é:)} ;;
  late-unicode) setopt multibyte; s=${(l:$size::é:)} ;;
  mixed-suffix) setopt multibyte; s=${(l:$size::abcdefghé:)} ;;
  mb-suffix) setopt multibyte; s=${(l:$size::x:)} ;;
  nul|nul-suffix) typeset unit=$'\0'; s=${(pl:$size::$unit:)}
       [[ $s[1] == "$unit" && $s[-1] == "$unit" && ${#s} == $size ]] || exit 1 ;;
  *) s=${(l:$size::x:)} ;;
esac
case $operation in
  prefix|unicode|nul) first=1 last=8 ;;
  middle) first=$((size / 2)) last=$((first + 7)) ;;
  suffix) first=$((size - 7)) last=$size ;;
  mb-suffix|late-unicode|mixed-suffix|nul-suffix) first=$((size - 7)) last=$size ;;
  negative) first=-8 last=-1 ;;
  empty) first=2 last=1 ;;
  full) first=1 last=$size ;;
  beyond) first=$((size + 1)) last=$((size + 8)) ;;
  *) exit 2 ;;
esac
expected=${s[first,last]}
run-workload() { repeat $iterations out=${s[first,last]}; }
run-workload
float -F 9 SECONDS=0
run-workload
float elapsed=$SECONDS
[[ $out == "$expected" ]] || exit 1
case $operation in
  empty|beyond) [[ -z $out ]] || exit 1 ;;
  full) [[ $out == "$s" ]] || exit 1 ;;
  *) (( ${#out} == 8 )) || exit 1 ;;
esac
printf '%.9f\n' $elapsed
