module_path=("$1" $module_path)
zmodload psh_scope_observer || exit 1
[[ $(psh-scope-tracking) == "$2" ]] || exit 2
repeat 2 {
 zmodload psh_scope_switch || exit 3
 [[ $(psh-scope-tracking) == "$2" ]] || exit 4
 zmodload -u psh_scope_switch || exit 5
}
cp -- "$1/psh_scope_opaque.so" "$1/psh_scope_switch.so" || exit 6
typeset psh_opaque_ctor_target=global
() { local seed=1; }
zmodload psh_scope_switch || exit 7
(( ${+psh_opaque_ctor_target} == 0 )) || exit 8
[[ $(psh-scope-tracking) == 0 ]] || exit 9
print -r -- RELOAD_FALLBACK_OK
