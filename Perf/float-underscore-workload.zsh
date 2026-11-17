emulate -R zsh
typeset expr=$1
integer iterations=$2 side=0 named_value=7
typeset -F 12 value
value=$(( $expr ))
(( value == 9.25 && side == 1 )) || exit 1
side=0
float -F 9 SECONDS=0
repeat $iterations { value=$(( $expr )); }
float elapsed=$SECONDS
(( value == 8.25+iterations && side == iterations )) || exit 2
print -r -- "$elapsed"
print -r -- "$value:$side:$named_value"
