#!/usr/bin/env python3
"""Compare substitution boundaries, evaluation order and literal byte spans."""
import argparse
import hashlib
import itertools
import json
from pathlib import Path
import subprocess


def cases():
    payloads = ("''", "'x=y:a b'", "'é😀'", "$'x\\0y\\203\\377z'",
                "'$(print -r -- expanded)'", "'${v} `print tick` = <(x)'",
                "$'" + "".join(f"\\{b:03o}" for b in range(256)) + "'")
    payloads += ("'" + "x" * 33 + "'", "'" + "x" * 1024 + "'",
                 "'" + "é" * 31 + "= " + "x" * 33 + "'")
    forms = (
        'r=prefix${v}suffix', 'r="prefix${v}suffix"',
        'r=${(qqq)v}', 'r=${(e)v}', 'r=${(U)v}', 'r=${v//x/REPLACED}',
        'r=$((++i))${v}$[i+=2]',
        'r=$(print -rn -- "before${v}after")',
        'r=`print -rn -- "before${v}after"`',
        'typeset r=key=${v}', 'typeset r="key=${v}"',
        'export r=key=${v}',
        'typeset -a a; a=(before${v}after "key=${v}"); typeset -p a; r=$#a',
        'setopt shwordsplit; typeset -a a; a=(before${v}after); typeset -p a; r=$#a',
        'setopt magic_equal_subst; typeset r=key=${v}',
        'r="${v}$(print -rn -- mid)${v}"',
        'r="${v}${(j.:.)${(s: :)v}}${v}"',
        'r=$(< <(print -rn -- "$v"))',
        'readfile() { REPLY=$(< "$1"); }; readfile =(print -rn -- "$v"); r=$REPLY',
        'r=$(print -r -- "$v" > >(IFS= read -r line; print -rn -- "$line"))',
    )
    forms += ('r="' + 'x' * 65 + '${v}' + 'y' * 65 + '$((++i))' + 'z' * 65 + '"',
              'typeset r=' + 'x' * 33 + '=${v}' + 'y' * 33)
    for mode, mb, payload, form in itertools.product(
            ("zsh", "ksh", "sh"), ("multibyte", "nomultibyte"), payloads, forms):
        script = (f"emulate -R {mode}\nsetopt {mb}\n"
                  f"v={payload}\ni=0\n{form}\n"
                  "printf '%s\\0' \"$r\"\ntypeset -p v i\n"
                  "print -r -- comparison-complete\n")
        yield f"{mode}/{mb}/{payload}/{form}", script


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("baseline", type=Path)
    parser.add_argument("candidate", type=Path)
    parser.add_argument("--output", type=Path, required=True)
    args = parser.parse_args()
    shells = [str(p.resolve(strict=True)) for p in (args.baseline, args.candidate)]
    failures = []
    checks = 0
    for locale in ("C", "C.UTF-8"):
        for label, script in cases():
            results = []
            for shell in shells:
                r = subprocess.run([shell, "-dfc", script, "comparison"],
                                   env={"PATH": "/usr/bin:/bin", "LC_ALL": locale},
                                   capture_output=True, timeout=30)
                results.append((r.returncode, r.stdout, r.stderr))
            checks += 1
            if results[0] != results[1] or not results[0][1].endswith(b"comparison-complete\n"):
                failures.append({"locale": locale, "case": label, "script": script,
                                 "results": [[rc, out.hex(), err.hex()] for rc, out, err in results]})
        print(f"{locale}: {checks} checks, {len(failures)} differences", flush=True)
    args.output.parent.mkdir(parents=True, exist_ok=True)
    args.output.write_text(json.dumps({"shells": shells, "checks": checks,
                                      "source_sha256": hashlib.sha256(Path(__file__).read_bytes()).hexdigest(),
                                      "differences": failures}, indent=2) + "\n")
    raise SystemExit(bool(failures))


if __name__ == "__main__":
    main()
