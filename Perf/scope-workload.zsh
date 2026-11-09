# Baseline scope teardown scaling; setup and observations are outside the timer.
emulate -R zsh
integer psh_scope_padding=$1 psh_scope_iterations=$2
typeset psh_scope_mode=$3 psh_scope_occupancy=$4 psh_scope_module=$5
module_path=("$psh_scope_module" $module_path)
zmodload psh_scope_observer || exit 1
integer psh_scope_index=0
typeset psh_scope_l0=outer psh_scope_before='' psh_scope_after=''
float -F 9 psh_scope_elapsed=0 SECONDS=0
for ((psh_scope_index=1; psh_scope_index<=psh_scope_padding; ++psh_scope_index)); do
  typeset -g "psh_scope_pad_${psh_scope_index}=$psh_scope_index"
done
case $psh_scope_occupancy in
  dense) ;;
  sparse)
    for ((psh_scope_index=1; psh_scope_index<=psh_scope_padding; ++psh_scope_index)); do
      unset "psh_scope_pad_${psh_scope_index}"
    done
    ;;
  *) exit 2 ;;
esac
case $psh_scope_mode in
  loop) ;;
  empty) psh-scope-probe() { :; } ;;
  local1) psh-scope-probe() { local psh_scope_l0=inner; } ;;
  local8)
    psh-scope-probe() {
      local psh_scope_l0=inner psh_scope_l1=1 psh_scope_l2=2 psh_scope_l3=3
      local psh_scope_l4=4 psh_scope_l5=5 psh_scope_l6=6 psh_scope_l7=7
    }
    ;;
  emulate) psh-scope-probe() { emulate -L zsh; local psh_scope_l0=inner; } ;;
  nested)
    psh-scope-inner() { local psh_scope_l0=inner; }
    psh-scope-probe() { local psh_scope_l0=middle; psh-scope-inner; }
    ;;
  *) exit 2 ;;
esac
if [[ $psh_scope_mode == loop ]]; then
  repeat 20 :
else
  repeat 20 psh-scope-probe
fi
psh_scope_before=$(psh-scope-observe) || exit 3
SECONDS=0
if [[ $psh_scope_mode == loop ]]; then
  repeat $psh_scope_iterations :
else
  repeat $psh_scope_iterations psh-scope-probe
fi
psh_scope_elapsed=$SECONDS
psh_scope_after=$(psh-scope-observe) || exit 3
[[ $psh_scope_before == $psh_scope_after && $psh_scope_l0 == outer &&
   ! -v psh_scope_l1 && ! -v psh_scope_l7 ]] || exit 4
printf '%.9f\n%s\n%s\n' $psh_scope_elapsed $psh_scope_before $psh_scope_after
