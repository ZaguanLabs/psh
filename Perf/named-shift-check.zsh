emulate -R zsh
case $1 in
  readonly)
    typeset -ar fixed=(x y)
    shift fixed
    exit $? ;;
  native)
    module_path=("$2" $module_path)
    zmodload shift_probe || exit 1
    probe_array=(a b)
    shift-probe queue || exit 1
    probe_array=(first second 'third value')
    shift-probe loan || exit 1
    shift probe_array || exit 1
    shift-probe check-copy || exit 1
    shift-probe wrap || exit 1
    shift -p probe_array || exit 1
    shift-probe unwrap || exit 1
    [[ $#probe_array == 1 && $probe_array[1] == second ]] || exit 1
    zmodload -u shift_probe
    exit $? ;;
esac
emit() { print -rNC1 -- "$@"; }
probe() {
  local -a a=('' x x 'λ' $'\xff' 'tail value')
  local -a b=(1 2 3 4 5)
  shift a && shift -p b || return 1
  emit "${a[@]}" "${b[@]}"
  shift 0 a b && shift 2 a b || return 1
  emit "${a[@]}" "${b[@]}"
  shift a b && shift -p a && shift a && shift b || return 1
  shift a
  print -r -- "empty:$?"
  a+=(restored)
  emit "${a[@]}"
}
for option in ksharrays noksharrays; do
  setopt "$option"
  probe || exit 1
done
typeset -aU uniq=(a b a c)
shift uniq && emit "${uniq[@]}" || exit 1
typeset -T joined tied ':'
joined='a:b:c'
shift tied && [[ $joined == b:c ]] || exit 1
typeset -a outer=(before after)
() { setopt localoptions warnnestedvar; shift outer; } || exit 1
emit "${outer[@]}"
# Populate the length cache before successive shifts and negative-index reads.
local -a many=( {1..180} )
repeat 40 {
  [[ -n ${many[100]} ]] && shift many || exit 1
}
(( $#many == 140 )) && [[ $many[1] == 41 && $many[-1] == 180 ]] || exit 1
