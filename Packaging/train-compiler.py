#!/usr/bin/env python3
"""Train an isolated compiler build using checked, bundled, offline workloads."""
import argparse
import hashlib
import json
import os
from pathlib import Path
import subprocess
import time


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--shell", type=Path, required=True)
    parser.add_argument("--modules", type=Path, required=True)
    parser.add_argument("--output", type=Path, required=True)
    args = parser.parse_args()
    root = Path(__file__).resolve().parent.parent
    shell, modules = args.shell.resolve(strict=True), args.modules.resolve(strict=True)
    driver = Path(__file__).resolve()
    generic = root / "Perf/compiler-training.zsh"
    application = root / "Perf/application-workload.zsh"
    inputs = [driver, generic, application, root / "Vendor/sources.json",
              root / "Vendor/zjson/zjson.zsh", *sorted((root / "Vendor/zjson/lib").glob("*.zsh"))]
    sha = lambda p: hashlib.sha256(p.read_bytes()).hexdigest()
    fingerprints = {str(p.relative_to(root)): sha(p) for p in inputs}
    digest = sha(shell)
    env = {"PATH": "/usr/bin:/bin", "LC_ALL": "C.UTF-8", "TERM": "xterm-256color"}
    wrapper = 'module_path=("$1" "${module_path[@]}"); shift; source "$@"'
    cases = [("core", [generic, root / "Vendor/zjson"])]
    cases += [(name, [application, name, root / "Vendor/zjson", "3"])
              for name in ("zjson-array", "zjson-encode-array", "zjson")]
    rows = []
    for name, arguments in cases:
        command = [str(shell), "-dfc", wrapper, "psh-compiler-training", str(modules), *map(str, arguments)]
        began = time.monotonic()
        result = subprocess.run(command, env=env, capture_output=True, timeout=180)
        if result.returncode or result.stderr:
            raise RuntimeError((name, result.returncode, result.stderr[-3000:]))
        if not result.stdout:
            raise RuntimeError(name + ": training produced no checked result")
        rows.append({"case": name, "command": command, "status": result.returncode,
                     "seconds": round(time.monotonic() - began, 3),
                     "stdout_sha256": hashlib.sha256(result.stdout).hexdigest()})
        print(name, "passed", flush=True)
    if sha(shell) != digest or {str(p.relative_to(root)): sha(p) for p in inputs} != fingerprints:
        raise RuntimeError("training inputs changed")
    report = {"passed": True, "shell_sha256": digest, "input_sha256": fingerprints,
              "environment": env, "runs": rows,
              "scope": "bundled offline core and JSON training; customer scenes and simulations are held out"}
    args.output.write_text(json.dumps(report, indent=2) + "\n")


if __name__ == "__main__":
    main()
