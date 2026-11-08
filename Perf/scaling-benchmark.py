#!/usr/bin/env python3
"""Measure input-size scaling of actual zjson validation and array encoding."""
import argparse
import hashlib
import json
import os
from pathlib import Path
import statistics
import subprocess


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("shell", type=Path)
    parser.add_argument("--zjson", type=Path, required=True)
    parser.add_argument("--cpu", type=int, required=True)
    parser.add_argument("--samples", type=int, default=5)
    parser.add_argument("--output", type=Path, required=True)
    args = parser.parse_args()
    if args.samples < 3:
        parser.error("at least three samples are required")
    os.sched_setaffinity(0, {args.cpu})
    sha = lambda p: hashlib.sha256(Path(p).read_bytes()).hexdigest()
    shell, project = args.shell.resolve(strict=True), args.zjson.resolve(strict=True)
    worker = Path(__file__).resolve().with_name("scaling-workload.zsh")
    files = [project / "zjson.zsh", *sorted((project / "lib").glob("*.zsh"))]
    sources = {str(p.relative_to(project)): sha(p) for p in files}
    env = {"PATH": "/usr/bin:/bin", "LC_ALL": "C.UTF-8", "LANG": "C.UTF-8"}
    report = {"shell": str(shell), "binary_sha256": sha(shell), "worker_sha256": sha(worker),
              "source_sha256": sources, "environment": env, "samples": args.samples,
              "cpu_affinity": sorted(os.sched_getaffinity(0)), "cases": []}
    for operation in ["validate", "encode"]:
        for size in [250, 500, 1000, 2000, 4000]:
            values = []
            for sample in range(args.samples):
                r = subprocess.run([str(shell), "-df", str(worker), operation, str(project), str(size)],
                    env=env, capture_output=True, timeout=120)
                assert r.returncode == 0 and not r.stderr, (r.returncode, r.stderr)
                elapsed, state = r.stdout.split(b"\n", 1)
                assert state == f"{operation}/{size}/ok\n".encode()
                values.append(float(elapsed) * 1000)
            median = statistics.median(values)
            report["cases"].append({"operation": operation, "items": size,
                                   "samples_ms": values, "median_ms": median})
            print(operation, size, f"{median:.3f} ms", flush=True)
    assert report["binary_sha256"] == sha(shell) and report["worker_sha256"] == sha(worker)
    assert sources == {str(p.relative_to(project)): sha(p) for p in files}
    args.output.parent.mkdir(parents=True, exist_ok=True)
    args.output.write_text(json.dumps(report, indent=2) + "\n")


if __name__ == "__main__":
    main()
