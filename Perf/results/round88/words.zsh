# Empty, packed and string-table words, including tokens and metafied bytes.
emit() { printf '%s\0' "$#" "$@"; }
v=x
hold() {
    local -a a=( '' a ab abc abcd é 猫 $'\x80' '$' $v '' )
    emit "$@" "${a[@]}"
}
for v in a ab abc; do
    hold '' a ab abc abcd é 猫 $'\x83' $v ${v} "a$v" 'a?' '?'
    case $v in
        ?) emit ?(N) one ;;
        ??) emit two ;;
        *) emit end ;;
    esac
done
TRAPUSR1() { hold sig aa b; }
kill -USR1 $$
emit a ab abc > out
while IFS= read -r -d '' v; do emit "$v"; done < out
