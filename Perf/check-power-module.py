#!/usr/bin/env python3
"""Compare power values, assignments, state and floating environment per host SDK."""
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
    p.add_argument('--huge', action='store_true', help='also check huge exponents on candidate only')
    p.add_argument('--locale', action='append', dest='locales')
    p.add_argument('--output', type=Path, required=True)
    a = p.parse_args()
    a.output.parent.mkdir(parents=True, exist_ok=True)
    a.output.unlink(missing_ok=True)
    root = Path(__file__).resolve().parent
    source = root / 'power-module.c'
    folder = a.output.resolve().with_suffix('')
    folder.mkdir(exist_ok=True)
    modules, commands = [], []
    for host in range(2):
        destination = folder / str(host)
        destination.mkdir(exist_ok=True)
        module = destination / 'psh_power_fixture.so'
        headers = (a.candidate_headers_build or a.headers_build) if host else a.headers_build
        sources = (a.candidate_headers_source or a.headers_source) if host else a.headers_source
        command = ['cc', '-O2', '-g', '-shared', '-fPIC', '-DMODULE', '-DHAVE_CONFIG_H',
                   '-I' + str(headers.resolve(strict=True) / 'Src'),
                   '-I' + str(sources.resolve(strict=True) / 'Src'), str(source), '-o', str(module), '-lm']
        subprocess.run(command, check=True)
        modules.append(module); commands.append(command)
    shells = [s.resolve(strict=True) for s in [a.baseline, a.candidate]]
    sha = lambda p: hashlib.sha256(p.read_bytes()).hexdigest()
    inputs = [*shells, source, *modules, Path(__file__).resolve()]
    fingerprints = {str(p): sha(p) for p in inputs}
    runs = []
    script = 'module_path=("$1"); zmodload psh_power_fixture || exit 1; "$2" || exit 2; zmodload -u psh_power_fixture || exit 3'
    for locale in a.locales or ['C', 'C.UTF-8']:
        expected = None
        jobs = [(0, False), (1, False)] + ([(1, True)] if a.huge else [])
        for host, huge in jobs:
            label = f'{host}-{locale}-' + ('huge' if huge else 'common')
            prefix = []
            memory_log = folder / (label + '.memcheck.log')
            if a.memcheck:
                prefix = ['valgrind', '--error-exitcode=97', '--leak-check=no',
                          '--log-file=' + str(memory_log)]
            command = prefix + [str(shells[host]), '-dfc', script, 'power-comparison',
                str(modules[host].parent), 'psh-power-huge-check' if huge else 'psh-power-check']
            result = subprocess.run(command, env={'PATH': '/usr/bin:/bin', 'LC_ALL': locale},
                                    capture_output=True, timeout=30 if huge else 300)
            count = re.fullmatch(rb'checks=(\d+) digest=\d+\npower-done\n', result.stdout)
            if result.returncode or result.stderr or not count or int(count[1]) != (160 if huge else 60832):
                raise RuntimeError((label, result.returncode, result.stdout[-1000:], result.stderr[-1000:]))
            if a.memcheck:
                assert 'ERROR SUMMARY: 0 errors' in memory_log.read_text()
            if not huge:
                if expected is not None and expected != result.stdout:
                    raise RuntimeError((locale, 'power state mismatch', expected, result.stdout))
                expected = result.stdout
            runs.append(dict(shell=str(shells[host]), locale=locale, huge=huge,
                memcheck=a.memcheck, checks=int(count[1]), stdout=result.stdout.decode(),
                command=command, status=0))
            print(label, int(count[1]), 'passed', flush=True)
    assert fingerprints == {str(p): sha(p) for p in inputs}
    a.output.write_text(json.dumps(dict(passed=True, fingerprints=fingerprints,
        compile_commands=commands, checks=sum(r['checks'] for r in runs), runs=runs), indent=2) + '\n')


if __name__ == '__main__':
    main()
