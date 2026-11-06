#!/usr/bin/env python3
"""Compare conditional matching, substitutions and both forms of match state."""
import argparse
import hashlib
import itertools
import json
from pathlib import Path
import subprocess


def cases(extended=False):
    payloads = ["s=''", "s=a", "s='abc a def a'", "s='éa😀Aé'",
                "s=$'a\\0b\\203\\377a'", "s=$'a\\303\\251b\\303'",
                "unit=$'\\0'; s=${(pl:64::$unit:)}", "s=${(l:64::x:)}$'\\0a'",
                "s=$'" + "".join(f"\\{byte:03o}" for byte in range(256)) + "'"]
    patterns = ("a*", "*a", "?*", "*", "(a|b)*", "(#i)a*", "(#l)a*",
                "(#b)(a)(*)", "(#m)a*", "[[:alpha:]]*", "[^a]*", "(#b)(?)(*)",
                "(#b)(*)a", "*~a*", "a#", "(a*)#", "", "missing", "*é*")
    if extended:
        payloads += ["s=$'a\\244\\242\\244\\244z'", "s=$'a\\2010\\2010z'",
                     "s=$'a\\216\\242\\241\\241z'", "s=$'a\\2010\\201'",
                     "s=a${(l:23::x:)}$'\\244\\242'${(l:31::y:)}",
                     "s=a${(l:7::x:)}$'\\2010\\2010'${(l:15::y:)}",
                     "s=a${(l:15::x:)}$'\\216\\242\\241\\241'${(l:33::y:)}",
                     "s=a${(l:8::x:)}$'\\0'${(l:16::y:)}",
                     "s=a${(l:15::x:)}$'\\303\\251'${(l:17::y:)}",
                     "s=a${(l:31::x:)}$'\\303'"]
        patterns += ("(#a1)a*", "(#a2)a*", "(#a1)(a|b)*", "a*(#a1)b",
                     "a*~ab*", "(a*~ab*)*", "a**", "a***", "a****b*",
                     "(#b)(a)*", "(#b)((a|b)*)*", "(#b)(a*)*", "(#m)(a|b)*",
                     "é*", "😀*", "(#U)a*", "(#u)a*", "a(#U)*", "a(#u)*",
                     "(#U)(#b)(a*)*", "(#u)(#m)a*")
    for mode, mb_option, payload in itertools.product(
        ("zsh", "ksh", "sh"), ("multibyte", "nomultibyte"), payloads,
    ):
        code = f"emulate -R {mode}\nsetopt extendedglob {mb_option}\n{payload}\n"
        code += "match=(before); mbegin=(99); mend=(99); MATCH=before; MBEGIN=99; MEND=99\n"
        for pattern in patterns:
            code += "needle='" + pattern + "'\n"
            code += 'if [[ $s == ${~needle} ]]; then result=0; else result=$?; fi\n'
            code += 'printf \'%s\\0\' "$result"\ntypeset -p match mbegin mend MATCH MBEGIN MEND\n'
            for operator in ("#", "##", "%", "%%", "/", "//"):
                expression = "${s" + operator + "${~needle}" + ("/X" if "/" in operator else "") + "}"
                code += f'out="{expression}"\nprintf \'%s\\0\' "$out"\n'
                code += "typeset -p match mbegin mend MATCH MBEGIN MEND\n"
        code += "typeset -p s\nprint -r -- matrix-done\n"
        yield f"{mode}/{mb_option}/{payload}", code, len(patterns) * 7


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("baseline", type=Path)
    parser.add_argument("candidate", type=Path)
    parser.add_argument("--output", required=True, type=Path)
    parser.add_argument("--extended", action="store_true",
                        help="add approximation, exclusions, star chains and encoding controls")
    parser.add_argument("--locale", action="append", dest="locales",
                        help="locale to check; repeat to override C and C.UTF-8 defaults")
    args = parser.parse_args()
    shells = [str(p.resolve(strict=True)) for p in (args.baseline, args.candidate)]
    failures = []
    checks = 0
    charmaps = {}
    for locale in args.locales or ("C", "C.UTF-8"):
        r = subprocess.run(["locale", "charmap"], env={"PATH": "/usr/bin:/bin", "LC_ALL": locale},
                           capture_output=True, check=True, timeout=30)
        if r.stderr:
            raise RuntimeError(r.stderr.decode(errors="replace"))
        charmaps[locale] = r.stdout.decode().strip()
        for label, code, count in cases(args.extended):
            results = []
            for shell in shells:
                result = subprocess.run([shell, "-dfc", code, "comparison"],
                                        env={"PATH": "/usr/bin:/bin", "LC_ALL": locale},
                                        capture_output=True, timeout=60)
                results.append((result.returncode, result.stdout, result.stderr))
            checks += count
            if (results[0] != results[1] or results[0][0] or
                not results[0][1].endswith(b"matrix-done\n")):
                failures.append({"locale": locale, "case": label, "code": code,
                                 "results": [[rc, out.hex(), err.hex()] for rc, out, err in results]})
        print(f"{locale}: {checks} cumulative checks, {len(failures)} differences", flush=True)
    args.output.parent.mkdir(parents=True, exist_ok=True)
    args.output.write_text(json.dumps({"shells": shells, "checks": checks,
                                       "extended": args.extended, "locale_charmaps": charmaps,
                                       "differences": failures,
                                       "source_sha256": hashlib.sha256(Path(__file__).read_bytes()).hexdigest()},
                                      indent=2) + "\n")
    raise SystemExit(bool(failures))


if __name__ == "__main__":
    main()
