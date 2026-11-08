#!/usr/bin/env python3
"""Cold and repeated array bound controls, including a large shallow query."""
import argparse
import hashlib
import json
import os
from pathlib import Path
import statistics
import subprocess


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("baseline", type=Path)
    parser.add_argument("candidate", type=Path)
    parser.add_argument("--cpu", type=int, required=True)
    parser.add_argument("--samples", type=int, default=9)
    parser.add_argument("--output", type=Path, required=True)
    args = parser.parse_args()
    os.sched_setaffinity(0, {args.cpu})
    worker = Path(__file__).with_name("array-bound-workload.zsh")
    shells = [p.resolve(strict=True) for p in [args.baseline, args.candidate]]
    sha = lambda p: hashlib.sha256(p.read_bytes()).hexdigest()
    fingerprints = {str(p): sha(p) for p in shells + [worker]}
    rows = []
    for name, size, index, reads in [("cold-shallow-large", 262144, 64, 2),
            ("cold-deep-large", 262144, 200000, 1),
            ("repeated-in-range", 1024, 1000, 5000),
            ("repeated-out-of-range", 1024, 2000, 100)]:
        samples = [[], []]
        states = set()
        for sample in range(args.samples):
            for which in ([0, 1] if sample % 2 == 0 else [1, 0]):
                cmd = [str(shells[which]), "-df", str(worker), str(size), str(index), str(reads)]
                result = subprocess.run(cmd, env={"PATH": "/usr/bin:/bin", "LC_ALL": "C.UTF-8"},
                                        capture_output=True, timeout=120)
                if result.returncode or result.stderr:
                    raise RuntimeError((cmd, result.returncode, result.stderr))
                elapsed, state = result.stdout.split(b"\n", 1)
                samples[which].append(float(elapsed) * 1000)
                states.add(hashlib.sha256(state).hexdigest())
        if len(states) != 1:
            raise RuntimeError((name, "state mismatch"))
        medians = [statistics.median(values) for values in samples]
        rows.append(dict(case=name, size=size, index=index, reads=reads,
            samples_ms=samples, median_ms=medians, state_sha256=states.pop()))
        print(name, " -> ".join(f"{value:.6f}" for value in medians), "ms", flush=True)
    if fingerprints != {str(p): sha(p) for p in shells + [worker]}:
        raise RuntimeError("measurement inputs changed")
    args.output.write_text(json.dumps(dict(fingerprints=fingerprints, cpu=args.cpu,
        samples=args.samples, scope="query loop only; array construction excluded", cases=rows),
        indent=2) + "\n")


if __name__ == "__main__":
    main()
