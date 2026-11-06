#!/usr/bin/env python3
"""Build one fixture against pristine headers and verify accessor/API behavior."""
import argparse
import hashlib
import json
import os
from pathlib import Path
import subprocess


def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument("baseline", type=Path)
    p.add_argument("candidate", type=Path)
    p.add_argument("--output", type=Path, required=True)
    p.add_argument("--search", action="store_true",
                   help="also verify pattern searches on custom getter snapshots")
    args = p.parse_args()
    root = Path(__file__).resolve().parent.parent
    module_dir = root / ".work/append-module"
    module_dir.mkdir(exist_ok=True)
    module = module_dir / "psh_append_fixture.so"
    source = root / "Perf/append-module.c"
    command = [os.environ.get("CC", "cc"), "-O2", "-g", "-shared", "-fPIC",
               "-DMODULE", "-DHAVE_CONFIG_H", "-I" + str(root / ".work/baseline/Src"),
               "-I" + str(root / ".work/pristine/Src"), str(source), "-o", str(module)]
    subprocess.run(command, check=True)
    expected = {
        "stable": b"gets=2 sets=1 values=[a][b][c][tail]\n",
        "changing": b"gets=2 sets=1 values=[a][tail][c]\n",
        "self-replacing": b"gets=1 sets=0 values=[a][tail][c]\n",
        "custom-setter": b"gets=0 sets=1 values=[a][b][c][tail]\n",
        "public-api": b"gets=1 sets=1 values=[a][api][c]\n",
    }
    script = '''emulate -R zsh
module_path=("$1" $module_path)
zmodload psh_append_fixture || exit 1
psh-array-fixture "$2" || exit 1
if [[ $2 != public-api ]]; then psh_fixture_array+=(tail); fi
psh-array-fixture report || exit 1
zmodload -u psh_append_fixture || exit 1
(( ! ${+psh_fixture_array} ))
'''
    shells = [str(s.resolve(strict=True)) for s in (args.baseline, args.candidate)]
    report = {"shells": shells, "compile_command": command,
              "source_sha256": hashlib.sha256(source.read_bytes()).hexdigest(),
              "module_sha256": hashlib.sha256(module.read_bytes()).hexdigest(), "cases": []}
    for mode, output in expected.items():
        results = []
        for shell in shells:
            r = subprocess.run([shell, "-dfc", script, "comparison", str(module_dir), mode],
                               env={"PATH": "/usr/bin:/bin", "LC_ALL": "C.UTF-8"},
                               capture_output=True, timeout=20)
            results.append((r.returncode, r.stdout, r.stderr))
        if results != [(0, output, b"")] * 2:
            raise RuntimeError(f"{mode}: {results!r}")
        report["cases"].append({"mode": mode, "status": 0, "stdout": output.decode()})
        print(mode + ": identical expected callbacks, values and cleanup", flush=True)
    if args.search:
        search_script = '''emulate -R zsh
module_path=("$1" $module_path)
zmodload psh_append_fixture || exit 1
psh-array-fixture "$2" || exit 1
case $3 in
  index) print -r -- "${psh_fixture_array[(i)c]}" ;;
  value) print -r -- "<${psh_fixture_array[(r)first]}>" ;;
  beyond) print -r -- "${psh_fixture_array[(ib:100:)c]}" ;;
esac
psh-array-fixture report || exit 1
zmodload -u psh_append_fixture || exit 1
(( ! ${+psh_fixture_array} ))
'''
        for mode in expected:
            short = mode in ("changing", "self-replacing")
            gets = 0 if mode == "custom-setter" else 2 if mode == "public-api" else 1
            sets = int(mode == "public-api")
            values = "[a][api][c]" if sets else "[a][b][c]"
            outputs = {"index": "2" if short else "3",
                       "value": "<first>" if short else "<>",
                       "beyond": "2" if short else "4"}
            for operation, result in outputs.items():
                # Value reads perform another getter call after locating the
                # index. A self-replacing getter is standard by that point.
                count = gets + int(operation == "value" and mode in
                                   ("stable", "changing", "public-api"))
                suffix = f"gets={count} sets={sets} values={values}\n"
                output = (result + "\n" + suffix).encode()
                results = []
                for shell in shells:
                    r = subprocess.run([shell, "-dfc", search_script, "comparison",
                                         str(module_dir), mode, operation],
                                       env={"PATH": "/usr/bin:/bin", "LC_ALL": "C.UTF-8"},
                                       capture_output=True, timeout=20)
                    results.append((r.returncode, r.stdout, r.stderr))
                if results != [(0, output, b"")] * 2:
                    raise RuntimeError(f"search/{mode}/{operation}: {results!r}")
                report["cases"].append({"mode": mode, "operation": operation,
                                        "status": 0, "stdout": output.decode()})
                print(f"search/{mode}/{operation}: expected snapshot and callbacks", flush=True)
    args.output.parent.mkdir(parents=True, exist_ok=True)
    args.output.write_text(json.dumps(report, indent=2) + "\n")


if __name__ == "__main__":
    main()
