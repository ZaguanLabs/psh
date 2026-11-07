#!/usr/bin/env python3
"""Time actual customer project functions, with exact state and expected-result checks."""
import argparse
import hashlib
import json
import os
from pathlib import Path
import statistics
import subprocess


CASES = [
    ("coder-paste", "labs", "zcoder.zsh", 1),
    ("coder-layout", "labs", "zcoder.zsh", 2),
    ("coder-wide-layout", "labs", "zcoder.zsh", 2),
    ("chat-paste", "labs", "zchat.zsh", 1),
    ("chat-layout", "labs", "zchat.zsh", 2),
    ("chat-wide-layout", "labs", "zchat.zsh", 2),
    ("endgame-world", "challenge", "endgame", 2),
    ("mario-race", "challenge", "z3dfx.mario", 120),
    ("shooter-step", "challenge", "z3dfx", 60),
    ("shooter-step", "challenge", "z3dfx.agy", 60),
    ("shooter-step", "challenge", "z3dfx.grok", 60),
    ("fetch-encode", "labs", "zfetch", 3),
    ("drawing-binning", "challenge", "z3dfx.drawing", 3),
]


def source_hashes(root):
    # Hash the passive sources used by these kernels. No launcher or native
    # module is loaded; no live service configuration is read.
    paths = list((root / "lib").glob("*.zsh")) + list((root / "levels").glob("*.zsh"))
    return {str(p.relative_to(root)): hashlib.sha256(p.read_bytes()).hexdigest()
            for p in sorted(paths)}


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("baseline", type=Path)
    parser.add_argument("candidate", type=Path)
    parser.add_argument("--labs", type=Path, required=True)
    parser.add_argument("--challenge", type=Path, required=True)
    parser.add_argument("--samples", type=int, default=9)
    parser.add_argument("--cpu", type=int)
    parser.add_argument("--case", action="append", help="project/operation; repeat to select cases")
    parser.add_argument("--output", type=Path, required=True)
    args = parser.parse_args()
    if args.samples < 3:
        parser.error("at least three samples are required")
    if args.cpu is not None:
        os.sched_setaffinity(0, {args.cpu})
    shells = [p.resolve(strict=True) for p in (args.baseline, args.candidate)]
    worker = Path(__file__).resolve().with_name("customer-workload.zsh")
    env = {"PATH": "/usr/bin:/bin", "LC_ALL": "C.UTF-8", "LANG": "C.UTF-8"}
    sha = lambda p: hashlib.sha256(p.read_bytes()).hexdigest()
    report = {"shells": list(map(str, shells)), "binary_sha256": list(map(sha, shells)),
              "worker_sha256": sha(worker), "samples": args.samples, "environment": env,
              "cpu_affinity": sorted(os.sched_getaffinity(0)), "cases": []}
    selected = {f"{project}/{op}" for op, _, project, _ in CASES}
    if args.case:
        if set(args.case) - selected:
            parser.error("unknown cases: " + ", ".join(sorted(set(args.case) - selected)))
        selected = set(args.case)
    for operation, group, project, iterations in CASES:
        label = f"{project}/{operation}"
        if label not in selected:
            continue
        root = (getattr(args, group) / project).resolve(strict=True)
        hashes = source_hashes(root)
        samples, states = [[], []], set()
        for sample in range(args.samples):
            for which in ((0, 1) if sample % 2 == 0 else (1, 0)):
                r = subprocess.run([str(shells[which]), "-df", str(worker), operation,
                                    str(root), str(iterations)], env=env, capture_output=True,
                                   timeout=120)
                if r.returncode or r.stderr:
                    raise RuntimeError((label, str(shells[which]), r.returncode,
                                        r.stdout[-200:], r.stderr[-2000:]))
                elapsed, state = r.stdout.split(b"\n", 1)
                if not state:
                    raise RuntimeError(label + ": missing state")
                samples[which].append(float(elapsed) * 1000)
                states.add(hashlib.sha256(state).hexdigest())
        if len(states) != 1:
            raise RuntimeError(label + ": project state differs")
        if source_hashes(root) != hashes:
            raise RuntimeError(label + ": project sources changed during measurement")
        medians = [statistics.median(s) for s in samples]
        report["cases"].append({"case": label, "project_root": str(root),
                                "source_sha256": hashes, "iterations": iterations,
                                "samples_ms_per_batch": samples, "median_ms": medians,
                                "speedup": medians[0] / medians[1], "state_sha256": states.pop()})
        print(f"{label}: {medians[0]:.3f} -> {medians[1]:.3f} ms/batch "
              f"({medians[0]/medians[1]:.2f}x); identical state", flush=True)
        args.output.parent.mkdir(parents=True, exist_ok=True)
        args.output.write_text(json.dumps(report, indent=2) + "\n")


if __name__ == "__main__":
    main()
