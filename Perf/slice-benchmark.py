#!/usr/bin/env python3
"""Compare bounded scalar reads with the preceding psh version; retain controls."""
import argparse
import hashlib
import json
import os
from pathlib import Path
import platform
import statistics
import subprocess


def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument("baseline", type=Path)
    p.add_argument("candidate", type=Path)
    p.add_argument("--samples", type=int, default=9)
    p.add_argument("--cpu", type=int)
    p.add_argument("--output", type=Path, required=True)
    p.add_argument("--indices", action="store_true",
                   help="include late multibyte and negative-index controls")
    args = p.parse_args()
    if args.samples < 3:
        p.error("at least three samples are required")
    if args.cpu is not None:
        os.sched_setaffinity(0, {args.cpu})
    shells = [str(s.resolve(strict=True)) for s in (args.baseline, args.candidate)]
    workload = Path(__file__).resolve().with_name("slice-workload.zsh")
    env = {"PATH": "/usr/bin:/bin", "LC_ALL": "C.UTF-8", "LANG": "C.UTF-8"}
    report = {"platform": platform.platform(), "cpu_affinity": sorted(os.sched_getaffinity(0)),
              "shells": shells, "locale": "C.UTF-8", "samples": args.samples,
              "binary_sha256": [hashlib.sha256(Path(s).read_bytes()).hexdigest() for s in shells],
              "cases": []}
    # Large late indices already spend milliseconds walking the source per
    # call. Keep those batches comparable in duration to the prefix batches.
    specs = [(op, size, 20 if size == 1000000 and op in ("middle", "suffix", "full") else 2000)
             for op in ("prefix", "middle", "suffix", "empty", "full")
             for size in (32, 10000, 1000000)]
    specs += [("unicode", 100000, 2000), ("nul", 100000, 2000),
              ("beyond", 1000000, 20)]
    if args.indices:
        specs += [("mb-suffix", 1000000, 20), ("late-unicode", 10000, 20),
                  ("mixed-suffix", 10000, 20),
                  ("nul-suffix", 10000, 20),
                  ("negative", 1000000, 20)]
    for op, size, iterations in specs:
        times = [[], []]
        for sample in range(args.samples):
            for which in ((0, 1) if sample % 2 == 0 else (1, 0)):
                result = subprocess.run([shells[which], "-df", str(workload), op,
                                         str(size), str(iterations)], env=env,
                                        capture_output=True, text=True, check=True, timeout=120)
                if result.stderr:
                    raise RuntimeError(result.stderr)
                times[which].append(float(result.stdout) * 1000)
        medians = [statistics.median(s) for s in times]
        case = {"operation": op, "size": size, "iterations": iterations,
                "samples_ms": times, "median_ms": medians, "speedup": medians[0] / medians[1]}
        report["cases"].append(case)
        print(f"{op:8} {size:8}: {medians[0]:9.3f} -> {medians[1]:9.3f} ms "
              f"({case['speedup']:.2f}x)", flush=True)
    args.output.parent.mkdir(parents=True, exist_ok=True)
    args.output.write_text(json.dumps(report, indent=2) + "\n")


if __name__ == "__main__":
    main()
