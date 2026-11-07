#!/usr/bin/env python3
"""Measure indexed array reads, slices and lengths without changing their representation."""
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
    parser.add_argument("--samples", type=int, default=9)
    parser.add_argument("--cpu", type=int)
    parser.add_argument("--output", type=Path, required=True)
    args = parser.parse_args()
    if args.samples < 3:
        parser.error("at least three samples are required")
    if args.cpu is not None:
        os.sched_setaffinity(0, {args.cpu})
    shells = [str(p.resolve(strict=True)) for p in (args.baseline, args.candidate)]
    worker = Path(__file__).resolve().with_name("array-length-workload.zsh")
    sha = lambda p: hashlib.sha256(Path(p).read_bytes()).hexdigest()
    report = {"shells": shells, "binary_sha256": [sha(p) for p in shells],
              "worker_sha256": sha(worker), "samples": args.samples,
              "locale": "C.UTF-8", "cpu_affinity": sorted(os.sched_getaffinity(0)),
              "cases": []}
    specs = [("read", 0, 1, 5000), ("length", 0, 0, 5000)]
    for size, iterations in [(8, 5000), (1000, 3000), (100000, 200)]:
        specs += [("read", size, p, iterations) for p in (1, size // 2, size, size + 1, -1)]
        specs += [("slice", size, size - 1, iterations), ("length", size, 0, iterations)]
    for operation, size, position, iterations in specs:
        samples = [[], []]
        for sample in range(args.samples):
            for which in ((0, 1) if sample % 2 == 0 else (1, 0)):
                r = subprocess.run([shells[which], "-df", str(worker), operation,
                                    str(size), str(position), str(iterations)],
                                   env={"PATH": "/usr/bin:/bin", "LC_ALL": "C.UTF-8"},
                                   capture_output=True, check=True, timeout=120)
                if r.stderr:
                    raise RuntimeError(r.stderr.decode(errors="replace"))
                samples[which].append(float(r.stdout) * 1000)
        medians = [statistics.median(s) for s in samples]
        case = {"operation": operation, "elements": size, "index": position,
                "iterations": iterations, "samples_ms": samples,
                "median_ms": medians, "speedup": medians[0] / medians[1]}
        report["cases"].append(case)
        print(f"{operation}/{size}/{position}: {medians[0]:.3f} -> {medians[1]:.3f} ms "
              f"({case['speedup']:.2f}x)", flush=True)
        args.output.parent.mkdir(parents=True, exist_ok=True)
        args.output.write_text(json.dumps(report, indent=2) + "\n")


if __name__ == "__main__":
    main()
