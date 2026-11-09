#!/usr/bin/env python3
"""Compare append prefix reuse, mutation and supported mutable native loans."""
import argparse
import hashlib
import json
from pathlib import Path
import re
import subprocess


def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument('baseline', type=Path)
    p.add_argument('candidate', type=Path)
    p.add_argument('--headers-build', type=Path, required=True)
    p.add_argument('--headers-source', type=Path, required=True)
    p.add_argument('--memcheck', action='store_true')
    p.add_argument('--locale', action='append', dest='locales')
    p.add_argument('--output', type=Path, required=True)
    a = p.parse_args()
    a.output.parent.mkdir(parents=True, exist_ok=True)
    a.output.unlink(missing_ok=True)
    root = Path(__file__).resolve().parent
    folder = a.output.resolve().with_suffix('')
    folder.mkdir(exist_ok=True)
    source, script = root / 'array-cache-module.c', root / 'append-prefix.zsh'
    module = folder / 'psh_array_cache_fixture.so'
    command = ['cc', '-O2', '-g', '-shared', '-fPIC', '-DMODULE', '-DHAVE_CONFIG_H',
               '-I' + str(a.headers_build.resolve(strict=True) / 'Src'),
               '-I' + str(a.headers_source.resolve(strict=True) / 'Src'), str(source), '-o', str(module)]
    subprocess.run(command, check=True)
    sha = lambda p: hashlib.sha256(p.read_bytes()).hexdigest()
    shells = [s.resolve(strict=True) for s in [a.baseline, a.candidate]]
    inputs = [*shells, source, script, module, Path(__file__).resolve()]
    fingerprints = {str(p): sha(p) for p in inputs}
    rows = []
    for locale in a.locales or ['C', 'C.UTF-8']:
        for mode in ['zsh', 'ksh', 'sh']:
            expected = None
            for index, shell in enumerate(shells):
                prefix = []
                if a.memcheck:
                    prefix = ['valgrind', '--error-exitcode=97', '--leak-check=no',
                              '--log-file=' + str(folder / f'{index}-{mode}-{locale}.memcheck.log')]
                r = subprocess.run(prefix + [str(shell), '-df', str(script), str(folder), mode],
                    env={'PATH': '/usr/bin:/bin', 'LC_ALL': locale}, capture_output=True, timeout=300)
                count = re.search(rb'checks=(\d+) append-prefix-complete\n$', r.stdout)
                if r.returncode or r.stderr or not count or int(count[1]) < 700:
                    raise RuntimeError((index, locale, mode, r.returncode, r.stdout[-1000:], r.stderr[-1000:]))
                value = (r.stdout, r.stderr)
                if expected is not None and value != expected:
                    raise RuntimeError((locale, mode, 'different append state'))
                expected = value
                rows.append(dict(shell=str(shell), locale=locale, mode=mode, checks=int(count[1]),
                                 status=0, memcheck=a.memcheck,
                                 stdout_sha256=hashlib.sha256(r.stdout).hexdigest()))
                print(index, locale, mode, int(count[1]), 'states matched', flush=True)
    assert fingerprints == {str(p): sha(p) for p in inputs}
    a.output.write_text(json.dumps(dict(passed=True, fingerprints=fingerprints,
        compile_command=command, checks=sum(r['checks'] for r in rows), runs=rows), indent=2) + '\n')


if __name__ == '__main__':
    main()
