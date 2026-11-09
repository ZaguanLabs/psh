#!/usr/bin/env python3
"""Check internal emulation installation against the original scan predicate."""
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
    p.add_argument('--memcheck', action='store_true')
    p.add_argument('--locale', action='append', dest='locales')
    p.add_argument('--output', type=Path, required=True)
    a = p.parse_args()
    a.output.parent.mkdir(parents=True, exist_ok=True)
    folder = a.output.resolve().with_suffix(''); folder.mkdir(exist_ok=True)
    source = root / 'Perf/emulation-module.c'; module = folder / 'psh_emulation_fixture.so'
    command = ['cc', '-O2', '-g', '-shared', '-fPIC', '-DMODULE', '-DHAVE_CONFIG_H',
        '-I' + str(a.headers_build.resolve(strict=True) / 'Src'),
        '-I' + str(a.headers_source.resolve(strict=True) / 'Src'), str(source), '-o', str(module)]
    subprocess.run(command, check=True)
    shells = [x.resolve(strict=True) for x in [a.baseline, a.candidate]]
    sha = lambda p: hashlib.sha256(p.read_bytes()).hexdigest()
    fingerprints = {str(p): sha(p) for p in [*shells, source, module]}
    script = 'module_path=("$1"); zmodload psh_emulation_fixture || exit 1; psh-emulation-check || exit 2; zmodload -u psh_emulation_fixture || exit 3'
    rows = []
    for locale in a.locales or ['C', 'C.UTF-8']:
        expected = None
        for host, shell in enumerate(shells):
            prefix = []
            if a.memcheck:
                prefix = ['valgrind', '--error-exitcode=97', '--leak-check=no', '--log-file=' + str(folder / f'{host}-{locale}.memcheck.log')]
            r = subprocess.run(prefix + [str(shell), '-dfc', script, 'comparison', str(folder)],
                env={'PATH': '/usr/bin:/bin', 'LC_ALL': locale}, capture_output=True, timeout=300)
            count = re.search(rb'^checks=(\d+) digest=\d+ queued=(\d+) unqueued=(\d+)\nmatrix-done\n$', r.stdout)
            if r.returncode or r.stderr or not count or not int(count[2]) or not int(count[3]):
                raise RuntimeError((host, locale, r.returncode, r.stdout[-1000:], r.stderr[-1000:]))
            if expected is not None:
                assert expected == r.stdout, (host, locale, 'different output')
            expected = r.stdout
            rows.append(dict(shell=str(shell), locale=locale, checks=int(count[1]), queued=int(count[2]),
                unqueued=int(count[3]), memcheck=a.memcheck, status=0, stdout=r.stdout.decode()))
            print(host, locale, count[1].decode(), 'emulation scenarios matched', flush=True)
    assert fingerprints == {n: sha(Path(n)) for n in fingerprints}, 'inputs changed'
    a.output.write_text(json.dumps(dict(passed=True, compile_command=command, fingerprints=fingerprints,
        checks=sum(x['checks'] for x in rows), runs=rows), indent=2) + '\n')


if __name__ == '__main__':
    main()
