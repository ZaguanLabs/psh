emulate -R zsh
module_path=("$1" $module_path)
zmodload psh_array_cache_fixture || exit 1
integer checks=0 i j
for kind in getaparam getter getarrvalue; do
  psh-cache-fixture init || exit 1
  repeat 4; do
    [[ -v 'psh_cache_array[1000]' && ${psh_cache_array[1000]} == item ]] || exit 2
  done
  psh-cache-fixture loan $kind || exit 3
  # Keep the native loan alive while interpreter queries populate/evict caches.
  repeat 4; do
    [[ -v 'psh_cache_array[1000]' ]] || exit 4
    : "${psh_cache_array[1000]}"
  done
  for (( i=0; i<192; i++ )); do
    eval "psh_cache_other$i=( {1..128} )"
    typeset other_name="psh_cache_other${i}[100]"
    repeat 3; do
      [[ -v $other_name ]] || exit 5
      : "${(P)other_name}"
    done
  done
  psh-cache-fixture cut || exit 6
  repeat 4; do
    [[ ! -v 'psh_cache_array[1000]' && ! -v 'psh_cache_array[1001]' &&
       ${+psh_cache_array[1000]} == 0 && -z ${psh_cache_array[1000]} &&
       -z ${psh_cache_array[1001]} ]] || exit 7
    (( checks++ ))
  done
  psh-cache-fixture restore || exit 8
  psh-cache-fixture same-set || exit 9
  repeat 4; do
    [[ -v 'psh_cache_array[1000]' ]] || exit 10
    : "${psh_cache_array[1000]}"
  done
  psh-cache-fixture cut || exit 11
  [[ ! -v 'psh_cache_array[1000]' && -z ${psh_cache_array[1000]} ]] || exit 12
  (( checks++ ))
  psh-cache-fixture restore || exit 13
  # The fixture overallocates initially, exercising an in-place realloc on
  # this host. If allocation moves, the old loan is invalid and is reacquired.
  psh_cache_array+=(tail)
  [[ ${#psh_cache_array} == 1025 && ${psh_cache_array[1025]} == tail ]] || exit 14
  if ! psh-cache-fixture same; then psh-cache-fixture loan $kind || exit 15; fi
  repeat 4; do
    [[ -v 'psh_cache_array[1000]' ]] || exit 16
    : "${psh_cache_array[1000]}"
  done
  psh-cache-fixture cut || exit 17
  [[ ! -v 'psh_cache_array[1000]' && -z ${psh_cache_array[1000]} ]] || exit 18
  (( checks++ ))
  psh-cache-fixture restore || exit 19
done
zmodload -u psh_array_cache_fixture || exit 20
print -r -- "checks=$checks"
