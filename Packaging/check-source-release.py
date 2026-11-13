#!/usr/bin/env python3
"""Build and test an extracted source RC outside Git, then stage its full package."""
import argparse
import hashlib
import json
import os
from pathlib import Path
import shutil
import subprocess
import tarfile
import tempfile
import time


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("archive", type=Path)
    parser.add_argument("--output", type=Path, required=True)
    parser.add_argument("--jobs", type=int, default=4)
    parser.add_argument("--optimization", choices=["standard", "lto", "pgo", "pgo-lto"],
                        default="standard", help="release package compiler profile to validate outside Git")
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
               "HOME": os.environ["HOME"], "GIT_CEILING_DIRECTORIES": str(scratch),
               "TERM": "xterm"}
        stub = scratch / "no-git"
        stub.mkdir()
        (stub / "git").write_text("#!/bin/sh\necho 'Git is disabled during this archive build' >&2\nexit 127\n")
        (stub / "git").chmod(0o755)
        build_env = dict(env, PATH=str(stub) + ":" + env["PATH"])

        def run(name, command, selected_env):
            start = time.monotonic()
            log = args.output.with_name(args.output.stem + "-" + name + ".log")
            with log.open("wb") as out:
                # Both package profiles must stage safe completion directories
                # even when invoked from a group-writable development umask.
                result = subprocess.run(command, cwd=root, env=selected_env,
                                        stdout=out, stderr=subprocess.STDOUT, timeout=1800,
                                        umask=0o002 if "package-stage" in name else -1)
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
        run("release-core-build", ["python3", "Perf/build.py", "--profile", "release",
                                   "--jobs", str(args.jobs)], build_env)
        run("release-core-tests", ["make", "-C", ".work/release-candidate", "check"], env)
        core_profiles = []
        for profile, names in [("debug", ["baseline", "candidate"]),
                               ("release", ["release-baseline", "release-candidate"])]:
            for name in names:
                folder = root / ".work" / name
                debug_enabled = "#define DEBUG 1" in (folder / "config.h").read_text().splitlines()
                assert debug_enabled == (profile == "debug")
                binary = folder / "Src/zsh"
                if name.endswith("candidate"):
                    assert subprocess.check_output([str(binary), "--version"], env=env) == expected
                script = ('zmodload zsh/mathfunc || exit 1; '
                          '(( sqrt(4) == 2 )) || exit 2; print -rl -- $module_path')
                result = subprocess.run([str(binary), "-dfc", script], env=env,
                                        capture_output=True, text=True, timeout=30)
                assert result.returncode == 0 and not result.stderr, result
                core_profiles.append({"profile": profile, "host": name,
                                      "shell_sha256": hashlib.sha256(binary.read_bytes()).hexdigest(),
                                      "module_path": result.stdout.strip()})
        assert len({row["module_path"] for row in core_profiles}) == 4
        assert (root / "psh").read_bytes() == (root / ".work/release-candidate/Src/zsh").read_bytes()
        run("package-stage", ["python3", "Packaging/build.py", "--jobs", str(args.jobs),
                              "--optimization", args.optimization], build_env)
        staged = json.loads((root / ".work/package/latest.json").read_text())
        assert staged["project_version"] == metadata["project_version"]
        assert staged["zsh_version"] == metadata["zsh_version"]
        assert staged["settings"]["profile"] == "release"
        assert staged["settings"]["debug_assertions"] is False
        assert staged["settings"]["optimization"] == args.optimization
        assert "#define DEBUG 1" not in (Path(staged["core"]) / "config.h").read_text().splitlines()
        assert subprocess.check_output([str(Path(staged["payload"]) / "bin/psh"), "--version"], env=env) == expected
        # Exercise the opt-in debug package in this disposable tree so its
        # native build caches cannot replace the modules used by installed tests.
        run("debug-package-stage", ["python3", "Packaging/build.py", "--profile", "debug",
                                    "--jobs", str(args.jobs)], build_env)
        debug = json.loads((root / ".work/package/latest.json").read_text())
        assert debug["settings"]["profile"] == "debug"
        assert debug["settings"]["debug_assertions"] is True
        assert debug["release"] != staged["release"]
        for package in (staged, debug):
            payload = Path(package["payload"])
            for directory in [payload, *(p for p in payload.rglob("*") if p.is_dir() and not p.is_symlink())]:
                assert not directory.stat().st_mode & 0o022, directory
        assert "#define DEBUG 1" in (Path(debug["core"]) / "config.h").read_text().splitlines()
        assert subprocess.check_output([str(Path(debug["payload"]) / "bin/psh"), "--version"], env=env) == expected
        debugger_checks = {}
        for name, package in [("release", staged), ("debug", debug)]:
            payload = Path(package["payload"])
            assert ("#define DEBUG 1" in (payload / "include/psh/config.h").read_text().splitlines()) == (name == "debug")
            if shutil.which("gdb", path=env["PATH"]):
                command = ["gdb", "--batch", "--nx", "--quiet", "-ex", "info line zsh_main",
                           str(payload / "bin/psh")]
                result = subprocess.run(command, env=env, capture_output=True, text=True, timeout=30)
                assert result.returncode == 0 and "Line " in result.stdout and "init.c" in result.stdout, result
                debugger_checks[name] = {"command": command, "status": result.returncode,
                                         "stdout": result.stdout.strip()}
        report = {"passed": True, "archive_sha256": hashlib.sha256(args.archive.read_bytes()).hexdigest(),
                  "source_commit": metadata["source_commit"], "project_version": metadata["project_version"],
                  "zsh_version": metadata["zsh_version"], "git_history_present": False,
                  "git_disabled_during_builds": True, "test_environment": {"TERM": "xterm", "LC_ALL": "C.UTF-8"},
                  "baseline_files_verified": metadata["baseline_files_verified"],
                  "package_staged_without_installing": True, "runs": rows}
        report["core_profiles"] = core_profiles
        report["core_profile_module_paths_isolated"] = True
        report["core_trial_release_published"] = True
        report["package_directories_safe_under_0002_umask"] = True
        report.update(release_profile=staged["settings"], debug_profile=debug["settings"],
                      distinct_profile_build_ids=True, debug_package_staged_without_installing=True,
                      debugger_checks=debugger_checks)
        report["release_compiler_training"] = staged.get("compiler_training")
        args.output.write_text(json.dumps(report, indent=2) + "\n")
    print("Extracted source RC builds and stages without Git", flush=True)


if __name__ == "__main__":
    main()
