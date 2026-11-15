#!/usr/bin/env python3
"""Check timed sysread at select's descriptor-set boundary (Linux harness).

Pass the tested build's FD_SETSIZE if it differs from the host's usual 1024.
Untimed reads and the poll backend must still accept the real high descriptors.
"""
import argparse
import errno
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
    parser.add_argument('--modules', type=Path)
    parser.add_argument('--backend', choices=('poll', 'select'), required=True)
    parser.add_argument('--fd-setsize', type=int, default=1024)
    parser.add_argument('--output', type=Path, required=True)
    parser.add_argument('--require-pass', action='store_true')
    args = parser.parse_args()
    if args.fd_setsize < 16:
        parser.error('FD_SETSIZE must be at least 16 for this harness')
    descriptors = [args.fd_setsize-1, args.fd_setsize, 4*args.fd_setsize]
    if resource.getrlimit(resource.RLIMIT_NOFILE)[0] <= max(descriptors):
        parser.error('Descriptor limit is too small; no limits were changed')
    shell = args.shell.resolve()
    env = dict(PATH='/usr/bin:/bin', UBSAN_OPTIONS='halt_on_error=1:exitcode=86')
    setup = 'zmodload zsh/system || exit 90; '
    if args.modules:
        env['PSH_TEST_MODULES'] = str(args.modules.resolve())
        setup = 'module_path=("$PSH_TEST_MODULES"); '+setup
    probe = subprocess.run([str(shell), '-dfc', setup+'cat /proc/$$/maps; :'],
                           env=env, capture_output=True, check=True, timeout=5)
    modules = sorted({line.split()[-1] for line in probe.stdout.decode().splitlines()
                      if line.endswith('/system.so')})
    if not modules or (args.modules and modules != [str(args.modules.resolve()/'zsh/system.so')]):
        raise RuntimeError('Unexpected module provenance: '+repr(modules))
    rows = []
    with tempfile.TemporaryFile() as source:
        source.write(b'ABC'); source.flush()
        for fd in descriptors:
            try:
                os.fstat(fd)
            except OSError as error:
                if error.errno != errno.EBADF:
                    raise
            else:
                raise RuntimeError(f'Refusing to replace occupied descriptor {fd}')
            os.dup2(source.fileno(), fd)
            try:
                for locale in ('C', 'C.UTF-8'):
                    for mode, option in [('untimed', ''), ('zero', '-t 0'),
                                         ('side-effect', '-t "(++side, 0)"')]:
                        source.seek(0)
                        code = (setup+'side=0; result=unchanged; count=unchanged; '
                                'sysread -i "$1" -s 1 -c count '+option+' result; '
                                'print -r -- "$?|$result|$count|$side"')
                        proc = subprocess.run([str(shell), '-dfc', code, 'probe', str(fd)],
                                              pass_fds=(fd,), stdin=subprocess.DEVNULL,
                                              env=dict(env, LC_ALL=locale), capture_output=True, timeout=5)
                        reject = args.backend == 'select' and fd >= args.fd_setsize and mode != 'untimed'
                        expected = b'1|unchanged|unchanged|0\n' if reject else (
                            b'0|A|1|1\n' if mode == 'side-effect' else b'0|A|1|0\n')
                        expected_err = (f'zsh:sysread:1: file descriptor out of range for select: {fd}\n'.encode()
                                        if reject else b'')
                        passed = (proc.returncode == 0 and proc.stdout == expected and
                                  proc.stderr == expected_err and source.tell() == (0 if reject else 1))
                        rows.append(dict(locale=locale, mode=mode, fd=fd, reject=reject, passed=passed,
                                         status=proc.returncode, stdout=proc.stdout.decode(errors='backslashreplace'),
                                         stderr=proc.stderr.decode(errors='backslashreplace'), offset=source.tell()))
            finally:
                os.close(fd)
    report = dict(shell=str(shell), sha256=hashlib.sha256(shell.read_bytes()).hexdigest(),
                  modules={p: hashlib.sha256(Path(p).read_bytes()).hexdigest() for p in modules},
                  backend=args.backend, fd_setsize=args.fd_setsize, cases=len(rows),
                  failures=sum(not r['passed'] for r in rows), runs=rows)
    args.output.parent.mkdir(parents=True, exist_ok=True)
    args.output.write_text(json.dumps(report, indent=2)+'\n')
    print(json.dumps({k: v for k, v in report.items() if k != 'runs'}))
    if args.require_pass and report['failures']:
        raise SystemExit(1)


if __name__ == '__main__':
    main()
