#!/usr/bin/env python3
"""Compare native printf observers loaded through libc and the ELF interpreter."""
import argparse
import ctypes
import hashlib
import json
import os
from pathlib import Path
import re
import subprocess


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--candidate", type=Path, required=True)
    parser.add_argument("--reference", type=Path, default=Path("/bin/zsh"))
    parser.add_argument("--output", type=Path, required=True)
    args = parser.parse_args()
    if os.geteuid() == 0:
        raise RuntimeError("run native library fixtures as the normal user")
    args.output.parent.mkdir(parents=True, exist_ok=True)
    args.output.unlink(missing_ok=True)
    folder = args.output.resolve().with_suffix("")
    folder.mkdir(exist_ok=True)
    source = Path(__file__).with_name("convfloat-loader-library.c").resolve()
    shells = {name: path.resolve(strict=True) for name, path in
              [("reference", args.reference), ("candidate", args.candidate)]}
    sha = lambda p: hashlib.sha256(p.read_bytes()).hexdigest()
    report = dict(passed=False, shells={k: str(p) for k, p in shells.items()},
                  binary_sha256={k: sha(p) for k, p in shells.items()},
                  driver_sha256=sha(Path(__file__)), library_source_sha256=sha(source),
                  supported=hasattr(ctypes.CDLL(None), "gnu_get_libc_version"),
                  runs=[], skips=[])
    if not report["supported"]:
        report.update(passed=True, skips=["GNU libc plugin interfaces are unavailable"])
        args.output.write_text(json.dumps(report, indent=2) + "\n")
        return
    library = folder / "pshcodec.so"
    compile_command = ["cc", "-O2", "-g", "-shared", "-fPIC", str(source), "-o", str(library)]
    subprocess.run(compile_command, check=True)
    (folder / "gconv-modules").write_text(
        "module INTERNAL ISO-8859-1// pshcodec 1\n"
        "module ISO-8859-1// INTERNAL pshcodec 1\n")
    report.update(compile_command=compile_command, library_sha256=sha(library))
    available = subprocess.check_output(["locale", "-a"], env={"PATH": "/usr/bin:/bin",
                                         "LC_ALL": "C"}, text=True).splitlines()
    utf8 = next((s for s in available if s.lower() in ["c.utf8", "c.utf-8"]), None)
    latin1 = next((s for s in available if s.lower() in
                   ["iso-8859-1", "en_us.iso88591", "en_us.iso-8859-1"]), None)
    floating = 'typeset -F 4 value=1.25; print -r -- "$value"'
    convert = "printf '%b\\n' '\\u0041\\u00e9'; "
    cases = [("ordinary-C", "C", {}, floating, False, False)]
    for locale in ["C", *([utf8] if utf8 else [])]:
        cases.append(("interpreter-preload-" + locale, locale, {}, floating, True, True))
    if utf8:
        cases.append(("unused-codec", utf8, {"GCONV_PATH": str(folder)},
                      floating, False, False))
    if latin1:
        cases.append(("startup-codec", latin1, {"GCONV_PATH": str(folder)},
                      convert + floating, True, False))
        if utf8:
            late = 'export LC_CTYPE="' + latin1 + '"; ' + convert
            cases.append(("late-codec", utf8, {"GCONV_PATH": str(folder)},
                          late + floating, True, False))
            cases.append(("clear-codec-marker", utf8, {"GCONV_PATH": str(folder)},
                          late + "unset GCONV_PATH; " + floating, True, False))
    else:
        report["skips"].append("Latin-1 locale unavailable: gconv injection cases omitted")
    if not utf8:
        report["skips"].append("C UTF-8 locale unavailable: UTF-8 controls omitted")
    passed = True
    for case, locale, extra_env, script, should_load, preload in cases:
        observations = []
        for name, shell in shells.items():
            marker = folder / (case + "-" + name + ".marker")
            marker.unlink(missing_ok=True)
            # LANG permits later LC_CTYPE changes; LC_ALL would override them.
            env = {"PATH": "/usr/bin:/bin", "LANG": locale,
                   "PSH_LOADER_MARKER": str(marker), **extra_env}
            command = [str(shell), "-dfc", script]
            if preload:
                elf = subprocess.check_output(["readelf", "-l", str(shell)], text=True)
                match = re.search(r"Requesting program interpreter: ([^\]]+)", elf)
                if not match:
                    raise RuntimeError("ELF interpreter unavailable: " + str(shell))
                command = [match[1], "--preload", str(library), *command]
            run = subprocess.run(command, env=env, capture_output=True, timeout=30)
            loaded = marker.exists() and marker.read_bytes() == b"loaded\n"
            expected = (b"A\xe9\n" if "codec" in case and should_load else b"")
            expected += b"global:C.\n" if should_load else b"1.2500\n"
            ok = (run.returncode == 0 and not run.stderr and loaded == should_load
                  and run.stdout == expected)
            observations.append((run.returncode, run.stdout, run.stderr, loaded))
            report["runs"].append(dict(case=case, host=name, locale=locale,
                command=command, environment=env, loaded=loaded, passed=ok,
                status=run.returncode, stdout_hex=run.stdout.hex(),
                stderr=run.stderr.decode(errors="replace")))
            passed = passed and ok
        same = observations[0] == observations[1]
        passed = passed and same
        print(case, "matched" if same and all(r["passed"] for r in report["runs"][-2:])
              else "FAILED", flush=True)
    assert report["binary_sha256"] == {k: sha(p) for k, p in shells.items()}
    assert report["driver_sha256"] == sha(Path(__file__))
    assert report["library_source_sha256"] == sha(source)
    assert report["library_sha256"] == sha(library)
    report["passed"] = passed
    args.output.write_text(json.dumps(report, indent=2) + "\n")
    raise SystemExit(0 if passed else 1)


if __name__ == "__main__":
    main()
