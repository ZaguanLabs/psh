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
    parser.add_argument("--descriptors", action="store_true",
                        help="include repeated lookups, descriptor exhaustion and recursive lvalue lifetimes")
    parser.add_argument("--descriptors-only", action="store_true",
                        help="run only the focused descriptor cases, including their callbacks")
    parser.add_argument("--state-frames", action="store_true",
                        help="include recursive state, precedence, radix and error-recovery cases")
    parser.add_argument("--state-frames-only", action="store_true",
                        help="run only the focused recursive-state cases")
    parser.add_argument("--memcheck", action="store_true",
                        help="run hosts under Memcheck and reject every reported memory error")
    parser.add_argument("--timeout", type=int, default=300,
                        help="maximum seconds per host and locale (default: 300)")
    args = parser.parse_args()
    if args.timeout < 1:
        parser.error("--timeout must be positive")
    if args.descriptors_only:
        args.descriptors = True
    if args.state_frames_only:
        args.state_frames = True
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
    if args.descriptors:
        if args.descriptors_only:
            expressions = []
        for n in [1, 2, 7, 8, 9, 15, 16, 17, 32, 64, 96, 128]:
            for item in ["x", "i", "a[1]", "h[k]", "a[++i%3+1]", "h[k]+=1"]:
                expressions += ["+".join(["(" + item + ")"] * n)]
            prefix = "+".join(["x"] * n)
            expressions += [prefix + " + psh_pop_recursive(7) + x",
                prefix + " + psh_pop_callback() + x",
                prefix + " + (a[1]+=psh_pop_recursive(3)) + a[1]",
                prefix + " + (h[k]+=psh_pop_retype()) + h[k]",
                "x += (" + prefix + ")", "a[1] += (" + prefix + ")"]
        for n in [1, 2, 7, 8, 9, 16, 32, 64, 96]:
            expressions += ["a[++i%3+1]+=(" * n + "2" + ")" * n,
                "h[k]+=(" * n + "psh_pop_recursive(7)" + ")" * n,
                "1 ? (" + "+".join(["x"] * n) + ") : psh_pop_callback()",
                "0 && (" + "+".join(["x"] * n) + ")",
                "x + psh_pop_recursive(" + str(n) + ") + x"]
        expressions += ["x += (x='x', x)", "x='a[1]', x+x+x+x+x+x+x+x+x",
                        "x='h[k]', x+x+x+x+x+x+x+x+x"]
        expressions = list(dict.fromkeys(expressions))
    if args.state_frames:
        if args.state_frames_only:
            expressions = []
        expressions += [
            "psh_state_prec()", "1<<2 + psh_state_prec()", "psh_state_prec() + 1<<2",
            "psh_state_prec() + psh_state_prec()", "max(psh_state_prec(), 2, 3)",
            "sin(psh_state_prec())", "psh_state_base()", "16#f + psh_state_base() + 2#11",
            "psh_state_radix()", "[##16]psh_state_radix()+1", "[#8_2]psh_state_radix()",
            "psh_state_float()", "x + psh_state_float() + x", "a[++i]+=psh_state_float()",
            "x='psh_state_prec()+1', x+x", "x='16#f', x+psh_state_base()+x",
            "h[k]+=psh_state_prec()", "a[++i]+=psh_state_prec()", "i + (i=5)",
            "psh_state_prec() ? psh_state_float() : psh_state_bad()",
            "0 && psh_state_bad()", "1 || psh_state_bad()", "0 ? psh_state_bad() : 3",
            "1 ? 3 : psh_state_bad()", "psh_state_bad()", "1+psh_state_bad()",
            "psh_state_bad()+1", "psh_state_prec()+1/0", "1/0+psh_state_prec()",
            "max(psh_state_prec(),)", "(psh_state_prec()", "psh_state_prec())",
            "x='x', x", "x='h[k]', h[k]='x', x",
        ]
        for depth in [0, 1, 7, 31, 127, 253, 254, 255, 256, 257]:
            expressions += [f"psh_state_recursive({depth})",
                            f"x + psh_state_recursive({depth}) + x"]
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
    if args.operators or args.descriptors:
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
    if args.state_frames:
        prelude = '''psh_state_prec() {
  setopt localoptions
  if [[ -o cprecedences ]]; then unsetopt cprecedences; else setopt cprecedences; fi
  psh_state_trace+=(prec)
  (( 1<<2 + 1 ))
}
psh_state_base() { psh_state_trace+=(base); (( 8#17 )); }
psh_state_radix() { psh_state_trace+=(radix); (( [##8_2]1234 )); }
psh_state_float() {
  setopt localoptions forcefloat
  psh_state_trace+=(float)
  (( 1.25 + 2 ))
}
psh_state_bad() { psh_state_trace+=(bad); (( 2 + )); }
psh_state_recursive() { (( $1 ? psh_state_recursive($1-1)+1 : 7 )); }
functions -M psh_state_prec 0 0 psh_state_prec
functions -M psh_state_base 0 0 psh_state_base
functions -M psh_state_radix 0 0 psh_state_radix
functions -M psh_state_float 0 0 psh_state_float
functions -M psh_state_bad 0 0 psh_state_bad
functions -M psh_state_recursive 1 1 psh_state_recursive
'''
        script = script.replace("for emulation in zsh ksh sh; do", prelude + "for emulation in zsh ksh sh; do")
        script = script.replace("        unset answer\n", "        unset answer\n"
            "        typeset -a psh_state_trace=()\n")
        script = script.replace("        exit $arithmetic_status\n",
            "        typeset -p psh_state_trace\n"
            "        (( psh_state_recovered = 3 + 4*2 ))\n"
            "        print -r -- \"recovered=$psh_state_recovered status=$?\"\n"
            "        exit $arithmetic_status\n")
    args.output.parent.mkdir(parents=True, exist_ok=True)
    report = {"shells": list(map(str, shells)), "binary_sha256": [sha(p) for p in shells],
              "driver_sha256": sha(Path(__file__)), "script_sha256": hashlib.sha256(script.encode()).hexdigest(),
              "expressions": len(expressions), "syntax": args.syntax, "operators": args.operators,
              "descriptors": args.descriptors,
              "descriptors_only": args.descriptors_only, "timeout_seconds": args.timeout,
              "state_frames": args.state_frames, "state_frames_only": args.state_frames_only,
              "memcheck": args.memcheck,
              "checks_per_locale": len(expressions) * 12, "cases": []}
    for locale in args.locales or ("C", "C.UTF-8", "fr_FR.UTF-8", "nb_NO.UTF-8", "tr_TR.UTF-8"):
        outputs = []
        for index, shell in enumerate(shells):
            prefix = []
            if args.memcheck:
                memory_log = args.output.with_suffix(f".{locale}.{index}.memcheck.log")
                memory_log.unlink(missing_ok=True)
                prefix = ["valgrind", "--quiet", "--error-exitcode=97", "--leak-check=no",
                          "--log-file=" + str(memory_log.resolve())]
            r = subprocess.run(prefix + [str(shell), "-dfc", script, "arithmetic-comparison"],
                env={"PATH": "/usr/bin:/bin", "LC_ALL": locale, "LANG": locale},
                capture_output=True, timeout=args.timeout)
            if args.memcheck and memory_log.read_bytes().strip():
                raise RuntimeError((str(shell), locale, "Memcheck reported errors", str(memory_log)))
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
    if report["driver_sha256"] != sha(Path(__file__)):
        raise RuntimeError("arithmetic driver changed")
    args.output.write_text(json.dumps(report, indent=2) + "\n")


if __name__ == "__main__":
    main()
