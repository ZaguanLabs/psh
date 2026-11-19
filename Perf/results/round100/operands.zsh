# Pause before, during and after the evaluation of a flat arithmetic sum.
emulate -R zsh
integer terms=$1 v=1 result
expr=${(l:$((terms*2))::v+:)}'operand_checkpoint()'
checkpoint() {
  print -r -- "$1"
  IFS= read -r REPLY || exit 1
}
operand_checkpoint() {
  checkpoint live
  (( 1 ))
}
functions -M operand_checkpoint 0 0 operand_checkpoint
checkpoint ready
(( result = expr ))
(( result == terms + 1 )) || exit 1
checkpoint after
print -r -- "$result"
