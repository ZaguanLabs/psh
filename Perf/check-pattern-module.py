#!/usr/bin/env python3
"""Verify pristine-header bounded pattern APIs and capture-offset reporting."""
import argparse
import hashlib
import json
from pathlib import Path
import subprocess


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("baseline", type=Path)
    parser.add_argument("candidate", type=Path)
    parser.add_argument("--output", required=True, type=Path)
    parser.add_argument("--memcheck", action="store_true")
    args = parser.parse_args()
    root = Path(__file__).resolve().parent.parent
    folder = root / ".work/pattern-module"
    folder.mkdir(exist_ok=True)
    source = root / "Perf/pattern-module.c"
    module = folder / "psh_pattern_fixture.so"
    command = ["cc", "-O2", "-g", "-shared", "-fPIC", "-DMODULE", "-DHAVE_CONFIG_H",
               "-I" + str(root / ".work/baseline/Src"),
               "-I" + str(root / ".work/pristine/Src"), str(source), "-o", str(module)]
    subprocess.run(command, check=True)
    script = '''emulate -R zsh
setopt extendedglob "$2"
module_path=("$1" $module_path)
zmodload psh_pattern_fixture || exit 1
match=(sentinel); mbegin=(99); mend=(99)
psh-pattern-check "$3" unqueued || exit 1
psh-pattern-check "$3" queued || exit 1
[[ $match[1] == sentinel && $mbegin[1] == 99 && $mend[1] == 99 ]] || exit 1
zmodload -u psh_pattern_fixture || exit 1
if whence psh-pattern-check >/dev/null; then exit 1; fi
exit 0
'''
    report = {"compile_command": command,
              "source_sha256": hashlib.sha256(source.read_bytes()).hexdigest(),
              "module_sha256": hashlib.sha256(module.read_bytes()).hexdigest(), "cases": []}
    args.output.parent.mkdir(parents=True, exist_ok=True)
    for index, shell in enumerate((args.baseline, args.candidate)):
        shell = shell.resolve(strict=True)
        for locale in ("C", "C.UTF-8"):
            for option in ("multibyte", "nomultibyte"):
                expected_width = "3" if locale == "C.UTF-8" and option == "multibyte" else "4"
                prefix = []
                if args.memcheck:
                    logfile = args.output.with_name(args.output.stem + f"-{index}-{locale}-{option}.memcheck.log")
                    prefix = ["valgrind", "--error-exitcode=97", "--leak-check=no",
                              "--log-file=" + str(logfile.resolve())]
                r = subprocess.run(prefix + [str(shell), "-dfc", script, "comparison", str(folder),
                                              option, expected_width],
                                   env={"PATH": "/usr/bin:/bin", "LC_ALL": locale},
                                   capture_output=True, timeout=300)
                if (r.returncode, r.stdout, r.stderr) != (0, b"checks=98\nchecks=98\n", b""):
                    raise RuntimeError((str(shell), locale, option, r.returncode, r.stdout, r.stderr))
                report["cases"].append({"shell": str(shell), "locale": locale, "option": option,
                                        "checks": 196, "queue_modes": ["unqueued", "queued"],
                                        "status": 0, "memcheck": args.memcheck,
                                        "binary_sha256": hashlib.sha256(shell.read_bytes()).hexdigest()})
                print(f"{shell.name}/{locale}/{option}: 196 bounded pattern API checks passed", flush=True)
    args.output.write_text(json.dumps(report, indent=2) + "\n")


if __name__ == "__main__":
    main()
