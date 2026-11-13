"""Compile an isolated core, optionally training GCC before its final build."""
import hashlib
import json
import os
from pathlib import Path
import shlex
import subprocess
import sys


def compiler_identity():
    command = shlex.split(os.environ.get("CC", "cc"))
    version = subprocess.check_output(command + ["--version"], text=True)
    return {"command": command, "version": version.splitlines()[0]}


def compiler_flags(optimization, profiles="@PROFILE_DIR@", generate=False):
    base = "-O2 -g" + (" -flto" if "lto" in optimization else "")
    link = "-g" + (" -flto" if "lto" in optimization else "")
    if optimization.startswith("pgo"):
        flag = shlex.quote(("-fprofile-generate=" if generate else "-fprofile-use=") + str(profiles))
        base += " " + flag
        link += " " + flag
        if not generate:
            base += " -fprofile-partial-training -Werror=coverage-mismatch"
    return base, link


def compile_core(root, core, work, configure, jobs, optimization):
    logs = work / "logs"
    profiles = work / "profiles"
    base, base_link = compiler_flags("lto" if "lto" in optimization else "standard")
    env = dict(os.environ, LC_ALL="C.UTF-8")
    # Exported gcov relocation settings must not redirect this build's evidence.
    for key in ("GCOV_PREFIX", "GCOV_PREFIX_STRIP", "GCOV_ERROR_FILE"):
        env.pop(key, None)

    def run(name, command, cflags=base, ldflags=base_link):
        print("Running:", " ".join(map(str, command)), flush=True)
        with (logs / (name + ".log")).open("wb") as out:
            subprocess.run(list(map(str, command)), cwd=core,
                           env=dict(env, CFLAGS=cflags, LDFLAGS=ldflags),
                           stdout=out, stderr=subprocess.STDOUT, check=True)

    training = None
    # Configure probes must use ordinary flags. Instrumenting the many different
    # conftest programs would collide in gcov's files and corrupt later probes.
    run("configure", configure)
    if optimization.startswith("pgo"):
        compiler = compiler_identity()
        macros = subprocess.check_output(compiler["command"] + ["-dM", "-E", "-x", "c", "/dev/null"], text=True)
        if "__GNUC__" not in macros or "__clang__" in macros:
            raise RuntimeError("profile-guided packaging currently requires GCC")
        profiles.mkdir()
        generate, generate_link = compiler_flags(optimization, profiles, generate=True)
        overrides = ["CFLAGS=" + generate, "LDFLAGS=" + generate_link]
        run("training-build", ["make", f"-j{jobs}", *overrides], generate, generate_link)
        modules = work / "training-modules"
        run("training-modules", ["make", f"MODDIR={modules}", "install.modules", *overrides], generate, generate_link)
        command = [sys.executable, root / "Packaging/train-compiler.py", "--shell", core / "Src/zsh",
                   "--modules", modules, "--output", work / "training.json"]
        run("training", command, generate, generate_link)
        data = sorted(profiles.rglob("*.gcda"))
        for unit in ("exec", "params", "math", "utils", "mem", "subst", "pattern"):
            if not any(p.name.endswith("#" + unit + ".gcda") or p.name == unit + ".gcda" for p in data):
                raise RuntimeError("missing core training profile: " + unit)
        training = json.loads((work / "training.json").read_text())
        training["profile_sha256"] = {str(p.relative_to(profiles)): hashlib.sha256(p.read_bytes()).hexdigest()
                                     for p in data}
        training["compiler"] = compiler
        run("training-clean", ["make", "clean"])
        cflags, ldflags = compiler_flags(optimization, profiles)
    else:
        cflags, ldflags = base, base_link
    run("core-build", ["make", f"-j{jobs}", "CFLAGS=" + cflags, "LDFLAGS=" + ldflags], cflags, ldflags)
    if training:
        # Unloaded optional modules have no training data. GCC uses its ordinary
        # heuristics for them; preserve and identify every such warning.
        text = (logs / "core-build.log").read_text(errors="replace")
        training["untrained_unit_warnings"] = [line for line in text.splitlines()
                                                if "missing-profile" in line]
        training["final_cflags"] = cflags
        (work / "training.json").write_text(json.dumps(training, indent=2) + "\n")
    return cflags, ldflags, training
