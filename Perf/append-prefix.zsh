emulate -R "$2"
setopt braceexpand
module_path=("$1" $module_path)
zmodload psh_array_cache_fixture || exit 1
integer checks=0 size i j
_psh_append_state() {
  print -r -- "size=${#a[@]} values=${(qqqq)a[@]}"
  for j in 1 3 63 64 65 128 257 513 -1; do
    print -r -- "index=$j exists=${+a[$j]} value=${(qqqq)a[$j]}"
  done
  (( checks++ ))
}
_psh_append_shadow() {
  typeset -a a=( {1..128} )
  a+=(inner); a[1,64]=(); a+=(inner-tail)
  _psh_append_state
}
for size in 0 1 31 32 33 63 64 65 127 128 129 255 256 257 511 512 513; do
  for action in append empty grow sparse prefix middle tail replace keyvalue shift unique attrs shadow recreate; do
    unset a
    typeset -a a=()
    for (( i=0; i<size; i++ )); do a+=("value-$i"); done
    # Publish a length through append, then mix mutations and cache collisions.
    a+=(seed)
    print -r -- "case=$size/$action"
    _psh_append_state
    case $action in
      append) repeat 8; do a+=(tail '' $'\0\377é'); done ;;
      empty) repeat 8; do a+=(); done ;;
      grow) a+=( {1..257} ) ;;
      sparse) a[600]=sparse ;;
      prefix) a[1,64]=() ;;
      middle) a[63,255]=() ;;
      tail) a[64,-1]=() ;;
      replace) a=(one two three) ;;
      keyvalue) a+=([3]=replacement [65]+=suffix) ;;
      shift) shift 3 a 2>/dev/null ;;
      unique) a+=(seed seed); typeset -U a; a+=(seed tail) ;;
      attrs) typeset -L 4 a; a+=(padding); typeset +L a ;;
      shadow) _psh_append_shadow ;;
      recreate) unset a; typeset -a a=(new array) ;;
    esac
    # Repeated append and subsequent reads must observe the mutated length.
    repeat 4; do a+=(after); done
    _psh_append_state
    for (( i=0; i<96; i++ )); do
      eval "psh_prefix_other$i=( {1..128} )"
      eval "psh_prefix_other$i+=(other)"
    done
    a+=(after-eviction)
    _psh_append_state
  done
done
# Readonly writes in nested scopes, and tied/special/unique fallbacks.
_psh_append_fallbacks() {
  typeset -a locked=( {1..128} )
  locked+=(seed)
  typeset -r locked
  (locked+=(tail)) 2>/dev/null
  print -r -- "readonly=${#locked[@]}:${locked[-1]}"
  typeset -T joined tied
  tied=( {1..128} ); tied+=(tail); tied[1,64]=(); tied+=(after)
  print -r -- "tied=$joined"
  typeset -aU uniq=(seed)
  repeat 80; do uniq+=(seed other); done
  print -r -- "unique=${(qqqq)uniq[@]}"
  argv=( {1..128} ); argv+=(tail); shift 64; argv+=(after)
  print -r -- "argv=${(qqqq)argv[@]}"
}
_psh_append_fallbacks
for kind in getaparam getter getarrvalue; do
  psh-cache-fixture init || exit 11
  psh_cache_array+=(warm)
  psh-cache-fixture loan "$kind" || exit 12
  psh-cache-fixture trim || exit 13
  repeat 4; do psh_cache_array+=(tail); done
  [[ ${#psh_cache_array[@]} == 7 ]] || exit 14
  print -r -- "loan=$kind:${(qqqq)psh_cache_array[@]}"
done
zmodload -u psh_array_cache_fixture || exit 15
print -r -- "checks=$checks append-prefix-complete"
