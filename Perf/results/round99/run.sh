# Run from the source root after building the isolated candidate.
set -eu
w=$PWD/.work/round99
trial=$w/trial
ref=$PWD/.work/rc0-release-baseline/Src/zsh
labs=/home/stig/dev/ai/zaguan/labs
project=$labs/zcoder.zsh
mkdir -p "$w/a" "$w/b"
cp -p .work/round98/trial/runtime/bin/zsh "$w/a/zsh"
cp -p "$trial/runtime/bin/zsh" "$w/b/zsh"
a=$w/a/zsh
b=$w/b/zsh
fixture=Perf/results/round94/viewport.zsh
timing=(python3 Perf/customer-benchmark.py --cpu 13 --labs "$labs" --challenge /home/stig/dev/challenge)
focus=(--case zcoder.zsh/coder-paste --case zcoder.zsh/coder-wide-layout --case zchat.zsh/chat-paste --case endgame/endgame-world)
for order in first repeat; do
    shells=("$a" "$b")
    if [[ $order == repeat ]]; then shells=("$b" "$a"); fi
    "${timing[@]}" "${shells[@]}" --samples 9 --output "$w/$order.json" > "$w/$order.log"
    python3 Perf/results/round94/viewport.py --shell "${shells[0]}" --shell "${shells[1]}" --shell "$ref" --project "$project" --cpu 13 --output "$w/viewport-$order.json"
done
"${timing[@]}" "$ref" "$b" "${focus[@]}" --samples 5 --output "$w/pristine.json" > "$w/pristine.log"
python3 Perf/results/round91/sourced.py --shell "$a" --shell "$b" --shell "$ref" --labs "$labs" --cpu 13 --output "$w/sourced.json"
python3 Perf/results/round99/word-timing.py "$a" "$b" --cpu 13 --output "$w/words.json"
memory=(python3 Perf/memory-checkpoints.py --heap-mapping --labs "$labs" --challenge /home/stig/dev/challenge --samples 5)
"${memory[@]}" --shell "$a" --shell "$b" "${focus[@]}" --output "$w/memory.json" > "$w/memory.log"
"${memory[@]}" --shell "$b" --shell "$a" --case zcoder.zsh/coder-wide-layout --cycles 120 --output "$w/long.json" > "$w/long.log"
for tag in a b; do
    build=$trial/build
    if [[ $tag == a ]]; then build=$PWD/.work/round98/trial/build; fi
    mkdir -p "$w/probe/$tag"
    cc -shared -fPIC -O2 -Wall -Werror -DMODULE -DHAVE_CONFIG_H -I"$build/Src" Perf/results/round94/literal.c -o "$w/probe/$tag/literal_probe.so"
done
python3 Perf/results/round94/viewport-memory.py --build "$a" "$w/probe/a" --build "$b" "$w/probe/b" --project "$project" --output "$w/viewport-memory.json"
for tag in a b; do
    for tool in callgrind dhat; do
        options=()
        if [[ $tool == callgrind ]]; then options=(--cache-sim=yes); fi
        env -i PATH=/usr/bin:/bin LC_ALL=C.UTF-8 valgrind --tool="$tool" "${options[@]}" --"$tool"-out-file="$w/$tag.$tool" "$w/$tag/zsh" -df "$fixture" "$project" 10000 wide 64 > "$w/$tag-$tool.out" 2> "$w/$tag-$tool.log"
        cmp <(tail -n+2 "$w/a-callgrind.out") <(tail -n+2 "$w/$tag-$tool.out")
    done
done
bash Perf/results/round99/focused.sh > "$w/focused.log"
python3 Packaging/check-ohmyzsh.py --candidate "$trial/runtime/bin/zsh" --output "$w/omz.json" > "$w/omz.log" 2>&1
python3 Perf/check-convfloat-loaders.py --candidate "$trial/runtime/bin/zsh" --output "$w/loaders.json" > "$w/loaders.log"
make -C "$trial/build" check > "$w/upstream.log" 2>&1
for loc in C C.UTF-8; do
    env -i LC_ALL="$loc" PATH=/usr/bin:/bin "$b" -df Vendor/zjson/tests/run.zsh > "$w/zjson-$loc.log" 2>&1
done
python3 Perf/substitution-compare.py "$ref" "$b" --output "$w/subst.json" > "$w/subst.log"
python3 Perf/pattern-compare.py "$ref" "$b" --extended --output "$w/pattern.json" > "$w/pattern.log"
