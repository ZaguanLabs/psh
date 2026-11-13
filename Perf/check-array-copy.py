#!/usr/bin/env python3
"""Check bounded array-copy ownership and slice results against legacy hosts."""
import argparse
import hashlib
import itertools
import json
from pathlib import Path
import subprocess


def sha(p):
    return hashlib.sha256(p.read_bytes()).hexdigest()


def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument('shells', type=Path, nargs='+')
    p.add_argument('--headers-build', type=Path, required=True)
    p.add_argument('--headers-source', type=Path, required=True)
    p.add_argument('--memcheck', action='store_true')
    p.add_argument('--output', type=Path, required=True)
    a = p.parse_args()
    shells = [x.resolve(strict=True) for x in a.shells]
    hashes = [sha(x) for x in shells]
    folder = a.output.resolve().with_suffix('')
    folder.mkdir(parents=True, exist_ok=True)
    source = Path(__file__).with_name('array-copy-module.c').resolve()
    module = folder / 'psh_array_copy.so'
    command = ['cc', '-O2', '-g', '-shared', '-fPIC', '-DMODULE', '-DHAVE_CONFIG_H',
               '-I'+str(a.headers_build.resolve()/'Src'), '-I'+str(a.headers_source.resolve()/'Src'),
               str(source), '-o', str(module)]
    subprocess.run(command, check=True)
    cases = [('native', 'module_path=("$1"); zmodload psh_array_copy || exit 90; '
                        'psh-array-copy-check || exit 91; zmodload -u psh_array_copy')]
    for mode, kind, size in itertools.product(('zsh', 'ksh', 'sh'), ('plain', 'unique', 'tied', 'special'), (0, 4, 33, 4096)):
        name = 'argv' if kind == 'special' else 'a'
        declaration = {'plain':'typeset -a a', 'unique':'typeset -aU a',
                       'tied':'typeset -T joined a', 'special':'argv=()'}[kind]
        code = (f'emulate -R {mode}; {declaration}; integer i start end; '
                f'for (( i=0; i<{size}; ++i )); do {name}+=("v$i"); done; '
                f'{name}+=(\'\' \'two words\' $\'line\\nbreak\' $\'\\0\\377é\'); '
                f'for start in -3 0 1 2 32 {size+5}; do '
                f'for end in -1 0 1 3 33 {size+10}; do '
                f'out=("${{(@){name}[start,end]}}"); '
                'print -r -- "$start,$end:${#out}"; print -rl -- "${(@qqqq)out}"; '
                'done; done')
        cases.append((f'{mode}/{kind}/{size}', code))
    rows = []
    for case, code in cases:
        for locale in ('C', 'C.UTF-8'):
            outputs = []
            for shell in shells:
                cmd = [str(shell), '-dfc', code, 'array-copy-fixture', str(folder)]
                if a.memcheck:
                    cmd = ['valgrind','--quiet','--track-origins=yes','--error-exitcode=97',*cmd]
                r = subprocess.run(cmd, env={'PATH':'/usr/bin:/bin','LC_ALL':locale}, capture_output=True, timeout=120)
                outputs.append(dict(status=r.returncode, stdout_hex=r.stdout.hex(), stderr_hex=r.stderr.hex()))
            passed = all(o == outputs[0] and o['status'] == 0 and not o['stderr_hex'] for o in outputs)
            if case == 'native':
                passed = passed and bytes.fromhex(outputs[0]['stdout_hex']) == b'bounded-copy-checks=429 ok=1\n'
            rows.append(dict(case=case, locale=locale, code=code, passed=passed, observations=outputs))
    assert hashes == [sha(x) for x in shells]
    report = dict(passed=all(r['passed'] for r in rows), shells=list(map(str,shells)), binary_sha256=hashes,
                  driver_sha256=sha(Path(__file__)), native_source_sha256=sha(source),
                  module_sha256=sha(module), compile_command=command, memcheck=a.memcheck, runs=rows)
    a.output.write_text(json.dumps(report,indent=2)+'\n')
    print('array-copy groups',len(rows),'passed',report['passed'])
    for r in rows:
        if not r['passed']: print('FAILED',r['case'],r['locale'])
    raise SystemExit(0 if report['passed'] else 1)


if __name__ == '__main__':
    main()
