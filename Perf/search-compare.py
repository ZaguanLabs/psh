#!/usr/bin/env python3
"""Compare array pattern search flags, result bytes and capture state."""
import argparse
import hashlib
import itertools
import json
from pathlib import Path
import subprocess


def cases():
    arrays = ("()", "('')", "(a '' ab a é $'a\\0b' 'two words')",
              "(zero one two three four five six seven eight a)")
    patterns = "'a' 'a*' '*' '?' '' 'missing' 'é*' $'a\\0*' '(#b)(a*)'"
    starts = "-9 -1 0 1 2 4 5 100"
    counts = "-2 -1 0 1 2"
    for mode, multibyte, array in itertools.product(
        ("zsh", "ksh", "sh"), ("multibyte", "nomultibyte"), arrays,
    ):
        code = f"emulate -R {mode}\nsetopt extendedglob {multibyte}\n"
        code += f"typeset -a a={array}\nmatch=(); mbegin=(); mend=()\n"
        code += "integer begin_at match_number\n"
        for flag in ("i", "I", "r", "R"):
            code += f"for needle in {patterns}; do\n  for begin_at in {starts}; do\n"
            code += f"    for match_number in {counts}; do\n"
            expression = "${a[(" + flag + "b:begin_at:n:match_number:)$needle]}"
            code += f'      out="{expression}"\n      printf \'%s\\0\' "$out"\n'
            code += "      if [[ $needle == '(#b)(a*)' ]]; then typeset -p match mbegin mend; fi\n"
            code += "    done\n  done\ndone\n"
        code += "typeset -p a\nprint -r -- matrix-done\n"
        yield (f"{mode}/{multibyte}/{array}", code, 9 * 8 * 5 * 4, True)

    for mode, kind, expression in itertools.product(
        ("zsh", "ksh", "sh"), ("scalar", "hash"),
        ("${a[(i)a]}", "${a[(I)a]}", "${a[(r)a*]}", "${a[(R)a*]}"),
    ):
        setup = "a='abc a def'" if kind == "scalar" else "typeset -A a=(a alpha b beta)"
        yield (f"control/{mode}/{kind}/{expression}",
               f"emulate -R {mode}\n{setup}\nout=\"{expression}\"\n"
               "printf '%s\\0' \"$out\"\n", 1, False)

    for expression in ("${a[(i)[]}", "${a[(i)(]}", "${a[(ib:++counter:)a]}",
                       "${a[(in:++counter:)a]}", "${a[(ib:0:)a]}"):
        yield (f"syntax/effects/{expression}", "emulate -R zsh\nsetopt extendedglob\n"
               "a=(a b a); integer counter=0\n"
               f"out=\"{expression}\"\nprintf '%s\\0' \"$out\"\nprint -r -- $counter\n",
               1, False)
    yield ("range", "emulate -R zsh\na=(x a b a tail)\n"
           'out="${a[(r)a,(R)a]}"; printf \'%s\\0\' "$out"\n', 1, False)


def scalar_cases():
    payloads = ("''", "'a'", "'abc a def a'", "'éa😀aé'", "$'a\\0b\\203\\377a'",
                "'é 👩‍💻 a'", "$'a\\303\\251b\\303'")
    patterns = "'a' 'a*' '*' '?' '' 'missing' 'é*' $'a\\0*' '(#b)(a*)'"
    starts = "-9 -1 0 1 2 4 5 100"
    counts = "-2 -1 0 1 2"
    for mode, multibyte, payload in itertools.product(
        ("zsh", "ksh", "sh"), ("multibyte", "nomultibyte"), payloads,
    ):
        setup = f"emulate -R {mode}\nsetopt extendedglob {multibyte}\ns={payload}\n"
        code = setup + "match=(); mbegin=(); mend=()\ninteger begin_at match_number\n"
        for flag in ("i", "I", "r", "R"):
            code += f"for needle in {patterns}; do\n  for begin_at in {starts}; do\n"
            code += f"    for match_number in {counts}; do\n"
            expression = "${s[(" + flag + "b:begin_at:n:match_number:)$needle]}"
            code += f'      out="{expression}"\n      printf \'%s\\0\' "$out"\n'
            code += "      if [[ $needle == '(#b)(a*)' ]]; then typeset -p match mbegin mend; fi\n"
            code += "    done\n  done\ndone\n"
        code += "typeset -p s\nprint -r -- matrix-done\n"
        yield (f"scalar/{mode}/{multibyte}/{payload}", code, 9 * 8 * 5 * 4, True)

        code = setup + "match=(); mbegin=(); mend=()\n"
        for first, last in itertools.product(("r", "R"), repeat=2):
            code += "for left in 'a' 'missing' '(#b)(a*)'; do\n"
            code += "  for right in 'a' 'missing' '(#b)(a*)'; do\n"
            expression = "${s[(" + first + ")$left,(" + last + ")$right]}"
            code += f'    out="{expression}"\n    printf \'%s\\0\' "$out"\n'
            code += "    typeset -p match mbegin mend\n  done\ndone\n"
        code += "typeset -p s\nprint -r -- matrix-done\n"
        yield (f"scalar-range/{mode}/{multibyte}/{payload}", code, 4 * 3 * 3, True)

    for declaration, value in (("typeset -L12", "' aBc a'"), ("typeset -R12", "' aBc a'"),
                               ("typeset -Z12", "'001234'"), ("typeset -u", "'aBca'"),
                               ("typeset -l", "'ABCa'"), ("typeset -i", "123412")):
        for expression in ("${s[(i)a]}", "${s[(I)a]}", "${s[(r)a,(r)a]}",
                           "${s[(R)a,(R)a]}", "${s[(i)1]}", "${s[(r)1,(r)2]}"):
            yield (f"scalar-format/{declaration}/{expression}",
                   f"emulate -R zsh\n{declaration} s={value}\nout=\"{expression}\"\n"
                   "printf '%s\\0' \"$out\"\ntypeset -p s\n", 1, False)


def large_cases():
    starts = "-1 0 1 63 64 65 127 128 129 1024 1025 4294967295 4294967296 9223372036854775807"
    patterns = "'target' '*' 'missing' '(#b)(t*)'"
    for mode, multibyte, size in itertools.product(
        ("zsh", "ksh", "sh"), ("multibyte", "nomultibyte"), (63, 64, 65, 127, 128, 129, 1024),
    ):
        # Construct the same physical vector before changing indexing options.
        code = f"emulate -R zsh\ninteger size={size}\n"
        code += "typeset -a a=( ${(s::)${(l:$size::x:)}} )\n"
        code += "a[2]=$'é\\0x'; a[$((size/2))]=target; a[size]=target\n"
        code += f"emulate -R {mode}\nsetopt extendedglob {multibyte}\n"
        code += "match=(); mbegin=(); mend=()\ninteger begin_at match_number\n"
        code += "for iteration in 1 2 3; do\n"
        for flag in ("i", "I", "r", "R"):
            code += f"for needle in {patterns}; do\n  for begin_at in {starts}; do\n"
            code += "    for match_number in -1 1 2; do\n"
            expression = "${a[(" + flag + "b:begin_at:n:match_number:)$needle]}"
            code += f'      out="{expression}"\n      printf \'%s\\0\' "$out"\n'
            code += "      if [[ $needle == '(#b)(t*)' ]]; then typeset -p match mbegin mend; fi\n"
            code += "    done\n  done\ndone\n"
        code += "done\ntypeset -p a\nprint -r -- matrix-done\n"
        yield (f"large/{mode}/{multibyte}/{size}", code, 3 * 4 * 4 * 14 * 3, True)


def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument("baseline", type=Path)
    p.add_argument("candidate", type=Path)
    p.add_argument("--output", type=Path, required=True)
    p.add_argument("--scalars", action="store_true",
                   help="also compare scalar pattern searches, ranges and formatting")
    p.add_argument("--large", action="store_true",
                   help="also compare repeated searches across cached-prefix and wide-integer start boundaries")
    args = p.parse_args()
    shells = [str(s.resolve(strict=True)) for s in (args.baseline, args.candidate)]
    failures = []
    checks = 0
    for locale in ("C", "C.UTF-8"):
        for label, code, count, matrix in itertools.chain(
            cases(), scalar_cases() if args.scalars else (), large_cases() if args.large else (),
        ):
            results = []
            for shell in shells:
                r = subprocess.run([shell, "-dfc", code, "comparison"],
                                   env={"PATH": "/usr/bin:/bin", "LC_ALL": locale},
                                   capture_output=True, timeout=60)
                results.append((r.returncode, r.stdout, r.stderr))
            checks += count
            if (results[0] != results[1] or
                (matrix and (results[0][0] or not results[0][1].endswith(b"matrix-done\n")))):
                failures.append({"locale": locale, "case": label, "code": code,
                                 "results": [[rc, out.hex(), err.hex()] for rc, out, err in results]})
        print(f"{locale}: {checks} cumulative checks, {len(failures)} differences", flush=True)
    args.output.parent.mkdir(parents=True, exist_ok=True)
    args.output.write_text(json.dumps({"shells": shells, "checks": checks,
                                       "differences": failures,
                                       "source_sha256": hashlib.sha256(Path(__file__).read_bytes()).hexdigest()},
                                      indent=2) + "\n")
    raise SystemExit(bool(failures))


if __name__ == "__main__":
    main()
