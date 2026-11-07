"""Local-only snapshots protecting the existing Zsh installation and startup files."""
import hashlib
import os
from pathlib import Path
import stat

PATHS = ["/bin/zsh", "/usr/bin/zsh", "/usr/local/bin/zsh", "/etc/zshenv",
         "/etc/zshrc", "/etc/zprofile", "/etc/zlogin", "/etc/zlogout", "/etc/zsh",
         "/usr/lib/zsh", "/usr/lib64/zsh", "/usr/local/lib/zsh", "/usr/local/lib64/zsh",
         "/usr/share/zsh", "/usr/local/share/zsh", "/usr/include/zsh", "/usr/local/include/zsh"]


def stable_snapshot():
    paths = set(map(Path, PATHS))
    paths.update(Path("/usr/share/man/man1").glob("zsh*"))
    paths.update(Path("/usr/local/share/man/man1").glob("zsh*"))
    for name in [".zshenv", ".zprofile", ".zshrc", ".zlogin", ".zlogout"]:
        paths.add(Path.home() / name)
    files = set(paths)
    for path in paths:
        if path.is_dir() and not path.is_symlink():
            files.update(path.rglob("*"))
    rows = {}
    for path in sorted(files):
        try:
            s = path.lstat()
        except FileNotFoundError:
            rows[str(path)] = {"kind": "absent"}
            continue
        item = {"mode": stat.S_IMODE(s.st_mode), "uid": s.st_uid, "gid": s.st_gid}
        if path.is_symlink():
            item.update(kind="symlink", target=os.readlink(path))
        elif path.is_file():
            item.update(kind="file", sha256=hashlib.sha256(path.read_bytes()).hexdigest())
        else:
            item.update(kind="directory")
        rows[str(path)] = item
    return rows
