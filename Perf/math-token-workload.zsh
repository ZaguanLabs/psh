# Authored expression cases supplied by math-token-benchmark.py.
emulate -R zsh
typeset expression=$1
integer iterations=$2
if [[ $3 == float ]]; then setopt forcefloat; fi
eval "psh-math-token-run() { repeat $iterations (( $expression )); return 0; }"
psh-math-token-run
float -F 9 SECONDS=0
psh-math-token-run
float elapsed=$SECONDS
print -r -- $elapsed
print -r -- "$(( $expression ))"
