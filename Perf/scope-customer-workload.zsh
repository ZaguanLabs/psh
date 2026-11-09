# Add unrelated globals before running the existing, unchanged project kernel.
emulate -R zsh
integer psh_scope_padding=$1 psh_scope_index=0
typeset psh_scope_module=$2 psh_scope_worker=$3
shift 3
module_path=("$psh_scope_module" $module_path)
zmodload psh_scope_observer || exit 1
for ((psh_scope_index=1; psh_scope_index<=psh_scope_padding; ++psh_scope_index)); do
  typeset -g "psh_scope_pad_${psh_scope_index}=$psh_scope_index"
done
source "$psh_scope_worker" "$@" || exit 2
print -r -- '__psh_scope_table__'
psh-scope-observe
