#!/usr/bin/env python3
"""Measure array list-append length reuse and related control operations."""
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
    args = p.parse_args()
    if args.samples < 3:
        p.error("at least three samples are required")
    if args.cpu is not None:
        os.sched_setaffinity(0, {args.cpu})
    shells = [str(s.resolve(strict=True)) for s in (args.baseline, args.candidate)]
    worker = Path(__file__).resolve().with_name("append-workload.zsh")
    env = {"PATH": "/usr/bin:/bin", "LC_ALL": "C.UTF-8", "LANG": "C.UTF-8"}
    report = {"shells": shells, "cpu_affinity": sorted(os.sched_getaffinity(0)),
              "locale": "C.UTF-8", "samples": args.samples,
              "worker_sha256": hashlib.sha256(worker.read_bytes()).hexdigest(),
              "binary_sha256": [hashlib.sha256(Path(s).read_bytes()).hexdigest() for s in shells],
              "cases": []}
    specs = [("list", 0, n) for n in (32, 4000, 16000, 32000)]
    specs += [("list", 10000, 4000), ("batch", 0, 4000),
              ("scalar", 0, 16000), ("unique", 0, 1000),
              ("duplicates", 0, 4000), ("tied", 0, 2000),
              ("replace", 10000, 20000)]
    for operation, initial, iterations in specs:
        samples = [[], []]
        for sample in range(args.samples):
            for which in ((0, 1) if sample % 2 == 0 else (1, 0)):
                r = subprocess.run([shells[which], "-df", str(worker), operation,
                                     str(initial), str(iterations)], env=env,
                                    capture_output=True, check=True, timeout=120)
                if r.stderr:
                    raise RuntimeError(r.stderr.decode(errors="replace"))
                samples[which].append(float(r.stdout) * 1000)
        medians = [statistics.median(s) for s in samples]
        report["cases"].append({"operation": operation, "initial": initial,
                                "iterations": iterations, "samples_ms": samples,
                                "median_ms": medians, "speedup": medians[0] / medians[1]})
        print(f"{operation:10} initial={initial:5} calls={iterations:5}: "
              f"{medians[0]:.3f} -> {medians[1]:.3f} ms ({medians[0] / medians[1]:.2f}x)",
              flush=True)
        args.output.parent.mkdir(parents=True, exist_ok=True)
        args.output.write_text(json.dumps(report, indent=2) + "\n")


if __name__ == "__main__":
    main()
