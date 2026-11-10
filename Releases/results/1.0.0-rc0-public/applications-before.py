#!/usr/bin/env python3
"""Time offline application kernels and compare their resulting shell state."""
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
    p.add_argument("--zjson", type=Path, required=True)
    p.add_argument("--z3dfx", type=Path, required=True)
    p.add_argument("--samples", type=int, default=9)
    p.add_argument("--cpu", type=int)
    p.add_argument("--output", type=Path, required=True)
    p.add_argument("--arrays", action="store_true",
                   help="include decoded-array parsing and encoding")
    args = p.parse_args()
    if args.samples < 3:
        p.error("at least three samples are required")
    if args.cpu is not None:
        os.sched_setaffinity(0, {args.cpu})
    shells = [str(s.resolve(strict=True)) for s in (args.baseline, args.candidate)]
    script = Path(__file__).resolve().with_name("application-workload.zsh")
    env = {"PATH": "/usr/bin:/bin", "LC_ALL": "C.UTF-8", "LANG": "C.UTF-8"}
    report = {"shells": shells, "cpu_affinity": sorted(os.sched_getaffinity(0)),
              "binary_sha256": [hashlib.sha256(Path(s).read_bytes()).hexdigest() for s in shells],
              "worker_sha256": hashlib.sha256(script.read_bytes()).hexdigest(),
              "samples": args.samples, "environment": env,
              "locale": "C.UTF-8", "cases": []}
    cases = [("zjson", args.zjson, 3), ("navigation", args.z3dfx, 10)]
    if args.arrays:
        cases = [("zjson-array", args.zjson, 1),
                 ("zjson-encode-array", args.zjson, 1)] + cases
    for operation, root, iterations in cases:
        root = root.resolve(strict=True)
        sources = sorted((root / "lib").glob("*.zsh"))
        sources += ([root / "zjson.zsh"] if operation.startswith("zjson") else
                    [root / "levels/relay.zsh"])
        hashes = {str(f): hashlib.sha256(f.read_bytes()).hexdigest() for f in sources}
        samples = [[], []]
        states = set()
        for sample in range(args.samples):
            for which in ((0, 1) if sample % 2 == 0 else (1, 0)):
                result = subprocess.run([shells[which], "-df", str(script), operation,
                                         str(root), str(iterations)], env=env,
                                        capture_output=True, check=True, timeout=120)
                if result.stderr:
                    raise RuntimeError(result.stderr.decode(errors="replace"))
                elapsed, state = result.stdout.split(b"\n", 1)
                samples[which].append(float(elapsed) * 1000 / iterations)
                states.add(hashlib.sha256(state).hexdigest())
        if len(states) != 1:
            raise RuntimeError(f"{operation}: application state differs")
        if hashes != {str(f): hashlib.sha256(f.read_bytes()).hexdigest() for f in sources}:
            raise RuntimeError(f"{operation}: application sources changed")
        medians = [statistics.median(s) for s in samples]
        report["cases"].append({"operation": operation, "source_sha256": hashes,
                                "samples_ms_per_call": samples, "median_ms": medians,
                                "state_sha256": states.pop(), "iterations": iterations})
        print(f"{operation}: {medians[0]:.3f} -> {medians[1]:.3f} ms/call; "
              "identical state", flush=True)
    args.output.parent.mkdir(parents=True, exist_ok=True)
    if report["binary_sha256"] != [hashlib.sha256(Path(s).read_bytes()).hexdigest() for s in shells]:
        raise RuntimeError("application benchmark binaries changed")
    args.output.write_text(json.dumps(report, indent=2) + "\n")


if __name__ == "__main__":
    main()
