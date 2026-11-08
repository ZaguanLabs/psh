#!/usr/bin/env python3
"""Test bundled projects with the installed inactive psh; do not activate it."""
import argparse
from concurrent.futures import ThreadPoolExecutor
import hashlib
import json
import os
from pathlib import Path
import subprocess
import time

ROOT = Path(__file__).resolve().parent.parent


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--build", type=Path, default=ROOT / ".work/package/latest.json")
    parser.add_argument("--suite", action="append", choices=["core", "zdraw", "zmdown", "zcurl", "zjson", "zhtml2md", "zoup"])
    parser.add_argument("--jobs", type=int, default=3)
    args = parser.parse_args()
    b = json.loads(args.build.read_text())
    work, core = Path(b["work"]), Path(b["core"])
    shell = Path(b["prefix"]) / "bin/psh"
    shim = work / "test-bin"
    shim.mkdir(exist_ok=True)
    if not (shim / "zsh").exists():
        (shim / "zsh").symlink_to(shell)
    if (shim / "zsh").resolve() != shell.resolve():
        raise RuntimeError("test shim does not select this psh")
    env = dict(os.environ, PATH=f"{shim}:/usr/bin:/bin", LC_ALL="C.UTF-8",
               ZSH_TEST_SHELL=str(shell), ZSH_BIN=str(shell), ZSH_BUILD_ROOT=str(core),
               ZHTML2MD_TEST_ZSH=str(shell))
    # An interactive parent can export its own system Zsh function path.
    # Let this candidate initialize fpath from its compiled private defaults.
    env.pop("FPATH", None)
    suites = {
        "core": [(core, ["python3", str(ROOT / "Packaging/core-test.py"),
                         "--build", str(args.build.resolve())], {})],
        "zdraw": [(ROOT / "Vendor/zdraw", ["make", "test", f"ZSH_BIN={shell}"], {})],
        "zmdown": [(ROOT / "Vendor/zmdown", ["make", "test"], {})],
        "zcurl": [(ROOT / "Vendor/zcurl", ["make", "test", f"ZSH_SRC={core}"], {})],
        "zjson": [(ROOT / "Vendor/zjson", [str(shell), "-df", "tests/run.zsh"], {"LC_ALL": locale})
                  for locale in ["C", "C.UTF-8"]],
        "zhtml2md": [(ROOT / "Vendor/zhtml2md", [str(shell), "-df", "tests/run.zsh"], {})],
        "zoup": [(ROOT / "Vendor/zoup", [str(shell), "-df", "scripts/test.zsh"], {})],
    }
    # These upstream build scripts deliberately reject a cache from another
    # source tree. Clear only their disposable default caches on a new release.
    for name in ["zdraw", "zmdown"]:
        project = ROOT / "Vendor" / name
        marker = project / ".build/source-root"
        if marker.exists() and marker.read_text().strip() != str(core):
            suites[name].insert(0, (project, ["make", "clean"], {}))

    def run(name):
        host_digest = hashlib.sha256(shell.read_bytes()).hexdigest()
        rows = []
        for number, (cwd, command, overrides) in enumerate(suites[name]):
            log = work / "logs" / f"test-{name}-{number}.log"
            started = time.monotonic()
            print(f"Testing {name} ({overrides.get('LC_ALL', 'C.UTF-8')}); log: {log}", flush=True)
            with log.open("wb") as out:
                try:
                    result = subprocess.run(command, cwd=cwd, env=dict(env, **overrides),
                                            stdout=out, stderr=subprocess.STDOUT, timeout=1800)
                    status = result.returncode
                except subprocess.TimeoutExpired:
                    status = 124
            rows.append({"command": command, "cwd": str(cwd), "overrides": overrides,
                         "status": status, "seconds": round(time.monotonic() - started, 3), "log": str(log)})
            print(f"{name}: exit {status} ({rows[-1]['seconds']}s)", flush=True)
        if hashlib.sha256(shell.read_bytes()).hexdigest() != host_digest:
            raise RuntimeError("installed test shell changed during the suite")
        report = {"release": b["release"], "shell": str(shell), "shell_sha256": host_digest, "FPATH_unset": True, "environment": {
            key: env[key] for key in ["PATH", "LC_ALL", "ZSH_TEST_SHELL", "ZSH_BIN", "ZSH_BUILD_ROOT", "ZHTML2MD_TEST_ZSH"]},
                  "runs": rows, "passed": all(row["status"] == 0 for row in rows)}
        (work / f"test-{name}.json").write_text(json.dumps(report, indent=2) + "\n")
        return report["passed"]

    with ThreadPoolExecutor(max_workers=args.jobs) as pool:
        passed = list(pool.map(run, args.suite or suites))
    raise SystemExit(0 if all(passed) else 1)


if __name__ == "__main__":
    main()
