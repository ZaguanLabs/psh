"""Measure zcompile time or memory for customer libraries and word-length controls."""
import argparse
import hashlib
import json
import os
from pathlib import Path
import runpy
import selectors
import subprocess
import tempfile
import time


def digest(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def compile_once(shell, directory, files, dump, env, mode):
    command = [shell, "-dfc", 'zcompile -R "$@" || exit 1', "compile", dump, *files]
    if mode == "time":
        start = time.perf_counter_ns()
        result = subprocess.run(command, cwd=directory, env=env, capture_output=True,
                                check=True, timeout=60)
        elapsed = (time.perf_counter_ns() - start) / 1e6
        if result.stdout or result.stderr:
            raise ValueError(f"Unexpected compiler output: {result}")
        return {"ms": elapsed}

    command[2] += '\nprint -r -- done\nread -r -t 30 REPLY'
    with subprocess.Popen(command, cwd=directory, env=env, stdin=subprocess.PIPE,
                          stdout=subprocess.PIPE, stderr=subprocess.PIPE) as proc:
        try:
            with selectors.DefaultSelector() as ready:
                ready.register(proc.stdout, selectors.EVENT_READ)
                if not ready.select(60) or proc.stdout.readline() != b"done\n":
                    raise RuntimeError(f"Compiler failed to reach checkpoint: {shell}")
            observation = read_memory(proc.pid)
            stdout, stderr = proc.communicate(b"continue\n", timeout=10)
            if proc.returncode or stdout or stderr:
                raise ValueError(f"Unexpected compiler result: {proc.returncode}, {stderr!r}")
        finally:
            if proc.poll() is None:
                proc.kill()
    return {k: observation[k] for k in ("Anonymous", "Private", "Rss",
                                         "status_VmSize", "status_VmHWM")}


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("shell", type=Path, nargs="+")
    parser.add_argument("--labs", type=Path, required=True)
    parser.add_argument("--cpu", type=int, required=True)
    parser.add_argument("--mode", choices=("time", "memory"), required=True)
    parser.add_argument("--samples", type=int, required=True)
    parser.add_argument("--output", type=Path, required=True)
    args = parser.parse_args()
    shells = [p.resolve(strict=True) for p in args.shell]
    os.sched_setaffinity(0, {args.cpu})
    env = {"PATH": "/usr/bin:/bin", "LC_ALL": "C.UTF-8"}
    report = {"shells": {str(p): digest(p) for p in shells}, "cpu": args.cpu,
              "mode": args.mode, "environment": env, "cases": []}
    with tempfile.TemporaryDirectory() as scratch:
        work = Path(scratch)
        dump = work / "out.zwc"
        cases = []
        for project in ("zcoder.zsh", "zchat.zsh"):
            directory = (args.labs / project).resolve(strict=True)
            files = sorted(p.relative_to(directory) for p in (directory / "lib").glob("*.zsh"))
            if not files:
                raise ValueError(f"No library sources in {directory}")
            cases.append((project, directory, files))
        for length in (7, 15, 16, 31, 32, 127):
            source = work / f"words-{length}.zsh"
            source.write_text("words=(\n" + ("x" * length + "\n") * 32768 + ")\n")
            cases.append((source.stem, work, [Path(source.name)]))

        for case, directory, files in cases:
            row = {"case": case, "sources": {str(p): digest(directory / p) for p in files},
                   "samples": []}
            for sample in range(-1, args.samples):
                order = range(len(shells)) if sample % 2 == 0 else reversed(range(len(shells)))
                for host in order:
                    result = compile_once(shells[host], directory, files, dump, env, args.mode)
                    checksum = digest(dump)
                    if row.setdefault("dump_sha256", checksum) != checksum:
                        raise ValueError(f"Compiled output differs for {case}, {shells[host]}")
                    dump.unlink()
                    if sample >= 0:
                        row["samples"].append({"sample": sample, "host": host, **result})
            report["cases"].append(row)
    args.output.write_text(json.dumps(report, indent=2) + "\n")


if __name__ == "__main__":
    source = Path(__file__).resolve().parents[2] / "memory-checkpoints.py"
    read_memory = runpy.run_path(str(source))["memory"]
    main()
