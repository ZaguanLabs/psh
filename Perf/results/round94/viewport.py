"""Alternate pinned comparisons of zcoder viewport updates and verify complete state."""
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
    parser.add_argument("--shell", type=Path, required=True, action="append")
    parser.add_argument("--project", type=Path, required=True)
    parser.add_argument("--cpu", type=int, required=True)
    parser.add_argument("--output", type=Path, required=True)
    args = parser.parse_args()
    shells = [s.resolve(strict=True) for s in args.shell]
    project = args.project.resolve(strict=True)
    worker = Path(__file__).resolve().with_name("viewport.zsh")
    paths = [*shells, worker, Path(__file__), project/"lib/input.zsh", project/"lib/util.zsh"]
    identity = {str(p): sha(p) for p in paths}
    os.sched_setaffinity(0, {args.cpu})
    env = {"PATH": "/usr/bin:/bin", "LC_ALL": "C.UTF-8"}
    cases = []
    for chars, kind in [(64, "ascii"), (10000, "ascii"), (10000, "wide")]:
        samples = [[] for shell in shells]
        state = None
        for rep in range(12):
            offset = rep // 2 % len(shells)
            order = list(range(len(shells)))
            order = order[offset:] + order[:offset]
            for host in (order[::-1] if rep % 2 else order):
                r = subprocess.run([shells[host], "-df", worker, project, str(chars), kind, "64"],
                                   env=env, capture_output=True, timeout=60, check=True)
                elapsed, data = r.stdout.split(b"\n", 1)
                if r.stderr or not data or (state is not None and state != data):
                    raise RuntimeError(f"Unexpected viewport state on {shells[host]}")
                state = data
                samples[host].append(1000 * float(elapsed))
        cases.append(dict(chars=chars, kind=kind, samples_ms=samples, median_ms=list(map(median, samples)),
                          state_sha256=hashlib.sha256(state).hexdigest()))
    if identity != {str(p): sha(p) for p in paths}:
        raise RuntimeError("Measurement inputs changed")
    args.output.write_text(json.dumps(dict(shells=list(map(str, shells)), inputs=identity, cpu=args.cpu,
                                          environment=env, updates=128, cases=cases), indent=2) + "\n")


if __name__ == "__main__":
    main()
