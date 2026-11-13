#!/usr/bin/env python3
"""Compare glob qualifier state and escaping program ownership across shells."""
import argparse
import concurrent.futures
import hashlib
import json
import os
from pathlib import Path
import shlex
import subprocess
import tempfile


def sha(p):
    return hashlib.sha256(p.read_bytes()).hexdigest()


def globcode(code, flags='N', pattern='*'):
    delimiter = next(c for c in '^%~!' if c not in code)
    return pattern + '(' + flags + 'e' + delimiter + shlex.quote(code) + delimiter + ')'


def fixtures():
    predicates = {
        'empty-program': '', 'true': ':', 'false': 'false', 'status': '(( ++count % 2 ))',
        'pattern': '[[ $REPLY == *a* ]]',
        'replace': 'REPLY="prefix:${REPLY}:suffix"',
        'array': 'reply=("$REPLY" "" "other:$REPLY")',
        'scalar-reply': 'reply="scalar:$REPLY"',
        'assoc-reply': 'typeset -A reply=(one "$REPLY" two value)',
        'unset': 'unset REPLY',
        'side-effects': 'trace+=("$REPLY"); (( ++count )); :',
        'eval': 'eval \'trace+=("eval:$REPLY"); :\'',
        'substitution': 'REPLY=$(print -r -- "$REPLY"); :',
        'subshell': '(trace+=(subshell); false); :',
        'pipeline': 'print -r -- "$REPLY" | { read -r item; trace+=("$item"); }; :',
        'anonymous': '() { local x=$REPLY; trace+=("$x"); }; :',
        'nested': 'saved=$REPLY; nested=(' + globcode(':', pattern='sub/*') + '); REPLY=$saved; :',
        'function': 'persist() { print -r -- "retained:$1"; }; :',
        'function-pattern': 'persist() { [[ $1 == a* ]] && print match; }; :',
        'function-redirect': 'persist() { print retained; } > /dev/null; :',
        'trap-string': 'trap \'print -r -- trapped\' USR1; :',
        'trap-function': 'TRAPUSR1() { print -r -- trapped; }; :',
        'trap-replace': 'trap \'trace+=(signal)\' USR1; kill -USR1 $$; :',
        'trap-exit': 'trap \'print -r -- exit-trapped\' EXIT; :',
        'handled-interrupt': 'trap \'trace+=(interrupt)\' INT; kill -INT $$; :',
        'always': '{ trace+=(body); false; } always { trace+=(cleanup); }; :',
        'return': 'return 0', 'break': 'break', 'continue': 'continue',
        'arithmetic-error': '(( 1 / 0 ))', 'syntax-error': 'if',
        'options': 'setopt extendedglob; [[ $REPLY != missing ]]',
        'legacy-native': 'psh-glob-parser-check',
    }
    rows = []
    tail = ('result=$?; print -r -- "status:$result" "count:$count"; '
            'print -rl -- "${(@qqqq)out}"; print -rl -- "${(@qqqq)trace}"; '
            'print -r -- end')
    for name, code in predicates.items():
        for flags in ('N', 'ND'):
            after = ''
            if name.startswith('function'):
                after = '; persist abc; persist xyz; print functions-survived'
            elif name in ('trap-string', 'trap-function'):
                after = '; kill -USR1 $$; print trap-survived'
            rows.append((name + '/' + flags,
                         'out=(' + globcode(code, flags) + '); ' + tail + after))
    rows.extend([
        ('plain-control', 'out=(*(ND)); ' + tail),
        ('function-qualifier', '_keep() { trace+=("$REPLY"); [[ $REPLY == a* ]]; }; out=(*(ND+_keep)); ' + tail),
        ('sort-code', 'out=(*(NDo' + "e^'REPLY=${#REPLY}'^" + ')); ' + tail),
        ('two-qualifiers', 'out=(*(NDe^\'trace+=(first); :\'^e^\'trace+=(second); :\'^)); ' + tail),
        ('dynamic-alias', "alias dynamic_pred='trace+=(first)'; out=(" + globcode("dynamic_pred; alias dynamic_pred='trace+=(later)'; :") + '); ' + tail),
        ('recursive-retention', 'out=(' + globcode('persist() { local -a r=(' + globcode(':', pattern='sub/*') + '); print -rl -- $r; }; :') + '); ' + tail + '; persist'),
        ('scope-return', 'runner() { local count=41; out=(' + globcode('return 3') + '); print reached; }; runner; ' + tail),
        ('empty-match', 'out=(' + globcode('print SHOULD_NOT_RUN', pattern='absent*') + '); ' + tail),
    ])
    return rows


def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument('shells', type=Path, nargs='+')
    p.add_argument('--headers-build', type=Path, required=True)
    p.add_argument('--headers-source', type=Path, required=True)
    p.add_argument('--output', type=Path, required=True)
    p.add_argument('--memcheck', action='store_true')
    args = p.parse_args()
    hosts = [x.resolve(strict=True) for x in args.shells]
    hashes = [sha(x) for x in hosts]
    folder = args.output.resolve().with_suffix('')
    folder.mkdir(parents=True, exist_ok=True)
    source = Path(__file__).with_name('glob-parser-module.c').resolve()
    module = folder / 'psh_glob_parser.so'
    compile_command = ['cc', '-O2', '-g', '-shared', '-fPIC', '-DMODULE', '-DHAVE_CONFIG_H',
                       '-I' + str(args.headers_build.resolve() / 'Src'),
                       '-I' + str(args.headers_source.resolve() / 'Src'), str(source), '-o', str(module)]
    subprocess.run(compile_command, check=True)
    with tempfile.TemporaryDirectory(prefix='psh-glob-programs-') as tmp:
        root = Path(tmp)
        for name in ('a', 'ab', 'b', '.hidden', 'two words', 'line\nend', "quote'file", 'é界', '-dash'):
            (root / name).touch()
        (root / os.fsdecode(b'raw\xff')).touch()
        (root / 'sub').mkdir()
        (root / 'sub/a').touch()
        (root / 'sub/b').touch()
        (root / 'link').symlink_to('a')
        (root / 'broken').symlink_to('absent')
        prefix = ('emulate -R zsh; module_path=("$1"); zmodload psh_glob_parser || exit 90; '
                  'psh-glob-parser-check || exit 91; typeset -a out trace; integer count=0; ')
        def run(spec):
            (name, code), locale = spec
            observations = []
            for shell in hosts:
                cmd = [str(shell), '-dfc', prefix + code, 'glob-fixture', str(folder)]
                if args.memcheck:
                    cmd = ['valgrind', '--quiet', '--track-origins=yes', '--error-exitcode=97', *cmd]
                r = subprocess.run(cmd, cwd=root, capture_output=True,
                                   env={'PATH': '/usr/bin:/bin', 'LC_ALL': locale}, timeout=60)
                observations.append(dict(status=r.returncode, stdout_hex=r.stdout.hex(), stderr_hex=r.stderr.hex()))
            matched = all(o == observations[0] for o in observations[1:])
            memory_ok = all(o['status'] not in (90, 91, 97) and o['status'] >= 0
                            for o in observations)
            diagnostic_case = name.split('/')[0] in ('syntax-error', 'arithmetic-error', 'break', 'continue', 'return')
            diagnostics_ok = diagnostic_case or all(not o['stderr_hex'] for o in observations)
            return dict(case=name, locale=locale, code=prefix+code, passed=matched and memory_ok and diagnostics_ok,
                        observations=observations)
        with concurrent.futures.ThreadPoolExecutor(max_workers=3) as pool:
            rows = list(pool.map(run, [(case, loc) for case in fixtures() for loc in ('C', 'C.UTF-8')]))
    assert hashes == [sha(x) for x in hosts]
    report = dict(passed=all(r['passed'] for r in rows), shells=[str(x) for x in hosts],
                  binary_sha256=hashes, driver_sha256=sha(Path(__file__)), module_source_sha256=sha(source),
                  module_sha256=sha(module), compile_command=compile_command, memcheck=args.memcheck, runs=rows)
    args.output.write_text(json.dumps(report, indent=2)+'\n')
    print('glob program cases', len(rows), 'passed', report['passed'])
    for row in rows:
        if not row['passed']: print('FAILED', row['case'], row['locale'])
    raise SystemExit(0 if report['passed'] else 1)


if __name__ == '__main__':
    main()
