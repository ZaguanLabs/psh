# Invoke with: /path/to/tested/zsh -df reproduce.zsh /directory/with/module
emulate -R zsh
[[ $# == 1 ]] || exit 2
module_path=( "$1" "${module_path[@]}" )
zmodload hash_reentry || exit 2
typeset -A reentry_outer=(a A b B) reentry_inner=(x X y Y)
hash-reentry-check
integer result=$?
zmodload -u hash_reentry || exit 2
exit $result
