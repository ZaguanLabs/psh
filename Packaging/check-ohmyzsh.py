#!/usr/bin/env python3
"""Exercise unchanged installed Oh My Zsh in isolated interactive terminals."""
import argparse
import hashlib
import json
import os
from pathlib import Path
import pty
import re
import select
import shlex
import shutil
import signal
import subprocess
import tempfile
import time

ROOT = Path(__file__).resolve().parent.parent


def sha(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def source_identity(folder, extra=()):
    names = subprocess.check_output(["git", "-C", str(folder), "ls-files", "-z"]).split(b"\0")
    files = {folder / os.fsdecode(n) for n in names if n}
    files.update(extra)
    digest = hashlib.sha256()
    for file in sorted(files):
        if file.is_file():
            digest.update(os.fsencode(file.relative_to(folder)) + b"\0" + file.read_bytes() + b"\0")
    return {"commit": subprocess.check_output(["git", "-C", str(folder), "rev-parse", "HEAD"], text=True).strip(),
            "files": len(files), "source_sha256": digest.hexdigest()}


class Terminal:
    def __init__(self, shell, home, repository, env, login):
        self.pid, self.fd = pty.fork()
        if self.pid == 0:
            os.chdir(repository)
            os.execve(shell, [str(shell), "-dil" if login else "-di"], env)
        self.home = home
        self.transcript = bytearray()
        self.status = None

    def pump(self, timeout=0.04):
        if select.select([self.fd], [], [], timeout)[0]:
            try:
                data = os.read(self.fd, 65536)
            except OSError:
                data = b""
            if not data:
                raise RuntimeError("interactive shell closed: " + repr(bytes(self.transcript[-2000:])))
            self.transcript.extend(data)

    def until(self, predicate, timeout=30):
        deadline = time.monotonic() + timeout
        while time.monotonic() < deadline:
            if predicate():
                return
            self.pump()
        raise RuntimeError("interactive operation timed out: " + repr(bytes(self.transcript[-2000:])))

    def capture(self, keys=b""):
        target = self.home / "capture"
        target.unlink(missing_ok=True)
        os.write(self.fd, keys)
        # Drain the terminal's redraw before asking a separate ZLE widget for
        # the buffer and highlighter state; do not execute the typed command.
        self.pump()
        os.write(self.fd, b"\x18\x10")
        self.until(target.exists)
        fields = target.read_bytes().split(b"\0")
        assert fields[-1] == b"" and len(fields) >= 6, fields
        rendered = self.home / "render"
        def current_frame():
            if not rendered.exists():
                return False
            frame = rendered.read_bytes().split(b"\0")
            return frame[:3] == fields[:3]
        self.until(current_frame)
        frame = rendered.read_bytes().split(b"\0")
        return {"buffer": fields[1].decode(), "cursor": int(fields[2]),
                "async": fields[3].decode(), "git_prompt": fields[4].decode(),
                "highlights": [x.decode() for x in frame[3:-1]]}

    def finish(self):
        os.write(self.fd, b"\x15_psh_omz_exit\n")
        deadline = time.monotonic() + 10
        while time.monotonic() < deadline:
            pid, status = os.waitpid(self.pid, os.WNOHANG)
            if pid:
                self.status = os.waitstatus_to_exitcode(status)
                assert self.status == 0, self.status
                return
            # The final terminal close is expected after exit.
            try:
                self.pump()
            except RuntimeError:
                pass
        raise RuntimeError("interactive shell did not exit")

    def close(self):
        if self.status is None:
            parents = {}
            for path in Path("/proc").iterdir():
                if path.name.isdigit():
                    try:
                        status = (path / "status").read_text()
                        parents[int(path.name)] = int(next(s for s in status.splitlines() if s.startswith("PPid:")).split()[1])
                    except (OSError, StopIteration):
                        pass
            def stop_children(parent):
                for child, ppid in parents.items():
                    if ppid == parent:
                        stop_children(child)
                        try:
                            os.kill(child, signal.SIGKILL)
                        except ProcessLookupError:
                            pass
            stop_children(self.pid)
            try:
                os.kill(self.pid, signal.SIGKILL)
                os.waitpid(self.pid, 0)
            except ProcessLookupError:
                pass
        os.close(self.fd)


def run_session(shell, home, repository, omz, theme, plugins, highlight, login, inherited_fpath, history):
    for name in ["ready", "state", "capture", "gate", "render"]:
        (home / name).unlink(missing_ok=True)
    os.mkfifo(home / "gate")
    (home / ".zshrc").write_text('source "$PSH_OMZ_DRIVER"\n')
    env = {"HOME": str(home), "ZDOTDIR": str(home), "PATH": "/usr/bin:/bin", "TERM": "xterm-256color",
           "LC_ALL": "C.UTF-8", "GIT_CONFIG_NOSYSTEM": "1", "GIT_CONFIG_GLOBAL": "/dev/null",
           "PSH_OMZ_ROOT": str(omz), "PSH_OMZ_THEME": theme, "PSH_OMZ_PLUGINS": " ".join(plugins),
           "PSH_OMZ_HIGHLIGHT": str(highlight) if highlight else "",
           "PSH_OMZ_HISTSIZE": str(history["HISTSIZE"]), "PSH_OMZ_SAVEHIST": str(history["SAVEHIST"]),
           "PSH_OMZ_DRIVER": str(ROOT / "Perf/ohmyzsh-session.zsh")}
    for name in ["READY", "STATE", "CAPTURE", "GATE", "RENDER"]:
        env["PSH_OMZ_" + name] = str(home / name.lower())
    if inherited_fpath is not None:
        env["FPATH"] = inherited_fpath
    terminal = Terminal(shell, home, repository, env, login)
    try:
        terminal.until(lambda: (home / "ready").exists())
        initial = terminal.capture()
        assert initial["buffer"] == "" and initial["async"] == "", initial
        first = terminal.capture(b"git checkou\t")
        assert first["buffer"].rstrip(" ") == "git checkout" and first["async"] == "", first
        # Only now release the async worker. Completion above must have worked
        # while the worker was blocked, without a sleep standing in for a barrier.
        deadline = time.monotonic() + 5
        while True:
            try:
                fd = os.open(home / "gate", os.O_WRONLY | os.O_NONBLOCK)
                os.write(fd, b"PSH_OMZ_ASYNC_OK\n")
                os.close(fd)
                break
            except OSError:
                if time.monotonic() >= deadline:
                    raise RuntimeError("async worker never opened its barrier")
                terminal.pump()
        latest = first
        deadline = time.monotonic() + 5
        state = (home / "state").read_text()
        uses_git_prompt = "theme-uses-git-prompt=1\n" in state
        while ("PSH_OMZ_ASYNC_OK" not in latest["async"]
               or (uses_git_prompt and "psh-omz-main" not in latest["git_prompt"])):
            assert time.monotonic() < deadline, latest
            terminal.pump()
            latest = terminal.capture()
        git_prompt = latest["git_prompt"] if uses_git_prompt else None
        results = [{k: v for k, v in first.items() if k not in ("async", "git_prompt")}]
        cases = [(b"\x15cat alp\t", "cat alpha\\ beta.txt "),
                 (b'\x15cat "alp\t', 'cat "alpha beta.txt" '),
                 ("\x15cat wei\t".encode(), "cat weird-é界.txt ")]
        if "git" in plugins:
            cases.append((b"\x15gco psh-omz-si\t", "gco psh-omz-side "))
        cases.append((b"\x15echo psh-\x1b[A", "echo psh-omz-history"))
        for keys, expected in cases:
            value = terminal.capture(keys)
            # ZLE may remove an automatically inserted trailing suffix when
            # invoking the inspection widget. Compare the complete raw states
            # between interpreters below; only the known word is flexible here.
            assert value["buffer"].rstrip(" ") == expected.rstrip(" ") and value["cursor"] == len(value["buffer"]), value
            results.append({k: v for k, v in value.items() if k not in ("async", "git_prompt")})
        if highlight:
            assert all(row["highlights"] for row in results), results
        # Abort an actual command line and verify it neither executes nor
        # prevents the next input/redisplay cycle.
        os.write(terminal.fd, b"\x15print bad > should-not-exist\x03")
        value = terminal.capture()
        assert value["buffer"] == "" and not (repository / "should-not-exist").exists(), value
        assert "branch=psh-omz-main\n" in state, state
        if "git" in plugins:
            assert "git-alias=git checkout\n" in state, state
        assert (home / ".zcompdump").is_file() and (home / ".zcompdump.zwc").is_file()
        terminal.finish()
        return {"state": state, "buffers": results, "async_input_and_callback": True,
                "git_prompt_after_async": git_prompt,
                "interrupt_recovery": True, "completion_dump": True, "compiled_dump": True,
                "status": terminal.status}
    finally:
        terminal.close()


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--candidate", type=Path, required=True)
    parser.add_argument("--reference", type=Path, default=Path("/usr/bin/zsh"))
    parser.add_argument("--omz", type=Path, default=Path.home() / ".oh-my-zsh")
    parser.add_argument("--user-config", type=Path, default=Path.home() / ".zshrc")
    parser.add_argument("--theme")
    parser.add_argument("--plugin", action="append")
    parser.add_argument("--syntax-highlighting", type=Path)
    parser.add_argument("--output", type=Path, required=True)
    args = parser.parse_args()
    # A failed rerun must never leave an older passing certificate usable.
    args.output.parent.mkdir(parents=True, exist_ok=True)
    args.output.unlink(missing_ok=True)
    args.omz = args.omz.resolve(strict=True)
    config = args.user_config.read_text() if args.user_config.is_file() else ""
    theme_match = re.search(r'^ZSH_THEME=[\'"]?([A-Za-z0-9_./+-]*)[\'"]?\s*(?:#.*)?$', config, re.M)
    plugins_match = re.search(r'^plugins=\(([^)]*)\)', config, re.M)
    if args.theme is None and re.search(r'^ZSH_THEME=', config, re.M) and theme_match is None:
        parser.error("dynamic theme configuration needs an explicit --theme argument")
    if args.plugin is None and re.search(r'^plugins=', config, re.M) and plugins_match is None:
        parser.error("dynamic plugin configuration needs explicit --plugin arguments")
    theme = args.theme if args.theme is not None else (theme_match[1] if theme_match else "robbyrussell")
    plugins = args.plugin or (shlex.split(plugins_match[1], comments=True) if plugins_match else ["git"])
    history = {"HISTSIZE": 50000, "SAVEHIST": 10000}
    for name in history:
        match = re.search(r'^(?:export\s+)?' + name + r'=[\'"]?(\d+)[\'"]?\s*(?:#.*)?$', config, re.M)
        if match:
            history[name] = int(match[1])
    if any(not re.fullmatch(r"[A-Za-z0-9_.+-]+", p) for p in plugins):
        parser.error("dynamic plugin configuration needs explicit --plugin arguments")
    highlight = args.syntax_highlighting
    if highlight is None and "zsh-syntax-highlighting.zsh" in config:
        candidate = Path.home() / "projects/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
        if not candidate.is_file():
            parser.error("supply --syntax-highlighting for the configured highlighter")
        highlight = candidate
    if highlight:
        highlight = highlight.resolve(strict=True)
    sources = source_identity(args.omz, (args.omz / "custom").glob("*.zsh"))
    highlighter_sources = source_identity(highlight.parent) if highlight else None
    shells = {"reference": args.reference.resolve(strict=True), "candidate": args.candidate.resolve(strict=True)}
    binary_hashes = {k: sha(p) for k, p in shells.items()}
    profiles = [("configured", plugins, False, None), ("configured-login", plugins, True, None),
                ("extended", list(dict.fromkeys(plugins + ["git", "gitfast", "z", "extract", "sudo", "history-substring-search"])), False, None)]
    if "FPATH" in os.environ:
        profiles.append(("configured-inherited-fpath", plugins, False, os.environ["FPATH"]))
    rows = []
    with tempfile.TemporaryDirectory(prefix="psh-omz-") as temporary:
        scratch = Path(temporary)
        repository = scratch / "repository"
        env = {"PATH": "/usr/bin:/bin", "HOME": str(scratch), "GIT_CONFIG_NOSYSTEM": "1", "GIT_CONFIG_GLOBAL": "/dev/null"}
        def git(*arguments):
            subprocess.run(["git", *arguments], cwd=repository, env=env, check=True, capture_output=True)
        repository.mkdir()
        git("init", "-b", "psh-omz-main")
        (repository / "alpha beta.txt").write_text("original\n")
        git("add", ".")
        git("-c", "user.name=psh-test", "-c", "user.email=psh@example.invalid", "-c", "core.hooksPath=/dev/null", "commit", "-m", "fixture")
        git("branch", "psh-omz-side")
        (repository / "alpha beta.txt").write_text("changed\n")
        (repository / "weird-é界.txt").write_text("fixture\n")
        for name, enabled, login, fpath in profiles:
            home = scratch / name
            home.mkdir()
            expected = None
            for host, phase in [("reference", "cold"), ("reference", "warm"),
                                ("candidate", "handoff"), ("candidate", "warm"),
                                ("candidate", "cold"), ("reference", "handback")]:
                if phase == "cold":
                    for path in home.glob(".zcompdump*"):
                        shutil.rmtree(path) if path.is_dir() else path.unlink()
                    shutil.rmtree(home / "cache", ignore_errors=True)
                value = run_session(shells[host], home, repository, args.omz, theme, enabled, highlight, login, fpath, history)
                if expected is None:
                    expected = value
                if value != expected:
                    failure = args.output.with_name(args.output.stem + "-failure.json")
                    failure.write_text(json.dumps({"profile": name, "host": host, "phase": phase,
                                                   "actual": value, "expected": expected}, indent=2) + "\n")
                    raise AssertionError(f"{name}/{host}/{phase} differs; see {failure}")
                rows.append({"profile": name, "host": host, "phase": phase, "result": value})
                print(name, host, phase, "passed", flush=True)
    assert sources == source_identity(args.omz, (args.omz / "custom").glob("*.zsh"))
    assert highlighter_sources == (source_identity(highlight.parent) if highlight else None)
    assert binary_hashes == {k: sha(p) for k, p in shells.items()}
    report = {"passed": True, "omz": sources, "omz_root": str(args.omz), "syntax_highlighting": highlighter_sources,
              "theme": theme, "configured_plugins": plugins, "history_limits": history,
              "shells": {k: str(p) for k, p in shells.items()},
              "binary_sha256": binary_hashes, "driver_sha256": sha(Path(__file__)),
              "session_sha256": sha(ROOT / "Perf/ohmyzsh-session.zsh"), "personal_startup_sourced": False,
              "updates_disabled_in_test": True, "sources_unchanged": True, "runs": rows}
    args.output.write_text(json.dumps(report, indent=2) + "\n")
    print(f"{len(rows)} Oh My Zsh interactive sessions match; source files unchanged")


if __name__ == "__main__":
    main()
