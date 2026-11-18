"""Time indirect reads of ASCII and Unicode identifiers on each supplied shell."""
import argparse
import hashlib
import json
import os
from pathlib import Path
from statistics import median
import subprocess


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--shell", type=Path, action="append", required=True)
    parser.add_argument("--cpu", type=int, required=True)
    parser.add_argument("--output", type=Path, required=True)
    args = parser.parse_args()
    os.sched_setaffinity(0, {args.cpu})
    shells = [p.resolve(strict=True) for p in args.shell]
    script = Path(__file__).resolve().with_name("lookup.zsh")
    env = {"LC_ALL": "C.UTF-8", "PATH": "/usr/bin:/bin"}
    report = {"sha256": {str(p): hashlib.sha256(p.read_bytes()).hexdigest()
                         for p in [*shells, script]}, "environment": env,
              "cpu": args.cpu, "cases": []}
    for case in ("short", "ascii", "wide", "mixed", "boundary"):
        values = {str(p): [] for p in shells}
        expected = None
        for sample in range(9):
            start = sample % len(shells)
            order = shells[start:] + shells[:start]
            for shell in order:
                run = subprocess.run([shell, "-df", script, case], env=env,
                                     capture_output=True, check=True, timeout=60)
                elapsed, state = run.stdout.split(b"\n", 1)
                if run.stderr or not state or (expected is not None and expected != state):
                    raise ValueError(f"{case}: unexpected output from {shell}")
                expected = state
                values[str(shell)].append(1000 * float(elapsed))
        report["cases"].append({"case": case, "samples_ms": values,
                                "median_ms": {k: median(v) for k, v in values.items()},
                                "state_sha256": hashlib.sha256(expected).hexdigest()})
    args.output.write_text(json.dumps(report, indent=2) + "\n")


if __name__ == "__main__":
    main()
