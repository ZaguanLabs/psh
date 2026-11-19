set -eu
w=$PWD/.work/round99
f=$w/focused
mkdir -p "$f/files"
touch -- "$f/files/preapost" "$f/files/prebpost" "$f/files/prea*" "$f/files/pre*post"
for tag in pristine a b; do
    shell=$w/$tag/zsh
    if [[ $tag == pristine ]]; then shell=$PWD/.work/rc0-release-baseline/Src/zsh; fi
    for locale in C C.UTF-8; do
        target=$f/$tag-$locale
        env -i PATH=/usr/bin:/bin LC_ALL="$locale" valgrind --error-exitcode=97 --leak-check=no --log-file="$target.memcheck.log" "$shell" -df Perf/results/round99/joins.zsh "$f/files" > "$target.out" 2> "$target.err"
        test ! -s "$target.err"
        test "$(tail -c 15 "$target.out")" = joins-complete
        cmp "$target.out" "$f/pristine-$locale.out"
        sha256sum "$target.out"
    done
done
