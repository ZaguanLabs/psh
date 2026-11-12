#!/usr/bin/env python3
"""Check native float-locale eligibility without altering personal startup files."""
import argparse
import hashlib
import json
from pathlib import Path
import subprocess


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("shell", type=Path)
    parser.add_argument("--headers-build", type=Path, required=True)
    parser.add_argument("--headers-source", type=Path, default=Path("."))
    parser.add_argument("--retired", action="store_true",
                        help="require the withdrawn locale-borrowing capability to stay off")
    parser.add_argument("--output", type=Path, required=True)
    args = parser.parse_args()
    args.output.parent.mkdir(parents=True, exist_ok=True)
    args.output.unlink(missing_ok=True)
    folder = args.output.resolve().with_suffix("")
    folder.mkdir(exist_ok=True)
    source = Path(__file__).with_name("convfloat-policy-module.c").resolve()
    shell = args.shell.resolve(strict=True)
    sha = lambda p: hashlib.sha256(p.read_bytes()).hexdigest()
    inputs = {str(p): sha(p) for p in [source, Path(__file__).resolve(), shell]}
    cases = []
    for label, defines, expected in [
            ("both", ["SCOPE", "FLOAT"], 1),
            ("scope-only", ["SCOPE"], 0),
            ("float-only", ["FLOAT"], 1),
            ("opaque", [], 0),
            ("failed", ["SCOPE", "FLOAT", "FAIL"], 0)]:
        scope_expected = int("SCOPE" in defines and "FAIL" not in defines)
        if args.retired:
            expected = 0
        state = f"{expected}:{scope_expected}"
        directory = folder / label
        directory.mkdir(exist_ok=True)
        module = directory / "psh_float_policy_fixture.so"
        command = ["cc", "-O2", "-g", "-shared", "-fPIC", "-DMODULE", "-DHAVE_CONFIG_H",
                   *["-DFIXTURE_" + d for d in defines],
                   "-I" + str(args.headers_build.resolve() / "Src"),
                   "-I" + str(args.headers_source.resolve() / "Src"),
                   str(source), "-o", str(module)]
        subprocess.run(command, check=True)
        if label == "failed":
            # The following acknowledged module must not re-enable a poisoned process.
            script = ('module_path=("$1" "$2" $module_path); '
                      'zmodload psh_float_policy_fixture 2>/dev/null && exit 1; '
                      'module_path=("$2" $module_path); '
                      'zmodload psh_float_policy_fixture || exit 2; '
                      'psh-float-policy-check 0:0 || exit 3')
        else:
            script = ('module_path=("$1" $module_path); '
                      'for trial in 1 2 3; do '
                      'zmodload psh_float_policy_fixture || exit 1; '
                      f'psh-float-policy-check {state} || exit 2; '
                      'zmodload -u psh_float_policy_fixture || exit 3; done; '
                      'module_path=("$2" $module_path); '
                      'zmodload psh_float_policy_fixture || exit 4; '
                      f'psh-float-policy-check {state} || exit 5; '
                      'integer traps=0; '
                      f'TRAPUSR1() {{ psh-float-policy-check {state} trap || exit 6; (( ++traps )); }}; '
                      f'psh-float-policy-check {state} signal || exit 7; '
                      '(( traps == 1 )) || exit 8; '
                      f'psh-float-policy-check {state} disable || exit 9; '
                      f'psh-float-policy-check 0:{scope_expected} || exit 10')
        for locale in ["C", "C.UTF-8", "fr_FR.UTF-8"]:
            result = subprocess.run([str(shell), "-dfc", script, "policy", str(directory),
                                     str(folder / "both")],
                                    env={"PATH": "/usr/bin:/bin", "LC_ALL": locale},
                                    capture_output=True, timeout=30)
            if result.returncode or result.stdout or result.stderr:
                raise RuntimeError((label, locale, result.returncode, result.stdout, result.stderr))
            cases.append(dict(case=label, locale=locale, passed=True,
                              compile_command=command, module_sha256=sha(module)))
            print(label, locale, "passed", flush=True)
    preload = folder / "preload.so"
    preload_source = source.with_name("convfloat-fault.c")
    subprocess.run(["cc", "-O2", "-shared", "-fPIC", str(preload_source), "-ldl",
                    "-o", str(preload)], check=True)
    for marker, value in [("LD_PRELOAD", str(preload)), ("LD_AUDIT", ""),
                          ("DYLD_INSERT_LIBRARIES", "present")]:
        script = ('unset LD_PRELOAD LD_AUDIT DYLD_INSERT_LIBRARIES; '
                  'module_path=("$1" $module_path); '
                  'zmodload psh_float_policy_fixture || exit 1; '
                  'psh-float-policy-check 0 || exit 2')
        result = subprocess.run([str(shell), "-dfc", script, "preload", str(folder / "both")],
                                env={"PATH": "/usr/bin:/bin", "LC_ALL": "C.UTF-8", marker: value},
                                capture_output=True, timeout=30)
        if result.returncode or result.stdout or result.stderr:
            raise RuntimeError((marker, result.returncode, result.stdout, result.stderr))
        cases.append(dict(case=marker + "-unset-before-load", passed=True,
                          preload_sha256=sha(preload), source_sha256=sha(preload_source)))
        print(marker, "capture before startup passed", flush=True)
    assert inputs == {str(p): sha(Path(p)) for p in inputs}
    args.output.write_text(json.dumps(dict(passed=True, retired=args.retired,
        inputs=inputs, cases=cases), indent=2) + "\n")


if __name__ == "__main__":
    main()
