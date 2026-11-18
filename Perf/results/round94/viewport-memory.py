"""Measure glibc allocator and Linux mapping sizes during verified zcoder viewport updates."""
import argparse
import hashlib
import json
from pathlib import Path
import runpy
import selectors
import subprocess


MEMORY_DRIVER = Path(__file__).resolve().parents[2] / "memory-checkpoints.py"
memory = runpy.run_path(str(MEMORY_DRIVER))["memory"]


def measure(shell, module, worker, project):
    command = [shell, "-df", worker, project, "10000", "wide", "64", module]
    env = {"PATH": "/usr/bin:/bin", "LC_ALL": "C.UTF-8"}
    proc = subprocess.Popen(command, env=env, stdin=subprocess.PIPE, stdout=subprocess.PIPE,
                            stderr=subprocess.PIPE)
    points = []
    try:
        with selectors.DefaultSelector() as selector:
            selector.register(proc.stdout, selectors.EVENT_READ)
            for phase in ("wrapped", "reused", "small"):
                if not selector.select(60):
                    raise RuntimeError(f"{shell} timed out before {phase}")
                fields = proc.stdout.readline().decode().split()
                if len(fields) != 5 or fields[0] != phase:
                    raise RuntimeError(f"{shell} failed at {phase}: {fields}")
                arena, used, free, mmapped = map(int, fields[1:])
                sample = memory(proc.pid, heap_mapping=True)
                heap_kib = {k: sample["heap_" + k] for k in ("Size", "Rss")}
                whole = {k: sample[k] for k in ("Anonymous", "Rss", "Private_Clean", "Private_Dirty")}
                points.append(dict(phase=phase, arena_bytes=arena, used_bytes=used, free_bytes=free,
                                   mmap_bytes=mmapped, heap_kib=heap_kib, process_kib=whole))
                proc.stdin.write(b"\n")
                proc.stdin.flush()
        out, err = proc.communicate(timeout=60)
        if err or proc.returncode or not out:
            raise RuntimeError((command, proc.returncode, err))
        _, state = out.split(b"\n", 1)
        if not state:
            raise RuntimeError("Missing final layout state")
        return points, hashlib.sha256(state).hexdigest()
    finally:
        if proc.poll() is None:
            proc.kill()
        proc.wait()
        proc.stdin.close()
        proc.stdout.close()
        proc.stderr.close()


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--build", type=Path, nargs=2, action="append", required=True,
                        metavar=("SHELL", "MODULE_DIR"))
    parser.add_argument("--project", type=Path, required=True)
    parser.add_argument("--output", type=Path, required=True)
    args = parser.parse_args()
    worker = Path(__file__).resolve().with_name("viewport.zsh")
    builds = [(p.resolve(strict=True), d.resolve(strict=True)) for p, d in args.build]
    files = [MEMORY_DRIVER, worker, Path(__file__), args.project/"lib/input.zsh", args.project/"lib/util.zsh"]
    for shell, folder in builds:
        files.extend((shell, folder/"literal_probe.so"))
    def hashes():
        return {str(p): hashlib.sha256(p.read_bytes()).hexdigest() for p in files}
    identity = hashes()
    rows = []
    expected = None
    for repeat in range(6):
        offset = repeat // 2 % len(builds)
        order = builds[offset:] + builds[:offset]
        for shell, folder in (reversed(order) if repeat % 2 else order):
            points, state = measure(shell, folder, worker, args.project.resolve(strict=True))
            if expected is not None and state != expected:
                raise RuntimeError("Layout states differ")
            expected = state
            rows.append(dict(shell=str(shell), repeat=repeat, points=points))
    if identity != hashes():
        raise RuntimeError("Measurement inputs changed")
    args.output.write_text(json.dumps(dict(inputs=identity, state_sha256=expected, runs=rows), indent=2)+"\n")


if __name__ == "__main__":
    main()
