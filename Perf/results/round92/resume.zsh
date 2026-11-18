# Run under an isolated controlling terminal with job control enabled.
setopt monitor
unsetopt notify
typeset -i trapped=0
TRAPUSR1() { eval ': | :'; (( ++trapped )); }
consumer() {
    local word
    read -r word || return 1
    ( : | : )
    /bin/sh -c 'kill -STOP "$$"'
    print -r -- "resumed-$word"
}
kill -USR1 $$
print -r -- payload | consumer
jobs -s > suspended
[[ -s suspended ]] || exit 1
fg || exit 1
jobs > remaining
[[ ! -s remaining && trapped -eq 1 ]] || exit 1
print -r -- done
