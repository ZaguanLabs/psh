#!/usr/bin/env python3
"""Compare release-profile terminal loading with pristine and system Zsh."""
import argparse
import hashlib
import json
from pathlib import Path
import subprocess


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--build", type=Path, required=True)
    parser.add_argument("--reference", type=Path,
                        help="optionally include a matched pristine build")
    parser.add_argument("--system", type=Path, default=Path("/usr/bin/zsh"))
    parser.add_argument("--output", type=Path, required=True)
    args = parser.parse_args()
    build = json.loads(args.build.read_text())
    assert build["settings"]["profile"] == "release"
    assert build["settings"]["debug_assertions"] is False
    prefix, core = Path(build["prefix"]), Path(build["core"])
    for config in [core / "config.h", prefix / "include/psh/config.h"]:
        assert "#define DEBUG 1" not in config.read_text().splitlines(), config
    shells = {"installed": prefix / "bin/psh", "system": args.system.resolve(strict=True)}
    if args.reference:
        shells["pristine"] = args.reference.resolve(strict=True)
    scripts = {
        "termcap-first": "zmodload zsh/termcap; zmodload zsh/terminfo",
        "terminfo-first": "zmodload zsh/terminfo; zmodload zsh/termcap",
        "unload-reload": "for attempt in 1 2 3; do zmodload zsh/termcap zsh/terminfo || exit; "
                         "zmodload -u zsh/terminfo zsh/termcap || exit; done",
        "change-terminal": "zmodload zsh/termcap zsh/terminfo; TERM=xterm; "
                           "zmodload -u zsh/terminfo zsh/termcap",
    }
    rows = []
    for term in [None, "", "psh-no-such-terminal", "xterm", "dumb"]:
        env = {"PATH": "/usr/bin:/bin", "LC_ALL": "C.UTF-8"}
        if term is not None:
            env["TERM"] = term
        for name, script in scripts.items():
            values = []
            for kind, shell in shells.items():
                result = subprocess.run(["zsh", "-dfc", script], executable=shell,
                                        env=env, capture_output=True, timeout=20)
                values.append((result.returncode, result.stdout, result.stderr))
                rows.append({"host": kind, "TERM": term, "case": name,
                             "status": result.returncode, "stdout": result.stdout.decode(),
                             "stderr": result.stderr.decode()})
            assert all(value == (0, b"", b"") for value in values), (term, name, values)
    report = {"passed": True, "release": build["release"], "settings": build["settings"],
              "shells": {k: str(p) for k, p in shells.items()},
              "binary_sha256": {k: hashlib.sha256(p.read_bytes()).hexdigest() for k, p in shells.items()},
              "scripts": scripts, "environment": {"PATH": "/usr/bin:/bin", "LC_ALL": "C.UTF-8"},
              "runs": rows}
    args.output.parent.mkdir(parents=True, exist_ok=True)
    args.output.write_text(json.dumps(report, indent=2) + "\n")
    print(f"{len(rows)} terminal-profile runs match across {', '.join(shells)}")


if __name__ == "__main__":
    main()
