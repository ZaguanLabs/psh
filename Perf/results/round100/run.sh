# Run from the repository root with both release builds available.
set -eu
w=$PWD/.work/round100
a=$w/a/zsh
b=$w/b/zsh
trial=$w/trial/runtime/bin/zsh
ref=$PWD/.work/rc0-release-baseline/Src/zsh
labs=/home/stig/dev/ai/zaguan/labs
challenge=/home/stig/dev/challenge
mkdir -p "$w/a" "$w/b"
cp -p .work/round99/trial/runtime/bin/zsh "$a"
cp -p "$trial" "$b"
timing=(python3 Perf/customer-benchmark.py --cpu 13 --labs "$labs" --challenge "$challenge")
focus=(--case endgame/endgame-world --case z3dfx.mario/mario-race --case z3dfx/shooter-step --case zcoder.zsh/coder-paste --case zchat.zsh/chat-paste --case zcoder.zsh/coder-wide-layout)
"${timing[@]}" "$a" "$b" --samples 9 --output "$w/first.json" > "$w/first.log"
"${timing[@]}" "$b" "$a" --samples 9 --output "$w/repeat.json" > "$w/repeat.log"
"${timing[@]}" "$ref" "$b" "${focus[@]}" --samples 5 --output "$w/pristine.json" > "$w/pristine.log"
memory=(python3 Perf/memory-checkpoints.py --heap-mapping --labs "$labs" --challenge "$challenge" --samples 5)
"${memory[@]}" --shell "$a" --shell "$b" "${focus[@]}" --output "$w/memory.json" > "$w/memory.log"
"${memory[@]}" --shell "$b" --shell "$a" --case endgame/endgame-world --cycles 120 --output "$w/long.json" > "$w/long.log"
python3 Perf/results/round100/operands.py "$a" "$b" "$ref" --output "$w/operands.json"
for host in a b; do
    for tool in callgrind dhat; do
        env -i PATH=/usr/bin:/bin LC_ALL=C.UTF-8 valgrind --tool="$tool" --"$tool"-out-file="$w/$host.$tool" "$w/$host/zsh" -df Perf/customer-workload.zsh endgame-world "$challenge/endgame" 2 > "$w/$host-$tool.out" 2> "$w/$host-$tool.log"
        cmp <(tail -n+2 "$w/a-callgrind.out") <(tail -n+2 "$w/$host-$tool.out")
    done
done
python3 Packaging/check-ohmyzsh.py --candidate "$trial" --output "$w/omz.json" > "$w/omz.log" 2>&1
python3 Perf/check-convfloat-loaders.py --candidate "$trial" --output "$w/loaders.json" > "$w/loaders.log"
make -C "$w/trial/build" check > "$w/upstream.log" 2>&1
for loc in C C.UTF-8; do
    env -i LC_ALL="$loc" PATH=/usr/bin:/bin "$b" -df Vendor/zjson/tests/run.zsh > "$w/zjson-$loc.log" 2>&1
done
python3 Perf/math-storage-compare.py "$ref" "$a" "$b" --output "$w/storage.json" > "$w/storage.log"
python3 Perf/math-compare.py "$ref" "$b" --syntax --operators --descriptors --state-frames --locale C --locale C.UTF-8 --output "$w/math.json" > "$w/math.log"
python3 Perf/math-compare.py "$a" "$b" --descriptors-only --locale C.UTF-8 --memcheck --output "$w/descriptors.json" > "$w/descriptors.log"
python3 Perf/check-math-counter-module.py "$ref" "$a" "$b" --headers-build "$PWD/.work/rc0-release-baseline" --headers-source "$PWD/.work/pristine" --memcheck --output "$w/counter.json" > "$w/counter.log"
