#!/usr/bin/env python3
"""Compare raw-byte hash values, unsigned overflow and protected boundaries."""
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
    p.add_argument('--headers-build', type=Path, default=Path('.work/baseline'))
    p.add_argument('--headers-source', type=Path, default=Path('.work/pristine'))
    p.add_argument('--memcheck', action='store_true')
    p.add_argument('--locale', action='append', dest='locales')
    p.add_argument('--output', type=Path, required=True)
    a = p.parse_args()
    a.output.parent.mkdir(parents=True, exist_ok=True)
    a.output.unlink(missing_ok=True)
    root = Path(__file__).resolve().parent
    folder = a.output.resolve().with_suffix('')
    folder.mkdir(exist_ok=True)
    source, module = root / 'hash-module.c', folder / 'psh_hash_fixture.so'
    command = ['cc', '-O2', '-g', '-shared', '-fPIC', '-DMODULE', '-DHAVE_CONFIG_H',
               '-I' + str(a.headers_build.resolve(strict=True) / 'Src'),
               '-I' + str(a.headers_source.resolve(strict=True) / 'Src'), str(source), '-o', str(module)]
    subprocess.run(command, check=True)
    sha = lambda p: hashlib.sha256(p.read_bytes()).hexdigest()
    shells = [s.resolve(strict=True) for s in [a.baseline, a.candidate]]
    inputs = [*shells, source, module, Path(__file__).resolve()]
    fingerprints = {str(p): sha(p) for p in inputs}
    script = 'module_path=("$1"); zmodload psh_hash_fixture || exit 1; psh-hash-check || exit 2; zmodload -u psh_hash_fixture || exit 3'
    rows = []
    for locale in a.locales or ['C', 'C.UTF-8']:
        expected = None
        for index, shell in enumerate(shells):
            prefix = []
            if a.memcheck:
                prefix = ['valgrind', '--error-exitcode=97', '--leak-check=no',
                          '--log-file=' + str(folder / f'{index}-{locale}.memcheck.log')]
            r = subprocess.run(prefix + [str(shell), '-dfc', script, 'comparison', str(folder)],
                env={'PATH': '/usr/bin:/bin', 'LC_ALL': locale}, capture_output=True, timeout=300)
            count = re.fullmatch(rb'checks=(\d+) digest=\d+ exhaustive=522248 triples=2744 heap=8256 guards=1084 random=4096\nhash-done\n', r.stdout)
            if r.returncode or r.stderr or not count or int(count[1]) != 538428:
                raise RuntimeError((index, locale, r.returncode, r.stdout[-1000:], r.stderr[-1000:]))
            if expected is not None and r.stdout != expected:
                raise RuntimeError((locale, 'different hash values'))
            expected = r.stdout
            rows.append(dict(shell=str(shell), locale=locale, checks=int(count[1]),
                             status=0, memcheck=a.memcheck, stdout=r.stdout.decode()))
            print(index, locale, int(count[1]), 'hash checks matched', flush=True)
    assert fingerprints == {str(p): sha(p) for p in inputs}
    a.output.write_text(json.dumps(dict(passed=True, fingerprints=fingerprints,
        compile_command=command, checks=sum(r['checks'] for r in rows), runs=rows), indent=2) + '\n')


if __name__ == '__main__':
    main()
