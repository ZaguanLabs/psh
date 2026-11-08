#!/usr/bin/env python3
"""Run upstream scripts with the exact installed ELF and matching installed modules."""
import argparse
import hashlib
import json
import os
from pathlib import Path
import re
import shutil
import subprocess


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--build", type=Path, required=True)
    args = parser.parse_args()
    build = json.loads(args.build.read_text())
    work, core, prefix = map(Path, (build["work"], build["core"], build["prefix"]))
    shell = prefix / "bin/psh"
    harness = work / "installed-core-test"
    if harness.exists():
        shutil.rmtree(harness)
    shutil.copytree(core, harness, symlinks=True)
    launcher = harness / "Src/zsh"
    launcher.unlink()
    launcher.symlink_to(shell)
    modules = prefix / "lib/psh" / build.get("zsh_version", "5.9.2")
    # Some upstream tests use ../Src/zsh or configured module-file paths.
    # Keep their layout, but route those paths to the actual installed bytes.
    module_files = {}
    for name, definition, link in re.findall(r"(?m)^name=(\S+) modfile=(\S+) link=(\S+)",
                                            (harness / "config.modules").read_text()):
        if link == "dynamic":
            module_files[Path(definition).with_suffix(".so")] = modules / (name + ".so")
    for path in (harness / "Src").rglob("*.so"):
        installed = module_files.get(path.relative_to(harness))
        if installed is None or not installed.is_file():
            raise RuntimeError(f"installed module mapping is missing: {path}")
        path.unlink()
        path.symlink_to(installed)
    test_modules = harness / "Test/Modules"
    if test_modules.is_symlink():
        test_modules.unlink()
    elif test_modules.exists():
        shutil.rmtree(test_modules)
    test_modules.symlink_to(modules)
    assert launcher.resolve() == shell.resolve()
    env = dict(os.environ, ZTST_srcdir=str(harness / "Test"), ZTST_exe=str(launcher),
               ZTST_testlist="\n".join(str(p) for p in sorted((harness / "Test").glob("*.ztst"))))
    env.pop("FPATH", None)
    digest = hashlib.sha256(shell.read_bytes()).hexdigest()
    print("Upstream harness ELF:", launcher.resolve(), flush=True)
    print("SHA256:", digest, flush=True)
    result = subprocess.run([str(launcher), "+Z", "-f", str(harness / "Test/runtests.zsh")],
                            cwd=harness / "Test", env=env)
    assert hashlib.sha256(shell.read_bytes()).hexdigest() == digest
    (work / "installed-core-harness.json").write_text(json.dumps({
        "shell": str(shell), "shell_sha256": digest, "launcher": str(launcher),
        "launcher_resolves_to_installed_shell": True, "module_path": str(modules),
        "diagnostic_invocation_name": "zsh", "status": result.returncode}, indent=2) + "\n")
    raise SystemExit(result.returncode)


if __name__ == "__main__":
    main()
