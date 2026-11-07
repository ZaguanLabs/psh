# Real project functions, invoked with explicit roots and no application launcher.
emulate -R zsh
setopt extendedglob
typeset psh_operation=$1 psh_project=$2
integer psh_iterations=$3
psh-reset() { return 0; }

case $psh_operation in
  coder-paste|chat-paste|coder-layout|chat-layout|coder-wide-layout|chat-wide-layout)
    source "$psh_project/lib/util.zsh" || exit 1
    source "$psh_project/lib/input.zsh" || exit 1
    typeset psh_expected=${(l:10000::x:)}
    if [[ $psh_operation == *-paste ]]; then
      run-workload() {
        local -i j
        local byte delimiter=$'\e[201~'
        repeat $psh_iterations {
          input_reset
          INPUT_TERM_STATE=paste
          for (( j=0; j<10000; ++j )); do input_decode_terminal_event x ''; done
          for byte in "${(@s::)delimiter}"; do input_decode_terminal_event "$byte" ''; done
        }
      }
      check-result() { [[ $INPUT_EVENT_ACTION == paste && $INPUT_EVENT_TEXT == "$psh_expected" ]]; }
      dump-result() { typeset -p INPUT_EVENT_ACTION INPUT_EVENT_TEXT; }
    else
      integer psh_rows=136 psh_column=10
      if [[ $psh_operation == *-wide-layout ]]; then
        [[ ${LC_ALL:-} == C.UTF-8 ]] || exit 2
        psh_expected=${(l:10000::界:)}
        psh_rows=271 psh_column=20
      fi
      input_reset
      INPUT_BUF=$psh_expected INPUT_POS=10000
      run-workload() {
        repeat $psh_iterations { INPUT_LAYOUT_WIDTH=-1; input_layout 74 4; }
        return 0
      }
      check-result() {
        [[ ${(j::)INPUT_VISUAL_LINES} == "$psh_expected" ]] &&
          (( ${#INPUT_VISUAL_LINES} == psh_rows && INPUT_CURSOR_ROW == psh_rows &&
             INPUT_CURSOR_COL == psh_column && INPUT_VISUAL_STARTS[-1] == 9990 ))
      }
      dump-result() { typeset -p INPUT_VISUAL_LINES INPUT_VISUAL_STARTS INPUT_VISUAL_LENGTHS INPUT_CURSOR_ROW INPUT_CURSOR_COL; }
    fi
    ;;
  endgame-world)
    for psh_component in data engine adventure expedition; do
      source "$psh_project/lib/$psh_component.zsh" || exit 1
    done
    run-workload() { repeat $psh_iterations ew-new 1 'psh benchmark'; }
    check-result() { (( ${#terrain} == 2736 && ${#party} == 1 )) && [[ $game[name] == 'psh benchmark' && $screen == world ]]; }
    dump-result() { typeset -p game terrain landmarks creatures party adventure; }
    ;;
  mario-race)
    zmodload zsh/mathfunc || exit 1
    source "$psh_project/lib/track.zsh" || exit 1
    source "$psh_project/lib/engine.zsh" || exit 1
    # track-build accumulates this global; restore its fresh-launch value.
    psh-reset() { track_length=0; race-reset; engine_accel=1; }
    run-workload() { repeat $psh_iterations race-step 0.016; }
    check-result() { (( speed > 5 && track_length > 448 && track_length < 449 &&
                           track_s[2] < 100 && !finished && abs(race_time-psh_iterations*0.016) < 0.000001 )); }
    dump-result() { typeset -p player_s player_lateral player_x player_y player_angle speed race_time lap coins ai_s ai_lap ai_distance coin_live; }
    ;;
  shooter-step)
    zmodload zsh/mathfunc || exit 1
    source "$psh_project/levels/relay.zsh" || exit 1
    source "$psh_project/lib/engine.zsh" || exit 1
    source "$psh_project/lib/input.zsh" || exit 1
    psh-reset() { game-reset; }
    run-workload() { repeat $psh_iterations game-step 0.016; }
    check-result() {
      (( ${#level_tile} == map_w*map_h && enemy_count == 10 && !won &&
         !dead && focused && abs(world_time-psh_iterations*0.016) < 0.000001 &&
         ${#nav_distance} == map_w*map_h ))
    }
    dump-result() { typeset -p world_time player_x player_y player_angle health armor enemy_x enemy_y enemy_hp item_live door_open nav_distance; }
    ;;
  fetch-encode)
    source "$psh_project/lib/http.zsh" || exit 1
    typeset psh_text=${(l:2048::x:)}$'café 🦊&\n'
    typeset psh_expected=${(l:2048::x:)}'caf%C3%A9%20%F0%9F%A6%8A%26%0A'
    run-workload() { repeat $psh_iterations zfetch_urlencode "$psh_text"; }
    check-result() { [[ $REPLY == "$psh_expected" ]]; }
    dump-result() { typeset -p REPLY; }
    ;;
  drawing-binning)
    source "$psh_project/lib/paint.zsh" || exit 1
    art_w=151 art_h=83 tile_w=75 tile_h=40 antialias=0
    # The project's binning test fixture, without allocating raster surfaces.
    tile_names=() tile_x=() tile_y=() tile_width=() tile_height=()
    integer psh_x psh_y psh_t psh_i psh_n x0 y0 x1 y1 x2 y2 ox oy xmax ymax
    for psh_y in 0 40 80; do
      for psh_x in 0 75 150; do
        tile_names+=(tile${#tile_names}) tile_x+=($psh_x) tile_y+=($psh_y)
        tile_width+=($(( 75 < 151-psh_x ? 75 : 151-psh_x ))) tile_height+=($(( 40 < 83-psh_y ? 40 : 83-psh_y )))
      done
    done
    typeset -a psh_batch psh_reference submitted
    for psh_n in {1..120}; do
      paint-random 240; x0=$((REPLY-40)); paint-random 150; y0=$((REPLY-30))
      paint-random 240; x1=$((REPLY-40)); paint-random 150; y1=$((REPLY-30))
      paint-random 240; x2=$((REPLY-40)); paint-random 150; y2=$((REPLY-30))
      psh_batch+=($x0 $y0 1 $x1 $y1 1 $x2 $y2 1 0)
    done
    psh_batch+=(75 0 1 75 40 1 75 80 1 0 150 40 1 151 40 1 151 83 1 0)
    for ((psh_t=1;psh_t<=${#tile_names};++psh_t)); do
      ((ox=tile_x[psh_t],oy=tile_y[psh_t],xmax=ox+tile_width[psh_t],ymax=oy+tile_height[psh_t]))
      submitted=()
      for ((psh_i=1;psh_i<=${#psh_batch};psh_i+=10)); do
        ((x0=psh_batch[psh_i],y0=psh_batch[psh_i+1],x1=psh_batch[psh_i+3],y1=psh_batch[psh_i+4],x2=psh_batch[psh_i+6],y2=psh_batch[psh_i+7]))
        (( (x0<ox && x1<ox && x2<ox) || (x0>xmax && x1>xmax && x2>xmax) ||
           (y0<oy && y1<oy && y2<oy) || (y0>ymax && y1>ymax && y2>ymax) )) && continue
        submitted+=($((x0-ox)) $((y0-oy)) 1 $((x1-ox)) $((y1-oy)) 1 $((x2-ox)) $((y2-oy)) 1 0)
      done
      psh_reference[psh_t]="${(j: :)submitted} "
    done
    run-workload() {
      repeat $psh_iterations {
        tile_commands=() batch=("${psh_batch[@]}") triangles=0
        paint-flush || return 1
      }
    }
    check-result() {
      (( triangles == 122 && ${#batch} == 0 )) || return 1
      for ((psh_t=1;psh_t<=${#tile_names};++psh_t)); do
        [[ $tile_commands[psh_t] == $psh_reference[psh_t] ]] || return 1
      done
    }
    dump-result() { typeset -p tile_commands triangles; }
    ;;
  *) exit 2 ;;
esac
psh-reset || exit 1
run-workload || exit 1
check-result || exit 1
psh-reset || exit 1
float -F 9 SECONDS=0
run-workload || exit 1
float psh_elapsed=$SECONDS
check-result || exit 1
printf '%.9f\n' $psh_elapsed
dump-result
