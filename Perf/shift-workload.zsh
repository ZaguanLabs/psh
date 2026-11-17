emulate -R zsh
typeset mode=$1
integer width=$2 count=$3
typeset -a words=( {1..$width} )
case $mode in
  front) set -- "${words[@]}" '' 'tail value' ;;
  back)  set -- 'head value' '' "${words[@]}" ;;
  zero)  set -- "${words[@]}" ;;
  *) exit 2 ;;
esac
float -F 9 SECONDS=0
case $mode in
  front) repeat $count { shift || exit 1; } ;;
  back)  repeat $count { shift -p || exit 1; } ;;
  zero)  repeat $count { shift 0 || exit 1; } ;;
esac
float elapsed=$SECONDS
case $mode in
  front) (( $# == 2 )) && [[ -z $1 && $2 == 'tail value' ]] || exit 1 ;;
  back)  (( $# == 2 )) && [[ $1 == 'head value' && -z $2 ]] || exit 1 ;;
  zero)  (( $# == width )) && [[ "${(j:,:)@}" == "${(j:,:)words}" ]] || exit 1 ;;
esac
printf '%.9f\n' $elapsed
print -rNC1 -- "$@"
