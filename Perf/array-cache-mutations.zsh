emulate -R $1
setopt braceexpand # authored fixture data; keep indexing/emulation options
typeset -a a
_psh_cache_probe() {
  typeset n
  for n in 64 65 128 255 256 257 511 512 513 1000 1001 0 -1 -3; do
    print -r -- "$n:${+a[$n]}:${(qqqq)a[$n]}"
    print -r -- "search=$n:${a[(ib:n:)2*]}:${(qqqq)a[(rb:n:)2*]}"
    [[ -v "a[$n]" ]]
    print -r -- "exists=$?"
  done
  print -r -- "size=${#a[@]}"
}
_psh_cache_local() {
  typeset -a a=( {1..128} )
  _psh_cache_probe
  a[65,127]=()
  _psh_cache_probe
}
for action in identity append sparse replace shrink prefix-delete middle-delete tail-delete shift unique attributes read-only-expansions shadow unset-recreate type-change; do
  a=( {1..512} )
  repeat 3; do _psh_cache_probe; done
  case $action in
    identity) ;;
    append) a+=( {1..512} ) ;;
    sparse) a[1000]=tail ;;
    replace) a[100]=replacement ;;
    shrink) a=(one two three) ;;
    prefix-delete) a[1,100]=() ;;
    middle-delete) a[64,400]=() ;;
    tail-delete) a[64,-1]=() ;;
    shift) shift 400 a ;;
    unique) a=( ${(l:512::x:)} ); a=( ${(s::)a[1]} ); repeat 3; do _psh_cache_probe; done; typeset -U a ;;
    attributes) typeset -L 4 a; typeset +L a ;;
    read-only-expansions) : "${(u)a[@]}" "${(O)a[@]}" "${a[(I)3*]}" "${(j:,:)a}" ;;
    shadow) _psh_cache_local ;;
    unset-recreate) unset a; typeset -a a=(short) ;;
    type-change) unset a; typeset a=scalar; unset a; typeset -a a=(new array) ;;
  esac
  print -r -- "action=$action"
  repeat 3; do _psh_cache_probe; done
  typeset +U a 2>/dev/null
done
integer outer
for (( outer=0; outer<500; outer++ )); do
  () {
    typeset -a transient=( {1..256} )
    [[ -v 'transient[200]' ]] || exit 31
    [[ -v 'transient[200]' ]] || exit 32
    # Expansions run inside prefork's queue boundary; bare -v probes do not
    # populate the cache in the guarded implementation.
    : "${transient[200]}"
    transient=(short)
    [[ ! -v 'transient[200]' ]] || exit 33
    [[ -z ${transient[200]} ]] || exit 34
  } || exit $?
done
print -r -- mutation-checks-complete
