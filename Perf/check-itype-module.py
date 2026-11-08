#!/usr/bin/env python3
"""Compare the public character classifier with the original release implementation."""
import argparse
import hashlib
import json
from pathlib import Path
import re
import subprocess


def main():
    root = Path(__file__).resolve().parent.parent
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("baseline", type=Path)
    parser.add_argument("candidate", type=Path)
    parser.add_argument("--output", type=Path, required=True)
    parser.add_argument("--memcheck", action="store_true")
    parser.add_argument("--locale", action="append", dest="locales")
    parser.add_argument("--headers-build", type=Path, default=root / ".work/baseline")
    parser.add_argument("--headers-source", type=Path, default=root / ".work/pristine")
    args = parser.parse_args()
    folder = root / ".work/itype-module"
    folder.mkdir(exist_ok=True)
    source = root / "Perf/itype-module.c"
    module = folder / "psh_itype_fixture.so"
    command = ["cc", "-O2", "-g", "-shared", "-fPIC", "-DMODULE", "-DHAVE_CONFIG_H",
               "-I" + str(args.headers_build.resolve(strict=True) / "Src"),
               "-I" + str(args.headers_source.resolve(strict=True) / "Src"), str(source), "-o", str(module)]
    subprocess.run(command, check=True)
    script = '''emulate -R zsh
module_path=("$1" $module_path)
zmodload psh_itype_fixture || exit 1
for mb in multibyte nomultibyte; do
  for posix in posixidentifiers noposixidentifiers; do
    setopt $mb $posix
    for config in default changed; do
      if [[ $config == default ]]; then
        unset IFS WORDCHARS
      else
        IFS=" :$2" WORDCHARS="_-$2"
      fi
      print -r -- "$mb/$posix/$config"
      psh-itype-check || exit 1
    done
  done
done
zmodload -u psh_itype_fixture || exit 1
if whence psh-itype-check >/dev/null; then exit 1; fi
exit 0
'''
    sha = lambda p: hashlib.sha256(p.read_bytes()).hexdigest()
    report = {"compile_command": command, "source_sha256": sha(source),
              "reference_sha256": sha(root / "Perf/itype-reference.c"),
              "module_sha256": sha(module), "cases": []}
    args.output.parent.mkdir(parents=True, exist_ok=True)
    results = {}
    for index, shell in enumerate((args.baseline, args.candidate)):
        shell = shell.resolve(strict=True)
        for locale in args.locales or ("C", "C.UTF-8"):
            env = {"PATH": "/usr/bin:/bin", "LC_ALL": locale}
            charmap = subprocess.check_output(["locale", "charmap"], env=env, text=True).strip()
            wide = b"" if charmap == "ANSI_X3.4-1968" else subprocess.check_output(
                ["iconv", "-f", "UTF-8", "-t", charmap], input="界".encode())
            prefix = []
            if args.memcheck:
                logfile = args.output.with_name(args.output.stem + f"-{index}-{locale}.memcheck.log")
                prefix = ["valgrind", "--error-exitcode=97", "--leak-check=no",
                          "--log-file=" + str(logfile.resolve())]
            r = subprocess.run(prefix + [str(shell), "-dfc", script, "comparison", str(folder), wide],
                               env=env,
                               capture_output=True, timeout=300)
            counts = [int(n) for n in re.findall(rb"(?m)^checks=(\d+)$", r.stdout)]
            if r.returncode or r.stderr or len(counts) != 8 or min(counts) <= 0:
                raise RuntimeError((str(shell), locale, r.returncode, r.stdout, r.stderr))
            if index and results[locale] != r.stdout:
                raise RuntimeError("classifier check results differ: " + locale)
            results[locale] = r.stdout
            report["cases"].append({"shell": str(shell), "locale": locale, "charmap": charmap, "wide_setting_hex": wide.hex(),
                                    "checks": sum(counts), "status": 0, "memcheck": args.memcheck,
                                    "stdout": r.stdout.decode(), "binary_sha256": sha(shell)})
            print(f"{shell.name}/{locale}: {sum(counts)} classifier checks passed", flush=True)
    args.output.write_text(json.dumps(report, indent=2) + "\n")


if __name__ == "__main__":
    main()
