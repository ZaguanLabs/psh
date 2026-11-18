"""Sample the Linux stack mapping before, during and after nested shell functions."""
import argparse
import json
import re
import selectors
import subprocess
from pathlib import Path

WORKER = """
FUNCNEST=400
nested() {
    if (( $1 )); then
        nested $(( $1 - 1 ))
    else
        print inside
        read -r REPLY
    fi
}
print ready
read -r REPLY || exit 1
nested "$1" || exit 1
print returned
read -r REPLY
"""


def sample(shell, depth):
    process = subprocess.Popen([shell, "-dfc", WORKER, "probe", str(depth)],
                               env={"PATH": "/usr/bin:/bin", "LC_ALL": "C"},
                               stdin=subprocess.PIPE, stdout=subprocess.PIPE)
    points = {}
    try:
        with selectors.DefaultSelector() as selector:
            selector.register(process.stdout, selectors.EVENT_READ)
            for phase in ("ready", "inside", "returned"):
                if not selector.select(10) or process.stdout.readline().strip() != phase.encode():
                    raise RuntimeError(f"{shell} failed to reach {phase} at depth {depth}")
                maps = Path(f"/proc/{process.pid}/smaps").read_text()
                stack = re.search(r"(?m)^\S+-\S+ .*\[stack\]\n((?:[A-Z][^\n]*\n)+)", maps)
                points[phase] = {name: int(value) for name, value in re.findall(
                    r"(?m)^(Size|Rss|Private_Dirty):\s+(\d+) kB$", stack[1])}
                process.stdin.write(b"\n")
                process.stdin.flush()
        if process.wait(timeout=10):
            raise RuntimeError(f"{shell} failed at depth {depth}")
        return points
    finally:
        process.kill()
        process.wait()
        process.stdin.close()
        process.stdout.close()


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--shell", type=Path, required=True, action="append")
    parser.add_argument("--output", type=Path, required=True)
    args = parser.parse_args()
    shells = [str(path.resolve(strict=True)) for path in args.shell]
    rows = []
    for depth in (32, 128, 256):
        for repeat in range(6):
            order = shells[repeat // 2:] + shells[:repeat // 2]
            for shell in (reversed(order) if repeat % 2 else order):
                rows.append(dict(depth=depth, repeat=repeat, shell=shell,
                                 stack_kib=sample(shell, depth)))
    args.output.write_text(json.dumps(rows, indent=2) + "\n")


if __name__ == "__main__":
    main()
