#!/usr/bin/env python3
"""Exercise array mutations and native vector loans using the preceding SDK."""
import argparse
import hashlib
import json
from pathlib import Path
import shlex
import subprocess


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("baseline", type=Path)
    parser.add_argument("candidate", type=Path)
    parser.add_argument("--headers-build", type=Path, required=True)
    parser.add_argument("--headers-source", type=Path, required=True)
    parser.add_argument("--cc", default="cc")
    parser.add_argument("--locale", action="append", dest="locales")
    parser.add_argument("--memcheck", action="store_true")
    parser.add_argument("--raw-contract", action="store_true",
                        help="also assert the documented raw-field difference and getter migration")
    parser.add_argument("--output", type=Path, required=True)
    args = parser.parse_args()
    root = Path(__file__).resolve().parent
    sha = lambda p: hashlib.sha256(p.read_bytes()).hexdigest()
    output = args.output.resolve()
    output.parent.mkdir(parents=True, exist_ok=True)
    output.unlink(missing_ok=True)
    folder = output.parent / (output.stem + "-native")
    folder.mkdir(exist_ok=True)
    module = folder / "psh_array_cache_fixture.so"
    source = root / "array-cache-module.c"
    command = shlex.split(args.cc) + ["-O2", "-g", "-shared", "-fPIC", "-DMODULE",
        "-DHAVE_CONFIG_H", "-I" + str(args.headers_build.resolve() / "Src"),
        "-I" + str(args.headers_source.resolve() / "Src"), str(source), "-o", str(module)]
    subprocess.run(command, check=True)
    shells = [args.baseline.resolve(strict=True), args.candidate.resolve(strict=True)]
    scripts = [root / "array-cache-lifetimes.zsh", root / "array-cache-mutations.zsh"]
    if args.raw_contract:
        scripts.append(root / "array-cache-raw-alias.zsh")
    fingerprints = {str(p): sha(p) for p in shells + scripts + [source]}
    rows = []
    # Ordinary malloc is needed to cover in-place realloc. Memcheck's realloc
    # commonly moves instead; both lifetimes are valid and tested separately.
    for memcheck in ([False, True] if args.memcheck else [False]):
        for script in scripts[:2]:
            for mode in (["zsh"] if "lifetimes" in script.name else ["zsh", "ksh", "sh"]):
                for locale in args.locales or ["C", "C.UTF-8", "fr_BE.UTF-8"]:
                    values = []
                    for host, shell in zip(["baseline", "candidate"], shells):
                        cmd = [str(shell), "-df", str(script),
                               str(folder) if "lifetimes" in script.name else mode]
                        if memcheck:
                            log = folder / f"{script.stem}-{host}-{mode}-{locale}.memcheck.log"
                            cmd = ["valgrind", "--error-exitcode=97", "--leak-check=no",
                                   "--log-file=" + str(log)] + cmd
                        result = subprocess.run(cmd, capture_output=True, timeout=300,
                            env={"PATH": "/usr/bin:/bin", "LC_ALL": locale})
                        if result.returncode or result.stderr:
                            raise RuntimeError((cmd, result.returncode, result.stdout, result.stderr))
                        physical = [int(line.split(b"=")[1]) for line in result.stdout.splitlines()
                                    if line.startswith(b"same_pointer=")]
                        normalized = b"\n".join(line for line in result.stdout.splitlines()
                                               if not line.startswith(b"same_pointer="))
                        values.append(normalized)
                        rows.append(dict(script=script.name, mode=mode, locale=locale,
                            host=host, memcheck=memcheck, status=0, command=cmd,
                            in_place_reallocations=sum(physical),
                            stdout_sha256=hashlib.sha256(result.stdout).hexdigest()))
                    if values[0] != values[1]:
                        raise RuntimeError((script, mode, locale, "different results"))
                    print(script.name, mode, locale, "memcheck" if memcheck else "malloc",
                          "matched", flush=True)
    raw_contract = []
    if args.raw_contract:
        expected = [b"raw:present=0:value=\ngetter:present=0:value=\n",
                    b"raw:present=1:value=item\ngetter:present=0:value=\n"]
        for host, shell, value in zip(["baseline", "candidate"], shells, expected):
            cmd = [str(shell), "-df", str(scripts[2]), str(folder)]
            result = subprocess.run(cmd, capture_output=True, timeout=30,
                                    env={"PATH": "/usr/bin:/bin", "LC_ALL": "C.UTF-8"})
            if result.returncode or result.stderr or result.stdout != value:
                raise RuntimeError((cmd, result.returncode, result.stdout, result.stderr))
            raw_contract.append(dict(host=host, command=cmd, status=0,
                                     stdout=result.stdout.decode()))
    if fingerprints != {str(p): sha(p) for p in shells + scripts + [source]}:
        raise RuntimeError("test inputs changed")
    output.write_text(json.dumps(dict(passed=True, compile_command=command,
        module_sha256=sha(module), fingerprints=fingerprints, runs=rows,
        raw_contract=raw_contract), indent=2) + "\n")


if __name__ == "__main__":
    main()
