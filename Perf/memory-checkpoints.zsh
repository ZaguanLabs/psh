# Linux parent samples /proc while this shell waits at explicit boundaries.
emulate -R zsh
typeset psh_memory_worker=$1 psh_memory_operation=$2 psh_memory_project=$3
typeset psh_memory_iterations=$4 psh_memory_output=$5 psh_memory_mode=$6
typeset psh_memory_trim=$7
if [[ -n $psh_memory_trim ]]; then
  module_path=("${psh_memory_trim:h}" $module_path)
  zmodload memory_trim || exit 91
fi
psh-memory-checkpoint() {
  print -r -- "$1"
  read -r REPLY || exit 90
}
psh-memory-checkpoint startup
if [[ $psh_memory_mode == burst ]]; then
  psh-memory-burst() {
    local -a payload
    local text=${(l:1024::x:)}
    local -i i
    for (( i=0; i<20000; ++i )); do payload+=("$text"); done
    (( ${#payload} == 20000 && ${#payload[-1]} == 1024 )) || exit 1
    psh-memory-checkpoint live-burst
  }
  psh-memory-burst
  psh-memory-checkpoint released-burst
  if [[ -n $psh_memory_trim ]]; then
    memory-trim-probe || exit 1
    psh-memory-checkpoint trimmed-burst
  fi
  psh-memory-burst
  psh-memory-checkpoint released-second-burst
  if [[ -n $psh_memory_trim ]]; then
    memory-trim-probe || exit 1
    psh-memory-checkpoint trimmed-second-burst
  fi
else
  source "$psh_memory_worker" "$psh_memory_operation" "$psh_memory_project" "$psh_memory_iterations" > "$psh_memory_output" || exit 1
  psh-memory-checkpoint initial-workload
  integer psh_memory_cycle psh_memory_cycles=${8:-20}
  for (( psh_memory_cycle=1; psh_memory_cycle<=psh_memory_cycles; ++psh_memory_cycle )); do
    psh-reset && run-workload && check-result || exit 1
    if (( psh_memory_cycle == 1 || psh_memory_cycle == 5 ||
          psh_memory_cycle % 20 == 0 || psh_memory_cycle == psh_memory_cycles )); then
      dump-result > "$psh_memory_output"
      psh-memory-checkpoint "cycle-$psh_memory_cycle"
    fi
  done
fi
if [[ -n $psh_memory_trim ]]; then
  zmodload -u memory_trim || exit 92
fi
