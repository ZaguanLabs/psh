emulate -R zsh
integer size=$1 index=$2 reads=$3
typeset -a a
# Only fixed numeric fixture arguments from the driver enter this expression.
eval "a=( {1..$size} )"
typeset -F 9 SECONDS=0 started elapsed
typeset value
started=$SECONDS
repeat $reads; do value=${a[$index]}; done
elapsed=$(( SECONDS - started ))
print -r -- "$elapsed"
print -r -- "$size:$index:$reads:${#a}:$value"
