#!/usr/bin/env python3
"""Independent range and state oracle for sysread timeout conversion.

Uses ready seekable input, so representable long/negative waits cannot hang.
The companion probe-system-timeouts.py covers delayed input and interruption.
"""
import argparse
import hashlib
import json
import math
from pathlib import Path
import subprocess
import tempfile


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--shell', type=Path, required=True)
    parser.add_argument('--modules', type=Path)
    parser.add_argument('--backend', choices=('poll', 'select'), required=True)
    parser.add_argument('--output', type=Path, required=True)
    parser.add_argument('--reference', type=Path)
    parser.add_argument('--require-pass', action='store_true')
    args = parser.parse_args()
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
    lo, hi = -2147483648, 2147483647
    integers = [lo-1, lo, lo+1, -4294967296, -2147484, -2147483, -1,
                0, 1, 2147483, 2147484, hi-1, hi, hi+1, 4294967296,
                9223372036854775807, -9223372036854775807]
    floats = [-1e300, -float('inf'), float('nan'), float('inf'), 1e300,
              -1.0, -0.001, -0.0001, -0.0, 0.0, 0.0001, 0.001, 0.9]
    # Adjacent binary floats around both conversion boundaries and zero.
    for scale in (1, 1000):
        for edge in ((lo-1)/scale, (hi+1)/scale, lo/scale, hi/scale):
            floats += [math.nextafter(edge, -math.inf), edge,
                       math.nextafter(edge, math.inf)]
    cases = [(str(n), n, False) for n in integers]
    cases += [(('NaN' if math.isnan(n) else 'Inf' if n == math.inf else
                '-Inf' if n == -math.inf else repr(n)), n, True) for n in floats]
    cases += [('(++side, 0)', 0, False), ('(++side, 4294967296)', 4294967296, False)]
    cases += [('(-9223372036854775807 - 1)', -9223372036854775808, False)]
    for n in [-float.fromhex('0x1.fffffffffffffp+1023'),
              math.nextafter(-0.001, -math.inf), math.nextafter(-0.001, math.inf),
              math.nextafter(0.0, -math.inf)]:
        cases.append((repr(n), n, True))
    rows = []
    with tempfile.TemporaryFile() as source:
        source.write(b'ABC'); source.flush()
        for locale in ('C', 'C.UTF-8'):
            for force_float in (False, True):
                for expression, value, floating in cases:
                    floating = floating or force_float
                    numeric = float(value) if floating else value
                    converted = numeric*1000 if args.backend == 'poll' else numeric
                    if args.backend == 'poll' and math.isfinite(numeric) and numeric <= -1:
                        converted = -1
                    reject = (not math.isfinite(converted) or
                              not lo <= math.trunc(converted) <= hi)
                    # Existing select behavior for negative timeval fields.
                    select_error = (not reject and args.backend == 'select' and
                                    (math.trunc(numeric) < 0 or
                                     (floating and math.trunc((numeric-math.trunc(numeric))*1e6) < 0)))
                    side = 1 if expression.startswith('(++side') else 0
                    side = '1.' if side and force_float else str(side)
                    expected = (f'1|unchanged|unchanged|{side}\n' if reject else
                                f'2|unchanged|unchanged|{side}\n' if select_error else
                                f'0|A|1|{side}\n').encode()
                    source.seek(0)
                    code = (setup+('setopt forcefloat; ' if force_float else '')+
                            'side=0; result=unchanged; count=unchanged; '
                            'sysread -t "$1" -s 1 -c count result; '
                            'print -r -- "$?|$result|$count|$side"')
                    proc = subprocess.run([str(shell), '-dfc', code, 'probe', expression],
                                          stdin=source, env=dict(env, LC_ALL=locale),
                                          capture_output=True, timeout=5)
                    expected_err = (f'zsh:sysread:1: timeout out of range: {expression}\n'.encode()
                                    if reject else b'')
                    passed = (proc.returncode == 0 and proc.stdout == expected and
                              proc.stderr == expected_err and
                              source.tell() == (0 if reject or select_error else 1))
                    rows.append(dict(locale=locale, force_float=force_float, expression=expression,
                                     reject=reject, passed=passed, status=proc.returncode,
                                     stdout=proc.stdout.decode(errors='backslashreplace'),
                                     stderr=proc.stderr.decode(errors='backslashreplace'), offset=source.tell()))
    report = dict(shell=str(shell), sha256=hashlib.sha256(shell.read_bytes()).hexdigest(),
                  modules={p: hashlib.sha256(Path(p).read_bytes()).hexdigest() for p in modules},
                  backend=args.backend, cases=len(rows), rejection_cases=sum(r['reject'] for r in rows),
                  failures=sum(not r['passed'] for r in rows), runs=rows)
    if args.reference:
        previous = [r for r in json.loads(args.reference.read_text())['runs'] if not r['reject']]
        control_keys = {(r['locale'], r['force_float'], r['expression']) for r in previous}
        current = [r for r in rows if (r['locale'], r['force_float'], r['expression']) in control_keys]
        # Controls must match raw observed outcomes, including stderr.
        keys = ('locale', 'force_float', 'expression', 'status', 'stdout', 'stderr', 'offset')
        diff = sum(any(a[k] != b[k] for k in keys) for a,b in zip(previous,current))
        diff += abs(len(previous)-len(current))
        report['controls'] = dict(cases=len(current), differences=diff)
    args.output.parent.mkdir(parents=True, exist_ok=True)
    args.output.write_text(json.dumps(report, indent=2)+'\n')
    print(json.dumps({k:v for k,v in report.items() if k != 'runs'}))
    if args.require_pass and (report['failures'] or report.get('controls',{}).get('differences',0)):
        raise SystemExit(1)


if __name__ == '__main__':
    main()
