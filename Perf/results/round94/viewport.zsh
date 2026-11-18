# Measure height-only updates using the project's own cached-layout path.
emulate -R zsh
setopt extendedglob
source "$1/lib/util.zsh" || exit 1
source "$1/lib/input.zsh" || exit 1
typeset -i length=$2 rounds=$4
if (( $# > 4 )); then
  module_path=("$5" $module_path)
  zmodload literal_probe || exit 1
fi
checkpoint() {
  literal-stats "$1" && read -r REPLY || exit 1
}
input_reset
if [[ $3 == wide ]]; then
  INPUT_BUF=${(l:$length::界:)}
else
  INPUT_BUF=${(l:$length::x:)}
fi
INPUT_POS=$length
input_layout 74 4
if (( $# > 4 )); then checkpoint wrapped; fi
input_layout 74 8
float -F 9 SECONDS=0
repeat $rounds {
  input_layout 74 4
  input_layout 74 8
}
float elapsed=$SECONDS
if (( $# > 4 )); then
  checkpoint reused
  typeset tiny=x
  [[ x == "$tiny" ]] || exit 1
  checkpoint small
fi
[[ ${(j::)INPUT_VISUAL_LINES} == "$INPUT_BUF" ]] || exit 1
(( INPUT_CURSOR_ROW == $#INPUT_VISUAL_LINES && INPUT_VISIBLE_ROWS <= 8 &&
   INPUT_VIEW_TOP + INPUT_VISIBLE_ROWS - 1 == INPUT_CURSOR_ROW )) || exit 1
printf '%.9f\n' $elapsed
typeset -p INPUT_BUF INPUT_POS INPUT_VISUAL_LINES INPUT_VISUAL_LENGTHS INPUT_VISUAL_STARTS \
  INPUT_CURSOR_ROW INPUT_CURSOR_COL INPUT_LAYOUT_WIDTH INPUT_LAYOUT_POS INPUT_VISIBLE_ROWS INPUT_VIEW_TOP
