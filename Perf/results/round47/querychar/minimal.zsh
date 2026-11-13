emulate -R zsh
setopt nounset
module_path=("$1")
typeset cmd=$2 report_fd=$4
typeset -a cell
if [[ $cmd == zcurses ]]; then zmodload zsh/curses; else zmodload zdraw; fi
"$cmd" init || exit 1
"$cmd" addwin sample 2 8 0 0 || exit 2
"$cmd" attr sample underline || exit 3
"$cmd" string sample X || exit 4
"$cmd" move sample 0 0 || exit 5
"$cmd" querychar sample cell || exit 6
print -r -u "$report_fd" -- 0
print -rl -u "$report_fd" -- "${cell[@]}"
"$cmd" delwin sample
"$cmd" end
