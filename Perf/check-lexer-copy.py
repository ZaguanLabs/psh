#!/usr/bin/env python3
"""Compare lexer alias/token behavior, including complete diagnostics and bytes."""
import argparse
from concurrent.futures import ThreadPoolExecutor
import hashlib
import itertools
import json
from pathlib import Path
import shlex
import subprocess
import tempfile


def sha(p):
    return hashlib.sha256(p.read_bytes()).hexdigest()


def fixtures():
    rows = []
    forms = ('mark', r'\mark', "'mark'", '"mark"', "m'a'rk", r'm\ark',
             '$name', '$(print -r -- mark)', '${name}', 'mark.sfx',
             "'mark.sfx'", 'é界', "$'raw\\xff'", "$'a\\0b'", "''")
    for mode, options, word in itertools.product(
            ('zsh', 'sh', 'ksh'), ('', 'setopt posixaliases', 'unsetopt aliases'), forms):
        setup = (f'emulate -R {mode}; {options or ":"}; '
                 'mark() { print -r -- function "$@"; }; '
                 "alias mark='print -r -- alias'; alias -s sfx='print -r -- suffix'; "
                 'name=mark; ')
        # A fresh eval is necessary: aliases take effect at parse time.
        code = word + ' tail; print -r -- done'
        rows.append((f'word/{mode}/{options}/{word}', setup+'eval '+shlex.quote(code), True))
    extra = {
        'trailing-space': "alias a='print -r -- '; alias b=expanded; eval 'a b b'",
        'global': "alias -g G='one two'; eval 'print -rl -- G \"G\" \\G'",
        'recursive': "alias a='b'; alias b='a'; a() { print recursion-stopped; }; eval a",
        'quoted-alias': "alias '\\mark=print -r -- escaped'; eval '\\mark tail'",
        'reserved': "alias '!=print -r -- bang'; eval '! true'; setopt posixaliases; eval '! false'",
        'operator': "alias -g '&&=(){ return $?; } && '; eval 'print one && print two'",
        'function-retention': "alias a='print -r -- old'; eval 'kept() { a; }'; alias a='print new'; kept",
        'nested-eval': "alias a='print -r -- nested'; eval 'eval a; print after'",
        'substitution': "alias a='print -r -- inside'; eval 'v=$(a); print -r -- \"$v\"'",
        'process-substitution': "alias a='print -r -- inside'; eval 'read -r v < <(a); print -r -- \"$v\"'",
        'condition': "eval '[[ ! abc == def ]] && print condition; { print braces; }'",
        'case': "eval 'case abc in a*) print matched;; *) print missed;; esac'",
        'loop': "eval 'for x in one two; do print -r -- $x; done'",
        'heredoc': "alias a='print wrong'; eval 'read -r x <<EOF\na\nEOF\nprint -r -- \"$x\"'",
        'trap': "alias a='print -r -- trapped'; trap 'a' USR1; kill -USR1 $$; print after",
        'always': "eval '{ print body; false; } always { print cleanup; }'",
        'syntax-error': "eval 'if'; print recovered",
        'function-error': "alias a=b; eval 'a() { :; }'; print recovered",
        'function-option': "setopt aliasfuncdef; alias a=b; eval 'a() { print retained; }'; b",
    }
    rows.extend((name, 'emulate -R zsh; '+code, name.endswith('error')) for name, code in extra.items())
    for n in (0, 1, 32, 4096, 32768):
        for quoted in (False, True):
            word = 'x'*n
            if quoted: word = '"'+word+'"'
            code = 'v=('+word+'); print -rl -- "${(@qqqq)v}"; print done'
            rows.append((f'long/{n}/{quoted}', code, False))
    return rows


def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument('shells', type=Path, nargs='+')
    p.add_argument('--output', type=Path, required=True)
    p.add_argument('--memcheck', action='store_true')
    a = p.parse_args()
    shells = [x.resolve(strict=True) for x in a.shells]
    hashes = [sha(x) for x in shells]
    with tempfile.TemporaryDirectory(prefix='psh-lexer-copy-') as tmp:
        def run(spec):
            (name, code, diagnostic), locale = spec
            observations = []
            for shell in shells:
                cmd = [str(shell), '-dfc', code, 'lexer-fixture']
                if a.memcheck:
                    cmd = ['valgrind', '--quiet', '--track-origins=yes', '--error-exitcode=97', *cmd]
                r = subprocess.run(cmd, cwd=tmp, env={'PATH':'/usr/bin:/bin', 'LC_ALL':locale},
                                   capture_output=True, timeout=60)
                observations.append(dict(status=r.returncode, stdout_hex=r.stdout.hex(), stderr_hex=r.stderr.hex()))
            expected_status = 1 if name == 'always' else 0
            passed = all(o == observations[0] and o['status'] == expected_status and
                         (diagnostic or not o['stderr_hex']) for o in observations)
            return dict(case=name, locale=locale, code=code, passed=passed, observations=observations)
        with ThreadPoolExecutor(max_workers=3) as pool:
            rows = list(pool.map(run, itertools.product(fixtures(), ('C', 'C.UTF-8'))))
    assert hashes == [sha(x) for x in shells]
    report = dict(passed=all(x['passed'] for x in rows), shells=list(map(str,shells)),
                  binary_sha256=hashes, driver_sha256=sha(Path(__file__)), memcheck=a.memcheck, runs=rows)
    a.output.write_text(json.dumps(report, indent=2)+'\n')
    print('lexer cases', len(rows), 'passed', report['passed'])
    for row in rows:
        if not row['passed']: print('FAILED', row['case'], row['locale'])
    raise SystemExit(0 if report['passed'] else 1)


if __name__ == '__main__':
    main()
