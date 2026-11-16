#!/usr/bin/env python3
"""Check zsocket descriptor parsing with real sockets and file state."""
import argparse
import ctypes
import hashlib
import json
import os
from pathlib import Path
import re
import shlex
import socket
import subprocess
import tempfile


BITS = ctypes.sizeof(ctypes.c_int) * 8
MODULUS = 1 << BITS
INT_MAX = MODULUS // 2 - 1


def run_probe(shell, modules, code, args, locale, memcheck, fds=()):
    code = ('module_path=(' + shlex.quote(str(modules)) +
            ' $module_path); zmodload zsh/net/socket || exit 90; ' + code)
    command = [str(shell), '-dfc', code, 'probe', *map(str, args)]
    if memcheck:
        command = ['valgrind', '--error-exitcode=97', '--leak-check=no',
                   '--track-origins=yes'] + command
    proc = subprocess.run(command, stdin=subprocess.DEVNULL,
                          pass_fds=fds, capture_output=True,
                          env={'PATH': '/usr/bin:/bin', 'LC_ALL': locale},
                          timeout=60 if memcheck else 5)
    return proc


def data(path):
    return path.read_text() if path.exists() else None


def accept_case(shell, modules, root, locale, target, value, test, memcheck,
                forced_fd=None):
    name = (target + '-' + ('test' if test else 'accept') +
            ('-' + str(forced_fd) if forced_fd is not None else ''))
    folder = root / name
    folder.mkdir()
    address = folder / 'socket'
    result = folder / 'result'
    listener = socket.socket(socket.AF_UNIX, socket.SOCK_STREAM)
    client = socket.socket(socket.AF_UNIX, socket.SOCK_STREAM)
    high_fd = None
    try:
        listener.bind(str(address))
        listener.listen(1)
        client.connect(str(address))
        client.sendall(b'PING\n')
        if forced_fd is not None:
            high_fd = os.dup2(listener.fileno(), forced_fd)
            fd = high_fd
        else:
            fd = listener.fileno()
        code = '''REPLY=unchanged
zsocket -a TEST "$1"
rc=$?
if ((rc == 0)); then
  IFS= read -r -u "$REPLY" line
  exec {REPLY}>&-
fi
print -r -- "$rc|$REPLY|$line" > "$2"
'''.replace('TEST', '-t' if test else '')
        proc = run_probe(shell, modules, code, [value, result], locale,
                         memcheck, (fd,))
        output = data(result)
        if target == 'high-select':
            passed = (output == '1|unchanged|\n' and
                      ('file descriptor out of range for select: ' + str(fd))
                      in proc.stderr.decode(errors='backslashreplace'))
        elif target in ('control', 'high'):
            passed = bool(output and re.fullmatch(r'0\|\d+\|PING\n?', output))
        else:
            passed = output == '1|unchanged|\n'
        return dict(type='accept', target=target, test=test, value=value,
                    passed=passed, status=proc.returncode,
                    stdout=proc.stdout.decode(errors='backslashreplace'),
                    stderr=proc.stderr.decode(errors='backslashreplace'),
                    result=output)
    finally:
        client.close()
        listener.close()
        if high_fd is not None:
            os.close(high_fd)


def destination_case(shell, modules, root, locale, target, value, memcheck):
    root.mkdir()
    address = root / 'socket'
    result = root / 'result'
    with tempfile.TemporaryFile() as sink:
        fd = sink.fileno()
        code = '''REPLY=unchanged
zsocket -l -d "$1" "$2"
rc=$?
if ((rc != 0)); then
  print -u "$3" -rn -- LIVE
fi
print -r -- "$rc|$REPLY" > "$4"
'''
        proc = run_probe(shell, modules, code, [value, address, fd, result],
                         locale, memcheck, (fd,))
        sink.seek(0)
        payload = sink.read().decode(errors='backslashreplace')
        output = data(result)
        if target == 'control':
            passed = None
        else:
            passed = (output == '1|unchanged\n' and payload == 'LIVE' and
                      not address.exists())
        return dict(type='destination', target=target, value=value,
                    passed=passed, status=proc.returncode,
                    stdout=proc.stdout.decode(errors='backslashreplace'),
                    stderr=proc.stderr.decode(errors='backslashreplace'),
                    result=output, output=payload,
                    socket_created=address.exists())


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--shell', type=Path, required=True)
    parser.add_argument('--modules', type=Path, required=True)
    parser.add_argument('--output', type=Path, required=True)
    parser.add_argument('--reference', type=Path)
    parser.add_argument('--memcheck', action='store_true')
    parser.add_argument('--backend', choices=('poll', 'select'), default='poll')
    parser.add_argument('--high', action='store_true')
    parser.add_argument('--require-pass', action='store_true')
    args = parser.parse_args()
    shell, modules = (path.resolve(strict=True)
                      for path in (args.shell, args.modules))
    rows = []
    with tempfile.TemporaryDirectory(prefix='psh-sock-') as temporary:
        root = Path(temporary)
        for locale in ([] if args.high else ('C', 'C.UTF-8')):
            for test in (False, True):
                folder = root / ('accept-' + locale + '-' + str(test))
                folder.mkdir()
                with socket.socket(socket.AF_UNIX, socket.SOCK_STREAM) as probe:
                    fd = probe.fileno()
                for target in ('control', 'invalid', 'changed'):
                    if target == 'control':
                        values = [str(fd), str(fd) + 'x']
                    elif target == 'invalid':
                        values = ['0', 'not-a-number']
                    else:
                        values = [str(MODULUS + fd), str(-MODULUS + fd),
                                  str(2 * MODULUS + fd), str(INT_MAX + 1), '-1']
                    for index, value in enumerate(values):
                        case_folder = folder / str(target + '-' + str(index))
                        case_folder.mkdir()
                        row = accept_case(shell, modules, case_folder, locale,
                                          target, value, test, args.memcheck)
                        row['locale'] = locale
                        rows.append(row)
            folder = root / ('destination-' + locale)
            folder.mkdir()
            with tempfile.TemporaryFile() as sink:
                fd = sink.fileno()
                cases = {'control': [str(fd), str(fd) + 'x', str(INT_MAX)],
                         'invalid': ['0', 'not-a-number'],
                         'changed': [str(MODULUS + fd), str(-MODULUS + fd),
                                     str(2 * MODULUS + fd), str(INT_MAX + 1), '-1']}
                for target, values in cases.items():
                    for index, value in enumerate(values):
                        row = destination_case(
                            shell, modules, folder / (target + '-' + str(index)),
                            locale, target, value, args.memcheck)
                        row['locale'] = locale
                        rows.append(row)
        for locale in (('C', 'C.UTF-8') if args.high else ()):
            folder = root / ('high-' + locale)
            folder.mkdir()
            for test in (False, True):
                for fd in (1023, 1024, 2048):
                    target = ('high-select' if args.backend == 'select' and
                              test and fd >= 1024 else 'high')
                    row = accept_case(shell, modules, folder, locale, target,
                                      str(fd), test, args.memcheck, fd)
                    row['locale'] = locale
                    row['high'] = True
                    rows.append(row)
    differences = []
    if args.reference:
        old_rows = json.loads(args.reference.read_text())['runs']
        for row in rows:
            if row['target'] in ('changed', 'high-select'):
                continue
            matches = [old for old in old_rows
                       if old['locale'] == row['locale'] and
                       old['type'] == row['type'] and
                       old['target'] == row['target'] and
                       old['value'] == row['value'] and
                       old.get('test') == row.get('test')]
            if len(matches) != 1 or any(row[key] != matches[0][key]
                                        for key in ('status', 'stderr', 'result')):
                differences.append({key: row[key] for key in
                                    ('locale', 'type', 'target', 'value')})
    report = dict(shell=str(shell), sha256=hashlib.sha256(shell.read_bytes()).hexdigest(),
                  module=str(modules / 'zsh/net/socket.so'),
                  module_sha256=hashlib.sha256((modules / 'zsh/net/socket.so').read_bytes()).hexdigest(),
                  cases=len(rows), memcheck=args.memcheck,
                  failures=sum(row['passed'] is False for row in rows),
                  control_differences=differences, runs=rows)
    args.output.parent.mkdir(parents=True, exist_ok=True)
    args.output.write_text(json.dumps(report, indent=2) + '\n')
    print(json.dumps({key: value for key, value in report.items()
                      if key != 'runs'}))
    if args.require_pass and (report['failures'] or differences):
        raise SystemExit(1)


if __name__ == '__main__':
    main()
