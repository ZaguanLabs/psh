"""Measure verified paste operations with the workload sourced by a parent shell."""
import argparse
import hashlib
import json
import os
from pathlib import Path
from statistics import median
import subprocess


def sha(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--shell", type=Path, action="append", required=True)
    parser.add_argument("--labs", type=Path, required=True)
    parser.add_argument("--cpu", type=int, required=True)
    parser.add_argument("--output", type=Path, required=True)
    args = parser.parse_args()
    shells = [p.resolve(strict=True) for p in args.shell]
    os.sched_setaffinity(0, {args.cpu})
    worker = Path(__file__).resolve().parents[2] / "customer-workload.zsh"
    env = {"PATH": "/usr/bin:/bin", "LC_ALL": "C.UTF-8"}
    report = {"shells": {str(p): sha(p) for p in shells}, "worker_sha256": sha(worker),
              "cpu": args.cpu, "environment": env, "cases": []}
    for app, operation in (("zchat.zsh", "chat-paste"), ("zcoder.zsh", "coder-paste")):
        project = (args.labs / app).resolve(strict=True)
        sources = {str(p): sha(project / p) for p in (Path("lib/input.zsh"), Path("lib/util.zsh"))}
        samples = [[] for _ in shells]
        expected = None
        for sample in range(12):
            order = list(range(len(shells)))
            offset = (sample // 2) % len(shells)
            order = order[offset:] + order[:offset]
            if sample % 2:
                order.reverse()
            for host in order:
                run = subprocess.run([shells[host], "-dfc", 'source "$@"', "caller",
                                      worker, operation, project, "1"], env=env,
                                     capture_output=True, check=True, timeout=60)
                elapsed, state = run.stdout.split(b"\n", 1)
                if run.stderr or not state or (expected is not None and state != expected):
                    raise ValueError(f"Unexpected output for {operation} on {shells[host]}")
                expected = state
                samples[host].append(float(elapsed) * 1000)
        if sources != {p: sha(project / p) for p in sources}:
            raise ValueError(f"Customer sources changed during {operation}")
        report["cases"].append({"case": operation, "sources": sources, "samples_ms": samples,
                                "median_ms": [median(values) for values in samples],
                                "state_sha256": hashlib.sha256(expected).hexdigest()})
    args.output.write_text(json.dumps(report, indent=2) + "\n")


if __name__ == "__main__":
    main()
