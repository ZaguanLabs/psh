#!/usr/bin/env python3
"""Compare verified customer kernels using Linux user-space hardware counters."""
import argparse
import hashlib
import importlib.util
import json
import os
from pathlib import Path
import statistics
import subprocess


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("baseline", type=Path)
    parser.add_argument("candidate", type=Path)
    parser.add_argument("--labs", type=Path, required=True)
    parser.add_argument("--challenge", type=Path, required=True)
    parser.add_argument("--cpu", type=int, required=True)
    parser.add_argument("--samples", type=int, default=9)
    parser.add_argument("--case", action="append", dest="cases")
    parser.add_argument("--output", type=Path, required=True)
    args = parser.parse_args()
    if args.samples < 3:
        parser.error("at least three samples are required")
    root = Path(__file__).resolve().parent.parent
    spec = importlib.util.spec_from_file_location("customer", root / "Perf/customer-benchmark.py")
    customer = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(customer)
    sha = lambda p: hashlib.sha256(Path(p).read_bytes()).hexdigest()
    os.sched_setaffinity(0, {args.cpu})
    folder = args.output.resolve().parent / ("hardware-fixture-" + args.output.stem)
    folder.mkdir(exist_ok=True, parents=True)
    launcher = folder / "count-command"
    source = root / "Perf/count-command.c"
    compile_command = ["cc", "-O2", "-g", "-Wall", "-Wextra", "-Werror", str(source), "-o", str(launcher)]
    subprocess.run(compile_command, check=True)
    shells = [str(p.resolve(strict=True)) for p in (args.baseline, args.candidate)]
    worker = root / "Perf/customer-workload.zsh"
    env = {"PATH": "/usr/bin:/bin", "LC_ALL": "C.UTF-8", "LANG": "C.UTF-8"}
    specs = [(f"{project}/{op}", op, getattr(args, group) / project, n)
             for op, group, project, n in customer.CASES]
    requested = set(args.cases or ["z3dfx.mario/mario-race", "endgame/endgame-world",
                    "z3dfx.drawing/drawing-binning", "zcoder.zsh/coder-paste"])
    if requested - {row[0] for row in specs}:
        parser.error("unknown case: " + str(requested - {row[0] for row in specs}))
    report = {"shells": shells, "binary_sha256": [sha(p) for p in shells],
              "worker_sha256": sha(worker), "launcher_sha256": sha(launcher),
              "launcher_source_sha256": sha(source), "compile_command": compile_command,
              "environment": env, "cpu_affinity": sorted(os.sched_getaffinity(0)),
              "samples": args.samples, "scope": "user space, exec through exit, inherited tasks",
              "cases": []}
    for label, operation, project, n in specs:
        if label not in requested:
            continue
        project = project.resolve(strict=True)
        sources = customer.source_hashes(project)
        values, states = [[], []], set()
        for sample in range(args.samples):
            for which in ((0, 1) if sample % 2 == 0 else (1, 0)):
                path = folder / "counters.json"
                command = [str(launcher), str(path), shells[which], "-df", str(worker),
                           operation, str(project), str(n)]
                result = subprocess.run(command, env=env, capture_output=True, timeout=180)
                if result.returncode or result.stderr:
                    raise RuntimeError((command, result.returncode, result.stderr))
                counters = json.loads(path.read_text())
                if counters["exit_status"] or any(e["running_ns"] / e["enabled_ns"] < .95
                                                   for e in counters["events"]):
                    raise RuntimeError("counter scheduling/worker failure: " + str(counters))
                elapsed, state = result.stdout.split(b"\n", 1)
                states.add(hashlib.sha256(state).hexdigest())
                counters["warm_batch_ms"] = float(elapsed) * 1000
                counters["command"] = command
                values[which].append(counters)
        if len(states) != 1 or sources != customer.source_hashes(project):
            raise RuntimeError("output/source drift: " + label)
        medians = []
        for samples in values:
            medians.append({name: statistics.median(next(e["value"] * e["enabled_ns"] / e["running_ns"]
                    for e in r["events"] if e["name"] == name) for r in samples)
                    for name in ("cycles", "instructions", "branches", "branch_misses")})
        report["cases"].append({"case": label, "source_sha256": sources,
            "state_sha256": states.pop(), "iterations": n, "measurements": values,
            "median_scaled_events": medians})
        print(f"{label}: cycles {medians[0]['cycles']:.0f} -> {medians[1]['cycles']:.0f}; "
              f"instructions {medians[0]['instructions']:.0f} -> {medians[1]['instructions']:.0f}", flush=True)
    if report["binary_sha256"] != [sha(p) for p in shells] or report["worker_sha256"] != sha(worker) or \
            report["launcher_source_sha256"] != sha(source):
        raise RuntimeError("measurement inputs changed")
    args.output.write_text(json.dumps(report, indent=2) + "\n")


if __name__ == "__main__":
    main()
