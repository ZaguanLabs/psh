#!/usr/bin/env python3
"""Check ztcp fd parsing on private loopback TCP connections."""
import argparse
import ctypes
import hashlib
import json
from pathlib import Path
import shlex
import socket
import subprocess
import tempfile


BITS = ctypes.sizeof(ctypes.c_int) * 8
MODULUS = 1 << BITS
INT_MAX = MODULUS // 2 - 1
PREFIX = 'module_path=(MODULES $module_path); zmodload zsh/net/tcp || exit 90; '


def port_number():
    with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as listener:
        listener.bind(('127.0.0.1', 0))
        return listener.getsockname()[1]


def run(shell, modules, code, arguments, locale, memcheck, fds=()):
    code = (PREFIX.replace('MODULES', shlex.quote(str(modules))) + code)
    command = [str(shell), '-dfc', code, 'probe', *map(str, arguments)]
    if memcheck:
        command = ['valgrind', '--error-exitcode=97', '--leak-check=no',
                   '--track-origins=yes'] + command
    return subprocess.run(command, stdin=subprocess.DEVNULL, pass_fds=fds,
                          capture_output=True, timeout=60 if memcheck else 5,
                          env={'PATH': '/usr/bin:/bin', 'LC_ALL': locale})


def read(path):
    return path.read_text() if path.exists() else None


def close_case(shell, modules, folder, token, locale, memcheck):
    folder.mkdir()
    port = port_number()
    code = '''ztcp -l "$1" || exit 91
listener=$REPLY
ztcp 127.0.0.1 "$1" || exit 92
outbound=$REPLY
ztcp -a "$listener" || exit 93
inbound=$REPLY
case "$2" in
  (actual) target=$outbound ;;
  (prefix) target=${outbound}x ;;
  (wide) target=$((outbound + MODULUS)) ;;
  (negative-wide) target=$((outbound - MODULUS)) ;;
  (double-wide) target=$((outbound + 2 * MODULUS)) ;;
  (int-overflow) target=2147483648 ;;
  (*) target=$2 ;;
esac
ztcp -c "$target"
close_rc=$?
print -u "$outbound" -r -- ALIVE
write_rc=$?
line=none
IFS= read -r -t 0 -u "$inbound" line
read_rc=$?
print -r -- "close:$close_rc|write:$write_rc|read:$read_rc|${line:-none}" > "$3"
ztcp -c "$outbound" 2>/dev/null
ztcp -c "$listener" 2>/dev/null
'''.replace('MODULUS', str(MODULUS))
    proc = run(shell, modules, code, [port, token, folder / 'result'],
               locale, memcheck)
    output = read(folder / 'result')
    if token in ('actual', 'prefix'):
        passed = output == 'close:0|write:1|read:1|none\n'
    else:
        passed = output == 'close:1|write:0|read:0|ALIVE\n'
    return dict(type='close', token=token, locale=locale, passed=passed,
                status=proc.returncode, result=output,
                stdout=proc.stdout.decode(errors='backslashreplace'),
                stderr=proc.stderr.decode(errors='backslashreplace'))


def target_case(shell, modules, folder, token, locale, memcheck):
    folder.mkdir()
    result = folder / 'result'
    sink = folder / 'sink'
    sink.write_bytes(b'')
    code = '''REPLY=unchanged
exec 3> "$3"
case "$1" in
  (actual) target=9 ;;
  (prefix) target=9x ;;
  (wide) target=4294967305 ;;
  (int-max) target=2147483647 ;;
  (int-overflow) target=2147483648 ;;
  (*) target=$1 ;;
esac
exec 9>&3
ztcp -l -d "$target" "$2"
rc=$?
write_rc=not-written
if ((rc)); then
  print -u 9 -rn -- LIVE
  write_rc=$?
fi
print -r -- "$rc|$REPLY|$write_rc" > "$4"
exec 9>&-
ztcp -c 2>/dev/null
'''
    proc = run(shell, modules, code, [token, port_number(), sink, result],
               locale, memcheck)
    output = read(result)
    payload = sink.read_text()
    if token in ('actual', 'prefix'):
        passed = output == '0|9|not-written\n' and payload == ''
    else:
        passed = output == '1|unchanged|0\n' and payload == 'LIVE'
    return dict(type='target', token=token, locale=locale, passed=passed,
                status=proc.returncode, result=output, output=payload,
                stdout=proc.stdout.decode(errors='backslashreplace'),
                stderr=proc.stderr.decode(errors='backslashreplace'))


def high_case(shell, modules, folder, fd, test, backend, locale, memcheck):
    folder.mkdir()
    code = '''ztcp -l -d "$1" "$2" || exit 91
listener=$REPLY
ztcp 127.0.0.1 "$2" || exit 92
outbound=$REPLY
print -u "$outbound" -r -- PING
ztcp -a TEST "$1"
rc=$?
line=none
fallback=not-needed
if ((rc)); then
  ztcp -a "$1"
  fallback=$?
fi
if ((rc == 0 || fallback == 0)); then
  IFS= read -r -u "$REPLY" line
fi
print -r -- "$rc|$fallback|$line" > "$3"
ztcp -c 2>/dev/null
'''.replace('TEST', '-t' if test else '')
    proc = run(shell, modules, code, [fd, port_number(), folder / 'result'],
               locale, memcheck)
    output = read(folder / 'result')
    reject = backend == 'select' and test and fd >= 1024
    expected = '1|0|PING\n' if reject else '0|not-needed|PING\n'
    error_ok = ('file descriptor out of range for select: ' + str(fd)) in \
        proc.stderr.decode(errors='backslashreplace') if reject else True
    return dict(type='high', fd=fd, test=test, backend=backend, locale=locale,
                passed=proc.returncode == 0 and output == expected and error_ok,
                status=proc.returncode, result=output,
                stdout=proc.stdout.decode(errors='backslashreplace'),
                stderr=proc.stderr.decode(errors='backslashreplace'))


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--shell', type=Path, required=True)
    parser.add_argument('--modules', type=Path, required=True)
    parser.add_argument('--output', type=Path, required=True)
    parser.add_argument('--reference', type=Path)
    parser.add_argument('--memcheck', action='store_true')
    parser.add_argument('--high', action='store_true')
    parser.add_argument('--backend', choices=('poll', 'select'), default='poll')
    parser.add_argument('--require-pass', action='store_true')
    args = parser.parse_args()
    shell, modules = (path.resolve(strict=True)
                      for path in (args.shell, args.modules))
    rows = []
    if args.high:
        cases = [('high', fd, test) for fd in (1023, 1024, 2048)
                 for test in (False, True)]
    else:
        cases = [('close', token) for token in
                 ('actual', 'prefix', 'wide', 'negative-wide', 'double-wide',
                  'int-overflow', '-1')]
        cases += [('target', token) for token in
                  ('actual', 'prefix', 'wide', 'int-max', 'int-overflow',
                   '-1', '0', 'words')]
    with tempfile.TemporaryDirectory(prefix='psh-tcp-') as temporary:
        root = Path(temporary)
        for locale in ('C', 'C.UTF-8'):
            for index, case in enumerate(cases):
                folder = root / (locale + '-' + str(index))
                if case[0] == 'close':
                    row = close_case(shell, modules, folder, case[1], locale,
                                     args.memcheck)
                elif case[0] == 'target':
                    row = target_case(shell, modules, folder, case[1], locale,
                                      args.memcheck)
                else:
                    row = high_case(shell, modules, folder, case[1], case[2],
                                    args.backend, locale, args.memcheck)
                rows.append(row)
    differences = []
    if args.reference:
        old_rows = json.loads(args.reference.read_text())['runs']
        for row in rows:
            intentionally_changed = (row['type'] == 'close' and
                                     row['token'] not in ('actual', 'prefix'))
            intentionally_changed |= (row['type'] == 'target' and
                                      row['token'] not in ('actual', 'prefix', 'int-max',
                                                           '0', 'words'))
            intentionally_changed |= (row['type'] == 'high' and row['fd'] >= 1024 and
                                      row['test'] and args.backend == 'select')
            if intentionally_changed:
                continue
            old = [candidate for candidate in old_rows
                   if candidate['type'] == row['type'] and
                   candidate['locale'] == row['locale'] and
                   candidate.get('token') == row.get('token') and
                   candidate.get('fd') == row.get('fd') and
                   candidate.get('test') == row.get('test')]
            compared = ('status', 'result') if args.memcheck else \
                ('status', 'stderr', 'result')
            if len(old) != 1 or any(row[key] != old[0][key]
                                    for key in compared):
                differences.append(dict(type=row['type'], locale=row['locale'],
                                        token=row.get('token'), fd=row.get('fd')))
    report = dict(shell=str(shell), sha256=hashlib.sha256(shell.read_bytes()).hexdigest(),
                  module=str(modules / 'zsh/net/tcp.so'),
                  module_sha256=hashlib.sha256((modules / 'zsh/net/tcp.so').read_bytes()).hexdigest(),
                  cases=len(rows), memcheck=args.memcheck, backend=args.backend,
                  failures=sum(not row['passed'] for row in rows),
                  control_differences=differences, runs=rows)
    args.output.parent.mkdir(parents=True, exist_ok=True)
    args.output.write_text(json.dumps(report, indent=2) + '\n')
    print(json.dumps({key: value for key, value in report.items()
                      if key != 'runs'}))
    if args.require_pass and (report['failures'] or differences):
        raise SystemExit(1)


if __name__ == '__main__':
    main()
