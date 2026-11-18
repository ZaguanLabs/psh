module_path=("$1" $module_path)
zmodload stack_probe || exit 1
setopt errreturn
leaf() {
    stack-probe enter
    print -Pr -- "leaf:<%_>"
    stack-probe leave
}
outer() {
    for word in one two; do
        stack-probe enter
        print -Pr -- "outer:<%_>"
        leaf
        () { leaf; }
        (leaf)
        eval 'leaf'
        kill -USR1 $$
        stack-probe leave
    done
}
TRAPUSR1() { leaf; }
replace_stack() { stack-probe replace; }
repeat 3; do
    stack-probe enter
    outer
    replace_stack
    leaf
    stack-probe leave
done
print -r -- passed
