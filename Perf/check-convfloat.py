#!/usr/bin/env python3
"""Compare float output with the pristine native converter and its callback states."""
import argparse
import hashlib
import json
from pathlib import Path
import re
import subprocess


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("baseline", type=Path)
    parser.add_argument("candidate", type=Path)
    parser.add_argument("--headers-build", type=Path, required=True)
    parser.add_argument("--headers-source", type=Path, default=Path(".work/pristine"))
    parser.add_argument("--candidate-headers-build", type=Path)
    parser.add_argument("--candidate-headers-source", type=Path)
    parser.add_argument("--locale", action="append")
    parser.add_argument("--quick", action="store_true")
    parser.add_argument("--memcheck", action="store_true")
    parser.add_argument("--fault", choices=["none", "newlocale", "enter"], default="none")
    parser.add_argument("--expect-candidate-faults", action="store_true")
    parser.add_argument("--linked-faults-candidate", action="store_true")
    parser.add_argument("--output", type=Path, required=True)
    args = parser.parse_args()
    root = Path(__file__).resolve().parent
    args.output.parent.mkdir(parents=True, exist_ok=True)
    args.output.unlink(missing_ok=True)
    folder = args.output.resolve().with_suffix("")
    folder.mkdir(exist_ok=True)
    source, oracle = root / "convfloat-module.c", root / "convfloat-reference.h"
    sha = lambda p: hashlib.sha256(Path(p).read_bytes()).hexdigest()
    modules, commands = [], []
    for host, (build, headers) in enumerate([
            (args.headers_build, args.headers_source),
            (args.candidate_headers_build or args.headers_build,
             args.candidate_headers_source or args.headers_source)]):
        module_dir = folder / str(host)
        module_dir.mkdir(exist_ok=True)
        module = module_dir / "psh_float_output_fixture.so"
        command = ["cc", "-O2", "-g", "-shared", "-fPIC", "-DMODULE", "-DHAVE_CONFIG_H",
                   "-I" + str(build.resolve(strict=True) / "Src"),
                   "-I" + str(headers.resolve(strict=True) / "Src"),
                   str(source), "-o", str(module), "-lm", "-ldl"]
        subprocess.run(command, check=True)
        modules.append(module)
        commands.append(command)
    preload = None
    if args.fault != "none":
        preload = folder / "fault.so"
        subprocess.run(["cc", "-O2", "-g", "-shared", "-fPIC", str(root / "convfloat-fault.c"),
                        "-ldl", "-o", str(preload)], check=True)
    shells = [p.resolve(strict=True) for p in (args.baseline, args.candidate)]
    binary_hashes = list(map(sha, shells))
    fingerprints = {str(p): sha(p) for p in [Path(__file__), source, oracle, root / "convfloat-fault.c"]}
    script = ('module_path=("$1" $module_path); zmodload psh_float_output_fixture || exit 1; '
              'for fixture_locale in global C fr_FR.UTF-8; do '
              'psh-float-output-check "$fixture_locale" "$2" || exit 1; done; '
              'zmodload -u psh_float_output_fixture || exit 1')
    report = {"passed": False, "shells": list(map(str, shells)), "shell_sha256": binary_hashes,
              "source_sha256": fingerprints, "compile_commands": commands,
              "module_sha256": list(map(sha, modules)), "fault": args.fault,
              "memcheck": args.memcheck, "quick": args.quick,
              "linked_faults_candidate": args.linked_faults_candidate, "runs": []}
    observations = {}
    for host, shell in enumerate(shells):
        for locale in args.locale or ["C", "C.UTF-8", "fr_FR.UTF-8", "nb_NO.UTF-8", "tr_TR.UTF-8"]:
            env = {"PATH": "/usr/bin:/bin", "LC_ALL": locale, "PSH_PRINTF_FAULT": args.fault}
            if preload and not (host and args.linked_faults_candidate):
                env["LD_PRELOAD"] = str(preload)
            prefix = []
            if args.memcheck:
                log = folder / f"{host}-{locale}.memcheck.log"
                prefix = ["valgrind", "--quiet", "--error-exitcode=99", "--leak-check=no",
                          "--log-file=" + str(log)]
            command = prefix + [str(shell), "-dfc", script, "float-output", str(modules[host].parent),
                                "quick" if args.quick else "full"]
            run = subprocess.run(command, env=env, capture_output=True, timeout=600)
            rows = re.findall(rb"(?m)^checks=(\d+) digest=(\d+) faults=(\d+)$", run.stdout)
            if run.returncode or run.stderr or len(rows) != 3 or any(int(r[0]) == 0 for r in rows):
                raise RuntimeError((host, locale, run.returncode, run.stdout, run.stderr))
            result = [(int(n), int(d)) for n, d, _ in rows]
            if not host:
                observations[locale] = result
            elif observations[locale] != result:
                raise RuntimeError((locale, "converter results differ", observations[locale], result))
            faults = [int(r[2]) for r in rows]
            if host and args.expect_candidate_faults and not max(faults):
                raise RuntimeError("fault injection did not reach the candidate")
            report["runs"].append({"host": host, "locale": locale, "status": 0,
                                   "checks": sum(n for n, _ in result), "faults": faults,
                                   "stdout": run.stdout.decode()})
            print(host, locale, report["runs"][-1]["checks"], "matched", flush=True)
    assert list(map(sha, shells)) == binary_hashes
    assert {str(p): sha(p) for p in map(Path, fingerprints)} == fingerprints
    report["passed"] = True
    args.output.write_text(json.dumps(report, indent=2) + "\n")


if __name__ == "__main__":
    main()
