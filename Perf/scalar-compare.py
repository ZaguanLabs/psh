#!/usr/bin/env python3
"""Compare scalar slicing, formatting, and byte preservation against a trusted build."""
import argparse
import hashlib
import itertools
import json
from pathlib import Path
import subprocess


def cases(include_assignments=False):
    indices = (-100, -9, -3, -1, 0, 1, 2, 3, 8, 9, 64, 100)
    payloads = ("''", "'x'", "'abcdefgh'", "'ténébreux😀'",
                "$'a\\0b\\203\\377z'", "'é 👩‍💻'",
                "$'" + "".join(f"\\{b:03o}" for b in range(256)) + "'")
    for mode, multibyte, payload in itertools.product(
        ("zsh", "ksh", "sh"), ("multibyte", "nomultibyte"), payloads,
    ):
        script = f"emulate -R {mode}\nsetopt {multibyte}\ns={payload}\n"
        script += "for i in " + " ".join(map(str, indices)) + "; do\n"
        script += "  for j in " + " ".join(map(str, indices)) + "; do\n"
        script += "    out=\"${s[i,j]}\"\n    printf '%s\\0' \"$out\"\n  done\ndone\n"
        script += "typeset -p s\nprint -r -- matrix-done\n"
        yield (f"{mode}/{multibyte}/{payload}", script, len(indices) ** 2)
    for declaration, value in (
        ("typeset", "'aBcDeFg'"), ("typeset -L12", "' aBcDeFg'"),
        ("typeset -R12", "' aBcDeFg'"), ("typeset -Z12", "'001234'"),
        ("typeset -l", "'ÉaBC'"), ("typeset -u", "'éAbc'"),
        ("typeset -i", "12345678"), ("typeset -F4", "123.4567"),
        ("typeset -E4", "123.4567"), ("typeset -r", "'abcdef'"),
    ):
        for expression in ("${s[1]}", "${s[2,4]}", "${s[-3,-1]}",
                           "${s[9,2]}", "${s[2,99]}", "${s:1:3}",
                           "${(U)s[1,3]}", "${(L)s[1,3]}"):
            yield (f"format/{declaration}/{expression}",
                   f"emulate -R zsh\n{declaration} s={value}\n"
                   f"out=\"{expression}\"\nprintf '%s\\0' \"$out\"\ntypeset -p s\n", 1)
    for expression in ("${s[(i)b]}", "${s[(r)b,(r)d]}", "${s[(w)2]}",
                       "${s[$((++i)),$((i+=2))]}", "${s[-100,-99]}"):
        yield (f"evaluation/{expression}", "emulate -R zsh\ns='abc def ghi'; i=0\n"
               f"out=\"{expression}\"\nprintf '%s\\0' \"$out\"\nprint -r -- $i\n", 1)

    if include_assignments:
        indices = (-9, -1, 0, 1, 2, 4, 8, 100)
        for mode, multibyte, payload in itertools.product(
            ("zsh", "ksh", "sh"), ("multibyte", "nomultibyte"), payloads,
        ):
            script = f"emulate -R {mode}\nsetopt {multibyte}\n"
            script += "for i in " + " ".join(map(str, indices)) + "; do\n"
            script += "  for j in " + " ".join(map(str, indices)) + "; do\n"
            script += "    for replacement in '' x $'\\0é'; do\n"
            # A bad subscript may abort the shell. Isolate each operation and
            # retain its status, rather than silently losing the rest of a matrix.
            script += f"      ( s={payload}; s[i,j]=$replacement; typeset -p s )\n"
            script += "      print -r -- mutation-status=$?\n    done\n  done\ndone\n"
            script += "print -r -- matrix-done\n"
            yield (f"assignment/{mode}/{multibyte}/{payload}", script,
                   len(indices) ** 2 * 3)


def prefix_cases(assignments, wide):
    lengths = (0, 1, 6, 7, 8, 9, 14, 15, 16, 17, 30, 31, 32, 33,
               62, 63, 64, 65, 127, 128, 129, 255)
    tails = ("''", "'é界😀é'", "$'\\0\\203\\377'", "$'\\303'",
             "$'\\xf0\\x9f\\xa6'", "$'" + "".join(f"\\{b:03o}" for b in wide) + "'")
    for mode, mb, tail, ending in itertools.product(("zsh", "ksh", "sh"),
            ("multibyte", "nomultibyte"), tails, ("", "yyyyyyyy")):
        script = f"emulate -R {mode}\nsetopt {mb}\n"
        script += "for n in " + " ".join(map(str, lengths)) + "; do\n"
        script += f"  original=\"${{(l:$n::x:)}}\"{tail}{ending}\n  s=$original\n"
        script += '''  for i in 0 1 7 8 9 15 16 17 "$n" "$((n+1))" "$((n+2))" -1 -8 -9 "$((-n-1))" 1000; do
    for j in "$i" "$((i+1))" -1 "$((n+4))"; do
      out="${s[i,j]}"
      printf '%s\\0' "$out"
    done
  done
'''
        count = len(lengths) * 16 * 4
        if assignments:
            script += '''  for i in 8 "$((n+1))" -8 "$((-n-1))"; do
    for j in "$i" "$((i+1))"; do
      for replacement in '' $'\\0é'; do
        ( s=$original; s[i,j]=$replacement; typeset -p s )
        print -r -- mutation-status=$?
      done
    done
  done
'''
            count += len(lengths) * 4 * 2 * 2
        script += "done\nprint -r -- matrix-done\n"
        yield (f"prefix/{mode}/{mb}/{tail}/ending={ending}", script, count)


def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument("baseline", type=Path)
    p.add_argument("candidate", type=Path)
    p.add_argument("--output", type=Path, required=True)
    p.add_argument("--assignments", action="store_true",
                   help="also compare isolated scalar slice assignments")
    p.add_argument("--prefixes", action="store_true", help="add ASCII block boundary matrices")
    p.add_argument("--locale", action="append", dest="locales")
    args = p.parse_args()
    driver_sha = hashlib.sha256(Path(__file__).read_bytes()).hexdigest()
    shells = [str(s.resolve(strict=True)) for s in (args.baseline, args.candidate)]
    failures = []
    checks = invocations = 0
    for locale in args.locales or ("C", "C.UTF-8"):
        env = {"PATH": "/usr/bin:/bin", "LC_ALL": locale, "LANG": locale}
        wide = b""
        if args.prefixes:
            charmap = subprocess.check_output(["locale", "charmap"], env=env, text=True).strip()
            if charmap != "ANSI_X3.4-1968":
                wide = subprocess.check_output(["iconv", "-f", "UTF-8", "-t", charmap],
                                               input="界".encode())
        scripts = itertools.chain(cases(args.assignments), prefix_cases(args.assignments, wide)) if args.prefixes else cases(args.assignments)
        for label, script, count in scripts:
            results = []
            for shell in shells:
                r = subprocess.run([shell, "-dfc", script, "comparison"],
                                   env=env, capture_output=True, timeout=60)
                results.append((r.returncode, r.stdout, r.stderr))
            invocations += 2
            checks += count
            if (results[0] != results[1] or
                (count > 1 and (results[0][0] != 0 or
                               not results[0][1].endswith(b"matrix-done\n")))):
                failures.append({"locale": locale, "case": label, "script": script,
                                 "results": [[rc, out.hex(), err.hex()]
                                             for rc, out, err in results]})
        print(f"{locale}: {checks} cumulative checks, {len(failures)} differences", flush=True)
    report = {"shells": shells, "checks": checks, "processes": invocations,
              "driver_sha256": driver_sha,
              "differences": failures,
              "source_sha256": hashlib.sha256(Path(__file__).read_bytes()).hexdigest()}
    args.output.parent.mkdir(parents=True, exist_ok=True)
    args.output.write_text(json.dumps(report, indent=2) + "\n")
    raise SystemExit(bool(failures))


if __name__ == "__main__":
    main()
