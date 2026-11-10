#!/usr/bin/env python3
"""Build private Zsh baseline / psh candidate trees without installing system-wide."""
import argparse
import hashlib
import json
import os
from pathlib import Path
import shutil
import subprocess
import tarfile
import tempfile


UPSTREAM_REF = "refs/tags/upstream/zsh-5.9.2"


def verify_pristine(pristine, manifest):
    actual = {p.relative_to(pristine).as_posix()
              for p in pristine.rglob("*") if p.is_file() or p.is_symlink()}
    if actual != set(manifest):
        raise RuntimeError("baseline source file list differs from the release manifest")
    for name, digest in manifest.items():
        if hashlib.sha256((pristine / name).read_bytes()).hexdigest() != digest:
            raise RuntimeError(f"baseline source changed: {name}")


def prepare_pristine(root, work):
    """Restore release sources from the tagged snapshot, never from HEAD."""
    manifest_file = root / "Perf/upstream-sha256.json"
    manifest = json.loads(manifest_file.read_text())
    local_manifest = work / "pristine-sha256.json"
    if local_manifest.exists() and json.loads(local_manifest.read_text()) != manifest:
        raise RuntimeError("local pristine manifest differs from Perf/upstream-sha256.json")
    pristine = work / "pristine"
    if not pristine.exists():
        with tempfile.TemporaryDirectory(prefix="pristine-", dir=work) as temporary:
            scratch = Path(temporary)
            archive = scratch / "source.tar"
            bundled = root / "Perf/upstream/zsh-5.9.2.tar.xz"
            if bundled.is_file():
                archive = bundled
            else:
                with archive.open("wb") as output:
                    result = subprocess.run(["git", "archive", "--format=tar", UPSTREAM_REF],
                                            cwd=root, stdout=output, stderr=subprocess.PIPE)
                if result.returncode:
                    raise RuntimeError("missing upstream snapshot tag or bundled release archive; use the attached "
                                       "psh source release, or in a Git clone run "
                                       "git fetch origin tag upstream/zsh-5.9.2")
            extracted = scratch / "source"
            with tarfile.open(archive) as source:
                source.extractall(extracted, filter="data")
            actual = {p.relative_to(extracted).as_posix()
                      for p in extracted.rglob("*") if p.is_file() or p.is_symlink()}
            if actual != set(manifest):
                raise RuntimeError("upstream snapshot file list differs from the release manifest")
            verify_pristine(extracted, manifest)
            os.replace(extracted, pristine)
        origin = "bundled release archive" if bundled.is_file() else UPSTREAM_REF
        print(f"Restored verified release baseline from {origin}", flush=True)
    verify_pristine(pristine, manifest)
    if not local_manifest.exists():
        shutil.copy2(manifest_file, local_manifest)
    return pristine


def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument("--which", choices=("baseline", "candidate", "all"), default="all")
    p.add_argument("--jobs", type=int, default=8)
    p.add_argument("--profile", choices=("debug", "release"), default="debug",
                   help="debug retains assertions; release uses separate build/module directories")
    args = p.parse_args()
    if args.jobs < 1:
        p.error("--jobs must be positive")
    root = Path(__file__).resolve().parent.parent
    work = root / ".work"
    logs = work / "logs"
    logs.mkdir(parents=True, exist_ok=True)
    try:
        pristine = prepare_pristine(root, work)
    except (OSError, RuntimeError, tarfile.TarError, ValueError) as error:
        p.error(str(error))
    selected = ("baseline", "candidate") if args.which == "all" else (args.which,)
    for name in selected:
        label = name if args.profile == "debug" else "release-" + name
        build = work / label
        build.mkdir(exist_ok=True)
        source = pristine if name == "baseline" else root
        runtime_name = "baseline-runtime" if name == "baseline" else "runtime"
        runtime = work / (runtime_name if args.profile == "debug" else "release-" + runtime_name)
        commands = [
            [str(source / "configure"), f"--prefix={runtime}",
             "--enable-multibyte",
             "--enable-zsh-debug" if args.profile == "debug" else "--disable-zsh-debug",
             "CFLAGS=-O2 -g", "LDFLAGS=-g"],
            ["make", f"-j{args.jobs}"],
            ["make", f"MODDIR={build / 'modules'}", "install.modules"],
            ["make", f"MODDIR={runtime / 'lib/zsh/5.9.2'}", "install.modules"],
        ]
        for phase, command in enumerate(commands):
            print(f"{label}: {' '.join(command)}", flush=True)
            with (logs / f"{label}-build-{phase}.log").open("w") as log:
                subprocess.run(command, cwd=build, stdout=log,
                               stderr=subprocess.STDOUT, check=True)
        if name == "candidate":
            # Publish a real executable, atomically. Upstream build targets and
            # compatibility identities (ZSH_VERSION, zsh/* modules) stay intact.
            temporary = root / "psh.new"
            shutil.copy2(build / "Src/zsh", temporary)
            os.replace(temporary, root / "psh")
            print(f"Ready: {root / 'psh'}", flush=True)


if __name__ == "__main__":
    main()
