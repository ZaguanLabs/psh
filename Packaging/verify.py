#!/usr/bin/env python3
"""Snapshot stable Zsh, stage tested modules, or verify an inactive psh release."""
import argparse
import hashlib
import json
import os
from pathlib import Path
import pty
import pwd
import select
import shutil
import signal
import tempfile
import time
import subprocess

from audit import stable_snapshot
from install import manifest

ROOT = Path(__file__).resolve().parent.parent
SUITES = ["core", "zdraw", "zmdown", "zcurl", "zjson", "zhtml2md", "zoup"]


def sha(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def startup(shell):
    with tempfile.TemporaryDirectory(prefix="psh-startup-") as directory:
        home = Path(directory)
        trace = home / "trace"
        for name in ["zshenv", "zprofile", "zshrc", "zlogin", "zlogout"]:
            content = f"print -r -- {name} >> \"$PSH_STARTUP_TRACE\"\n"
            if name == "zshrc":
                content += "PROMPT='psh-test> '; HISTFILE=''\n"
            (home / ("." + name)).write_text(content)
        env = {"HOME": directory, "ZDOTDIR": directory, "PATH": "/usr/bin:/bin",
               "TERM": "xterm-256color", "LC_ALL": "C.UTF-8", "PSH_STARTUP_TRACE": str(trace)}
        pid, fd = pty.fork()
        if pid == 0:
            os.execve(shell, [str(shell), "-dil"], env)
        transcript = b""
        completed = False
        try:
            deadline = time.monotonic() + 15
            sent = False
            while time.monotonic() < deadline:
                if select.select([fd], [], [], 0.1)[0]:
                    try:
                        data = os.read(fd, 65536)
                    except OSError:
                        break
                    if not data:
                        break
                    transcript += data
                    if b"psh-test> " in transcript and not sent:
                        os.write(fd, b"print -r -- PSH_INTERACTIVE_OK:$options[interactive]:$options[login]; exit\n")
                        sent = True
            # Drain the PTY through EOF before reaping: a fast child can exit
            # while its final output is still waiting in the terminal buffer.
            while not completed and time.monotonic() < deadline:
                exited, status = os.waitpid(pid, os.WNOHANG)
                completed = bool(exited)
                if not completed:
                    time.sleep(0.01)
            if not completed:
                raise RuntimeError("interactive startup did not exit promptly")
            if os.waitstatus_to_exitcode(status) != 0 or b"PSH_INTERACTIVE_OK:on:on" not in transcript:
                raise RuntimeError(f"interactive login smoke failed: {transcript!r}")
            assert trace.read_text().splitlines() == ["zshenv", "zprofile", "zshrc", "zlogin", "zlogout"]
        finally:
            os.close(fd)
            if not completed:
                os.kill(pid, signal.SIGKILL)
                os.waitpid(pid, 0)
    return "interactive login PTY and all five original startup filenames passed"


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("action", choices=["snapshot", "stage-modules", "verify"])
    parser.add_argument("--build", type=Path, default=ROOT / ".work/package/latest.json")
    args = parser.parse_args()
    b = json.loads(args.build.read_text())
    work, prefix, payload = map(Path, [b["work"], b["prefix"], b["payload"]])
    if args.action == "snapshot":
        for name, value in [("stable-before.json", json.dumps(stable_snapshot(), indent=2) + "\n"),
                            ("login-shell-before.txt", pwd.getpwuid(os.getuid()).pw_shell + "\n")]:
            with (work / name).open("x") as out:
                out.write(value)
        print("Saved local-only stable Zsh and login-shell snapshots")
        return
    reports = {name: json.loads((work / f"test-{name}.json").read_text()) for name in SUITES}
    shell = prefix / "bin/psh"
    for name, report in reports.items():
        if not report["passed"] or report["release"] != b["release"] or report["shell"] != str(shell):
            raise RuntimeError(f"suite did not pass with this psh: {name}")
        if report.get("shell_sha256", sha(shell)) != sha(shell):
            raise RuntimeError(f"suite tested a different psh: {name}")
    tested = {"zdraw": ROOT / "Vendor/zdraw/.build/modules/zdraw.so",
              "zmdown": ROOT / "Vendor/zmdown/.build/modules/zmdown.so",
              "zcurl": ROOT / "Vendor/zcurl/build/zcurl.so"}
    modules = Path("lib/psh/5.9.2")
    if args.action == "stage-modules":
        for name, path in tested.items():
            shutil.copy2(path, payload / modules / (name + ".so"))
        print("Staged the three exact native modules exercised by the project suites")
        return
    before = json.loads((work / "stable-before.json").read_text())
    after = stable_snapshot()
    if before != after:
        changed = [p for p in set(before) | set(after) if before.get(p) != after.get(p)]
        raise RuntimeError(f"protected Zsh installation changed: {changed}")
    assert pwd.getpwuid(os.getuid()).pw_shell == (work / "login-shell-before.txt").read_text().strip()
    for name, entry in json.loads((ROOT / "Vendor/sources.json").read_text()).items():
        for file, digest in entry["files"].items():
            assert sha(ROOT / "Vendor" / name / file) == digest, f"vendor source changed: {name}/{file}"
    for file, digest in b["core_source_sha256"].items():
        assert sha(ROOT / file) == digest, f"build input changed: {file}"
    assert sha(shell) == sha(Path(b["core"]) / "Src/zsh") == sha(payload / "bin/psh")
    for name, file in tested.items():
        assert sha(file) == sha(prefix / modules / (name + ".so")) == sha(payload / modules / (name + ".so"))
    expected = manifest(payload)
    assert manifest(prefix) == expected
    env = {"PATH": "/usr/bin:/bin", "LC_ALL": "C.UTF-8", "PSH_PREFIX": str(prefix)}
    stable_paths = subprocess.run(["/usr/bin/zsh", "-dfc", "print -rl -- $module_path"],
                                  env=env, text=True, capture_output=True, check=True).stdout.splitlines()
    stable_modules = set()
    for directory in stable_paths:
        folder = Path(directory)
        if folder.is_dir():
            stable_modules.update(str(file.relative_to(folder)) for file in folder.rglob("*.so"))
    package_modules = {str(file.relative_to(prefix / modules)) for file in (prefix / modules).rglob("*.so")}
    if stable_modules - package_modules:
        raise RuntimeError(f"stock modules missing from psh: {sorted(stable_modules - package_modules)}")
    script = r'''
setopt errexit
[[ $ZSH_VERSION == 5.9.2 ]]
[[ $module_path == "$PSH_PREFIX/lib/psh/5.9.2" ]]
[[ ${(j.:.)fpath} == "/usr/local/psh/site-functions:$PSH_PREFIX/share/psh/5.9.2/functions" ]]
zmodload zsh/system zsh/parameter zsh/curses zsh/pcre zdraw zcurl zmdown
setopt rematchpcre
[[ psh =~ '^p(sh)$' && $match[1] == sh ]]
unsetopt rematchpcre
autoload -Uz zjson_quote zhtml2md zoup zdraw-ui zdraw-color
zjson_quote 'psh'; [[ $REPLY == '"psh"' ]]
zjson_quote 'again'; [[ $REPLY == '"again"' ]]
zjson_get '{"app":"psh"}' /app; [[ $REPLY == psh ]]
autoload -Uz zjson
zjson
zjson_validate '{"bundled":true}'
[[ $(zhtml2md <<< '<p>&copy; psh</p>') == '© psh' ]]
[[ $(zhtml2md <<< '<p>again</p>') == again ]]
zoup clean -- '<p>hello<script>bad()</script></p>'; [[ $REPLY == '<p>hello</p>' ]]
[[ $(zmdown --plain --text '**hello**') == hello ]]
typeset -A zdraw_color=(profile 16 encoding indexed)
REPLY=sentinel
zdraw-color 1; [[ $REPLY == 1 ]]
zdraw-color 2; [[ $REPLY == 2 ]]
zdraw-ui
[[ -n $functions[zdraw-ui-theme] ]]
zmodload -u zcurl
source "$PSH_PREFIX/share/psh/5.9.2/scripts/zcurl/zcurl.zsh"
zmodload -e zcurl
print -r -- PSH_PACKAGE_OK
while IFS= read -r entry; do
  if [[ $entry == *'/zsh/'*'.so'* || $entry == *'/zdraw.so'* || $entry == *'/zcurl.so'* || $entry == *'/zmdown.so'* ]]; then
    print -r -- "${entry##* }"
  fi
done < /proc/$$/maps
'''
    with tempfile.TemporaryDirectory(prefix="psh-installed-") as cwd:
        result = subprocess.run([str(shell), "-dfc", script], cwd=cwd, env=env,
                                text=True, capture_output=True, timeout=30)
    (work / "logs/installed-smoke.log").write_text(result.stdout + result.stderr)
    if result.returncode != 0 or not result.stdout.startswith("PSH_PACKAGE_OK\n"):
        raise RuntimeError(f"installed package smoke failed: {result.returncode}; see installed-smoke.log")
    mapped = sorted(set(result.stdout.splitlines()[1:]))
    assert mapped and all(path.startswith(str(prefix) + "/") for path in mapped), mapped
    for name in ["zdraw.so", "zcurl.so", "zmdown.so", "curses.so"]:
        assert any(path.endswith("/" + name) for path in mapped), name
    startup_result = startup(shell)
    receipt = {"passed": True, "release": b["release"], "payload_manifest": expected,
               "shell_sha256": sha(shell), "native_sha256": {name: sha(file) for name, file in tested.items()},
               "suites": reports, "stable_protected_entries": len(before), "stable_unchanged": True,
               "login_shell_unchanged": True, "mapped_modules": mapped, "startup": startup_result,
               "stock_modules_preserved": sorted(stable_modules)}
    (work / "validation.json").write_text(json.dumps(receipt, indent=2) + "\n")
    print(f"Verified {len(before)} protected entries unchanged; all seven suites passed")
    print(startup_result)
    print("Validation receipt:", work / "validation.json")


if __name__ == "__main__":
    main()
