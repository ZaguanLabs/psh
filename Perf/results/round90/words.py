"""Time literal words and parameter expansions in pre-parsed shell code."""
import argparse
import hashlib
import json
import os
from pathlib import Path
import statistics
import subprocess


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("shell", nargs="+", type=Path)
    parser.add_argument("--cpu", required=True, type=int)
    parser.add_argument("--output", required=True, type=Path)
    args = parser.parse_args()
    shells = [p.resolve(strict=True) for p in args.shell]
    os.sched_setaffinity(0, {args.cpu})
    env = {"LC_ALL": "C.UTF-8", "PATH": "/usr/bin:/bin"}
    report = {"shells": {str(p): hashlib.sha256(p.read_bytes()).hexdigest() for p in shells},
              "cpu": args.cpu, "environment": env, "cases": []}
    long_word = "x" * 1024
    cases = [
        ("one-byte", "set -- a b c d", ["a", "b", "c", "d"]),
        ("two-byte", "set -- ab bc cd de", ["ab", "bc", "cd", "de"]),
        ("long", "set -- " + long_word, [long_word]),
        ("tokens", 'set -- "$v" ${v} "$v" ${v}', ["ab"] * 4),
        ("mixed", 'set -- x a${v}b ${v}c =', ["x", "aabb", "abc", "="]),
    ]
    for name, statement, expected in cases:
        program = f'''zmodload zsh/datetime || exit 1
v=ab
repeat 100; do {statement}; done
float start=$EPOCHREALTIME
repeat 20000; do {statement}; done
print -r -- $(( EPOCHREALTIME - start ))
printf '%s\\0' "$@"
'''
        samples = [[] for _ in shells]
        for sample in range(9):
            offset = sample % len(shells)
            for h in [*range(offset, len(shells)), *range(offset)]:
                run = subprocess.run([shells[h], "-dfc", program], env=env,
                                     capture_output=True, timeout=30, check=True)
                elapsed, result = run.stdout.split(b"\n", 1)
                if run.stderr or result != b"".join(w.encode() + b"\0" for w in expected):
                    raise ValueError(f"Unexpected result for {name} on {shells[h]}: {run.stderr!r}")
                samples[h].append(1000 * float(elapsed))
        report["cases"].append({"case": name, "samples_ms": samples,
                                "median_ms": [statistics.median(s) for s in samples]})
    args.output.write_text(json.dumps(report, indent=2) + "\n")


if __name__ == "__main__":
    main()
