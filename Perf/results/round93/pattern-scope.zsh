module_path=("$1" $module_path)
zmodload pattern_scope_probe || exit 1
setopt errreturn
pattern-scope-probe
localize_late() {
    disable -p '*'
    setopt localpatterns
}
propagate() {
    unsetopt localpatterns
    disable -p '?'
}
outer() {
    setopt localpatterns
    disable -p '['
    localize_late
    disable -p
    () { enable -p '['; localize_late; disable -p; }
    propagate
    disable -p
    pattern-scope-probe
}
TRAPUSR1() { setopt localpatterns; disable -p '^'; outer; }
emulate zsh -c 'sticky() { setopt localpatterns; disable -p; outer; }'
setopt localoptions
for operator in '' '*' '@('; do
    if [[ -n $operator ]]; then disable -p "$operator"; fi
    outer
    sticky
    kill -USR1 $$
    eval 'disable -p'
    (outer)
    if [[ -n $operator ]]; then enable -p "$operator"; fi
done
print passed
