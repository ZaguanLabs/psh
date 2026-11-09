#!/usr/bin/env python3
"""Compare numeric values, consumed bytes, errno and diagnostics with original Zsh."""
import argparse
import hashlib
import json
from pathlib import Path
import re
import subprocess


def main():
    root = Path(__file__).resolve().parent.parent
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument('baseline', type=Path)
    p.add_argument('candidate', type=Path)
    p.add_argument('--headers-build', type=Path, default=root / '.work/baseline')
    p.add_argument('--headers-source', type=Path, default=root / '.work/pristine')
    p.add_argument('--locale', action='append', dest='locales')
    p.add_argument('--memcheck', action='store_true')
    p.add_argument('--output', type=Path, required=True)
    a = p.parse_args()
    a.output.parent.mkdir(parents=True, exist_ok=True)
    folder = a.output.resolve().with_suffix('')
    folder.mkdir(exist_ok=True)
    module = folder / 'psh_strtol_fixture.so'
    source = root / 'Perf/strtol-module.c'
    command = ['cc', '-O2', '-g', '-shared', '-fPIC', '-DMODULE', '-DHAVE_CONFIG_H',
               '-I' + str(a.headers_build.resolve(strict=True) / 'Src'),
               '-I' + str(a.headers_source.resolve(strict=True) / 'Src'), str(source), '-o', str(module)]
    subprocess.run(command, check=True)
    script = '''module_path=("$1")
zmodload psh_strtol_fixture || exit 1
psh-strtol-check "$2" || exit 2
zmodload -u psh_strtol_fixture || exit 3
print -r -- matrix-done
'''
    sha = lambda path: hashlib.sha256(path.read_bytes()).hexdigest()
    shells = [x.resolve(strict=True) for x in (a.baseline, a.candidate)]
    fingerprints = {str(x): sha(x) for x in [*shells, source, root / 'Perf/strtol-reference.c', module]}
    rows = []
    for locale in a.locales or ['C', 'C.UTF-8']:
        expected = None
        for host, shell in enumerate(shells):
            for mode in ['reference', 'actual']:
                prefix = []
                if a.memcheck:
                    log = folder / f'{host}-{locale}-{mode}.memcheck.log'
                    prefix = ['valgrind', '--error-exitcode=97', '--leak-check=no', '--log-file=' + str(log)]
                result = subprocess.run(prefix + [str(shell), '-dfc', script, 'comparison', str(folder), mode],
                    env={'PATH': '/usr/bin:/bin', 'LC_ALL': locale}, capture_output=True, timeout=300)
                count = re.search(rb'(?m)^checks=(\d+)\nmatrix-done\n$', result.stdout)
                if result.returncode or not count:
                    raise RuntimeError((host, mode, locale, result.returncode, result.stderr[-1000:]))
                value = (result.stdout, result.stderr)
                if expected is None:
                    expected = value
                elif value != expected:
                    for label, old, new in zip(['stdout', 'stderr'], expected, value):
                        if old != new:
                            (folder / f'mismatch-{host}-{locale}-{mode}-{label}.expected').write_bytes(old)
                            (folder / f'mismatch-{host}-{locale}-{mode}-{label}.actual').write_bytes(new)
                    raise RuntimeError((host, mode, locale, 'values or diagnostics differ'))
                rows.append(dict(shell=str(shell), mode=mode, locale=locale, checks=int(count[1]),
                    status=0, memcheck=a.memcheck, stdout_sha256=hashlib.sha256(result.stdout).hexdigest(),
                    stderr_sha256=hashlib.sha256(result.stderr).hexdigest(), stderr_bytes=len(result.stderr)))
                print(host, mode, locale, count[1].decode(), 'conversion checks matched', flush=True)
    assert fingerprints == {name: sha(Path(name)) for name in fingerprints}, 'inputs changed'
    a.output.write_text(json.dumps(dict(passed=True, compile_command=command, fingerprints=fingerprints,
        checks=sum(x['checks'] for x in rows), runs=rows), indent=2) + '\n')


if __name__ == '__main__':
    main()
