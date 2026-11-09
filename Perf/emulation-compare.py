#!/usr/bin/env python3
"""Compare front-end option emulation, local restoration, traces and sticky autoloads."""
import argparse
import hashlib
import itertools
import json
from pathlib import Path
import subprocess
import tempfile


def cases():
    for initial, target, dirty, context in itertools.product(
            ['zsh', 'ksh', 'sh', 'csh'], ['zsh', 'ksh', 'sh', 'csh'], [False, True],
            ['plain', 'full', 'local', 'local-full', 'sticky', 'autoload', 'trace', 'nested']):
        script = 'emulate -R ' + initial + '\n'
        if dirty:
            script += 'setopt extendedglob globdots appendhistory noaliases\n'
        script += 'builtin print -r -- before\nbuiltin emulate\nbuiltin set -o\n'
        body = 'builtin emulate; builtin set -o; builtin print -r -- inside'
        if context in ['plain', 'full']:
            script += f'emulate {"-R " if context == "full" else ""}{target}\n{body}\n'
        elif context in ['local', 'local-full', 'trace', 'nested']:
            flags = '-LR' if context == 'local-full' else '-L'
            inner = (f'g() {{ emulate -L {initial}; {body}; }}; g; ' if context == 'nested' else '')
            script += f'f() {{ emulate {flags} {target}; {body}; {inner}}}\n'
            if context == 'trace':
                script += 'functions -t f\n'
            script += 'f\n'
            if context == 'trace':
                script += 'functions +t f\n'
        elif context == 'sticky':
            script += f"emulate -R {target} -c 'f() {{ {body}; }}'\nf\n"
        else:
            script += 'fpath=("$1")\n'
            script += f"emulate -R {target} -c 'autoload -Uz _psh_emu_probe'\n_psh_emu_probe\n"
        script += 'builtin print -r -- after\nbuiltin emulate\nbuiltin set -o\nbuiltin print -r -- emulation-done\n'
        yield f'{initial}/{target}/{int(dirty)}/{context}', script


def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument('baseline', type=Path); p.add_argument('candidate', type=Path)
    p.add_argument('--locale', action='append', dest='locales')
    p.add_argument('--output', type=Path, required=True)
    a = p.parse_args(); a.output.parent.mkdir(parents=True, exist_ok=True)
    shells = [x.resolve(strict=True) for x in [a.baseline, a.candidate]]
    sha = lambda x: hashlib.sha256(x.read_bytes()).hexdigest()
    fingerprints = {str(x): sha(x) for x in [*shells, Path(__file__).resolve()]}; rows = []
    with tempfile.TemporaryDirectory(prefix='psh-emulation-') as folder:
        Path(folder, '_psh_emu_probe').write_text('builtin emulate\nbuiltin set -o\nbuiltin print -r -- autoload-inside\n')
        for locale in a.locales or ['C', 'C.UTF-8']:
            for label, script in cases():
                values = []
                for shell in shells:
                    r = subprocess.run([str(shell), '-dfc', script, 'comparison', folder],
                        env={'PATH': '/usr/bin:/bin', 'LC_ALL': locale}, capture_output=True, timeout=30)
                    if r.returncode or not r.stdout.endswith(b'emulation-done\n') or len(r.stdout.splitlines()) < 300:
                        raise RuntimeError((label, locale, r.returncode, r.stderr[-1500:]))
                    values.append((r.stdout, r.stderr))
                if values[0] != values[1]:
                    raise RuntimeError((label, locale, 'different state or trace'))
                rows.append(dict(case=label, locale=locale, status=0,
                    script_sha256=hashlib.sha256(script.encode()).hexdigest(),
                    stdout_sha256=hashlib.sha256(values[0][0]).hexdigest(),
                    stderr_sha256=hashlib.sha256(values[0][1]).hexdigest()))
            print(locale, '256 emulation front-end scenarios matched', flush=True)
    assert fingerprints == {n: sha(Path(n)) for n in fingerprints}
    a.output.write_text(json.dumps(dict(passed=True, checks=len(rows), fingerprints=fingerprints, cases=rows), indent=2) + '\n')


if __name__ == '__main__':
    main()
