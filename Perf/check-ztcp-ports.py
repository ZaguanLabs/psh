#!/usr/bin/env python3
"""Check ztcp numeric ports against independent loopback socket state."""
import argparse
import hashlib
import json
from pathlib import Path
import shlex
import socket
import subprocess
import tempfile
import time


def read(path):
    return path.read_text() if path.exists() else None


def read_result(path):
    deadline = time.monotonic() + 5
    while time.monotonic() < deadline:
        if path.exists():
            data = path.read_bytes()
            if data.endswith(b'\n'):
                return data.decode()
        time.sleep(0.002)
    return None


def run(shell, modules, code, value, result, locale, memcheck):
    code = ('module_path=(' + shlex.quote(str(modules)) +
            ' $module_path); zmodload zsh/net/tcp || exit 90; ' + code)
    command = [str(shell), '-dfc', code, 'probe', str(value), str(result)]
    if memcheck:
        command = ['valgrind', '--error-exitcode=97', '--leak-check=no',
                   '--track-origins=yes'] + command
    return subprocess.Popen(command, stdin=subprocess.PIPE,
                            stdout=subprocess.PIPE, stderr=subprocess.PIPE,
                            env={'PATH': '/usr/bin:/bin', 'LC_ALL': locale})


def finish(proc):
    try:
        stdout, stderr = proc.communicate(timeout=65)
    finally:
        if proc.stdin:
            proc.stdin.close()
    return proc.returncode, stdout.decode(errors='backslashreplace'), \
        stderr.decode(errors='backslashreplace')


def listen_case(shell, modules, root, locale, token, memcheck):
    folder = root / token
    folder.mkdir()
    result = folder / 'result'
    with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as reserved:
        reserved.bind(('127.0.0.1', 0))
        port = reserved.getsockname()[1]
    values = {
        'actual': port, 'prefix': str(port) + 'x',
        'wide': port + 65536, 'double-wide': port + 131072,
        'negative-wide': port - 65536,
        'zero': '0', 'word': 'not-a-port', 'negative': '-1',
    }
    code = '''REPLY=unchanged
ztcp -l "$1"
rc=$?
print -r -- "$rc|$REPLY" > "$2"
if ((rc == 0)); then
  IFS= read -r done
fi
ztcp -c 2>/dev/null
'''
    proc = run(shell, modules, code, values[token], result, locale, memcheck)
    output = read_result(result)
    connected = None
    try:
        with socket.create_connection(('127.0.0.1', port), timeout=2) as peer:
            connected = True
    except OSError:
        connected = False
    try:
        if proc.stdin and not proc.stdin.closed:
            proc.stdin.write(b'done\n')
            proc.stdin.flush()
    except BrokenPipeError:
        pass
    status, stdout, stderr = finish(proc)
    if token in ('actual', 'prefix'):
        passed = (status == 0 and output is not None and
                  output.startswith('0|') and connected)
    else:
        passed = status == 0 and output_is_invalid(output) and not connected
    return dict(type='listen', token=token, value=str(values[token]), port=port,
                locale=locale, passed=passed, connected=connected,
                status=status, stdout=stdout, stderr=stderr, result=output)


def connect_case(shell, modules, root, locale, token, memcheck):
    folder = root / token
    folder.mkdir()
    result = folder / 'result'
    listener = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    try:
        listener.bind(('127.0.0.1', 0))
        listener.listen(1)
        port = listener.getsockname()[1]
        listener.settimeout(65 if memcheck and token in ('actual', 'prefix') else 2)
        values = {
            'actual': port, 'prefix': str(port) + 'x',
            'wide': port + 65536, 'double-wide': port + 131072,
            'negative-wide': port - 65536,
            'zero': '0', 'word': 'not-a-port', 'negative': '-1',
        }
        code = '''REPLY=unchanged
ztcp 127.0.0.1 "$1"
rc=$?
print -r -- "$rc|$REPLY" > "$2"
ztcp -c 2>/dev/null
'''
        proc = run(shell, modules, code, values[token], result, locale, memcheck)
        connected = None
        try:
            peer, unused_address = listener.accept()
            peer.close()
            connected = True
        except TimeoutError:
            connected = False
        status, stdout, stderr = finish(proc)
        if token in ('actual', 'prefix'):
            output = read(result)
            passed = (status == 0 and output is not None and
                      output.startswith('0|') and connected)
        else:
            passed = status == 0 and output_is_invalid(read(result)) and not connected
        return dict(type='connect', token=token, value=str(values[token]),
                    port=port, locale=locale, passed=passed, connected=connected,
                    status=status, stdout=stdout, stderr=stderr, result=read(result))
    finally:
        listener.close()


def output_is_invalid(output):
    return output == '1|unchanged\n'


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--shell', type=Path, required=True)
    parser.add_argument('--modules', type=Path, required=True)
    parser.add_argument('--output', type=Path, required=True)
    parser.add_argument('--reference', type=Path)
    parser.add_argument('--memcheck', action='store_true')
    parser.add_argument('--require-pass', action='store_true')
    args = parser.parse_args()
    shell, modules = (path.resolve(strict=True)
                      for path in (args.shell, args.modules))
    rows = []
    tokens = ('actual', 'prefix', 'wide', 'double-wide', 'negative-wide',
              'negative', 'zero', 'word')
    with tempfile.TemporaryDirectory(prefix='psh-tcp-port-') as temporary:
        root = Path(temporary)
        for locale in ('C', 'C.UTF-8'):
            for operation in ('listen', 'connect'):
                folder = root / (locale + '-' + operation)
                folder.mkdir()
                for token in tokens:
                    function = listen_case if operation == 'listen' else connect_case
                    rows.append(function(shell, modules, folder, locale, token,
                                         args.memcheck))
    differences = []
    if args.reference:
        previous = {(row['locale'], row['type'], row['token']): row
                    for row in json.loads(args.reference.read_text())['runs']}
        for row in rows:
            if row['token'] in ('wide', 'double-wide', 'negative-wide', 'negative'):
                continue
            old = previous[(row['locale'], row['type'], row['token'])]
            compared = ('status', 'result', 'connected') if args.memcheck else \
                ('status', 'stderr', 'result', 'connected')
            if any(row[key] != old[key] for key in compared):
                differences.append(dict(locale=row['locale'], type=row['type'],
                                        token=row['token']))
    report = dict(shell=str(shell), sha256=hashlib.sha256(shell.read_bytes()).hexdigest(),
                  module=str(modules / 'zsh/net/tcp.so'),
                  module_sha256=hashlib.sha256((modules / 'zsh/net/tcp.so').read_bytes()).hexdigest(),
                  cases=len(rows), memcheck=args.memcheck,
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
