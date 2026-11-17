emulate -R zsh
typeset mode=$1
integer width=$2 iterations=$3
typeset -a words
case $mode in
  transcript)
    source "$4/vendor/zjson/zjson.zsh" || exit 1
    source "$4/lib/transcript.zsh" || exit 1
    UI_IDS=('event-1') UI_BLOCK_OPEN=(1) UI_TOOL_NAMES=('read')
    UI_TOOL_ARGS=('a "quote"') UI_TOOL_RESULTS=("${(l:$width::x:)}")
    UI_TOOL_STATES=(completed) UI_TOOL_SUMMARIES=($'line one\nline two')
    UI_TOOL_DIFFS=('λ') UI_STREAM_INDEX=1
    expected='{"id":"event-1","open":"1","name":"read","args":"a \"quote\"","result":"'"${UI_TOOL_RESULTS[1]}"'","state":"completed","summary":"line one\nline two","diff":"λ","streaming":1}'
    run() { transcript_metadata_json 1; }
    ;;
  front|back)
    words=( {1..$width} )
    run() {
      local -a pending=("${words[@]}")
      if [[ $mode == front ]]; then
        repeat $((width-1)) { shift pending || return 1; }
        [[ $#pending == 1 && $pending[1] == "$width" ]]
      else
        repeat $((width-1)) { shift -p pending || return 1; }
        [[ $#pending == 1 && $pending[1] == 1 ]]
      fi
    }
    ;;
  *) exit 2 ;;
esac
run || exit 1
float -F 9 SECONDS=0
repeat $iterations { run || exit 1; }
float elapsed=$SECONDS
printf '%.9f\n' $elapsed
if [[ $mode == transcript ]]; then
  [[ $REPLY == "$expected" ]] || exit 1
  print -r -- "$REPLY"
else
  print -r -- "$mode $width $iterations"
fi
