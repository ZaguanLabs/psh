#!/usr/bin/env python3
"""Compare fresh customer scene construction, checking every rendered output byte."""
import argparse
import datetime
import hashlib
import json
import os
from pathlib import Path
import re
import statistics
import subprocess
import time

SCENES = {"alpine": "vigil.zsh", "moonlit": "moonlit-vigil/main.zsh",
          "faerie": "faerie-pool/main.zsh", "profile": "profile-study/main.zsh",
          "per-arne": "per-arne/main.zsh", "emerald": "emerald-rings/main.zsh"}


def sha(path):
    return hashlib.sha256(Path(path).read_bytes()).hexdigest()


def source_hashes(project):
    # Active scene libraries and their mesh/palette inputs; exclude histories,
    # captures, caches and unrelated nested dependency/build trees.
    folders = [project / "lib", *(project / Path(entry).parent for entry in SCENES.values())]
    paths = {project / "vigil.zsh"}
    for folder in set(folders) - {project}:
        paths.update(folder.glob("*.zsh"))
        assets = folder / "assets"
        if assets.is_dir():
            paths.update(p for p in assets.rglob("*") if p.is_file())
    return {str(p.relative_to(project)): sha(p) for p in sorted(paths)}


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("baseline", type=Path)
    parser.add_argument("candidate", type=Path)
    parser.add_argument("--project", type=Path, required=True)
    parser.add_argument("--baseline-modules", type=Path)
    parser.add_argument("--candidate-modules", type=Path)
    parser.add_argument("--scene", choices=SCENES, action="append")
    parser.add_argument("--samples", type=int, default=5)
    parser.add_argument("--cpu", type=int)
    parser.add_argument("--output", type=Path, required=True)
    args = parser.parse_args()
    if args.samples < 3:
        parser.error("at least three measured samples are required")
    if args.cpu is not None:
        os.sched_setaffinity(0, {args.cpu})
    project = args.project.resolve(strict=True)
    worker = Path(__file__).with_name("scene-workload.zsh").resolve()
    shells = [p.resolve(strict=True) for p in (args.baseline, args.candidate)]
    modules = [p.resolve(strict=True) if p else None
               for p in (args.baseline_modules, args.candidate_modules)]
    inputs = source_hashes(project)
    binary_hashes = list(map(sha, shells))

    def environment(which):
        env = {"PATH": "/usr/local/bin:/usr/bin:/bin", "LC_ALL": "C.UTF-8",
               "LANG": "C.UTF-8", "TERM": "xterm-256color"}
        if modules[which]:
            env.update(ZDRAW_MODULE_DIR=str(modules[which]),
                       PSH_SCENE_MODULE_DIR=str(modules[which]))
        return env

    native_paths = []
    for which, shell in enumerate(shells):
        probe = subprocess.run([str(shell), "-dfc", 'source "$1/lib/runtime.zsh" || exit; '
                                'print -r -- "$Z3DFX_ZDRAW_BINARY"', "scene-probe", str(project)],
                               env=environment(which), capture_output=True, text=True, timeout=30)
        if probe.returncode or probe.stderr:
            raise RuntimeError(("native module probe", probe.returncode, probe.stderr))
        native_paths.append(Path(probe.stdout.strip()).resolve(strict=True))
    module_hashes = list(map(sha, native_paths))
    driver_hash, worker_hash = sha(__file__), sha(worker)
    report = {"date_utc": datetime.datetime.now(datetime.timezone.utc).isoformat(),
              "shells": list(map(str, shells)), "binary_sha256": binary_hashes,
              "module_paths": [str(p) if p else None for p in modules],
              "resolved_zdraw_paths": list(map(str, native_paths)),
              "zdraw_sha256": module_hashes, "source_sha256": inputs,
              "worker_sha256": worker_hash, "driver_sha256": driver_hash,
              "samples": args.samples, "cpu_affinity": sorted(os.sched_getaffinity(0)),
              "method": "serial alternating fresh processes, one excluded warmup per host/scene; "
                        "construction timer excludes sourcing and output serialization; "
                        "no cache; compare complete palette and material/depth pixels",
              "cases": []}
    args.output.parent.mkdir(parents=True, exist_ok=True)
    for name in args.scene or SCENES:
        elapsed, walls, expected, dimensions = [[], []], [[], []], None, None
        for trial in range(args.samples + 1):
            for which in ((0, 1) if trial % 2 == 0 else (1, 0)):
                env = environment(which)
                began = time.monotonic()
                run = subprocess.run([str(shells[which]), "-df", str(worker), str(project),
                                      SCENES[name]], env=env, capture_output=True, timeout=600)
                wall = time.monotonic() - began
                match = re.fullmatch(rb"PSH_SCENE ([\d.]+) (\d+) (\d+) (\d+) (\d+)\n", run.stderr)
                if run.returncode or match is None:
                    raise RuntimeError((name, str(shells[which]), run.returncode, run.stderr[-4000:]))
                if not run.stdout:
                    raise RuntimeError(name + ": no scene output")
                state = hashlib.sha256(run.stdout).hexdigest()
                shape = list(map(int, match.groups()[1:]))
                if expected is None:
                    expected, dimensions = state, shape
                if state != expected or shape != dimensions:
                    raise RuntimeError(name + ": rendered output differs")
                seconds = float(match[1])
                if trial:
                    elapsed[which].append(seconds)
                    walls[which].append(wall)
                print(f"{name} host={which} trial={trial} build={seconds:.6f}s", flush=True)
        medians = list(map(statistics.median, elapsed))
        report["cases"].append({"case": name, "entry": SCENES[name],
                                "samples_seconds": elapsed, "process_wall_seconds": walls,
                                "median_seconds": medians, "speedup": medians[0] / medians[1],
                                "width_height_triangles_colors": dimensions,
                                "output_sha256": expected})
        args.output.write_text(json.dumps(report, indent=2) + "\n")
        print(f"{name}: {medians[0]:.6f} -> {medians[1]:.6f}s ({medians[0]/medians[1]:.3f}x); exact output", flush=True)
    if (source_hashes(project) != inputs or list(map(sha, shells)) != binary_hashes or
            list(map(sha, native_paths)) != module_hashes or
            sha(__file__) != driver_hash or sha(worker) != worker_hash):
        raise RuntimeError("benchmark inputs changed during measurement")
    report["passed"] = True
    args.output.write_text(json.dumps(report, indent=2) + "\n")


if __name__ == "__main__":
    main()
