"""Measure a shell with pending arithmetic reads, then verify its result."""
import argparse
import hashlib
import json
import runpy
import selectors
import subprocess
from pathlib import Path

WORKER = Path(__file__).with_name("operands.zsh").resolve()
DRIVER = WORKER.parents[2] / "memory-checkpoints.py"
memory = runpy.run_path(str(DRIVER))["memory"]


def sample(shell, terms):
    env = {"PATH": "/usr/bin:/bin", "LC_ALL": "C.UTF-8"}
    with subprocess.Popen([shell, "-df", WORKER, str(terms)], stdin=subprocess.PIPE,
                          stdout=subprocess.PIPE, stderr=subprocess.PIPE, env=env) as proc:
        try:
            points = {}
            with selectors.DefaultSelector() as sel:
                sel.register(proc.stdout, selectors.EVENT_READ)
                for phase in ("ready", "live", "after"):
                    if not sel.select(30) or proc.stdout.readline().strip() != phase.encode():
                        raise RuntimeError(f"{shell} failed to reach {phase}")
                    points[phase] = memory(proc.pid, heap_mapping=True)
                    proc.stdin.write(b"\n")
                    proc.stdin.flush()
            out, err = proc.communicate(timeout=30)
            if proc.returncode or err or out != f"{terms+1}\n".encode():
                raise ValueError((shell, terms, out, err))
            return points
        finally:
            if proc.poll() is None:
                proc.kill()


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("shells", type=Path, nargs="+")
    parser.add_argument("--output", type=Path, required=True)
    args = parser.parse_args()
    builds = [p.resolve(strict=True) for p in args.shells]
    inputs = {str(p): hashlib.sha256(p.read_bytes()).hexdigest() for p in
              [*builds, WORKER, DRIVER, Path(__file__)]}
    runs = []
    for terms in (64, 8192, 65536):
        for rep in range(6):
            start = (rep // 2) % len(builds)
            order = builds[start:] + builds[:start]
            for shell in (reversed(order) if rep % 2 else order):
                runs.append(dict(shell=str(shell), terms=terms, sample=rep, points=sample(shell, terms)))
    args.output.write_text(json.dumps(dict(units="KiB", inputs=inputs, runs=runs), indent=2) + "\n")


if __name__ == "__main__":
    main()
