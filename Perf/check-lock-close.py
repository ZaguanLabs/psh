#!/usr/bin/env python3
"""Observe lock/ordinary-file state while testing negative close descriptors.

Linux-only private files and pipe handshakes; no account or install changes.
Reference control mode omits negative calls through the unchecked old helper.
"""
import argparse
import fcntl
import hashlib
import json
import os
from pathlib import Path
import re
import selectors
import subprocess
import tempfile


def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument('--shell', type=Path, required=True)
    p.add_argument('--modules', type=Path, required=True)
    p.add_argument('--native', type=Path)
    p.add_argument('--controls-only', action='store_true')
    p.add_argument('--wide', action='store_true')
    p.add_argument('--aliases-only', action='store_true')
    p.add_argument('--memcheck', action='store_true')
    p.add_argument('--reference', type=Path)
    p.add_argument('--output', type=Path, required=True)
    a = p.parse_args()
    if a.native and (a.wide or a.aliases_only):
        p.error('Wide arithmetic belongs to the shell caller, not the int native interface')
    shell, modules = a.shell.resolve(), a.modules.resolve()
    env = dict(PATH='/usr/bin:/bin')
    setup = 'module_path=("$1"); shift; zmodload zsh/system || exit 90; '
    if a.native:
        env['PSH_TEST_NATIVE'] = str(a.native.resolve())
        setup = 'module_path=("$1" "$PSH_TEST_NATIVE"); shift; zmodload zsh/system lock_oracle || exit 90; '
    probe = subprocess.run([str(shell), '-dfc', setup+'cat /proc/$$/maps; :',
                            'probe', str(modules)], capture_output=True, env=env, check=True)
    paths = {line.split()[-1] for line in probe.stdout.decode().splitlines()
             if line.endswith(('/system.so', '/lock_oracle.so'))}
    expected = {str(modules/'zsh/system.so')}
    if a.native:
        expected.add(str(a.native.resolve()/'lock_oracle.so'))
    if paths != expected:
        raise RuntimeError(('Unexpected modules', paths, expected))
    negative = ['-1', '-2', '-16', '-1024', '-2147483648']
    controls = ['0', '1', '2', 'plain', 'closed', '2147483647', 'locka', 'lockb']
    if not a.native:
        negative += ['-1.9', '-2147483648.9', '(side++, -1)']
        controls += ['-0.9', '(side++, locka)', 'locka + 0.9']
    rows = []
    aliases = ['locka + 4294967296', 'lockb + 4294967296',
               'locka - 4294967296', '(side++, locka + 4294967296)']
    wide = aliases + ['2147483648', '-2147483649', '2147483648.0',
                      '-2147483649.0', '9223372036854775807',
                      '1e300', '-1e300', 'NaN', 'Inf', '-Inf']
    expressions = aliases if a.aliases_only else controls + ([] if a.controls_only else negative)
    if a.wide:
        expressions += wide
    with tempfile.NamedTemporaryFile() as first, tempfile.NamedTemporaryFile() as second, tempfile.NamedTemporaryFile() as ordinary:
        for locale in ['C', 'C.UTF-8']:
            for options in ['', 'setopt forcefloat; ', 'setopt cprecedences; ']:
                for keep_exec in ['', '-e']:
                    for expr in expressions:
                        is_negative = expr in negative
                        is_wide = expr in wide
                        release_a = expr in ['locka', '(side++, locka)', 'locka + 0.9']
                        release_b = expr == 'lockb'
                        operation = ('integer native_fd; (( native_fd = EXPR )); psh-test-lockclose "$native_fd"' if a.native else
                                     'zsystem flock -u -- "EXPR"; print -r -- "$?:$side"')
                        operation = operation.replace('EXPR', expr)
                        code = setup + options + '''
zsystem flock KEEP -t 0 -f locka "$1" || exit 91
zsystem flock KEEP -t 0 -f lockb "$2" || exit 91
exec {plain}< "$3"
exec {closed}< "$3"
exec {closed}<&-
side=0
OPERATION
read -r gate
'''.replace('KEEP', keep_exec).replace('OPERATION', operation)
                        prefix = ['valgrind', '--quiet', '--tool=memcheck', '--error-exitcode=99', '--leak-check=no'] if a.memcheck else []
                        proc = subprocess.Popen([*prefix, str(shell), '-dfc', code, 'probe',
                                                 str(modules), first.name, second.name, ordinary.name],
                                                stdin=subprocess.PIPE, stdout=subprocess.PIPE, stderr=subprocess.PIPE,
                                                env=dict(env, LC_ALL=locale))
                        line = b''
                        try:
                            with selectors.DefaultSelector() as selector:
                                selector.register(proc.stdout, selectors.EVENT_READ)
                                if not selector.select(10):
                                    raise RuntimeError('No helper result before deadline')
                                line = proc.stdout.readline()
                            held = []
                            for target in [first, second]:
                                try:
                                    fcntl.lockf(target, fcntl.LOCK_EX | fcntl.LOCK_NB)
                                except BlockingIOError:
                                    held.append(True)
                                else:
                                    held.append(False)
                                    fcntl.lockf(target, fcntl.LOCK_UN)
                            handles = [os.readlink(path) for path in Path(f'/proc/{proc.pid}/fd').iterdir()]
                            ordinary_open = ordinary.name in handles
                            tail, stderr = proc.communicate(b'continue\n', timeout=10)
                        finally:
                            if proc.poll() is None:
                                proc.kill(); proc.communicate()
                        success = release_a or release_b
                        if a.native:
                            expected_line = '0:1\n' if success else '-1:1\n'
                        else:
                            side = ('1.' if 'forcefloat' in options else '1') if 'side++' in expr else '0'
                            expected_line = f'{0 if success else 1}:{side}\n'
                        errors_ok = not stderr if success or a.native else b'not in use for locking' in stderr and b'Invalid read' not in stderr
                        if is_wide:
                            errors_ok = b'file descriptor out of range:' in stderr
                        passed = (proc.returncode == 0 and line == expected_line.encode() and not tail
                                  and held == [not release_a, not release_b] and ordinary_open and errors_ok)
                        # Descriptor numbers embedded in warnings are incidental, not semantic.
                        warning = stderr.decode(errors='backslashreplace')
                        if not is_negative and not a.native and not success:
                            warning = re.sub(r'file descriptor -?\d+', 'file descriptor <fd>', warning)
                        rows.append(dict(locale=locale, options=options, keep_exec=keep_exec,
                                         expression=expr, negative=is_negative, wide=is_wide, passed=passed,
                                         status=proc.returncode, stdout=line.decode(errors='backslashreplace'),
                                         stderr=warning, held=held, ordinary_open=ordinary_open))
    differences = []
    if a.reference:
        previous = {(r['locale'], r['options'], r['keep_exec'], r['expression']): r
                    for r in json.loads(a.reference.read_text())['runs']}
        for row in rows:
            if row['negative'] or row['wide']:
                continue
            old = previous[(row['locale'], row['options'], row['keep_exec'], row['expression'])]
            if any(row[key] != old[key] for key in ['status','stdout','stderr','held','ordinary_open']):
                differences.append(row['expression'])
    report = dict(shell=str(shell), sha256=hashlib.sha256(shell.read_bytes()).hexdigest(),
                  modules={path:hashlib.sha256(Path(path).read_bytes()).hexdigest() for path in paths},
                  native=bool(a.native), memcheck=a.memcheck, cases=len(rows),
                  failures=sum(not row['passed'] for row in rows), control_differences=differences, runs=rows)
    a.output.parent.mkdir(parents=True, exist_ok=True)
    a.output.write_text(json.dumps(report, indent=2)+'\n')
    print(json.dumps({key:report[key] for key in ['cases','failures','control_differences']}))
    if report['failures'] or differences:
        raise SystemExit(1)


if __name__ == '__main__':
    main()
