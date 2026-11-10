module_path=("$1" $module_path)
zmodload zsh/parameter || exit 1
TRAPUSR1() { zmodload -u psh_scope_signal || return 7; }
zmodload psh_scope_signal || exit 2
(( ${+modules[psh_scope_signal]} == 0 )) || exit 3
print -r -- SIGNAL_UNLOAD_OK
