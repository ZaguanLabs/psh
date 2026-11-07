#!/usr/bin/env python3
"""Check public pointer-array length APIs, including exact ends and wrapped bounds."""
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
    folder = root / ".work/array-length-module"
    folder.mkdir(exist_ok=True)
    source = root / "Perf/array-length-module.c"
    module = folder / "psh_array_length_fixture.so"
    command = ["cc", "-O2", "-g", "-shared", "-fPIC", "-DMODULE", "-DHAVE_CONFIG_H",
               "-I" + str(root / ".work/baseline/Src"),
               "-I" + str(root / ".work/pristine/Src"), str(source), "-o", str(module)]
    subprocess.run(command, check=True)
    script = '''emulate -R zsh
module_path=("$1" $module_path)
zmodload psh_array_length_fixture || exit 1
psh-array-length-check || exit 1
zmodload -u psh_array_length_fixture || exit 1
if whence psh-array-length-check >/dev/null; then exit 1; fi
exit 0
'''
    sha = lambda p: hashlib.sha256(Path(p).read_bytes()).hexdigest()
    report = {"compile_command": command, "source_sha256": sha(source),
              "module_sha256": sha(module), "cases": []}
    args.output.parent.mkdir(parents=True, exist_ok=True)
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
            if (r.returncode, r.stdout, r.stderr) != (0, b"checks=125660\n", b""):
                raise RuntimeError((str(shell), locale, r.returncode, r.stdout, r.stderr))
            report["cases"].append({"shell": str(shell), "locale": locale,
                                    "checks": 125660, "status": 0, "memcheck": args.memcheck,
                                    "binary_sha256": sha(shell)})
            print(f"{shell.name}/{locale}: 125660 length checks passed", flush=True)
    args.output.write_text(json.dumps(report, indent=2) + "\n")


if __name__ == "__main__":
    main()
