#!/usr/bin/env python3
"""Count successful private anonymous mmap requests for zcoder workloads on Linux."""

import argparse
import collections
import hashlib
import json
import os
from pathlib import Path
import subprocess
import tempfile


def counts(trace):
    sizes = collections.Counter()
    unmaps = 0
    with trace.open() as lines:
        for line in lines:
            if (line.startswith("mmap(") and "MAP_PRIVATE" in line
                    and "MAP_ANONYMOUS" in line and " = 0x" in line):
                sizes[int(line.split(",", 2)[1])] += 1
            elif line.startswith("munmap(") and line.rstrip().endswith("= 0"):
                unmaps += 1
    if not sizes:
        raise ValueError("strace recorded no successful anonymous private mappings")
    return {"by_length": dict(sorted(sizes.items())), "anonymous_private_maps": sizes.total(),
            "cumulative_requested_bytes": sum(size * count for size, count in sizes.items()),
            "successful_unmaps": unmaps}


def hashes(inputs):
    return {str(p): hashlib.sha256(p.read_bytes()).hexdigest() for p in inputs if p.is_file()}


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--shell", type=Path, action="append", required=True)
    parser.add_argument("--zcoder", type=Path, required=True)
    parser.add_argument("--output", type=Path, required=True)
    args = parser.parse_args()
    perf = Path(__file__).resolve().parent
    project = str(args.zcoder.resolve(strict=True))
    worker = str(perf / "customer-workload.zsh")
    transcript = str(perf / "named-shift-workload.zsh")
    cases = {"paste": [worker, "coder-paste", project, "1"],
             "wide-layout": [worker, "coder-wide-layout", project, "2"],
             "transcript": [transcript, "transcript", "65536", "3", project],
             "skill-fold": [worker, "coder-skill-fold", project, "200"]}
    shells = [str(shell.resolve(strict=True)) for shell in args.shell]
    inputs = [Path(path) for path in [*shells, worker, transcript]]
    for stem in ("lib/util", "lib/input", "lib/skills", "lib/transcript", "vendor/zjson/zjson"):
        source = Path(project) / (stem + ".zsh")
        inputs.append(source.resolve(strict=True))
        compiled = source.with_suffix(".zsh.zwc")
        if compiled.is_file():
            inputs.append(compiled)

    env = {"LC_ALL": "C.UTF-8", "PATH": "/usr/bin:/bin"}
    report = {"page_size": os.sysconf("SC_PAGE_SIZE"), "sha256": hashes(inputs),
              "environment": env, "runs": []}
    with tempfile.TemporaryDirectory() as tmp:
        trace = Path(tmp) / "trace"
        for case, workload in cases.items():
            expected = None
            for shell in shells:
                command = [shell, "-df", *workload]
                result = subprocess.run(["strace", "-qq", "-e", "trace=mmap,munmap",
                                         "-o", str(trace), *command], env=env,
                                        capture_output=True, timeout=180, check=True)
                _, _, state = result.stdout.partition(b"\n")
                if result.stderr or not state or (expected is not None and expected != state):
                    raise ValueError(f"{shell} {case} failed output comparison: {result.stderr!r}")
                expected = state
                report["runs"].append({"case": case, "shell": shell, "command": command,
                                       "state_sha256": hashlib.sha256(state).hexdigest(),
                                       **counts(trace)})
    if hashes(inputs) != report["sha256"]:
        raise ValueError("input files changed during profiling")
    args.output.write_text(json.dumps(report, indent=2) + "\n")


if __name__ == "__main__":
    main()
