#!/usr/bin/env python3
"""Verify whole metafied byte counts and byte-mode wrappers with pristine headers."""
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
    parser.add_argument("--headers-build", type=Path, default=Path(".work/baseline"))
    parser.add_argument("--memcheck", action="store_true")
    args = parser.parse_args()
    root = Path(__file__).resolve().parent.parent
    headers = args.headers_build.resolve(strict=True)
    folder = root / (".work/byte-length-module-" + headers.name)
    folder.mkdir(exist_ok=True)
    source = root / "Perf/byte-length-module.c"
    module = folder / "psh_byte_length_fixture.so"
    command = ["cc", "-O2", "-g", "-shared", "-fPIC", "-DMODULE", "-DHAVE_CONFIG_H",
               "-I" + str(headers / "Src"), "-I" + str(root / ".work/pristine/Src"),
               str(source), "-o", str(module)]
    subprocess.run(command, check=True)
    script = '''emulate -R zsh
module_path=("$1" $module_path)
zmodload psh_byte_length_fixture || exit 1
for mode in multibyte nomultibyte; do
  setopt $mode
  print -r -- "$mode"
  psh-byte-length-check || exit 1
done
zmodload -u psh_byte_length_fixture || exit 1
if whence psh-byte-length-check >/dev/null; then exit 1; fi
exit 0
'''
    sha = lambda p: hashlib.sha256(p.read_bytes()).hexdigest()
    report = {"compile_command": command, "source_sha256": sha(source),
              "module_sha256": sha(module), "cases": []}
    args.output.parent.mkdir(parents=True, exist_ok=True)
    outputs = {}
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
            counts = [(int(a), int(b)) for a, b in re.findall(
                rb"(?m)^checks=(\d+) malformed=(\d+)$", r.stdout)]
            if r.returncode or len(counts) != 2 or min(a for a, _ in counts) <= 0:
                raise RuntimeError((str(shell), locale, r.returncode, r.stdout, r.stderr[-1000:]))
            malformed = sum(b for _, b in counts)
            if r.stderr != b"BUG: unexpected end of string in ztrlen()\n" * malformed:
                raise RuntimeError((str(shell), locale, "unexpected diagnostics", r.stderr[-1000:]))
            if index and outputs[locale] != (r.stdout, r.stderr):
                raise RuntimeError("byte length results differ: " + locale)
            outputs[locale] = (r.stdout, r.stderr)
            checks = sum(a for a, _ in counts)
            report["cases"].append({"shell": str(shell), "locale": locale, "checks": checks,
                                    "malformed_diagnostics": malformed, "stdout": r.stdout.decode(),
                                    "stderr_sha256": hashlib.sha256(r.stderr).hexdigest(),
                                    "status": 0, "memcheck": args.memcheck,
                                    "binary_sha256": sha(shell)})
            print(f"{shell.name}/{locale}: {checks} checks, {malformed} expected diagnostics", flush=True)
    args.output.write_text(json.dumps(report, indent=2) + "\n")


if __name__ == "__main__":
    main()
