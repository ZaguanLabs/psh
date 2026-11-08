#!/usr/bin/env python3
"""Compare the arithmetic floating conversion, locale restoration and rounding."""
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
    parser.add_argument("--output", type=Path, required=True)
    parser.add_argument("--memcheck", action="store_true")
    parser.add_argument("--locale", action="append", dest="locales")
    parser.add_argument("--headers-build", type=Path, default=Path(".work/baseline"))
    parser.add_argument("--preload", type=Path)
    args = parser.parse_args()
    root = Path(__file__).resolve().parent.parent
    folder = args.output.resolve().parent / ("math-locale-fixture-" + args.output.stem)
    folder.mkdir(exist_ok=True, parents=True)
    source = root / "Perf/math-locale-module.c"
    module = folder / "psh_math_locale_fixture.so"
    command = ["cc", "-O2", "-g", "-shared", "-fPIC", "-DMODULE", "-DHAVE_CONFIG_H",
               "-I" + str(args.headers_build.resolve(strict=True) / "Src"),
               "-I" + str(root / ".work/pristine/Src"), str(source), "-o", str(module), "-lm"]
    subprocess.run(command, check=True)
    script = '''emulate -R zsh
module_path=("$1" $module_path)
zmodload psh_math_locale_fixture || exit 1
for fixture_locale in global fr_FR.UTF-8; do
  print -r -- "$fixture_locale"
  psh-math-locale-check "$fixture_locale" || exit 1
done
zmodload -u psh_math_locale_fixture || exit 1
if whence psh-math-locale-check >/dev/null; then exit 1; fi
exit 0
'''
    sha = lambda p: hashlib.sha256(p.read_bytes()).hexdigest()
    report = {"compile_command": command, "source_sha256": sha(source),
              "module_sha256": sha(module), "cases": []}
    if args.preload:
        report["preload_sha256"] = sha(args.preload)
    args.output.parent.mkdir(parents=True, exist_ok=True)
    results = {}
    for index, shell in enumerate((args.baseline, args.candidate)):
        shell = shell.resolve(strict=True)
        for locale in args.locales or ("C", "C.UTF-8", "fr_FR.UTF-8", "nb_NO.UTF-8", "tr_TR.UTF-8", "ja_JP.eucjp", "zh_CN.GB18030", "zh_TW.EUC-TW"):
            env = {"PATH": "/usr/bin:/bin", "LC_ALL": locale}
            if args.preload:
                env["LD_PRELOAD"] = str(args.preload.resolve(strict=True))
            charmap = subprocess.check_output(["locale", "charmap"], env=env, text=True).strip()
            prefix = []
            if args.memcheck:
                logfile = args.output.with_name(args.output.stem + f"-{index}-{locale}.memcheck.log")
                prefix = ["valgrind", "--error-exitcode=97", "--leak-check=no",
                          "--log-file=" + str(logfile.resolve())]
            r = subprocess.run(prefix + [str(shell), "-dfc", script, "comparison", str(folder)],
                               env=env,
                               capture_output=True, timeout=300)
            counts = [int(n) for n in re.findall(rb"(?m)^checks=(\d+) digest=\d+$", r.stdout)]
            if r.returncode or r.stderr or len(counts) != 2 or min(counts) <= 0:
                raise RuntimeError((str(shell), locale, r.returncode, r.stdout, r.stderr))
            if index and results[locale] != r.stdout:
                raise RuntimeError("math locale check results differ: " + locale)
            results[locale] = r.stdout
            report["cases"].append({"shell": str(shell), "locale": locale, "charmap": charmap,
                                    "checks": sum(counts), "status": 0, "memcheck": args.memcheck,
                                    "stdout": r.stdout.decode(), "binary_sha256": sha(shell)})
            print(f"{shell.name}/{locale}: {sum(counts)} math locale checks passed", flush=True)
    args.output.write_text(json.dumps(report, indent=2) + "\n")


if __name__ == "__main__":
    main()
