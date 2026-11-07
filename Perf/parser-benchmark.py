#!/usr/bin/env python3
"""Measure offline parser calls with identical input bytes and verified output."""
import argparse
import hashlib
import json
import os
from pathlib import Path
import statistics
import subprocess
import tempfile


def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument("baseline", type=Path)
    p.add_argument("candidate", type=Path)
    for project in ("zhtml2md", "zjson", "zoup"):
        p.add_argument("--" + project, type=Path, required=True)
    p.add_argument("--cpu", type=int)
    p.add_argument("--samples", type=int, default=9)
    p.add_argument("--case", action="append", choices=("html-comment-1m", "html-prose-100k",
                   "json-repair-100k", "html-clean-128"), help="select individual controls")
    p.add_argument("--output", type=Path, required=True)
    args = p.parse_args()
    if args.samples < 3:
        p.error("at least three samples are required")
    if args.cpu is not None:
        os.sched_setaffinity(0, {args.cpu})
    shells = [str(s.resolve(strict=True)) for s in (args.baseline, args.candidate)]
    worker = Path(__file__).resolve().with_name("parser-workload.zsh")
    html_root, json_root, soup_root = (getattr(args, n).resolve(strict=True)
                                       for n in ("zhtml2md", "zjson", "zoup"))
    section = (b'<section class="card"><h2>Heading</h2><p>Hello '
               b'<a href="/next">world</a>.</p><img src="photo.jpg" '
               b'alt="A landscape"><script>ignore()</script></section>')
    # Repeat complete authored units. An existing generated corpus file may
    # end mid-element and is not a valid strict-conversion benchmark.
    prose_unit = (html_root / "bench/seeds/prose.html").read_bytes()
    copies, padding = divmod(102400, len(prose_unit))
    prose = prose_unit * copies + b" " * padding
    cases = [
        ("html-comment-1m", "html", html_root,
         b"<!--" + b"x" * 1048576 + b"--><p>retained</p>", b"retained\n", 3),
        ("html-prose-100k", "html", html_root, prose, None, 3),
        ("json-repair-100k", "repair", json_root,
         b"\xff" + b"x" * 99999, b'"\xef\xbf\xbd' + b"x" * 99999 + b'"', 3),
        ("html-clean-128", "clean", soup_root, section * 128, None, 3),
    ]
    if args.case:
        cases = [case for case in cases if case[0] in args.case]
    env = {"PATH": "/usr/bin:/bin", "LC_ALL": "C.UTF-8", "LANG": "C.UTF-8"}
    report = {"shells": shells, "cpu_affinity": sorted(os.sched_getaffinity(0)),
              "binary_sha256": [hashlib.sha256(Path(s).read_bytes()).hexdigest() for s in shells],
              "locale": "C.UTF-8", "samples": args.samples, "cases": []}
    with tempfile.TemporaryDirectory(prefix="psh-parser-") as temporary:
        scratch = Path(temporary)
        for label, operation, root, data, expected, iterations in cases:
            input_file, output_file = scratch / "input", scratch / "output"
            input_file.write_bytes(data)
            samples = [[], []]
            states = set()
            for sample in range(args.samples):
                for which in ((0, 1) if sample % 2 == 0 else (1, 0)):
                    result = subprocess.run([shells[which], "-df", str(worker), operation,
                                             str(root), str(input_file), str(output_file),
                                             str(iterations)], env=env, capture_output=True,
                                            check=True, timeout=120)
                    if result.stderr:
                        raise RuntimeError(result.stderr.decode(errors="replace"))
                    actual = output_file.read_bytes()
                    if expected is not None and actual != expected:
                        raise RuntimeError(f"{label}: incorrect output")
                    states.add(hashlib.sha256(actual).hexdigest())
                    samples[which].append(float(result.stdout) * 1000 / iterations)
            if len(states) != 1:
                raise RuntimeError(f"{label}: output differs")
            sources = (sorted((root / "lib").glob("*.zsh")) +
                       sorted((root / "functions").glob("*")) +
                       sorted(root.glob("*.zsh")))
            hashes = {str(f): hashlib.sha256(f.read_bytes()).hexdigest()
                      for f in sources if f.is_file()}
            medians = [statistics.median(s) for s in samples]
            report["cases"].append({"case": label, "input_bytes": len(data),
                                    "input_sha256": hashlib.sha256(data).hexdigest(),
                                    "output_bytes": len(actual), "output_sha256": states.pop(),
                                    "source_sha256": hashes, "samples_ms_per_call": samples,
                                    "iterations": iterations, "median_ms": medians,
                                    "speedup": medians[0] / medians[1]})
            print(f"{label}: {medians[0]:.3f} -> {medians[1]:.3f} ms/call "
                  f"({medians[0] / medians[1]:.2f}x); identical bytes", flush=True)
            # Retain completed samples even if a later workload fails.
            args.output.parent.mkdir(parents=True, exist_ok=True)
            args.output.write_text(json.dumps(report, indent=2) + "\n")
    args.output.parent.mkdir(parents=True, exist_ok=True)
    args.output.write_text(json.dumps(report, indent=2) + "\n")


if __name__ == "__main__":
    main()
