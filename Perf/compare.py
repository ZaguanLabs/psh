#!/usr/bin/env python3
"""Compare observable array-assignment behavior of two trusted Zsh builds."""
import argparse
import itertools
import json
import os
from pathlib import Path
import subprocess


def cases(include_appends=False):
    indices = (-6, -1, 0, 1, 2, 4, 5, 8)
    for mode, initial, start, end, rhs in itertools.product(
        ("zsh", "ksh", "sh"),
        ("()", "('')", "(one '' three four)"),
        indices, indices,
        ("()", "('')", "('two words' $'line\\nbreak')"),
    ):
        yield (f"{mode}/{initial}/{start},{end}/{rhs}",
               f"emulate -R {mode}\ntypeset -a a={initial}\n"
               f"a[{start},{end}]={rhs}\ntypeset -p a\n")

    setups = {
        "plain": "typeset -a a=(one '' three four)",
        "unique": "typeset -aU a=(one '' three four)",
        "tied": "typeset -T joined a; a=(one '' three four)",
        "exported-tie": "typeset -xT joined a; a=(one '' three four)",
        "readonly": "typeset -ar a=(one '' three four)",
        "special": "a=(one '' three four)",
    }
    operations = (
        "a[1]=three", "a[4]=''", "a[2,3]=(three four)",
        "a[1,1]=()", "a[1,2]=(three)", "a[2,2]=(three four)",
        "a[4,5]=(three four)", "a[8]=end", "a[-1]=last",
        "a[(i)three]=one", "a[(r)three]=one", "a[(I)missing]=last",
        "a[0]=zero", "a+=(one '')", "a[1]+=suffix",
        "a[$((++i))]=incremented", "a[1]=$a[3]",
        "a[1,2]=(\"${a[2]}\" \"${a[1]}\")",
        "a[1]=$'\\0\\377é😀'",
    )
    for mode, kind, operation in itertools.product(
        ("zsh", "ksh", "sh"), setups, operations,
    ):
        # argv is a genuine special array with Zsh's special setter.
        setup = setups[kind]
        if kind == "special":
            setup = setup.replace("a=", "argv=")
            operation = operation.replace("a[", "argv[").replace("a+=", "argv+=")
            output = "typeset -p argv"
        else:
            output = "typeset -p a"
        yield (f"{mode}/{kind}/{operation}",
               f"emulate -R {mode}\n{setup}\ni=0\n{operation}\n"
               f"{output}\nprint -r -- \"i=$i joined=${{joined-}}\"\n")

    for option in ("kshzerosubscript", "ksharrays", "rcexpandparam", "allexport"):
        yield (f"option/{option}", f"emulate -R zsh\nsetopt {option}\n"
               "typeset -a a=(one two three)\na[0]=zero\na[1,2]=('' two)\n"
               "a[-1]=last\ntypeset -p a\n")
    yield ("dynamic-scope", "emulate -R zsh\n"
           "a=(global value); f() { local -a a=(local value); g; typeset -p a; }; "
           "g() { a[1]=changed; }; f; typeset -p a\n")
    for size, index in itertools.product((0, 31, 32, 33, 64), (1, 31, 32, 33, 64)):
        yield (f"prefix-boundary/{size}/{index}", "emulate -R zsh\n"
               f"a=( ${{(s::)${{(l:{size}::x:)}}}} )\na[{index}]=y\n"
               "typeset -p a\n")

    if include_appends:
        setups = {
            "unset": "unset a",
            "scalar": "typeset a=seed",
            "empty": "typeset -a a=()",
            "plain": "typeset -a a=(seed '' tail)",
            "unique": "typeset -aU a=(seed '' tail)",
            "lower": "typeset -al a=(SEED TAIL)",
            "readonly": "typeset -ar a=(seed tail)",
            "tied": "typeset -T joined a; a=(seed '' tail)",
            "exported-tie": "typeset -xT joined a; a=(seed '' tail)",
            "special": "argv=(seed '' tail)",
            "association": "typeset -A a=(one first two second)",
        }
        operations = (
            "a+=()", "a+=(x)", "a+=('' 'two words' $'\\0\\377é')", "a+=x",
            'a+=("${a[@]}")', "a[1]+=(x y)", "a[-1]+=(x y)",
            "a[1,-1]+=(x)", "a[2,-1]+=(x)", "a+=([1]=x)",
            "a+=([3]+=tail)", "a+=(x); a=(); a+=('')",
            "a+=(x); a[1,2]=(); a+=(tail)", "a+=(x); unset a; a+=(tail)",
            "a+=(x); typeset -aU a; a+=(x)",
        )
        for mode, kind, operation in itertools.product(("zsh", "ksh", "sh"), setups, operations):
            target = "argv" if kind == "special" else "a"
            if kind == "special":
                operation = (operation.replace("a[", "argv[").replace("a+=", "argv+=")
                             .replace("a=", "argv=").replace("unset a", "unset argv")
                             .replace("-aU a", "-aU argv"))
            yield (f"append/{mode}/{kind}/{operation}",
                   f"emulate -R {mode}\n{setups[kind]}\n{operation}\n"
                   f"typeset -p {target}\nprint -r -- \"joined=${{joined-}}\"\n")
        yield ("append/dynamic-scope", "emulate -R zsh\na=(outer)\n"
               "f() { local -a a=(inner); a+=(tail); typeset -p a; }; f\n"
               "a+=(outertail); typeset -p a\n")


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("baseline", type=Path)
    parser.add_argument("candidate", type=Path)
    parser.add_argument("--output", type=Path, required=True)
    parser.add_argument("--appends", action="store_true",
                        help="also compare append types, slices, flags and mutation sequences")
    args = parser.parse_args()
    shells = [str(p.resolve(strict=True)) for p in (args.baseline, args.candidate)]
    failures = []
    count = 0
    for locale in ("C", "C.UTF-8"):
        env = {"PATH": "/usr/bin:/bin", "LC_ALL": locale, "LANG": locale}
        for label, code in cases(args.appends):
            results = []
            for shell in shells:
                p = subprocess.run([shell, "-dfc", code, "comparison"],
                                   env=env, capture_output=True, timeout=10)
                results.append((p.returncode, p.stdout, p.stderr))
            count += 1
            if results[0] != results[1]:
                failures.append({"locale": locale, "case": label, "code": code,
                                 "results": [[rc, out.hex(), err.hex()]
                                             for rc, out, err in results]})
        print(f"{locale}: {count} cumulative cases, {len(failures)} differences", flush=True)
    args.output.parent.mkdir(parents=True, exist_ok=True)
    args.output.write_text(json.dumps({"shells": shells, "cases": count,
                                       "differences": failures}, indent=2) + "\n")
    raise SystemExit(bool(failures))


if __name__ == "__main__":
    main()
