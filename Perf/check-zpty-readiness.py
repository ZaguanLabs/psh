#!/usr/bin/env python3
"""Linux zpty readiness oracle, including descriptors beyond FD_SETSIZE.

Uses private PTYs and inherited /dev/null descriptors; changes no shell limits.
Each child waits after writing, so output and no-output cases are deterministic.
"""
import argparse
import hashlib
import json
import os
from pathlib import Path
import resource
import subprocess
import tempfile


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--shell', type=Path, required=True)
    parser.add_argument('--modules', type=Path, required=True)
    parser.add_argument('--output', type=Path, required=True)
    parser.add_argument('--reference', type=Path)
    parser.add_argument('--backend', choices=['poll', 'select', 'legacy'], default='poll')
    parser.add_argument('--require-pass', action='store_true')
    parser.add_argument('--memcheck', action='store_true')
    parser.add_argument('--counts', type=int, nargs='+', default=[0, 1019, 1020, 1021, 2044])
    args = parser.parse_args()
    shell, modules = args.shell.resolve(), args.modules.resolve()
    env = dict(PATH='/usr/bin:/bin', UBSAN_OPTIONS='halt_on_error=1:exitcode=86')
    setup = 'module_path=("$1"); shift; zmodload zsh/zpty || exit 90; '
    probe = subprocess.run([str(shell), '-dfc', setup+'cat /proc/$$/maps; :',
                            'probe', str(modules)], env=env, capture_output=True,
                           check=True, timeout=5)
    paths = {line.split()[-1] for line in probe.stdout.decode().splitlines()
             if line.endswith('/zpty.so')}
    expected_path = str(modules/'zsh/zpty.so')
    if paths != {expected_path}:
        raise RuntimeError(('Wrong module loaded', paths, expected_path))
    if resource.getrlimit(resource.RLIMIT_NOFILE)[0] < 2100:
        raise RuntimeError('Need at least 2100 available descriptors; no limits changed')
    cases = [
        ('empty', "''", '', 1, b''),
        ('text', "$'alpha'", '', 0, b'alpha'),
        ('eof', "$'alpha'", '', 0, b'alpha'),
        ('line', "$'alpha\\nbeta'", '', 0, b'alpha\r\n'),
        ('blocking', "$'alpha\\nbeta'", '', 0, b'alpha\r\n'),
        ('binary', "$'a\\0b\\x83\\xff'", '', 0, b'a\0b\x83\xff'),
        ('unicode', "$'h\\xc3\\xa9llo'", '', 0, b'h\xc3\xa9llo'),
        ('match', "'abcENDtail'", "'*END'", 0, b'abcEND'),
        ('partial', "'abc'", "'*END'", 0, b'abc'),
        ('mustmatch', "'abc'", "'*END'", 1, b'abc'),
    ]
    # For this Linux fixture movefd makes the master fd count+4 (except count 0).
    fillers = args.counts
    rows = []
    with tempfile.TemporaryDirectory(prefix='psh-zpty-') as temp:
        readyfile = Path(temp)/'ready'
        for count in fillers:
            fds = []
            try:
                for _ in range(count):
                    fds.append(os.open('/dev/null', os.O_RDONLY))
                for locale in ['C', 'C.UTF-8']:
                    for creation in ['', '-b']:
                        for name, payload, pattern, status, data in cases:
                            readyfile.unlink(missing_ok=True)
                            option = '-rtm' if name == 'mustmatch' else '-rt'
                            if name == 'blocking':
                                option = '-r'
                            code = setup + '''
readyfile=$1
payload=PAYLOAD
flags() {
  local key value
  while IFS=$'\t' read -r key value; do
    [[ $key == flags: ]] && print -r -- "$value"
  done < /proc/$$/fdinfo/$pty_fd
}
zpty CREATE subject 'print -rn -- "$payload"; : > "$readyfile"; read -r line' || exit 91
pty_fd=$REPLY
print -r -- "fd=$pty_fd"
while [[ ! -f $readyfile ]]; do /bin/sleep 0.001; done
before=$(flags)
result=sentinel
zpty OPTION subject result PATTERN
rc=$?
after=$(flags)
print -r -- "rc=$rc flags=$([[ $before == $after ]] && print same || print changed)"
print -rn -- "$result"
zpty -d subject
'''
                            code = (code.replace('PAYLOAD', payload).replace('CREATE', creation)
                                    .replace('OPTION', option).replace('PATTERN', pattern))
                            if name == 'eof':
                                code = code.replace('; read -r line\'', "'")
                                code = code.replace('before=$(flags)', '/bin/sleep 0.02; before=$(flags)')
                            try:
                                prefix = (['valgrind', '--quiet', '--tool=memcheck',
                                           '--error-exitcode=99', '--leak-check=no']
                                          if args.memcheck else [])
                                proc = subprocess.run([*prefix, str(shell), '-dfc', code, 'probe',
                                                       str(modules), str(readyfile)],
                                                      env=dict(env, LC_ALL=locale), pass_fds=fds,
                                                      capture_output=True, timeout=20 if args.memcheck else 8)
                                stdout, stderr, returncode = proc.stdout, proc.stderr, proc.returncode
                            except subprocess.TimeoutExpired as error:
                                stdout, stderr, returncode = error.stdout or b'', error.stderr or b'', 'timeout'
                            first, _, rest = stdout.partition(b'\n')
                            fd = int(first[3:]) if first.startswith(b'fd=') else -1
                            high = fd >= 1024
                            reject = args.backend == 'select' and high and name != 'blocking'
                            expected = (b'rc=1 flags=same\nsentinel' if reject else
                                        f'rc={status} flags=same\n'.encode()+data)
                            error_ok = (b'file descriptor out of range for select: '+str(fd).encode()
                                        in stderr) if reject else not stderr
                            passed = (fd >= 10 and (count == 0 or fd == count+4) and
                                      returncode == 0 and rest == expected and error_ok)
                            rows.append(dict(count=count, fd=fd, high=high, locale=locale,
                                             creation=creation, case=name, passed=passed,
                                             status=returncode, stdout=rest.hex(), stderr=stderr.decode(errors='backslashreplace')))
            finally:
                for fd in fds:
                    os.close(fd)
    differences = []
    if args.reference:
        previous = {(r['count'], r['locale'], r['creation'], r['case']): r
                    for r in json.loads(args.reference.read_text())['runs']}
        for row in rows:
            old = previous.get((row['count'], row['locale'], row['creation'], row['case']))
            if old is None:
                continue
            if row['high']:
                continue
            if any(row[key] != old[key] for key in ['status', 'stdout', 'stderr']):
                differences.append({key: row[key] for key in ['count', 'locale', 'creation', 'case']})
    report = dict(shell=str(shell), sha256=hashlib.sha256(shell.read_bytes()).hexdigest(),
                  module=expected_path, module_sha256=hashlib.sha256(Path(expected_path).read_bytes()).hexdigest(),
                  backend=args.backend, cases=len(rows), failures=sum(not row['passed'] for row in rows),
                  control_differences=differences, runs=rows)
    args.output.parent.mkdir(parents=True, exist_ok=True)
    args.output.write_text(json.dumps(report, indent=2)+'\n')
    print(json.dumps({key: report[key] for key in ['cases', 'failures', 'control_differences']}))
    if args.require_pass and (report['failures'] or differences):
        raise SystemExit(1)


if __name__ == '__main__':
    main()
