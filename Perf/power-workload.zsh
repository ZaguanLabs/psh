# Non-overflowing integer powers, with setup and warmup outside the timer.
emulate -R zsh
integer psh_power_base=$1 psh_power_exponent=$2 psh_power_iterations=$3
integer psh_power_answer=0 psh_power_expected=1
float -F 9 SECONDS=0 psh_power_elapsed=0
(( psh_power_exponent >= 0 && psh_power_iterations > 0 &&
   (psh_power_base == 0 || psh_power_base == 1 || psh_power_base == -1) )) || exit 2
if (( psh_power_exponent )); then
  if (( psh_power_base == 0 )); then
    psh_power_expected=0
  elif (( psh_power_base == -1 && psh_power_exponent % 2 )); then
    psh_power_expected=-1
  fi
fi
(( psh_power_answer = psh_power_base ** psh_power_exponent ))
(( psh_power_answer == psh_power_expected )) || exit 3
SECONDS=0
repeat $psh_power_iterations (( psh_power_answer = psh_power_base ** psh_power_exponent ))
psh_power_elapsed=$SECONDS
(( psh_power_answer == psh_power_expected )) || exit 3
printf '%.9f\n' $psh_power_elapsed
typeset -p psh_power_base psh_power_exponent psh_power_answer
