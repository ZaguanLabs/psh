#!/usr/bin/env python3
"""Diagnostic only: log actual malloc_trim calls at PTY boundaries, with states."""
import argparse
import hashlib
import json
from pathlib import Path
import runpy
import tempfile


def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument('--shell', type=Path, required=True)
    p.add_argument('--preload', type=Path, required=True)
    p.add_argument('--output', type=Path, required=True)
    p.add_argument('--fail-rusage', action='store_true')
    a = p.parse_args()
    shell = a.shell.resolve(strict=True)
    preload = a.preload.resolve(strict=True)
    helper = Path(__file__).with_name('prompt-memory.py')
    Shell = runpy.run_path(str(helper))['Shell']
    sha = lambda p: hashlib.sha256(p.read_bytes()).hexdigest()
    identities = {str(p): sha(p) for p in [shell, preload, helper, Path(__file__)]}
    rows = []
    with tempfile.TemporaryDirectory(prefix='psh-trim-cadence-') as temporary:
        home = Path(temporary)
        trace = home / 'trace'
        overrides = {'LD_PRELOAD': str(preload), 'PSH_TRIM_TRACE': str(trace)}
        if a.fail_rusage:
            overrides['PSH_RUSAGE_FAIL'] = '1'
        term = Shell(shell, home, overrides)
        try:
            def observe(phase, command):
                term.command(command + '; print -r -- "RESULT:$?"')
                data = trace.read_bytes() if trace.exists() else b''
                assert data == b'trim\n' * data.count(b'\n')
                rows.append(dict(phase=phase, trim_calls=data.count(b'\n'), memory=term.memory()))
            observe('setup', 'burst() { local -a payload; typeset -ga kept=(); local text=${(l:1024::x:)}; local -i i; '
                    'for ((i=0;i<20000;++i)); do payload+=("$text"); '
                    'if ((i%1000==0)); then kept+=("$text"); fi; done; '
                    '(( ${#payload}==20000 && ${#kept}==20 )); }')
            observe('first-burst', 'burst')
            for i in range(64):
                observe(f'idle-{i+1}', ':')
            observe('second-burst', 'burst')
            observe('check-results', 'verify() { local item; (( ${#kept}==20 )) || return 1; '
                    'for item in "${kept[@]}"; do [[ $item == ${(l:1024::x:)} ]] || return 1; done; }; verify')
        finally:
            term.close()
    assert identities == {p: sha(Path(p)) for p in identities}
    a.output.write_text(json.dumps(dict(identity=identities, fail_rusage=a.fail_rusage, scope='Instrumented call counts and memory; no timing claim', rows=rows), indent=2)+'\n')


if __name__ == '__main__':
    main()
