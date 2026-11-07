#!/usr/bin/env python3
"""Measure scalar assignments, including reset costs and small/large controls."""
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
    parser.add_argument("--boundaries", action="store_true",
                        help="include short inputs around the null-marker scan cutoff")
    args = parser.parse_args()
    if args.samples < 3:
        parser.error("at least three samples are required")
    if args.cpu is not None:
        os.sched_setaffinity(0, {args.cpu})
    shells = [str(p.resolve(strict=True)) for p in (args.baseline, args.candidate)]
    worker = Path(__file__).resolve().with_name("scalar-write-workload.zsh")
    sha = lambda p: hashlib.sha256(Path(p).read_bytes()).hexdigest()
    report = {"shells": shells, "binary_sha256": [sha(p) for p in shells],
              "worker_sha256": sha(worker), "samples": args.samples,
              "locale": "C.UTF-8", "cpu_affinity": sorted(os.sched_getaffinity(0)),
              "cases": []}
    specs = [("replace", "ascii", 16, 8, 5000),
             ("replace", "ascii", 16, 1000000, 100),
             ("replace", "ascii", 100000, 1000000, 100),
             ("replace", "unicode", 16, 100000, 200),
             ("replace", "nul", 16, 100000, 200),
             ("replace", "invalid", 16, 100000, 200),
             ("replace", "byte", 16, 1000000, 100),
             ("append", "ascii", 1000000, 32, 100),
             ("prepend", "ascii", 1000000, 32, 100),
             ("replace", "ascii", 1000000, 0, 100),
             ("replace", "ascii", 1000000, 1, 100),
             ("whole", "ascii", 16, 1000000, 100)]
    if args.boundaries:
        specs += [("whole", "ascii", 16, n, 5000)
                  for n in (31, 32, 63, 64, 65, 127, 128, 255, 256, 512, 575, 576, 577, 1024, 1087, 1088, 1089, 2048, 4096)]
    for operation, unit, initial, supplied, iterations in specs:
        samples = [[], []]
        for sample in range(args.samples):
            for which in ((0, 1) if sample % 2 == 0 else (1, 0)):
                r = subprocess.run([shells[which], "-df", str(worker), operation, unit,
                                    str(initial), str(supplied), str(iterations)],
                                   env={"PATH": "/usr/bin:/bin", "LC_ALL": "C.UTF-8"},
                                   capture_output=True, check=True, timeout=120)
                if r.stderr:
                    raise RuntimeError(r.stderr.decode(errors="replace"))
                samples[which].append(float(r.stdout) * 1000)
        medians = [statistics.median(s) for s in samples]
        case = {"operation": operation, "unit": unit, "initial_characters": initial,
                "replacement_characters": supplied, "iterations": iterations,
                "samples_ms": samples, "median_ms": medians,
                "speedup": medians[0] / medians[1]}
        report["cases"].append(case)
        print(f"{operation}/{unit}/{initial}/{supplied}: "
              f"{medians[0]:.3f} -> {medians[1]:.3f} ms ({case['speedup']:.2f}x)", flush=True)
        args.output.parent.mkdir(parents=True, exist_ok=True)
        args.output.write_text(json.dumps(report, indent=2) + "\n")


if __name__ == "__main__":
    main()
