#!/usr/bin/env python3
"""Compare actual ZLE completion buffers around the null-marker scan cutoffs."""
import argparse
import hashlib
import json
from pathlib import Path
import subprocess
import tempfile


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("baseline", type=Path)
    parser.add_argument("candidate", type=Path)
    parser.add_argument("--output", type=Path, required=True)
    args = parser.parse_args()
    root = Path(__file__).resolve().parent.parent
    worker = root / "Perf/completion-prefix.zsh"
    sha = lambda p: hashlib.sha256(Path(p).read_bytes()).hexdigest()
    results, rows = [], []
    for shell in (args.baseline, args.candidate):
        shell = shell.resolve(strict=True)
        with tempfile.TemporaryDirectory(prefix="completion-prefix-", dir=root / ".work") as d:
            r = subprocess.run([str(shell), "-df", str(worker), str(root), str(shell)], cwd=d,
                               env={"PATH": "/usr/bin:/bin", "LC_ALL": "C.UTF-8"},
                               capture_output=True, timeout=120)
        if r.returncode or r.stderr or not r.stdout.endswith(b"checks=24\n"):
            raise RuntimeError((str(shell), r.returncode, r.stdout[-400:], r.stderr))
        results.append(r.stdout)
        rows.append({"shell": str(shell), "binary_sha256": sha(shell),
                     "checks": 24, "stdout_sha256": hashlib.sha256(r.stdout).hexdigest(),
                     "stdout": r.stdout.decode(), "status": 0})
    if results[0] != results[1]:
        raise RuntimeError("completed ZLE buffers differ")
    args.output.parent.mkdir(parents=True, exist_ok=True)
    args.output.write_text(json.dumps({"worker_sha256": sha(worker),
                                      "upstream_helper_sha256": sha(root / "Test/comptest"),
                                      "cases": rows, "differences": []}, indent=2) + "\n")
    print("24 PTY completion buffers match pristine Zsh")


if __name__ == "__main__":
    main()
