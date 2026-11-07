#!/usr/bin/env python3
"""Compare in-place token conversion, including mutable classification and mapping."""
import argparse
import hashlib
import json
from pathlib import Path
import subprocess


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("baseline", type=Path)
    parser.add_argument("candidate", type=Path)
    parser.add_argument("--output", type=Path, required=True)
    parser.add_argument("--memcheck", action="store_true")
    args = parser.parse_args()
    root = Path(__file__).resolve().parent.parent
    folder = root / ".work/untokenize-module"
    folder.mkdir(exist_ok=True)
    source = root / "Perf/untokenize-module.c"
    module = folder / "psh_untokenize_fixture.so"
    command = ["cc", "-O2", "-g", "-shared", "-fPIC", "-DMODULE", "-DHAVE_CONFIG_H",
               "-I" + str(root / ".work/baseline/Src"),
               "-I" + str(root / ".work/pristine/Src"), str(source), "-o", str(module)]
    subprocess.run(command, check=True)
    script = '''emulate -R zsh
module_path=("$1" $module_path)
zmodload psh_untokenize_fixture || exit 1
psh-untokenize-check || exit 1
zmodload -u psh_untokenize_fixture || exit 1
if whence psh-untokenize-check >/dev/null; then exit 1; fi
exit 0
'''
    sha = lambda p: hashlib.sha256(Path(p).read_bytes()).hexdigest()
    report = {"compile_command": command, "source_sha256": sha(source),
              "module_sha256": sha(module), "cases": []}
    args.output.parent.mkdir(parents=True, exist_ok=True)
    reference = {}
    for index, shell in enumerate((args.baseline, args.candidate)):
        shell = shell.resolve(strict=True)
        for locale in ("C", "C.UTF-8"):
            prefix = []
            if args.memcheck:
                logfile = args.output.with_name(args.output.stem + f"-{index}-{locale}.memcheck.log")
                prefix = ["valgrind", "--error-exitcode=97", "--leak-check=no",
                          "--log-file=" + str(logfile.resolve())]
            r = subprocess.run(prefix + [str(shell), "-dfc", script, "comparison", str(folder)],
                               env={"PATH": "/usr/bin:/bin", "LC_ALL": locale},
                               capture_output=True, timeout=300)
            if r.returncode or r.stderr or not r.stdout.endswith(b"checks=78732\n"):
                raise RuntimeError((str(shell), locale, r.returncode, r.stdout[-100:], r.stderr))
            if index == 0:
                reference[locale] = r.stdout
            elif r.stdout != reference[locale]:
                raise RuntimeError(f"{locale}: resulting allocation bytes differ")
            report["cases"].append({"shell": str(shell), "locale": locale, "checks": 78732,
                                    "status": 0, "memcheck": args.memcheck,
                                    "binary_sha256": sha(shell),
                                    "stdout_sha256": hashlib.sha256(r.stdout).hexdigest(),
                                    "stdout_bytes": len(r.stdout)})
            print(f"{shell.name}/{locale}: 78732 token-conversion checks passed", flush=True)
    args.output.write_text(json.dumps(report, indent=2) + "\n")


if __name__ == "__main__":
    main()
