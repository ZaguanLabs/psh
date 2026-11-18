# Read each substitution during the command that owns its descriptor.
emulate -R zsh
pair() {
    print -r -- "$(< "$1")" "$(< "$2")"
}
adjacent() {
    local left=${1%%:*} right=${1#*:}
    pair "$left" "$right"
}
prefix() {
    local file=${1#prefix}
    print -r -- "$(< "$file")"
}
pair <(print -nr -- left) =(print -nr -- right)
adjacent <(print -nr -- one):<(print -nr -- two)
prefix prefix<(print -nr -- joined)
pair <(print -nr -- "$(print -nr -- nested)") <(print -nr -- $((2 + 3)))
print -r -- 'literal <(x) =(x)' "\$(literal)" $'\203\224\210'
print -r -- "$((1 + (2 * 3)))" "$(print -r -- ok)"
setopt shwordsplit kshtypeset
v="a b"
typeset field=base=$v
print -r -- "$field"
