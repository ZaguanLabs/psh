emulate -R zsh
typeset ZTST_srcdir=$1/Test ZTST_testdir=$PWD ZTST_verbose=0 ZTST_fd=2
typeset ZSH_TEST_LANG=$LC_ALL prefix report input quote
integer n checks=0
source $ZTST_srcdir/comptest || exit 1
comptestinit -z "$2" || exit 1
comptesteval '_psh_prefix() { compadd -- "${psh_prefix} space"; }
compdef _psh_prefix psh-prefix' || exit 1
for n in 63 64 65 575 576 577 600 1024 1087 1088 1089 2048; do
  prefix=${(l:$n::x:)}
  comptesteval "typeset -g psh_prefix=${(q)prefix}" || exit 1
  for quote in '' '"' "'"; do
    input="psh-prefix ${quote}${prefix}"$'\t'
    comptest "$input" > result || exit 1
    report=$(< result)
    [[ $report == *"$prefix"* && $report == *space* ]] || exit 1
    print -r -- "$n:${(qqq)quote}:$report"
    (( checks++ ))
  done
done
zmodload -u zsh/zpty || exit 1
print -r -- checks=$checks
