#!/usr/bin/env python3
"""Time indexed-array pattern searches, including offset and direction controls."""
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
    worker = Path(__file__).resolve().with_name("search-workload.zsh")
    env = {"PATH": "/usr/bin:/bin", "LC_ALL": "C.UTF-8"}
    report = {"shells": shells, "cpu_affinity": sorted(os.sched_getaffinity(0)),
              "locale": "C.UTF-8", "samples": args.samples,
              "worker_sha256": hashlib.sha256(worker.read_bytes()).hexdigest(),
              "binary_sha256": [hashlib.sha256(Path(s).read_bytes()).hexdigest() for s in shells],
              "cases": []}
    # name, size, match position (zero means absent), start, calls, result, direction
    specs = [
        ("tiny-first", 8, 1, 1, 20000, 1, "forward"),
        ("first", 100000, 1, 1, 2000, 1, "forward"),
        ("middle", 100000, 50000, 1, 20, 50000, "forward"),
        ("last", 100000, 100000, 1, 20, 100000, "forward"),
        ("missing", 100000, 0, 1, 20, 100001, "forward"),
        ("start-middle", 100000, 50000, 50000, 1000, 50000, "forward"),
        ("start-last", 100000, 100000, 100000, 1000, 100000, "forward"),
        ("start-beyond", 100000, 1, 100001, 1000, 100001, "forward"),
        ("negative-start", 100000, 100000, -1, 1000, 100000, "forward"),
        ("backward", 100000, 100000, -1, 1000, 100000, "backward"),
    ]
    for name, size, position, start, iterations, expected, direction in specs:
        samples = [[], []]
        for sample in range(args.samples):
            for which in ((0, 1) if sample % 2 == 0 else (1, 0)):
                r = subprocess.run([shells[which], "-df", str(worker), str(size),
                                     str(position), str(start), str(iterations),
                                     str(expected), direction], env=env,
                                    capture_output=True, check=True, timeout=120)
                if r.stderr:
                    raise RuntimeError(r.stderr.decode(errors="replace"))
                samples[which].append(float(r.stdout) * 1000)
        medians = [statistics.median(s) for s in samples]
        report["cases"].append({"name": name, "size": size, "position": position,
                                "start": start, "iterations": iterations,
                                "direction": direction, "expected": expected,
                                "samples_ms": samples, "median_ms": medians,
                                "speedup": medians[0] / medians[1]})
        print(f"{name:16}: {medians[0]:.3f} -> {medians[1]:.3f} ms "
              f"({medians[0] / medians[1]:.2f}x)", flush=True)
        args.output.parent.mkdir(parents=True, exist_ok=True)
        args.output.write_text(json.dumps(report, indent=2) + "\n")


if __name__ == "__main__":
    main()
