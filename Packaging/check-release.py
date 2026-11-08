#!/usr/bin/env python3
"""Check RC identity, runtime preservation, invocation modes and debugger symbols."""
import argparse
import hashlib
import json
from pathlib import Path
import shutil
import subprocess

from elf import allocated_sections, dynamic_exports


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--build", type=Path, required=True)
    parser.add_argument("--reference", type=Path, required=True)
    parser.add_argument("--output", type=Path, required=True)
    args = parser.parse_args()
    build = json.loads(args.build.read_text())
    prefix = Path(build["prefix"])
    shell, raw = prefix / "bin/psh", Path(build["core"]) / "Src/zsh"
    env = {"PATH": "/usr/bin:/bin", "LC_ALL": "C.UTF-8"}
    expected = f"psh {build['project_version']} (zsh {build['zsh_version']})\n".encode()
    assert subprocess.check_output([str(shell), "--version"], env=env) == expected
    assert allocated_sections(shell) == allocated_sections(raw)
    assert dynamic_exports(shell) == dynamic_exports(raw)
    assert (prefix / "bin" / ("psh-" + build["zsh_version"])).resolve() == shell
    script = '''emulate
builtin set -o
'''
    modes = []
    for name in ["psh", "zsh", "sh", "ksh", "rzsh", "rsh", "rksh", "bash"]:
        values = []
        for binary in [args.reference.resolve(), shell]:
            result = subprocess.run([name, "--no-rcs", "--no-globalrcs", "-c", script], executable=binary, env=env,
                                    capture_output=True, timeout=20)
            values.append((result.returncode, result.stdout, result.stderr))
        assert values[0] == values[1] and values[0][0] == 0, (name, values)
        assert len(values[0][1].splitlines()) > 100, "incomplete option-state output"
        modes.append({"argv0": name, "status": 0,
                      "option_count": len(values[0][1].splitlines()) - 1,
                      "options_sha256": hashlib.sha256(values[0][1]).hexdigest()})
    script = '''[[ $ZSH_VERSION == 5.9.2 && ${+PSH_VERSION} == 0 ]] || exit 1
PSH_VERSION=caller
[[ $PSH_VERSION == caller ]] || exit 1
autoload -Uz is-at-least
is-at-least 5.9.2 || exit 1
if is-at-least 6.0; then exit 1; fi
print -r -- "$ZSH_VERSION/caller/version-checks-ok"
'''
    assert subprocess.check_output([str(shell), "-dfc", script], env=env) == b"5.9.2/caller/version-checks-ok\n"
    fpath = "/tmp/psh-fpath-probe-a:/tmp/psh-fpath-probe-b"
    result = subprocess.check_output([str(shell), "-dfc", "print -rl -- $fpath"],
                                     env=dict(env, FPATH=fpath))
    assert result == fpath.replace(":", "\n").encode() + b"\n"
    debugger = "unavailable"
    if shutil.which("gdb") and build.get("debug_file"):
        result = subprocess.run(["gdb", "--batch", "--nx", "--quiet", "-ex", "info line zsh_main", str(shell)],
                                env=env, text=True, capture_output=True, timeout=30)
        assert result.returncode == 0 and "Line " in result.stdout and "init.c" in result.stdout, result
        debugger = result.stdout.strip()
    report = {"passed": True, "project_version": build["project_version"],
              "zsh_version": build["zsh_version"], "shell": str(shell),
              "shell_sha256": hashlib.sha256(shell.read_bytes()).hexdigest(),
              "version_stdout": expected.decode(), "allocated_sections_preserved": True,
              "dynamic_exports_preserved": True, "invocation_modes": modes,
              "no_reserved_PSH_VERSION_parameter": True, "is_at_least_uses_upstream_version": True,
              "inherited_FPATH_preserved": True, "debugger_line_lookup": debugger,
              "installed_bytes": shell.stat().st_size, "unstripped_bytes": raw.stat().st_size}
    args.output.parent.mkdir(parents=True, exist_ok=True)
    args.output.write_text(json.dumps(report, indent=2) + "\n")
    print(json.dumps(report, indent=2))


if __name__ == "__main__":
    main()
