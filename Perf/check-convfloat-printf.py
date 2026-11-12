#!/usr/bin/env python3
"""Reproduce standard printf callbacks through an older native-module SDK."""
import argparse
import hashlib
import json
from pathlib import Path
import subprocess


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("baseline", type=Path)
    parser.add_argument("candidate", type=Path)
    parser.add_argument("--headers-build", type=Path, required=True,
                        help="older SDK without the float-locale capability")
    parser.add_argument("--headers-source", type=Path, default=Path(".work/pristine"))
    parser.add_argument("--output", type=Path, required=True)
    args = parser.parse_args()
    args.output.parent.mkdir(parents=True, exist_ok=True)
    args.output.unlink(missing_ok=True)
    folder = args.output.resolve().with_suffix("")
    folder.mkdir(exist_ok=True)
    source = Path(__file__).with_name("convfloat-printf-module.c").resolve()
    module = folder / "psh_printf_extension_fixture.so"
    command = ["cc", "-O2", "-g", "-shared", "-fPIC", "-DMODULE", "-DHAVE_CONFIG_H",
               "-I" + str(args.headers_build.resolve(strict=True) / "Src"),
               "-I" + str(args.headers_source.resolve(strict=True) / "Src"),
               str(source), "-o", str(module), "-ldl"]
    subprocess.run(command, check=True)
    shells = [p.resolve(strict=True) for p in (args.baseline, args.candidate)]
    sha = lambda p: hashlib.sha256(p.read_bytes()).hexdigest()
    inputs = {str(p): sha(p) for p in [source, Path(__file__).resolve(), module, *shells]}
    script = ('module_path=("$1" $module_path); '
              'zmodload psh_printf_extension_fixture || exit 1; '
              'psh-printf-extension-check || exit 2; '
              'zmodload -u psh_printf_extension_fixture || exit 3')
    runs = []
    for locale in ["C", "C.UTF-8", "fr_FR.UTF-8", "nb_NO.UTF-8", "tr_TR.UTF-8"]:
        for host, shell in enumerate(shells):
            run_command = [str(shell), "-dfc", script, "printf", str(folder)]
            result = subprocess.run(run_command,
                                    env={"PATH": "/usr/bin:/bin", "LC_ALL": locale},
                                    capture_output=True, timeout=30)
            text = result.stdout.decode()
            if (result.returncode or result.stderr or not text.startswith(
                    "constructor=global:C.\nvalue=global:C.\ntracking=") or
                    (host and not text.endswith("tracking=0\n"))):
                raise RuntimeError((host, locale, result.returncode, text, result.stderr))
            runs.append(dict(host=host, locale=locale, command=run_command, stdout=text, status=0))
            print(host, locale, "legacy callback context preserved", flush=True)
    assert inputs == {p: sha(Path(p)) for p in inputs}
    args.output.write_text(json.dumps(dict(passed=True, inputs=inputs, shells=list(map(str, shells)),
        compile_command=command, runs=runs), indent=2) + "\n")


if __name__ == "__main__":
    main()
