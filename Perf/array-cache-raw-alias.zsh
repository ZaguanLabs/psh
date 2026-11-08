# Negative control: demonstrate the documented raw-field native incompatibility
# and its getter migration. The allocation/tail stay alive and are restored.
emulate -R zsh
module_path=("$1" $module_path)
zmodload psh_array_cache_fixture || exit 1
for kind in raw getter; do
  psh-cache-fixture init || exit 2
  repeat 4; do
    [[ -v 'psh_cache_array[1000]' ]] || exit 3
    : "${psh_cache_array[1000]}"
  done
  psh-cache-fixture loan $kind || exit 4
  psh-cache-fixture cut || exit 5
  print -r -- "$kind:present=${+psh_cache_array[1000]}:value=${psh_cache_array[1000]}"
  psh-cache-fixture restore || exit 6
done
zmodload -u psh_array_cache_fixture || exit 7
