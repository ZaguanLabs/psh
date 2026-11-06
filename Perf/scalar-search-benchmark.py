#!/usr/bin/env python3
"""Measure scalar search length elision with offset, direction and byte controls."""
import argparse
import hashlib
import json
import os
from pathlib import Path
import statistics
import subprocess


def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument("baseline", type=Path)
    p.add_argument("candidate", type=Path)
    p.add_argument("--samples", type=int, default=9)
    p.add_argument("--cpu", type=int)
    p.add_argument("--output", type=Path, required=True)
    p.add_argument("--mixed", action="store_true",
                   help="add alternating ASCII/Unicode and Unicode-to-ASCII controls")
    args = p.parse_args()
    if args.samples < 3:
        p.error("at least three samples are required")
    if args.cpu is not None:
        os.sched_setaffinity(0, {args.cpu})
    shells = [str(s.resolve(strict=True)) for s in (args.baseline, args.candidate)]
    worker = Path(__file__).resolve().with_name("scalar-search-workload.zsh")
    env = {"PATH": "/usr/bin:/bin", "LC_ALL": "C.UTF-8"}
    report = {"shells": shells, "cpu_affinity": sorted(os.sched_getaffinity(0)),
              "locale": "C.UTF-8", "samples": args.samples,
              "worker_sha256": hashlib.sha256(worker.read_bytes()).hexdigest(),
              "binary_sha256": [hashlib.sha256(Path(s).read_bytes()).hexdigest() for s in shells],
              "cases": []}
    # name, operation, unit, multibyte option, characters, match, start, calls, result
    specs = [
        ("tiny-first", "index", "ascii", "multibyte", 16, 1, 1, 5000, 1),
        ("ascii-first", "index", "ascii", "multibyte", 100000, 1, 1, 100, 1),
        ("unicode-first", "index", "unicode", "multibyte", 100000, 1, 1, 100, 1),
        ("nul-first", "index", "nul", "multibyte", 100000, 1, 1, 100, 1),
        ("invalid-first", "index", "invalid", "multibyte", 100000, 1, 1, 100, 1),
        ("byte-first", "index", "ascii", "nomultibyte", 100000, 1, 1, 100, 1),
        ("ascii-middle", "index", "ascii", "multibyte", 2000, 1000, 1, 5, 1000),
        ("ascii-last", "index", "ascii", "multibyte", 2000, 1995, 1, 5, 1995),
        ("ascii-missing", "index", "ascii", "multibyte", 2000, 0, 1, 5, 2001),
        ("range-first", "range", "ascii", "multibyte", 100000, 1, 1, 100, 0),
        ("offset-zero", "offset", "ascii", "multibyte", 100000, 1, 0, 100, 1),
        ("offset-middle", "offset", "ascii", "multibyte", 100000, 50000, 50000, 100, 50000),
        ("offset-beyond", "offset", "ascii", "multibyte", 100000, 1, 100001, 100, 100001),
        ("negative-start", "offset", "ascii", "multibyte", 100000, 99995, -6, 100, 99995),
        ("backward", "backward", "ascii", "multibyte", 2000, 1995, 1, 5, 1995),
    ]
    if args.mixed:
        specs += [("mixed-first", "index", "mixed", "multibyte", 100000, 1, 1, 100, 1),
                  ("post-unicode", "index", "post-unicode", "multibyte", 100000, 1, 1, 100, 1)]
    for name, operation, unit, mb_option, size, position, start, iterations, expected in specs:
        samples = [[], []]
        for sample in range(args.samples):
            for which in ((0, 1) if sample % 2 == 0 else (1, 0)):
                r = subprocess.run([shells[which], "-df", str(worker), operation,
                                     unit, mb_option, str(size), str(position), str(start),
                                     str(iterations), str(expected)], env=env,
                                    capture_output=True, check=True, timeout=120)
                if r.stderr:
                    raise RuntimeError(r.stderr.decode(errors="replace"))
                samples[which].append(float(r.stdout) * 1000)
        medians = [statistics.median(s) for s in samples]
        report["cases"].append({"name": name, "operation": operation, "unit": unit,
                                "multibyte": mb_option, "characters": size,
                                "position": position, "start": start,
                                "iterations": iterations, "expected": expected,
                                "samples_ms": samples, "median_ms": medians,
                                "speedup": medians[0] / medians[1]})
        print(f"{name:16}: {medians[0]:.3f} -> {medians[1]:.3f} ms "
              f"({medians[0] / medians[1]:.2f}x)", flush=True)
        args.output.parent.mkdir(parents=True, exist_ok=True)
        args.output.write_text(json.dumps(report, indent=2) + "\n")


if __name__ == "__main__":
    main()
