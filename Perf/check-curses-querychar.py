#!/usr/bin/env python3
"""Check stock/zdraw first-character readback without losing colors or attributes."""
import argparse
import hashlib
import importlib.util
import json
import os
from pathlib import Path


def sha(p):
    return hashlib.sha256(p.read_bytes()).hexdigest()


def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument('--shell', type=Path, required=True)
    p.add_argument('--modules', type=Path, required=True)
    p.add_argument('--backend', choices=('zcurses', 'zdraw'), action='append')
    p.add_argument('--memcheck', action='store_true')
    p.add_argument('--output', type=Path, required=True)
    a = p.parse_args()
    shell = a.shell.resolve(strict=True)
    modules = a.modules.resolve(strict=True)
    folder = a.output.resolve().with_suffix('')
    folder.mkdir(parents=True, exist_ok=True)
    worker = Path(__file__).with_name('curses-querychar.zsh').resolve()
    driver = worker.parent.parent/'Vendor/zdraw/benchmarks/native.py'
    spec = importlib.util.spec_from_file_location('native_trial', driver)
    native = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(native)
    backends = a.backend or ['zcurses', 'zdraw']
    files = [shell, worker, driver, *[modules/('zsh/curses.so' if b == 'zcurses' else 'zdraw.so') for b in backends]]
    identities = {str(f):sha(f) for f in files}
    rows = []
    for locale in ('C', 'C.UTF-8'):
        os.environ['ZDRAW_TEST_LOCALE'] = locale
        for backend in backends:
            name = locale.replace('.', '-')+'-'+backend
            prefix = ()
            if a.memcheck:
                prefix = ('valgrind', '--quiet', '--track-origins=yes', '--error-exitcode=103',
                          '--log-file='+str(folder/(name+'.memcheck')))
            observed = native.trial(shell, modules, backend, 1, fixture=worker,
                                    capture=folder/name, prefix=prefix)
            raw = (folder/(name+'.report')).read_bytes()
            expected = f'cases={16 if locale == "C" else 48} failures=0\n'.encode()
            rows.append(dict(locale=locale, backend=backend, passed=raw.endswith(expected),
                             result=observed, stdout_hex=raw.hex()))
    assert identities == {name:sha(Path(name)) for name in identities}
    report = dict(passed=all(x['passed'] for x in rows), identities=identities,
                  driver_sha256=sha(Path(__file__)), memcheck=a.memcheck, runs=rows)
    a.output.write_text(json.dumps(report, indent=2)+'\n')
    print('querychar checks passed:', report['passed'])
    raise SystemExit(0 if report['passed'] else 1)


if __name__ == '__main__':
    main()
