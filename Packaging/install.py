#!/usr/bin/env python3
"""Install a private candidate, refresh tested modules, or activate a verified psh release."""
import argparse
import hashlib
import json
import os
from pathlib import Path
import shutil
import stat
import tempfile
import time

ROOT = Path(__file__).resolve().parent.parent
BASE = Path("/usr/local/psh")


def sha(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def manifest(folder):
    entries = {}
    for p in sorted(folder.rglob("*")):
        key = str(p.relative_to(folder))
        if key == "psh-install.json":
            continue
        if p.lstat().st_mode & 0o6000:
            raise RuntimeError(f"unexpected privileged mode: {p}")
        if p.is_symlink():
            target = (p.parent / os.readlink(p)).resolve()
            if not target.is_relative_to(folder.resolve()):
                raise RuntimeError(f"symlink escapes release: {p}")
            entries[key] = {"symlink": os.readlink(p)}
        elif p.is_file():
            entries[key] = {"sha256": sha(p), "mode": stat.S_IMODE(p.stat().st_mode)}
        elif not p.is_dir():
            raise RuntimeError(f"unexpected file type: {p}")
    return entries


def atomic_json(path, value):
    temporary = path.with_name(path.name + ".new")
    temporary.write_text(json.dumps(value, indent=2) + "\n")
    temporary.chmod(0o644)
    os.replace(temporary, path)


def check_link(path):
    if path.exists() or path.is_symlink():
        if not path.is_symlink() or not str(path.resolve()).startswith(str(BASE) + "/"):
            raise RuntimeError(f"refusing to replace unrelated entry: {path}")
    temporary = path.with_name(path.name + ".psh-new")
    if temporary.exists() or temporary.is_symlink():
        raise RuntimeError(f"temporary path already exists: {temporary}")


def link(path, target):
    check_link(path)
    temporary = path.with_name(path.name + ".psh-new")
    temporary.symlink_to(target)
    os.replace(temporary, path)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("action", choices=["candidate", "refresh-modules", "activate"])
    parser.add_argument("--build", type=Path, default=ROOT / ".work/package/latest.json")
    args = parser.parse_args()
    if os.geteuid() != 0:
        parser.error("run this installation step with sudo")
    b = json.loads(args.build.read_text())
    prefix, payload, work = Path(b["prefix"]), Path(b["payload"]), Path(b["work"])
    if prefix.parent != BASE / "releases" or prefix.name != b["release"]:
        raise RuntimeError("unexpected installation prefix")
    if not payload.resolve().is_relative_to(ROOT / ".work/package"):
        raise RuntimeError("payload is outside the build area")
    expected = manifest(payload)
    record = prefix / "psh-install.json"
    if args.action == "candidate":
        if prefix.exists():
            if manifest(prefix) != expected:
                raise RuntimeError("existing candidate differs; refusing to overwrite it")
        else:
            prefix.parent.mkdir(parents=True, exist_ok=True)
            temporary = prefix.with_name(prefix.name + ".installing")
            shutil.copytree(payload, temporary, symlinks=True)
            os.replace(temporary, prefix)
        atomic_json(record, {"release": b["release"], "files": expected})
        print(f"Installed inactive candidate: {prefix}")
    elif args.action == "refresh-modules":
        if (BASE / "current").resolve() == prefix:
            raise RuntimeError("cannot replace modules in an active release; build a new release")
        previous = json.loads(record.read_text())["files"]
        if manifest(prefix) != previous:
            raise RuntimeError("installed candidate was changed outside this installer")
        allowed = {f"lib/psh/5.9.2/{name}.so" for name in ["zdraw", "zcurl", "zmdown"]}
        differences = {p for p in set(previous) | set(expected) if previous.get(p) != expected.get(p)}
        if not differences <= allowed:
            raise RuntimeError(f"non-module payload changes: {differences - allowed}")
        for name in differences:
            destination = prefix / name
            temporary = destination.with_name(destination.name + ".new")
            shutil.copy2(payload / name, temporary)
            os.replace(temporary, destination)
        atomic_json(record, {"release": b["release"], "files": expected})
        print("Published exact tested native modules:", ", ".join(sorted(differences)))
    else:
        receipt = json.loads((work / "validation.json").read_text())
        if not receipt.get("passed") or receipt["release"] != b["release"]:
            raise RuntimeError("release has no passing validation receipt")
        if manifest(prefix) != expected or receipt["payload_manifest"] != expected:
            raise RuntimeError("release differs from the tested payload")
        links = [(BASE / "current", Path("releases") / b["release"]),
                 (Path("/usr/local/bin/psh"), BASE / "current/bin/psh"),
                 (Path("/usr/local/bin/psh-config"), BASE / "current/bin/psh-config")]
        for path, target in links:
            check_link(path)
        for p in [BASE / "etc", BASE / "site-functions", BASE / "state"]:
            p.mkdir(parents=True, exist_ok=True)
        shells = Path("/etc/shells")
        old = shells.read_bytes()
        for path, target in links:
            link(path, target)
        if b"/usr/local/bin/psh" not in old.splitlines():
            backup = BASE / "state" / ("shells.before-" + time.strftime("%Y%m%d-%H%M%S"))
            shutil.copy2(shells, backup)
            s = shells.stat()
            new = old + (b"" if not old or old.endswith(b"\n") else b"\n") + b"/usr/local/bin/psh\n"
            fd, temporary = tempfile.mkstemp(prefix=".psh-shells-", dir="/etc")
            try:
                with os.fdopen(fd, "wb") as out:
                    out.write(new)
                    out.flush()
                    os.fsync(out.fileno())
                os.chmod(temporary, stat.S_IMODE(s.st_mode))
                os.chown(temporary, s.st_uid, s.st_gid)
                os.replace(temporary, shells)
            finally:
                if os.path.exists(temporary):
                    os.unlink(temporary)
        atomic_json(BASE / "state/active.json", {"release": b["release"], "prefix": str(prefix)})
        print(f"Activated /usr/local/bin/psh -> {prefix}/bin/psh")


if __name__ == "__main__":
    main()
