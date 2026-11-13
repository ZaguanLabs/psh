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

from elf import split_symbols
from version import versions
from compiler import compile_core, compiler_flags, compiler_identity

ROOT = Path(__file__).resolve().parent.parent
PROJECT_VERSION, VERSION = versions(ROOT)


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
    parser.add_argument("--symbols", choices=["split", "embedded"], default="split")
    parser.add_argument("--profile", choices=["release", "debug"], default="release",
                        help="release disables Zsh debug assertions; debug enables them (symbols are independent)")
    parser.add_argument("--optimization", choices=["standard", "lto", "pgo", "pgo-lto"], default="standard",
                        help="compiler optimization experiment; default retains the ordinary release flags")
    args = parser.parse_args()
    if args.jobs < 1:
        parser.error("--jobs must be positive")
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
    for name in ["Packaging/verify.py", "Packaging/install.py",
                 "Perf/check-convfloat-loaders.py", "Perf/convfloat-loader-library.c"]:
        fingerprints[name] = sha(ROOT / name)
    for name in ["Src/psh_version.h", "Packaging/elf.py", "Packaging/version.py"]:
        fingerprints[name] = sha(ROOT / name)
    for name in ["Packaging/compiler.py", "Packaging/train-compiler.py", "Perf/compiler-training.zsh",
                 "Perf/application-workload.zsh"]:
        fingerprints[name] = sha(ROOT / name)
    debug_assertions = args.profile == "debug"
    # Upstream disables GDBM by default. Retain it when the host's stable Zsh
    # ships the module; the final inventory gate still checks every module.
    stock_paths = subprocess.check_output(
        ["/usr/bin/zsh", "-dfc", "print -rl -- $module_path"],
        env={"PATH": "/usr/bin:/bin", "LC_ALL": "C.UTF-8"}, text=True).splitlines()
    enable_gdbm = any((Path(folder) / "zsh/db/gdbm.so").is_file() for folder in stock_paths)
    configured_cflags, configured_ldflags = compiler_flags(args.optimization)
    settings = {"symbols": args.symbols, "cflags": configured_cflags, "ldflags": configured_ldflags, "profile": args.profile,
                "debug_assertions": debug_assertions, "optimization": args.optimization,
                "gdbm": enable_gdbm,
                "compiler": compiler_identity()}
    digest = hashlib.sha256(json.dumps({"sources": fingerprints, "settings": settings},
                                      sort_keys=True).encode()).hexdigest()[:12]
    release = f"{PROJECT_VERSION}-{digest}"
    prefix = Path("/usr/local/psh/releases") / release
    work = ROOT / ".work/package" / release
    core, stage, logs = work / "core", work / "stage", work / "logs"
    if work.exists():
        raise RuntimeError(f"build already exists: {work}; retain it and use its build.json")
    core.mkdir(parents=True)
    logs.mkdir()
    for name in names:
        copy(ROOT / name, core / name)
    copy(ROOT / "Src/psh_version.h", core / "Src/psh_version.h")
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
                 "--enable-dynamic", "--enable-multibyte",
                 "--enable-zsh-debug" if debug_assertions else "--disable-zsh-debug", "--enable-pcre",
                 "--enable-etcdir=/usr/local/psh/etc", "--enable-site-fndir=no",
                 "--enable-additional-fpath=/usr/local/psh/site-functions"]
    if enable_gdbm:
        configure.append("--enable-gdbm")
    # Otherwise release configure defaults add -s at link time, before the
    # separate debugger file can be created. Symbols do not require DEBUG.
    cflags, ldflags, training = compile_core(ROOT, core, work, configure, args.jobs, args.optimization)
    run(["make", "install", f"DESTDIR={stage}"], core, logs / "core-stage.log")
    payload = stage / prefix.relative_to("/")
    raw_shell_sha256 = sha(core / "Src/zsh")
    shell = payload / "bin/psh"
    versioned_shell = payload / "bin" / ("psh-" + VERSION)
    versioned_shell.unlink()
    versioned_shell.symlink_to("psh")
    debug_file = None
    runtime_sections = None
    if args.symbols == "split":
        debug_file = Path("bin/.debug/psh.debug")
        runtime_sections = split_symbols(shell, payload / debug_file)
    modules = payload / "lib/psh" / VERSION
    functions = payload / "share/psh" / VERSION / "functions"
    scripts = payload / "share/psh" / VERSION / "scripts"
    # Compiler experiments must not replace another host's native-module cache.
    curl_source = work / "zcurl-source"
    for name in sources["zcurl"]["files"]:
        if name == "Makefile" or name.startswith("src/"):
            copy(ROOT / "Vendor/zcurl" / name, curl_source / name)
    run(["make", "all", f"ZSH_SRC={core}", "CFLAGS=-O2 -g"],
        curl_source, logs / "zcurl-build.log")
    copy(curl_source / "build/zcurl.so", modules / "zcurl.so")
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
    values = {"--prefix": str(prefix), "--version": PROJECT_VERSION,
              "--zsh-version": VERSION, "--build-id": digest,
              "--module-dir": str(prefix / "lib/psh" / VERSION),
              "--function-dir": str(prefix / "share/psh" / VERSION / "functions"),
              "--script-dir": str(prefix / "share/psh" / VERSION / "scripts"),
              "--headers-root": str(prefix / "include/psh"), "--mandir": str(prefix / "share/man")}
    config.write_text("#!/bin/sh\ncase \"${1:---prefix}\" in\n" + "".join(
        f"  {key}) printf '%s\\n' '{value}' ;;\n" for key, value in values.items()) +
        "  *) echo 'Usage: psh-config [--prefix|--version|--zsh-version|--build-id|--module-dir|--function-dir|--script-dir|--headers-root|--mandir]' >&2; exit 2 ;;\nesac\n")
    config.chmod(0o755)
    # Python-created parent directories inherit the caller's umask. A 0002
    # umask otherwise leaves e.g. share/psh/5.9.2 group-writable, which compaudit
    # correctly rejects even when functions/ itself was installed with 0755.
    # Tighten only distribution directories; never alter source or user paths.
    for directory in [payload, *(p for p in payload.rglob("*") if p.is_dir() and not p.is_symlink())]:
        directory.chmod(directory.stat().st_mode & 0o7777 & ~0o022)
    build = {"release": release, "prefix": str(prefix), "work": str(work), "core": str(core),
             "project_version": PROJECT_VERSION, "zsh_version": VERSION,
             "settings": settings, "raw_shell_sha256": raw_shell_sha256,
             "installed_shell_sha256": sha(shell),
             "debug_file": str(debug_file) if debug_file else None,
             "debug_file_sha256": sha(payload / debug_file) if debug_file else None,
             "runtime_sections": runtime_sections,
             "stage": str(stage), "payload": str(payload), "configure": configure,
             "cflags": cflags, "ldflags": ldflags, "compiler_training": training,
             "payload_directory_policy": "remove group/other write permissions independent of caller umask",
             "core_source_sha256": fingerprints,
             "vendor_commits": {name: row["commit"] for name, row in sources.items()},
             "zjson_autoload_functions": sorted(public)}
    (work / "build.json").write_text(json.dumps(build, indent=2) + "\n")
    (ROOT / ".work/package/latest.json").write_text(json.dumps(build, indent=2) + "\n")
    print(json.dumps({k: build[k] for k in ("release", "prefix", "payload", "core")}, indent=2))


if __name__ == "__main__":
    main()
