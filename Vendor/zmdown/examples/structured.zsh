# Source this file after placing the matching module on module_path.
zmdown_spans_demo() {
  emulate -L zsh
  zmodload zmdown || return
  local -A document
  local markdown=${2:-$'# Structured output\n\n***Combined styles*** and `literal code`.\n\n```zsh\nprint -r -- "Hello"\n```'}
  zmdown --spans document --width "${1:-60}" --text "$markdown" || return
  local -i i j flags cells
  local key text
  for (( i=1; i<=document[line_count]; ++i )); do
    for (( j=1; j<=document[line,$i,span_count]; ++j )); do
      key=line,$i,span,$j
      text=$document[$key,text]
      flags=$document[$key,style]
      cells=$document[$key,cells]
      # An application can draw "$text" using its own palette and these flags.
      print -rn -- "$text"
    done
    print
  done
}
