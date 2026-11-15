#!/usr/bin/env python3
"""Check flock retry-interval validation and independently observe held locks.

All operations use a private temporary file and zero lock timeout. A pipe
handshake keeps each shell alive while Python checks the POSIX record lock.
"""
import argparse
import ctypes
import fcntl
import hashlib
import json
import os
from pathlib import Path
import selectors
import subprocess
import tempfile


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--shell', type=Path, required=True)
    parser.add_argument('--modules', type=Path, required=True)
    parser.add_argument('--output', type=Path, required=True)
    parser.add_argument('--reference', type=Path)
    parser.add_argument('--require-pass', action='store_true')
    args = parser.parse_args()
    if ctypes.sizeof(ctypes.c_long) != 8:
        parser.error('This boundary matrix currently requires a 64-bit C long')
    shell, modules = args.shell.resolve(), args.modules.resolve()
    env = dict(PATH='/usr/bin:/bin', UBSAN_OPTIONS='halt_on_error=1:exitcode=86')
    setup = 'module_path=("$1"); shift; zmodload zsh/system || exit 90; '
    probe = subprocess.run([str(shell), '-dfc', setup+'cat /proc/$$/maps; :',
                            'probe', str(modules)], env=env, capture_output=True,
                           check=True, timeout=5)
    loaded = {line.split()[-1] for line in probe.stdout.decode().splitlines()
              if line.endswith('/system.so')}
    module = modules/'zsh/system.so'
    if loaded != {str(module)}:
        raise RuntimeError(('Unexpected system module', loaded, str(module)))
    # Retain the existing ceil-to-microseconds and conservative LONG_MAX bound.
    controls = [
        ('1', True), ('0.1', True), ('0.000001', True), ('0.0000001', True),
        ('1e-300', True), ('5e-324', True), ('(side++, 0.000001)', True),
        ('1000000', True), ('9214148664817.0', True),
        ('0', False), ('-0.0', False), ('-1', False), ('-1e300', False),
        ('1e300', False), ('Inf', False), ('-Inf', False),
        ('9214148664818.0', False), ('(side++, 0)', False),
    ]
    new_rejections = ['NaN', '-NaN', '+NaN', '(NaN + 1.0)', '(side++, NaN)']
    rows = []
    with tempfile.NamedTemporaryFile(prefix='psh-interval-') as target:
        for locale in ['C', 'C.UTF-8']:
            for options in ['', 'setopt forcefloat; ', 'setopt cprecedences; ']:
                for attached in [False, True]:
                    for expression, valid, changed in [
                        *[(expr, valid, False) for expr, valid in controls],
                        *[(expr, False, True) for expr in new_rejections],
                    ]:
                        option = '-i"$2"' if attached else '-i "$2"'
                        code = setup + options + '''side=0; fd=unchanged;
zsystem flock -t 0 OPTION -f fd "$1"
rc=$?
print -r -- "$rc|$fd|$side"
read -r gate
if (( rc == 0 )); then zsystem flock -u "$fd" || exit 92; fi
print -r -- DONE
'''.replace('OPTION', option)
                        proc = subprocess.Popen([str(shell), '-dfc', code, 'probe',
                                                 str(modules), target.name, expression],
                                                stdin=subprocess.PIPE, stdout=subprocess.PIPE,
                                                stderr=subprocess.PIPE,
                                                env=dict(env, LC_ALL=locale))
                        line = b''
                        held = None
                        try:
                            with selectors.DefaultSelector() as selector:
                                selector.register(proc.stdout, selectors.EVENT_READ)
                                if not selector.select(5):
                                    raise RuntimeError('Shell did not reach the lock handshake')
                                line = proc.stdout.readline()
                            try:
                                fcntl.lockf(target, fcntl.LOCK_EX | fcntl.LOCK_NB)
                            except BlockingIOError:
                                held = True
                            else:
                                held = False
                                fcntl.lockf(target, fcntl.LOCK_UN)
                            open_target_fds = [path.name for path in Path(f'/proc/{proc.pid}/fd').iterdir()
                                               if os.readlink(path) == target.name]
                            tail, stderr = proc.communicate(b'continue\n', timeout=5)
                        finally:
                            if proc.poll() is None:
                                proc.kill()
                                proc.communicate()
                        fields = line.decode().strip().split('|')
                        good_fd = (fields[1].isdigit() if valid else fields[1] == 'unchanged') if len(fields) == 3 else False
                        expected_side = '1' if 'side++' in expression else '0'
                        if expected_side == '1' and 'forcefloat' in options:
                            expected_side = '1.'
                        expected_status = '0' if valid else '1'
                        passed = (proc.returncode == 0 and tail == b'DONE\n' and
                                  len(fields) == 3 and fields[0] == expected_status and
                                  fields[2] == expected_side and good_fd and held == valid and
                                  len(open_target_fds) == int(valid) and
                                  (not stderr if valid else b'flock: invalid interval value:' in stderr))
                        # The actual allocated number is incidental; verify it, then normalize.
                        if len(fields) == 3 and fields[1].isdigit():
                            fields[1] = '<fd>'
                        rows.append(dict(locale=locale, options=options, attached=attached,
                                         expression=expression, changed=changed, valid=valid,
                                         passed=passed, status=proc.returncode, result=fields,
                                         tail=tail.decode(errors='backslashreplace'), held=held,
                                         open_target_fds=len(open_target_fds),
                                         stderr=stderr.decode(errors='backslashreplace')))
    differences = []
    if args.reference:
        previous = json.loads(args.reference.read_text())['runs']
        for row, old in zip(rows, previous, strict=True):
            if row['changed']:
                continue
            if any(row[key] != old[key] for key in ['status', 'result', 'tail', 'held', 'open_target_fds', 'stderr']):
                differences.append({key: row[key] for key in ['locale', 'options', 'attached', 'expression']})
    report = dict(shell=str(shell), sha256=hashlib.sha256(shell.read_bytes()).hexdigest(),
                  module=str(module), module_sha256=hashlib.sha256(module.read_bytes()).hexdigest(),
                  cases=len(rows), failures=sum(not row['passed'] for row in rows),
                  control_differences=differences, runs=rows)
    args.output.parent.mkdir(parents=True, exist_ok=True)
    args.output.write_text(json.dumps(report, indent=2)+'\n')
    print(json.dumps({key: report[key] for key in ['cases', 'failures', 'control_differences']}))
    if args.require_pass and (report['failures'] or differences):
        raise SystemExit(1)


if __name__ == '__main__':
    main()
