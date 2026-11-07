#!/usr/bin/env python3
"""Build and stage a self-contained psh distribution and its pinned packages."""
import argparse
import hashlib
import json
import os
from pathlib import Path
import re
import shutil
import subprocess

ROOT = Path(__file__).resolve().parent.parent
VERSION = "5.9.2"


def sha(path):
    return hashlib.sha256(Path(path).read_bytes()).hexdigest()


def run(command, cwd, log):
    print("Running:", " ".join(map(str, command)), flush=True)
    with log.open("wb") as out:
        subprocess.run(list(map(str, command)), cwd=cwd, stdout=out,
                       stderr=subprocess.STDOUT, check=True)


def copy(source, target):
    target.parent.mkdir(parents=True, exist_ok=True)
    if source.is_symlink():
        target.symlink_to(os.readlink(source))
    else:
        shutil.copy2(source, target)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--jobs", type=int, default=8)
    args = parser.parse_args()
    sources = json.loads((ROOT / "Vendor/sources.json").read_text())
    for name, entry in sources.items():
        for path, digest in entry["files"].items():
            if sha(ROOT / "Vendor" / name / path) != digest:
                raise RuntimeError(f"vendored source changed: {name}/{path}")
    names = list(json.loads((ROOT / "Perf/upstream-sha256.json").read_text()))
    fingerprints = {name: sha(ROOT / name) for name in names}
    fingerprints["Packaging/build.py"] = sha(Path(__file__))
    fingerprints["Vendor/sources.json"] = sha(ROOT / "Vendor/sources.json")
    fingerprints["LICENSE"] = sha(ROOT / "LICENSE")
    digest = hashlib.sha256(json.dumps(fingerprints, sort_keys=True).encode()).hexdigest()[:12]
    release = f"{VERSION}-{digest}"
    prefix = Path("/usr/local/psh/releases") / release
    work = ROOT / ".work/package" / release
    core, stage, logs = work / "core", work / "stage", work / "logs"
    if work.exists():
        raise RuntimeError(f"build already exists: {work}; retain it and use its build.json")
    core.mkdir(parents=True)
    logs.mkdir()
    for name in names:
        copy(ROOT / name, core / name)
    draw = ROOT / "Vendor/zdraw"
    for name in ("zdraw.c", "zdraw.mdd", "zdraw_keys.awk", "zdraw_grapheme.h",
                 "zdraw_grapheme_data.h", "zdraw_raster.h"):
        copy(draw / "Src/Modules" / name, core / "Src/Modules" / name)
    copy(draw / "Doc/Zsh/mod_zdraw.yo", core / "Doc/Zsh/mod_zdraw.yo")
    patch = draw / "patches/zdraw-build.patch"
    with patch.open("rb") as data:
        subprocess.run(["patch", "-p1"], cwd=core, stdin=data, check=True)
    copy(patch, core / ".zdraw-build-patch")
    md = ROOT / "Vendor/zmdown"
    mapping = {"zmdown.c": "src/zmdown.c", "zmdown.mdd": "src/zmdown.mdd",
               "render.h": "src/render.h", "grapheme.h": "src/grapheme.h",
               "grapheme_data.h": "src/grapheme_data.h", "zmd_render.c": "src/render.c",
               "zmd_grapheme.c": "src/grapheme.c", "zmd_md4c.c": "vendor/md4c/md4c.c",
               "zmd_entity.c": "vendor/md4c/entity.c", "md4c.h": "vendor/md4c/md4c.h",
               "entity.h": "vendor/md4c/entity.h"}
    for name, source in mapping.items():
        copy(md / source, core / "Src/Modules" / name)
    run(["autoconf"], core, logs / "autoconf.log")
    run(["autoheader"], core, logs / "autoheader.log")
    configure = ["./configure", f"--prefix={prefix}", "--program-transform-name=s/zsh/psh/",
                 "--enable-dynamic", "--enable-multibyte", "--enable-zsh-debug", "--enable-pcre",
                 "--enable-etcdir=/usr/local/psh/etc", "--enable-site-fndir=no",
                 "--enable-additional-fpath=/usr/local/psh/site-functions"]
    env = dict(os.environ, CFLAGS="-O2 -g")
    with (logs / "configure.log").open("wb") as out:
        subprocess.run(configure, cwd=core, env=env, stdout=out,
                       stderr=subprocess.STDOUT, check=True)
    run(["make", f"-j{args.jobs}"], core, logs / "core-build.log")
    run(["make", "install", f"DESTDIR={stage}"], core, logs / "core-stage.log")
    payload = stage / prefix.relative_to("/")
    modules = payload / "lib/psh" / VERSION
    functions = payload / "share/psh" / VERSION / "functions"
    scripts = payload / "share/psh" / VERSION / "scripts"
    run(["make", "all", f"ZSH_SRC={core}", "CFLAGS=-O2 -g"],
        ROOT / "Vendor/zcurl", logs / "zcurl-build.log")
    copy(ROOT / "Vendor/zcurl/build/zcurl.so", modules / "zcurl.so")
    runtime = {"zjson": ["zjson.zsh", "lib"], "zhtml2md": ["zhtml2md.zsh", "lib", "data"],
               "zoup": ["functions", "bin"],
               "zdraw": ["lib", "VERSION", "examples/components"],
               "zcurl": ["zcurl.zsh", "completions"], "zmdown": []}
    for name, parts in runtime.items():
        project = ROOT / "Vendor" / name
        for part in parts + [p.name for p in project.iterdir()
                             if p.is_file() and (p.name.startswith("LICEN") or p.name in ["README.md", "NOTICE"])]:
            src, dst = project / part, scripts / name / part
            if src.is_dir():
                shutil.copytree(src, dst)
            else:
                copy(src, dst)
    # Keep the zcurl source loader's documented relative module location.
    target = scripts / "zcurl/build/zcurl.so"
    target.parent.mkdir()
    target.symlink_to(os.path.relpath(modules / "zcurl.so", target.parent))
    licences = payload / "share/psh" / VERSION / "licenses"
    for source, destination in {
            "LICENCE": "zsh/LICENCE", "LICENSE": "psh/LICENSE",
            "Vendor/zmdown/vendor/md4c/LICENSE.md": "zmdown/md4c-LICENSE.md",
            "Vendor/zmdown/vendor/unicode/LICENSE.txt": "zmdown/unicode-LICENSE.txt",
            "Vendor/zdraw/tests/unicode/LICENSE.txt": "zdraw/unicode-LICENSE.txt"}.items():
        copy(ROOT / source, licences / destination)
    for source in (ROOT / "Vendor/zoup/functions").iterdir():
        copy(source, functions / source.name)
    for source in (ROOT / "Vendor/zcurl/completions").iterdir():
        copy(source, functions / source.name)

    def loader(name, entry, invoke=False):
        target = functions / name
        if target.exists():
            raise RuntimeError(f"autoload collision: {name}")
        text = f"# Bundled psh loader; public package names are unchanged.\n'builtin' 'source' -- \"${{${{(%):-%x}}:A:h:h}}/scripts/{entry}\" || return $?\n"
        if invoke:
            text += f"'{name}' \"$@\"\n"
        target.write_text(text)
    loader("zjson", "zjson/zjson.zsh")
    public = set()
    for file in (ROOT / "Vendor/zjson/lib").glob("*.zsh"):
        public.update(re.findall(r"(?m)^(zjson_[A-Za-z0-9_]+)\(\)\s*\{", file.read_text()))
    for name in sorted(public):
        loader(name, "zjson/zjson.zsh", True)
    loader("zhtml2md", "zhtml2md/zhtml2md.zsh", True)
    draw_functions = set()
    for file in (ROOT / "Vendor/zdraw/lib").rglob("*.zsh"):
        for function, traditional in re.findall(
                r"(?m)^(?:function\s+([A-Za-z_][A-Za-z0-9_-]*)\s*\{|([A-Za-z_][A-Za-z0-9_-]*)\(\)\s*\{)",
                file.read_text()):
            draw_functions.add(function or traditional)
    for file in (ROOT / "Vendor/zdraw/lib").glob("*.zsh"):
        loader(file.stem, "zdraw/lib/" + file.name, file.stem in draw_functions)
    include = payload / "include/psh"
    for file in [core / "config.h", *(core / "Src").glob("*.h"),
                 *(core / "Src").glob("*.mdh"), *(core / "Src").glob("*.epro")]:
        copy(file, include / file.relative_to(core))
    config = payload / "bin/psh-config"
    values = {"--prefix": str(prefix), "--version": VERSION,
              "--module-dir": str(prefix / "lib/psh" / VERSION),
              "--function-dir": str(prefix / "share/psh" / VERSION / "functions"),
              "--script-dir": str(prefix / "share/psh" / VERSION / "scripts"),
              "--headers-root": str(prefix / "include/psh"), "--mandir": str(prefix / "share/man")}
    config.write_text("#!/bin/sh\ncase \"${1:---prefix}\" in\n" + "".join(
        f"  {key}) printf '%s\\n' '{value}' ;;\n" for key, value in values.items()) +
        "  *) echo 'Usage: psh-config [--prefix|--version|--module-dir|--function-dir|--script-dir|--headers-root|--mandir]' >&2; exit 2 ;;\nesac\n")
    config.chmod(0o755)
    build = {"release": release, "prefix": str(prefix), "work": str(work), "core": str(core),
             "stage": str(stage), "payload": str(payload), "configure": configure,
             "cflags": "-O2 -g", "core_source_sha256": fingerprints,
             "vendor_commits": {name: row["commit"] for name, row in sources.items()},
             "zjson_autoload_functions": sorted(public)}
    (work / "build.json").write_text(json.dumps(build, indent=2) + "\n")
    (ROOT / ".work/package/latest.json").write_text(json.dumps(build, indent=2) + "\n")
    print(json.dumps({k: build[k] for k in ("release", "prefix", "payload", "core")}, indent=2))


if __name__ == "__main__":
    main()
