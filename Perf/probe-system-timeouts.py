#!/usr/bin/env python3
"""Bounded timeout characterization; observations, not a timing benchmark.

The READY handshake distinguishes shell startup from the observation window.
Real signals and delayed pipe data exercise retry behavior. No behavior is
declared correct merely because a reference produces it.
"""
import argparse
import hashlib
import json
import os
from pathlib import Path
import select
import signal
import subprocess
import time


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--shell', type=Path, required=True)
    parser.add_argument('--modules', type=Path)
    parser.add_argument('--output', type=Path, required=True)
    args = parser.parse_args()
    shell = args.shell.resolve()
    env = dict(PATH='/usr/bin:/bin', UBSAN_OPTIONS='halt_on_error=1:exitcode=86')
    setup = 'zmodload zsh/system || exit 90; '
    if args.modules:
        env['PSH_TEST_MODULES'] = str(args.modules.resolve())
        setup = 'module_path=("$PSH_TEST_MODULES"); ' + setup
    probe = subprocess.run([str(shell), '-dfc', setup+'cat /proc/$$/maps; :'],
                           env=env, capture_output=True, check=True, timeout=5)
    modules = sorted({line.split()[-1] for line in probe.stdout.decode().splitlines()
                      if line.endswith('/system.so')})
    if not modules or (args.modules and modules != [str(args.modules.resolve()/'zsh/system.so')]):
        raise RuntimeError('Unexpected module provenance: '+repr(modules))
    cases = {
        'ready': ['0', '0.0001', '0.02', '1', '-1', '-0.0001', '-0.001',
                  '2147484', '4294967296', '1e300', '-1e300', 'Inf', 'NaN',
                  '(++side, 1)', '1/0'],
        'delayed': ['0', '0.02', '1', '-1', '-0.0001', '-0.001',
                    '2147484', '4294967296', '1e300'],
        'interrupt': ['1', '-1', '2147484'],
        'eof': ['0', '1'],
    }
    rows = []
    for locale in ('C', 'C.UTF-8'):
        for mode, values in cases.items():
            for value in values:
                code = (setup + 'signals=0; side=0; count=unchanged; result=unchanged; ERRNO=0; '
                        'TRAPUSR1() { (( signals++ )); return 0; }; '
                        'print -ru2 READY; '
                        'sysread -i 0 -s 1 -t "$1" -c count result; '
                        'rc=$?; observed_errno=$ERRNO; '
                        'print -r -- "$rc|$result|$count|$side|$signals|$observed_errno"')
                proc = subprocess.Popen([str(shell), '-dfc', code, 'probe', value],
                                        env=dict(env, LC_ALL=locale), stdin=subprocess.PIPE,
                                        stdout=subprocess.PIPE, stderr=subprocess.PIPE, bufsize=0)
                marker = b''
                timed_out = False
                sent_signal = False
                try:
                    if mode == 'ready':
                        proc.stdin.write(b'X'); proc.stdin.flush()
                    if not select.select([proc.stderr], [], [], 5)[0]:
                        raise RuntimeError('Child did not reach READY')
                    marker = proc.stderr.readline()
                    if marker != b'READY\n':
                        raise RuntimeError('Unexpected startup output: '+repr(marker))
                    if mode in ('delayed', 'interrupt'):
                        time.sleep(.05)
                    if mode == 'interrupt' and proc.poll() is None:
                        try:
                            os.kill(proc.pid, signal.SIGUSR1)
                            sent_signal = True
                        except ProcessLookupError:
                            pass
                        time.sleep(.05)
                    try:
                        out, err = proc.communicate(b'X' if mode in ('delayed', 'interrupt') else b'', timeout=2)
                    except subprocess.TimeoutExpired:
                        timed_out = True
                        proc.kill(); out, err = proc.communicate()
                    rows.append(dict(locale=locale, mode=mode, value=value, status=proc.returncode,
                                     stdout=out.decode(errors='backslashreplace'),
                                     stderr=err.decode(errors='backslashreplace'),
                                     sent_signal=sent_signal, harness_timeout=timed_out))
                finally:
                    if proc.poll() is None:
                        proc.kill(); proc.communicate()
    report = dict(shell=str(shell), sha256=hashlib.sha256(shell.read_bytes()).hexdigest(),
                  modules={p: hashlib.sha256(Path(p).read_bytes()).hexdigest() for p in modules},
                  cases=len(rows), harness_timeouts=sum(r['harness_timeout'] for r in rows),
                  sanitizer_diagnostics=sum('runtime error:' in r['stderr'] for r in rows), runs=rows)
    args.output.parent.mkdir(parents=True, exist_ok=True)
    args.output.write_text(json.dumps(report, indent=2)+'\n')
    print(json.dumps({k: v for k, v in report.items() if k != 'runs'}))


if __name__ == '__main__':
    main()
