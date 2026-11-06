#!/usr/bin/env python3
"""Check bounded metafied lengths through one pristine-header native fixture."""
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
    folder = root / ".work/ztrsub-module"
    folder.mkdir(exist_ok=True)
    source = root / "Perf/ztrsub-module.c"
    module = folder / "psh_ztrsub_fixture.so"
    command = ["cc", "-O2", "-g", "-shared", "-fPIC", "-DMODULE", "-DHAVE_CONFIG_H",
               "-I" + str(root / ".work/baseline/Src"),
               "-I" + str(root / ".work/pristine/Src"), str(source), "-o", str(module)]
    subprocess.run(command, check=True)
    script = '''emulate -R zsh
module_path=("$1" $module_path)
zmodload psh_ztrsub_fixture || exit 1
psh-ztrsub-check || exit 1
zmodload -u psh_ztrsub_fixture || exit 1
if whence psh-ztrsub-check >/dev/null; then exit 1; fi
exit 0
'''
    report = {"compile_command": command,
              "source_sha256": hashlib.sha256(source.read_bytes()).hexdigest(),
              "module_sha256": hashlib.sha256(module.read_bytes()).hexdigest(),
              "cases": []}
    args.output.parent.mkdir(parents=True, exist_ok=True)
    for index, shell in enumerate((args.baseline, args.candidate)):
        shell = shell.resolve(strict=True)
        for locale in ("C", "C.UTF-8"):
            prefix = []
            if args.memcheck:
                logfile = args.output.with_name(args.output.stem + f"-{index}-{locale}.memcheck.log")
                prefix = ["valgrind", "--error-exitcode=97", "--leak-check=no",
                          "--log-file=" + str(logfile.resolve())]
            result = subprocess.run(prefix + [str(shell), "-dfc", script, "comparison", str(folder)],
                                    env={"PATH": "/usr/bin:/bin", "LC_ALL": locale},
                                    capture_output=True, timeout=300)
            if (result.returncode, result.stdout, result.stderr) != (0, b"checks=132615\n", b""):
                raise RuntimeError((str(shell), locale, result.returncode, result.stdout, result.stderr))
            report["cases"].append({"shell": str(shell), "locale": locale, "checks": 132615,
                                    "status": 0, "memcheck": args.memcheck,
                                    "binary_sha256": hashlib.sha256(shell.read_bytes()).hexdigest()})
            print(f"{shell.name}/{locale}: 132615 bounded spans and module cleanup passed", flush=True)
    args.output.write_text(json.dumps(report, indent=2) + "\n")


if __name__ == "__main__":
    main()
