#!/usr/bin/env python3
"""Compare arithmetic token values, endpoints, state and floating environment."""
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
    p.add_argument('--candidate-headers-build', type=Path)
    p.add_argument('--candidate-headers-source', type=Path)
    p.add_argument('--memcheck', action='store_true')
    p.add_argument('--locale', action='append', dest='locales')
    p.add_argument('--output', type=Path, required=True)
    a = p.parse_args()
    a.output.parent.mkdir(parents=True, exist_ok=True)
    a.output.unlink(missing_ok=True)
    root = Path(__file__).resolve().parent
    folder = a.output.resolve().with_suffix('')
    folder.mkdir(exist_ok=True)
    source = root / 'math-small-module.c'
    modules, commands, folders = [], [], []
    for index in range(2):
        destination = folder / str(index)
        destination.mkdir(exist_ok=True)
        module = destination / 'psh_small_math_fixture.so'
        headers = (a.candidate_headers_build or a.headers_build) if index else a.headers_build
        headers_source = (a.candidate_headers_source or a.headers_source) if index else a.headers_source
        command = ['cc', '-O2', '-g', '-shared', '-fPIC', '-DMODULE', '-DHAVE_CONFIG_H',
            '-I' + str(headers.resolve(strict=True) / 'Src'),
            '-I' + str(headers_source.resolve(strict=True) / 'Src'), str(source), '-o', str(module), '-lm']
        subprocess.run(command, check=True)
        modules.append(module); commands.append(command); folders.append(destination)
    sha = lambda p: hashlib.sha256(p.read_bytes()).hexdigest()
    shells = [s.resolve(strict=True) for s in [a.baseline, a.candidate]]
    inputs = [*shells, source, *modules, Path(__file__).resolve()]
    fingerprints = {str(p): sha(p) for p in inputs}
    script = 'module_path=("$1"); zmodload psh_small_math_fixture || exit 1; psh-small-math-check || exit 2; zmodload -u psh_small_math_fixture || exit 3'
    rows = []
    for locale in a.locales or ['C', 'C.UTF-8']:
        expected = None
        for index, shell in enumerate(shells):
            prefix = []
            if a.memcheck:
                prefix = ['valgrind', '--error-exitcode=97', '--leak-check=no',
                          '--log-file=' + str(folder / f'{index}-{locale}.memcheck.log')]
            r = subprocess.run(prefix + [str(shell), '-dfc', script, 'comparison', str(folders[index])],
                env={'PATH': '/usr/bin:/bin', 'LC_ALL': locale}, capture_output=True, timeout=300)
            count = re.fullmatch(rb'checks=(\d+) digest=\d+\nsmall-math-done\n', r.stdout)
            if r.returncode or r.stderr or not count or int(count[1]) != 1677760:
                raise RuntimeError((index, locale, r.returncode, r.stdout[-1000:], r.stderr[-1000:]))
            if expected is not None and r.stdout != expected:
                raise RuntimeError((locale, 'different arithmetic state'))
            expected = r.stdout
            rows.append(dict(shell=str(shell), locale=locale, checks=int(count[1]),
                             status=0, memcheck=a.memcheck, stdout=r.stdout.decode()))
            print(index, locale, int(count[1]), 'small-token states matched', flush=True)
    assert fingerprints == {str(p): sha(p) for p in inputs}
    a.output.write_text(json.dumps(dict(passed=True, fingerprints=fingerprints,
        compile_commands=commands, checks=sum(r['checks'] for r in rows), runs=rows), indent=2) + '\n')


if __name__ == '__main__':
    main()
