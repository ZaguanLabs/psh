#!/usr/bin/env python3
"""Check source/history lifetimes against an upstream oracle and arena-aware builds."""
import argparse
import concurrent.futures
import hashlib
import json
import os
from pathlib import Path
import subprocess
import tempfile


def sha(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument('--reference', type=Path, required=True)
    p.add_argument('--candidate', type=Path, required=True)
    p.add_argument('--baseline', type=Path, required=True)
    p.add_argument('--heap-reference', type=Path, required=True)
    p.add_argument('--heap-candidate', type=Path, required=True)
    p.add_argument('--output', type=Path, required=True)
    args = p.parse_args()
    if os.geteuid() == 0:
        p.error('run as an ordinary user; unreadable-file tests require it')
    hosts = {name: getattr(args, name.replace('-', '_')).resolve(strict=True)
             for name in ('reference', 'candidate', 'baseline',
                          'heap-reference', 'heap-candidate')}
    fingerprints = {name: sha(path) for name, path in hosts.items()}
    with tempfile.TemporaryDirectory(prefix='psh-heap-lifetimes-') as temporary:
        root = Path(temporary)
        folder = root / 'input'
        folder.mkdir()
        (folder / 'sub').mkdir()
        (folder / 'directory').mkdir()
        for name in ('denied.zsh', 'denied script.zsh', 'sub/denied.zsh'):
            f = folder / name
            f.write_text('print SHOULD_NOT_RUN\n')
            f.chmod(0)
        (folder / 'good.zsh').write_text('print -r -- "inside:$0:$*"; return 7\n')
        cases = []
        targets = [('searched-denied', 'denied.zsh', True, ''),
                   ('spaced-denied', 'denied script.zsh', True, ''),
                   ('absolute-denied', str(folder / 'denied.zsh'), False, ''),
                   ('pathdirs-denied', 'sub/denied.zsh', True, 'setopt pathdirs'),
                   ('missing', 'absent.zsh', False, ''),
                   ('directory', 'directory', False, ''),
                   ('success', 'good.zsh', False, '')]
        for mode in ('zsh', 'sh', 'ksh'):
            for builtin in ('.', 'source'):
                for label, target, known_bug, options in targets:
                    code = (f'emulate -R {mode}; {options}; '
                            'path=("$1/input"); target=$2; '
                            'set -- preserved arguments; '
                            f'{builtin} "$target" changed operands; '
                            'result=$?; print -r -- "status:$result" "restored:$*"')
                    # An empty optional command must not produce "; ;" syntax.
                    code = code.replace('; ;', ';')
                    cases.append(dict(name=f'source/{mode}/{builtin}/{label}',
                                      kind='source', known_bug=known_bug, code=code,
                                      arguments=[str(root), target]))
        inputs = {
            'empty': b'',
            'ordinary': b'print one\nprint "two words"\n',
            'extended': b': 100:2;print one\n: 103:1;print two\n',
            'continuation': b'print one\\\n two\n',
            'partial-meta': b'print x\x83\n',
            'partial-meta-eof': b'print x\x83',
            'long-partial-meta': b'print ' + b'x' * 18000 + b'\x83\n',
            'raw-token': b'print \x84\n',
            'corrupt-following-line': b'print \x84\n\x00\n',
            'utf8': 'print æ界\n'.encode(),
        }
        for label, data in inputs.items():
            for lex in (False, True):
                hist = root / f'history-{label}-{lex}'
                hist.write_bytes(data)
                code = ('emulate -R zsh; ' + ('setopt histlexwords; ' if lex else '') +
                        'fc -p "$1" 100 0; print -r -- "push:$?"; '
                        'if (( HISTCMD > 0 )); then fc -ln 1; fi; '
                        'fc -P; print -r -- "pop:$?"')
                cases.append(dict(name=f'history/{label}/lex={lex}', kind='history',
                                  known_bug=label in ('partial-meta', 'partial-meta-eof',
                                                     'long-partial-meta', 'raw-token',
                                                     'corrupt-following-line'),
                                  code=code, arguments=[str(hist)],
                                  input_sha256=hashlib.sha256(data).hexdigest()))
        def run(spec):
            case, locale = spec
            arguments = list(case['arguments'])
            history = None
            if case['kind'] == 'history':
                # Locale workers must not contend for the same history lock.
                original = Path(arguments[0])
                history = original.with_name(original.name + '-' + locale)
                history.write_bytes(original.read_bytes())
                arguments[0] = str(history)
            observations = {}
            for name, shell in hosts.items():
                command = [str(shell), '-dfc', case['code'], 'lifetime-fixture',
                           *arguments]
                if name.startswith('heap-'):
                    command = ['valgrind', '--quiet', '--track-origins=yes',
                               '--error-exitcode=97', *command]
                result = subprocess.run(command, cwd=root, capture_output=True,
                                        env={'PATH': '/usr/bin:/bin', 'LC_ALL': locale},
                                        timeout=90)
                observations[name] = dict(command=command, status=result.returncode,
                                          stdout_hex=result.stdout.hex(),
                                          stderr_hex=result.stderr.hex())
                if history is not None:
                    assert sha(history) == case['input_sha256']
                    # A crashing negative control can leave a lock behind.
                    # Record it, then isolate the next host from that side effect.
                    lock = Path(str(history) + '.LOCK')
                    left_lock = os.path.lexists(lock)
                    observations[name]['left_history_lock'] = left_lock
                    if left_lock:
                        lock.unlink()
            def state(name):
                row = observations[name]
                return row['status'], row['stdout_hex'], row['stderr_hex']
            correct = state('candidate') == state('reference')
            heap_correct = state('heap-candidate') == state('reference')
            baseline_same = state('baseline') == state('reference')
            # Preserve diagnosed negative controls; unrelated differences fail.
            allowed_difference = baseline_same or case['known_bug']
            return dict(case=case['name'], locale=locale,
                        input_sha256=case.get('input_sha256'), known_bug=case['known_bug'],
                        baseline_matches=baseline_same, candidate_matches=correct,
                        heap_candidate_matches=heap_correct,
                        passed=correct and heap_correct and allowed_difference,
                        observations=observations)
        with concurrent.futures.ThreadPoolExecutor(max_workers=3) as pool:
            rows = list(pool.map(run, [(c, loc) for c in cases
                                      for loc in ('C', 'C.UTF-8')]))
    negative = {kind: sum(r['observations']['heap-reference']['status'] == 97
                         for r in rows if r['case'].startswith(kind + '/'))
                for kind in ('source', 'history')}
    passed = all(r['passed'] for r in rows) and all(negative.values())
    assert fingerprints == {name: sha(path) for name, path in hosts.items()}
    report = dict(passed=passed, cases=len(rows), driver_sha256=sha(Path(__file__)),
                  binary_sha256=fingerprints, negative_memcheck_cases=negative,
                  runs=rows)
    args.output.parent.mkdir(parents=True, exist_ok=True)
    args.output.write_text(json.dumps(report, indent=2) + '\n')
    print(f"heap lifetime cases={len(rows)} passed={passed} negative controls={negative}")
    for row in rows:
        if not row['passed']:
            print('FAILED', row['case'], row['locale'])
    raise SystemExit(0 if passed else 1)


if __name__ == '__main__':
    main()
