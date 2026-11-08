#!/usr/bin/env python3
"""Build and test an extracted source RC outside Git, then stage its full package."""
import argparse
import hashlib
import json
import os
from pathlib import Path
import subprocess
import tarfile
import tempfile
import time


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("archive", type=Path)
    parser.add_argument("--output", type=Path, required=True)
    parser.add_argument("--jobs", type=int, default=4)
    args = parser.parse_args()
    args.archive = args.archive.resolve(strict=True)
    args.output = args.output.resolve()
    args.output.parent.mkdir(parents=True, exist_ok=True)
    rows = []
    with tempfile.TemporaryDirectory(prefix="psh-source-rc-") as temporary:
        scratch = Path(temporary)
        with tarfile.open(args.archive) as archive:
            archive.extractall(scratch, filter="data")
        roots = [p for p in scratch.iterdir() if p.is_dir()]
        if len(roots) != 1:
            raise RuntimeError("source archive must contain one project directory")
        root = roots[0]
        assert not (root / ".git").exists()
        metadata = json.loads((root / "SOURCE-INFO.json").read_text())
        env = {"PATH": "/usr/bin:/bin", "LC_ALL": "C.UTF-8", "LANG": "C.UTF-8",
               "HOME": os.environ["HOME"], "GIT_CEILING_DIRECTORIES": str(scratch)}
        stub = scratch / "no-git"
        stub.mkdir()
        (stub / "git").write_text("#!/bin/sh\necho 'Git is disabled during this archive build' >&2\nexit 127\n")
        (stub / "git").chmod(0o755)
        build_env = dict(env, PATH=str(stub) + ":" + env["PATH"])

        def run(name, command, selected_env):
            start = time.monotonic()
            log = args.output.with_name(args.output.stem + "-" + name + ".log")
            with log.open("wb") as out:
                result = subprocess.run(command, cwd=root, env=selected_env,
                                        stdout=out, stderr=subprocess.STDOUT, timeout=1800)
            rows.append({"name": name, "command": command, "status": result.returncode,
                         "seconds": round(time.monotonic() - start, 3), "log": str(log)})
            print(name, result.returncode, flush=True)
            if result.returncode:
                raise RuntimeError(name + ": see " + str(log))

        run("core-build", ["python3", "Perf/build.py", "--jobs", str(args.jobs)], build_env)
        expected = f"psh {metadata['project_version']} (zsh {metadata['zsh_version']})\n".encode()
        assert subprocess.check_output([str(root / "psh"), "--version"], env=env) == expected
        # Upstream test fixtures may themselves use Git as a utility; they
        # still run outside a repository. Both builds above have Git disabled.
        run("core-tests", ["make", "-C", ".work/candidate", "check"], env)
        run("package-stage", ["python3", "Packaging/build.py", "--jobs", str(args.jobs)], build_env)
        staged = json.loads((root / ".work/package/latest.json").read_text())
        assert staged["project_version"] == metadata["project_version"]
        assert staged["zsh_version"] == metadata["zsh_version"]
        assert subprocess.check_output([str(Path(staged["payload"]) / "bin/psh"), "--version"], env=env) == expected
        report = {"passed": True, "archive_sha256": hashlib.sha256(args.archive.read_bytes()).hexdigest(),
                  "source_commit": metadata["source_commit"], "project_version": metadata["project_version"],
                  "zsh_version": metadata["zsh_version"], "git_history_present": False,
                  "git_disabled_during_builds": True, "baseline_files_verified": metadata["baseline_files_verified"],
                  "package_staged_without_installing": True, "runs": rows}
        args.output.write_text(json.dumps(report, indent=2) + "\n")
    print("Extracted source RC builds and stages without Git", flush=True)


if __name__ == "__main__":
    main()
