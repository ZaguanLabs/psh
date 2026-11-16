#!/usr/bin/env python3
"""Exercise real ZLE fd callbacks across select's descriptor boundary."""
import argparse
import hashlib
import json
import os
from pathlib import Path
import pty
import resource
import select
import shlex
import signal
import tempfile
import time


SOURCE = '''module_path=(MODULES $module_path)
zmodload zsh/zle || exit 90
PROMPT='PROBE> '
bindkey -e
capture_buffer() { print -rn -- "$BUFFER" > "$PROBE_DIR/buffer"; }
zle -N capture_buffer
bindkey '^X^P' capture_buffer
on_ready() {
  local line fd=$1
  IFS= read -r line <&$fd || line=READ-FAILED
  print -r -- "$line" > "$PROBE_DIR/callback"
  zle -F "$fd"
  exec {fd}<&-
  zle -R
}
for ((i = 0; i < COUNT; ++i)); do
  exec {held}</dev/null || exit 91
done
exec {watch_fd}< <(print -r -- CALLBACK) || exit 92
zle -F "$watch_fd" on_ready
registration_rc=$?
print -r -- "$watch_fd|$registration_rc" > "$PROBE_DIR/registration"
if (( registration_rc )); then
  exec {watch_fd}<&-
fi
print -r -- ready > "$PROBE_DIR/ready"
'''


class Terminal:
    def __init__(self, shell, env, memcheck):
        self.transcript = bytearray()
        self.status = None
        self.pid, self.fd = pty.fork()
        if self.pid == 0:
            argv = [str(shell), '-fi']
            if memcheck:
                argv = ['valgrind', '--error-exitcode=97', '--leak-check=no',
                        '--track-origins=yes'] + argv
            try:
                os.execvpe(argv[0], argv, env)
            except OSError as error:
                os.write(2, ('exec: ' + str(error) + '\n').encode())
                os._exit(125)

    def pump(self, timeout=0.02):
        if self.status is not None:
            return
        if not select.select([self.fd], [], [], timeout)[0]:
            return
        try:
            data = os.read(self.fd, 65536)
        except OSError:
            data = b''
        if not data:
            self.reap(block=False)
        else:
            self.transcript.extend(data)

    def wait_file(self, path, content, timeout):
        deadline = time.monotonic() + timeout
        while time.monotonic() < deadline:
            if path.exists():
                data = path.read_bytes()
                if (data.endswith(b'\n') if content is None else
                        data == content):
                    return True
            self.pump()
        return False

    def reap(self, block):
        if self.status is not None:
            return self.status
        while True:
            try:
                pid, status = os.waitpid(self.pid, 0 if block else os.WNOHANG)
            except ChildProcessError:
                return self.status
            if pid:
                self.status = os.waitstatus_to_exitcode(status)
                return self.status
            if not block:
                return None

    def finish(self):
        try:
            os.write(self.fd, b'\x15exit\n')
        except OSError:
            pass
        deadline = time.monotonic() + 5
        while self.status is None and time.monotonic() < deadline:
            self.pump()
            self.reap(block=False)
        if self.status is None:
            os.kill(self.pid, signal.SIGKILL)
            self.reap(block=True)
        os.close(self.fd)
        return self.status


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--shell', type=Path, required=True)
    parser.add_argument('--modules', type=Path, required=True)
    parser.add_argument('--backend', choices=('poll', 'select'), required=True)
    parser.add_argument('--output', type=Path, required=True)
    parser.add_argument('--reference', type=Path)
    parser.add_argument('--memcheck', action='store_true')
    parser.add_argument('--require-pass', action='store_true')
    parser.add_argument('--counts', type=int, nargs='+',
                        default=[0, 1011, 1012, 2044])
    args = parser.parse_args()
    shell, modules = (path.resolve(strict=True)
                      for path in (args.shell, args.modules))
    if resource.getrlimit(resource.RLIMIT_NOFILE)[0] < 2100:
        raise RuntimeError('Need at least 2100 available descriptors; no limits changed')
    module = modules / 'zsh/zle.so'
    rows = []
    with tempfile.TemporaryDirectory(prefix='psh-zle-fd-') as temporary:
        for count in args.counts:
            for locale in ('C', 'C.UTF-8'):
                folder = Path(temporary) / (locale + '-' + str(count))
                folder.mkdir()
                source = folder / 'probe.zsh'
                source.write_text(SOURCE.replace('MODULES', shlex.quote(str(modules)))
                                  .replace('COUNT', str(count)))
                env = dict(os.environ, PATH='/usr/bin:/bin', LC_ALL=locale,
                           TERM='xterm', PROBE_DIR=str(folder))
                terminal = Terminal(shell, env, args.memcheck)
                try:
                    os.write(terminal.fd, ('source ' + shlex.quote(str(source)) +
                                           '\n').encode())
                    timeout = 60 if args.memcheck else 8
                    startup_ok = terminal.wait_file(folder / 'registration', None,
                                                   timeout)
                    startup_ok = terminal.wait_file(folder / 'ready', b'ready\n',
                                                   timeout) and startup_ok
                    registration = ((folder / 'registration').read_text().strip()
                                    if (folder / 'registration').exists() else '')
                    fd_text, separator, rc_text = registration.partition('|')
                    fd = int(fd_text) if separator and fd_text.isdigit() else -1
                    rc = int(rc_text) if rc_text.isdigit() else -1
                    high = fd >= 1024
                    reject = args.backend == 'select' and high
                    if not startup_ok or rc:
                        callback = (folder / 'callback').read_text().strip() \
                            if (folder / 'callback').exists() else None
                        callback_ok = callback is None if reject else False
                    else:
                        callback_ok = terminal.wait_file(folder / 'callback',
                                                        b'CALLBACK\n', timeout)
                    expected_error = ('file descriptor out of range for select: ' +
                                      str(fd)).encode()
                    error_ok = expected_error in terminal.transcript if reject \
                        else b'Bad file descriptor number for -F' not in terminal.transcript
                    buffer_ok = False
                    if callback_ok and error_ok and terminal.status is None:
                        os.write(terminal.fd, b'abc\x18\x10')
                        buffer_ok = terminal.wait_file(folder / 'buffer', b'abc', timeout)
                    status = terminal.finish()
                    passed = (startup_ok and fd == count + 12 and
                              rc == (1 if reject else 0) and callback_ok and
                              error_ok and buffer_ok and status == 0)
                    rows.append(dict(count=count, locale=locale, fd=fd, high=high,
                                     backend=args.backend, reject=reject,
                                     registration=registration, passed=passed,
                                     callback_ok=callback_ok, error_ok=error_ok,
                                     buffer_ok=buffer_ok, status=status,
                                     callback=(folder / 'callback').read_text().strip()
                                     if (folder / 'callback').exists() else None,
                                     buffer=(folder / 'buffer').read_text()
                                     if (folder / 'buffer').exists() else None,
                                     transcript=terminal.transcript.decode(
                                         errors='backslashreplace')))
                finally:
                    if terminal.status is None:
                        terminal.finish()
    report = dict(shell=str(shell), sha256=hashlib.sha256(shell.read_bytes()).hexdigest(),
                  module=str(module), module_sha256=hashlib.sha256(module.read_bytes()).hexdigest(),
                  backend=args.backend, memcheck=args.memcheck, cases=len(rows),
                  failures=sum(not row['passed'] for row in rows), runs=rows)
    differences = []
    if args.reference:
        previous = {(row['locale'], row['count']): row
                    for row in json.loads(args.reference.read_text())['runs']}
        for row in rows:
            old = previous.get((row['locale'], row['count']))
            if old is None or row['reject']:
                continue
            if any(row[key] != old[key] for key in
                   ('registration', 'callback', 'buffer', 'status')):
                differences.append(dict(locale=row['locale'], count=row['count']))
        report['control_differences'] = differences
    args.output.parent.mkdir(parents=True, exist_ok=True)
    args.output.write_text(json.dumps(report, indent=2) + '\n')
    print(json.dumps({key: value for key, value in report.items()
                      if key not in ('runs',)}))
    if args.require_pass and (report['failures'] or differences):
        raise SystemExit(1)


if __name__ == '__main__':
    main()
