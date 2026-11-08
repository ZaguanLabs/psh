#!/usr/bin/env python3
"""Create a source RC with its verified upstream baseline, without build caches."""
import argparse
import hashlib
import io
import json
import lzma
from pathlib import Path
import subprocess
import tarfile
import tempfile

from version import versions

ROOT = Path(__file__).resolve().parent.parent


def git(*args):
    return subprocess.check_output(["git", *args], cwd=ROOT)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--ref", default="HEAD")
    parser.add_argument("--output", type=Path)
    args = parser.parse_args()
    if git("status", "--porcelain").strip():
        parser.error("commit the release inputs first; the working tree must be clean")
    project, upstream = versions(ROOT)
    if args.output is None:
        args.output = ROOT / ".work/releases" / ("v" + project)
    commit = git("rev-parse", args.ref + "^{commit}").decode().strip()
    if git("show", commit + ":Src/psh_version.h") != (ROOT / "Src/psh_version.h").read_bytes():
        parser.error("selected commit has a different project version")
    if git("show", commit + ":Config/version.mk") != (ROOT / "Config/version.mk").read_bytes():
        parser.error("selected commit has a different upstream version")
    source_name = f"psh-{project}"
    epoch = int(git("show", "-s", "--format=%ct", commit))
    baseline_ref = "refs/tags/upstream/zsh-" + upstream
    baseline = git("archive", "--format=tar", baseline_ref)
    # Validate the exact same pristine file set/content used by the build tool.
    manifest = json.loads(git("show", commit + ":Perf/upstream-sha256.json"))
    with tempfile.TemporaryDirectory(prefix="psh-source-release-") as temporary:
        scratch = Path(temporary)
        pristine = scratch / "pristine"
        with tarfile.open(fileobj=io.BytesIO(baseline)) as archive:
            archive.extractall(pristine, filter="data")
        files = {p.relative_to(pristine).as_posix()
                 for p in pristine.rglob("*") if p.is_file() or p.is_symlink()}
        if files != set(manifest) or any(hashlib.sha256((pristine / p).read_bytes()).hexdigest() != h
                                         for p, h in manifest.items()):
            raise RuntimeError("upstream archive differs from the pristine manifest")
        archive_path = scratch / "source.tar"
        archive_path.write_bytes(git("archive", "--format=tar", "--prefix=" + source_name + "/", commit))
        metadata = {"project_version": project, "zsh_version": upstream,
                    "source_commit": commit, "source_tree": git("rev-parse", commit + "^{tree}").decode().strip(),
                    "source_date_epoch": epoch, "upstream_commit": git("rev-parse", baseline_ref + "^{commit}").decode().strip(),
                    "baseline_files_verified": len(manifest)}
        additions = {
            "Perf/upstream/zsh-" + upstream + ".tar.xz": lzma.compress(baseline),
            "SOURCE-INFO.json": (json.dumps(metadata, indent=2) + "\n").encode()}
        with tarfile.open(archive_path, "a", format=tarfile.PAX_FORMAT) as archive:
            for name, data in sorted(additions.items()):
                member = tarfile.TarInfo(source_name + "/" + name)
                member.mode, member.mtime, member.size = 0o644, epoch, len(data)
                archive.addfile(member, io.BytesIO(data))
        content = lzma.compress(archive_path.read_bytes())
    args.output.mkdir(parents=True, exist_ok=True)
    target = args.output / (source_name + ".tar.xz")
    if target.exists() and target.read_bytes() != content:
        raise RuntimeError("a different candidate already exists at " + str(target))
    target.write_bytes(content)
    digest = hashlib.sha256(content).hexdigest()
    (args.output / "SHA256SUMS").write_text(digest + "  " + target.name + "\n")
    (args.output / "release.json").write_text(json.dumps(dict(metadata, archive=target.name,
                                                            archive_sha256=digest), indent=2) + "\n")
    print(json.dumps({"archive": str(target), "sha256": digest, "commit": commit}, indent=2))


if __name__ == "__main__":
    main()
