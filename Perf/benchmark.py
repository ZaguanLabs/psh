#!/usr/bin/env python3
"""Alternate two Zsh builds on array workloads; retain every wall-time sample."""
import argparse
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
    args = p.parse_args()
    if args.samples < 3:
        p.error("at least three samples are required")
    if args.cpu is not None:
        os.sched_setaffinity(0, {args.cpu})
    shells = [str(s.resolve(strict=True)) for s in (args.baseline, args.candidate)]
    workload = Path(__file__).resolve().with_name("array-workload.zsh")
    env = {"PATH": "/usr/bin:/bin", "LC_ALL": "C", "LANG": "C"}
    report = {"platform": platform.platform(), "cpu_affinity": sorted(os.sched_getaffinity(0)),
              "shells": shells, "locale": "C", "samples": args.samples, "cases": []}
    specs = [(op, n, 20000) for op in ("first", "middle", "last", "slice")
             for n in (10, 1000, 10000, 100000)]
    specs += [("append", 0, 16000), ("scalar", 10000, 20000),
              ("prefix", 100000, 20000), ("past-prefix", 100000, 20000)]
    for op, n, iterations in specs:
        times = [[], []]
        for sample in range(args.samples):
            for which in ((0, 1) if sample % 2 == 0 else (1, 0)):
                result = subprocess.run([shells[which], "-df", str(workload), op,
                                         str(n), str(iterations)], env=env,
                                        capture_output=True, text=True, check=True, timeout=120)
                times[which].append(float(result.stdout) * 1000)
        medians = [statistics.median(t) for t in times]
        case = {"operation": op, "size": n, "iterations": iterations,
                "samples_ms": times, "median_ms": medians,
                "speedup": medians[0] / medians[1]}
        report["cases"].append(case)
        print(f"{op:8} {n:6}: {medians[0]:9.3f} -> {medians[1]:9.3f} ms "
              f"({case['speedup']:.2f}x)", flush=True)
    args.output.parent.mkdir(parents=True, exist_ok=True)
    args.output.write_text(json.dumps(report, indent=2) + "\n")


if __name__ == "__main__":
    main()
