#!/usr/bin/env python3
"""Compare arithmetic values, side effects, statuses and diagnostics with pristine Zsh."""
import argparse
import hashlib
import itertools
import json
import re
from pathlib import Path
import subprocess


def quote(text):
    return "'" + text.replace("'", "'\\''") + "'"


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("baseline", type=Path)
    parser.add_argument("candidate", type=Path)
    parser.add_argument("--locale", action="append", dest="locales")
    parser.add_argument("--output", type=Path, required=True)
    parser.add_argument("--syntax", action="store_true",
                        help="include operator/operand token pairs and diagnostic boundaries")
    parser.add_argument("--operators", action="store_true",
                        help="include valid operators, lazy lvalues, recursive callbacks and stack boundaries")
    args = parser.parse_args()
    shells = [p.resolve(strict=True) for p in (args.baseline, args.candidate)]
    sha = lambda p: hashlib.sha256(Path(p).read_bytes()).hexdigest()
    literals = ["0", "-0", "0.0", "-0.0", ".5", "1.", "1.25", "-1.25", "1e20",
                "1e-4000", "1e4000", "1_2.3_4e+2", "0xff", "077", "16#ff", "2#101",
                "1.7976931348623157e308", "2.2250738585072014e-308",
                "4.9406564584124654e-324", "9007199254740993.0"]
    expressions = list(literals)
    for a, op, b in itertools.product(literals[:14], ["+", "-", "*", "/", "<", "==", "**"], ["2", "1.5"]):
        expressions.append(f"({a}) {op} ({b})")
    expressions += ["1.2.3", "1e", "1e+", "1e-", ".", "..5", "1__2.3__4", "1e_2", "1._0",
                    "1.0x", "1.0 +", "1.0 / 0", "1.0 % 2", "0 && 1.0/0", "1 || 1.0/0",
                    "0 ? 1.0/0 : 2.5", "1 ? 2.5 : 1.0/0", "x=1.25, x+=2.5, x",
                    "a[1]+=1.25", "h[k]=1.25, h[k]*2", "x='1.25', x*2", "sin(1.25)",
                    "sqrt(2.0)", "psh_numeric_change()+1.25", "1.25+psh_numeric_change()+2.5",
                    "psh_numeric_nested(1.25)+2.5", "(++i)+1.25", "1.25 + i++", "(i=2, i++)+1.25"]
    expressions += ["1.25" + chr(c) for c in (1, 9, 10, 13, 32, 127, 128, 131, 160, 255)]
    if args.syntax:
        tokens = ["0", "1", "1.25", "x", "a[1]", "h[k]", "(", ")", "!", "~", "++", "--",
                  "+", "-", "*", "/", "%", "<<", ">>", "&", "|", "^", "&&", "||", "^^",
                  "?", ":", "=", "+=", "**", ","]
        expressions += [a + " " + b for a, b in itertools.product(tokens, repeat=2)]
        for suffix in ["", " ", "\t", "\n", *["2" * n for n in (1, 8, 9, 10, 11, 12, 32)],
                       *["2" + char * n for char in ("é", "界", chr(0x83), chr(0x7f))
                         for n in (1, 4, 8, 10, 11)]]:
            for whitespace in ("", " ", "\t", "\n", " \t\n"):
                expressions += ["1 " + whitespace + suffix,
                                "1 + " + whitespace + "*" + suffix,
                                "1 && (" + whitespace + suffix + ")",
                                "0 && (" + whitespace + suffix + ")"]
        expressions += ["(" * n + "1+2" + ")" * n for n in (1, 2, 8, 32)]
        expressions += ["(" * n + "1 2" + ")" * n for n in (1, 2, 8, 32)]
        expressions = list(dict.fromkeys(expressions))
    if args.operators:
        operators = ["+", "-", "*", "/", "%", "**", "<<", ">>", "&", "^", "|",
                     "&&", "||", "^^", "<", "<=", ">", ">=", "==", "!="]
        for op in operators:
            expressions += [f"({a}) {op} ({b})" for a, b in
                [(1, 2), (0, 3), (-7, 2), (9, -1), (1.25, 2), (3, 1.5), ("-0.0", 4)]]
            expressions += [f"({a}) {op} ({b})" for a, b in itertools.product(
                ["x", "i", "a[1]", "h[k]"], ["x", "i++", "++i", "a[1]", "h[k]",
                "psh_pop_callback()", "psh_pop_recursive(7)", "psh_pop_retype()", "(x=2)"])]
        for op in ["=", "+=", "-=", "*=", "/=", "%=", "**=", "<<=", ">>=",
                   "&=", "^=", "|=", "&&=", "||="]:
            expressions += [f"{a} {op} ({b})" for a, b in itertools.product(
                ["x", "i", "a[1]", "h[k]"],
                ["3", "1.25", "i++", "psh_pop_callback()", "psh_pop_recursive(2)"])]
        expressions += [op + a for op, a in itertools.product(
            ["!", "~", "+", "-", "++", "--"], ["x", "i", "a[1]", "h[k]"])]
        expressions += ["1+(" * n + "1" + ")" * n for n in [0, 1, 8, 98, 99, 100, 101, 128]]
        expressions += ["0 && psh_pop_callback()", "1 || psh_pop_callback()",
            "0 ? psh_pop_callback() : 3", "1 ? 3 : psh_pop_callback()",
            "x + (x=5)", "i + i++", "i++ + i++", "(i=3)+(i=5)",
            "x + psh_pop_callback() + x", "x += psh_pop_callback()",
            "x = psh_pop_retype()", "x + psh_pop_recursive(31) + x",
            "(x=psh_pop_recursive(7)), x", "1/0 + psh_pop_callback()",
            "psh_pop_callback() + 1/0", "(x++) + (a[1]+=h[k])"]
        expressions = list(dict.fromkeys(expressions))
    arrays = "expressions=(" + " ".join(map(quote, expressions)) + ")\n"
    script = '''emulate -R zsh
zmodload zsh/mathfunc || exit 1
psh_numeric_change() { unset LC_ALL; LC_NUMERIC=fr_FR.UTF-8; (( 1 )); }
psh_numeric_nested() { local LC_ALL=nb_NO.UTF-8; (( $1 + 0.125 )); }
functions -M psh_numeric_change 0 0 psh_numeric_change
functions -M psh_numeric_nested 1 1 psh_numeric_nested
''' + arrays + '''
for emulation in zsh ksh sh; do
  for configuration in default forcefloat octalzeroes cprecedences; do
    integer index=0
    for expression in "${expressions[@]}"; do
      (( ++index ))
      (
        emulate -R $emulation
        case $configuration in
          forcefloat) setopt forcefloat ;;
          octalzeroes) setopt octalzeroes ;;
          cprecedences) setopt cprecedences ;;
        esac
        integer i=1
        typeset x=3
        typeset -a a=(2 4 6)
        typeset -A h=(k 2)
        unset answer
        print -r -- "$emulation/$configuration/$index: $expression"
        (( answer = expression ))
        integer arithmetic_status=$?
        print -r -- "status=$arithmetic_status LC_ALL=${LC_ALL-unset} LC_NUMERIC=${LC_NUMERIC-unset}"
        typeset -p answer i x a h 2>/dev/null
        exit $arithmetic_status
      )
      print -r -- "subshell=$?"
    done
  done
done
exit 0
'''
    if args.operators:
        prelude = '''psh_pop_callback() {
  psh_pop_trace+=(callback)
  (( ++psh_pop_calls ))
  unset x
  typeset -gi x=17
  (( 7 ))
}
psh_pop_retype() {
  psh_pop_trace+=(retype)
  (( ++psh_pop_calls ))
  unset x
  typeset -gF x=1.25
  (( 2 ))
}
psh_pop_recursive() { (( $1 ? psh_pop_recursive($1-1)+1 : 3 )); }
functions -M psh_pop_callback 0 0 psh_pop_callback
functions -M psh_pop_retype 0 0 psh_pop_retype
functions -M psh_pop_recursive 1 1 psh_pop_recursive
'''
        script = script.replace("for emulation in zsh ksh sh; do", prelude + "for emulation in zsh ksh sh; do")
        script = script.replace("        unset answer\n", "        unset answer\n"
            "        integer psh_pop_calls=0\n        typeset -a psh_pop_trace=()\n")
        script = script.replace("        exit $arithmetic_status\n",
            "        typeset -p psh_pop_calls psh_pop_trace\n        exit $arithmetic_status\n")
    args.output.parent.mkdir(parents=True, exist_ok=True)
    report = {"shells": list(map(str, shells)), "binary_sha256": [sha(p) for p in shells],
              "driver_sha256": sha(Path(__file__)), "script_sha256": hashlib.sha256(script.encode()).hexdigest(),
              "expressions": len(expressions), "syntax": args.syntax, "operators": args.operators,
              "checks_per_locale": len(expressions) * 12, "cases": []}
    for locale in args.locales or ("C", "C.UTF-8", "fr_FR.UTF-8", "nb_NO.UTF-8", "tr_TR.UTF-8"):
        outputs = []
        for shell in shells:
            r = subprocess.run([str(shell), "-dfc", script, "arithmetic-comparison"],
                env={"PATH": "/usr/bin:/bin", "LC_ALL": locale, "LANG": locale},
                capture_output=True, timeout=300)
            completed = len(re.findall(rb"(?m)^subshell=[0-9]+$", r.stdout))
            if completed != report["checks_per_locale"]:
                raise RuntimeError((str(shell), locale, "incomplete arithmetic corpus",
                                    completed, report["checks_per_locale"]))
            outputs.append((r.returncode, r.stdout, r.stderr))
        if outputs[0] != outputs[1] or outputs[0][0]:
            for i, result in enumerate(outputs):
                args.output.with_suffix(f".{locale}.{i}.stdout").write_bytes(result[1])
                args.output.with_suffix(f".{locale}.{i}.stderr").write_bytes(result[2])
            raise RuntimeError("arithmetic mismatch: " + locale)
        report["cases"].append({"locale": locale, "checks": report["checks_per_locale"],
            "stdout_sha256": hashlib.sha256(outputs[0][1]).hexdigest(),
            "stderr_sha256": hashlib.sha256(outputs[0][2]).hexdigest(), "status": 0})
        print(locale, report["checks_per_locale"], "arithmetic cases matched", flush=True)
    if report["binary_sha256"] != [sha(p) for p in shells]:
        raise RuntimeError("arithmetic binaries changed")
    args.output.write_text(json.dumps(report, indent=2) + "\n")


if __name__ == "__main__":
    main()
