#!/usr/bin/env python3
"""Compare reproducible sequences of parameter mutations and scope/error recovery."""
import argparse
import hashlib
import json
import os
from pathlib import Path
import random
import subprocess
import tempfile


def quoted(text):
    return "'" + text.replace("'", "'\\''") + "'"


def program(seed, steps):
    rng = random.Random(seed)
    literals = ["", "plain", "café", "界", "a b", "*[x]?", "a'b", "x:y", "one\ntwo"]
    lines = ["emulate -R zsh", "setopt extendedglob", "typeset -a a=(one two three)",
             "typeset -A h=(first original)", "typeset s='original'", "integer total=0",
             "psh-inner() { local -a a=(inner nested); local s=inner; "
             "print -r -- scope:$1:${(qqq)a}:${(qqq)s}; a[2]=changed; }",
             "psh-outer() { emulate -L zsh; local -a a=(local outer); local s=outer; "
             "local -A h=(scope local); psh-inner $1; "
             "unset a; local -i a=17; (( a+=3 )); print -r -- restored:$a:$s:$h[scope]; }",
             "psh-recover() { local -i n=7; ( eval '(( 1 / 0 ))' ); "
             "local status_code=$?; (( n+=5 )); print -r -- recovery:$status_code:$n; }"]
    for step in range(steps):
        value = quoted(rng.choice(literals))
        index = rng.randint(1, 32)
        key = "key" + str(rng.randint(0, 31))
        action = rng.randrange(13)
        if action == 0:
            lines.append("a=(" + " ".join(quoted(rng.choice(literals)) for _ in range(rng.randrange(9))) + ")")
        elif action == 1:
            lines.append(f"a+=({value})")
        elif action == 2:
            lines.append(f"a[{index}]={value}")
        elif action == 3:
            lines.append(f"a[{index}]=()")
        elif action == 4:
            lines.append(f'h[{key}]={value}')
        elif action == 5:
            lines.append(f'unset "h[{key}]"')
        elif action == 6:
            lines.append(f"s={value}; print -r -- scalar:${{(qqq)s[1,{rng.randint(1, 8)}]}}:${{(qqq)s//a/A}}")
        elif action == 7:
            lines.append(f"psh-outer {step}")
        elif action == 8:
            lines.append(f"typeset -g psh_pad_{rng.randint(0, 255)}={value}; psh-outer {step}")
        elif action == 9:
            lines.append(f"unset psh_pad_{rng.randint(0, 255)}")
        elif action == 10:
            lines.append(f"(( total+=({rng.randrange(100)}*3+{step})%97 ))")
        elif action == 11:
            lines.append(f'print -r -- search:${{a[(i){value}]}}:${{(qqq)a[-1]}}')
        else:
            lines.append("psh-recover")
        # Include every step's complete externally visible array/map/scalar
        # state. Sorted associative keys remove unspecified iteration ordering.
        lines += [f"print -r -- step:{step}:$total:${{(qqq)s}}",
                  "print -rl -- array:${#a} \"${(@qqq)a}\"",
                  "for psh_key in ${(ok)h}; do print -r -- map:${(qqq)psh_key}:${(qqq)h[$psh_key]}; done"]
    lines.append("print -r -- STATEFUL_COMPLETE")
    return "\n".join(lines) + "\n"


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("baseline", type=Path)
    parser.add_argument("candidate", type=Path)
    parser.add_argument("--seed", type=int, action="append")
    parser.add_argument("--steps", type=int, default=1000)
    parser.add_argument("--locale", action="append")
    parser.add_argument("--memcheck", action="store_true")
    parser.add_argument("--output", type=Path, required=True)
    args = parser.parse_args()
    if args.steps < 1:
        parser.error("steps must be positive")
    shells = [s.resolve(strict=True) for s in (args.baseline, args.candidate)]
    fingerprints = [hashlib.sha256(s.read_bytes()).hexdigest() for s in shells]
    args.output.parent.mkdir(parents=True, exist_ok=True)
    cases = args.output.with_suffix(".cases")
    cases.mkdir(exist_ok=False)
    report = {"passed": False, "shells": list(map(str, shells)),
              "shell_sha256": fingerprints, "steps_per_seed": args.steps,
              "driver_sha256": hashlib.sha256(Path(__file__).read_bytes()).hexdigest(),
              "memcheck": args.memcheck, "runs": []}
    with tempfile.TemporaryDirectory(prefix="psh-stateful-") as directory:
        aliases = []
        for index, shell in enumerate(shells):
            folder = Path(directory) / str(index)
            folder.mkdir()
            alias = folder / "zsh"
            alias.symlink_to(shell)
            aliases.append(alias)
        for seed in args.seed or range(8):
            script = cases / f"seed-{seed}.zsh"
            script.write_text(program(seed, args.steps))
            for locale in args.locale or ["C", "C.UTF-8"]:
                observations = []
                for index, shell in enumerate(aliases):
                    log = cases / f"seed-{seed}-{locale}-{index}.memcheck.log"
                    command = [str(shell), "-df", str(script.resolve())]
                    if args.memcheck:
                        command = ["valgrind", "--tool=memcheck", "--quiet", "--error-exitcode=99",
                                   "--leak-check=no", "--log-file=" + str(log.resolve()), *command]
                    result = subprocess.run(command, env={"PATH": "/usr/bin:/bin", "LC_ALL": locale},
                                            capture_output=True, timeout=300)
                    observations.append((result.returncode, result.stdout, result.stderr))
                    if result.returncode or not result.stdout.endswith(b"STATEFUL_COMPLETE\n"):
                        raise RuntimeError((seed, locale, index, result.returncode, result.stderr[-2000:]))
                if observations[0] != observations[1]:
                    for index, (_, stdout, stderr) in enumerate(observations):
                        (cases / f"seed-{seed}-{locale}-{index}.stdout").write_bytes(stdout)
                        (cases / f"seed-{seed}-{locale}-{index}.stderr").write_bytes(stderr)
                    raise RuntimeError(f"seed {seed}, {locale}: state or diagnostics differ; see {cases}")
                report["runs"].append({"seed": seed, "locale": locale,
                                       "script_sha256": hashlib.sha256(script.read_bytes()).hexdigest(),
                                       "stdout_sha256": hashlib.sha256(observations[0][1]).hexdigest(),
                                       "stderr_sha256": hashlib.sha256(observations[0][2]).hexdigest()})
                args.output.write_text(json.dumps(report, indent=2) + "\n")
                print(f"seed={seed} locale={locale}: identical state and diagnostics", flush=True)
    assert [hashlib.sha256(s.read_bytes()).hexdigest() for s in shells] == fingerprints
    assert hashlib.sha256(Path(__file__).read_bytes()).hexdigest() == report["driver_sha256"]
    report["passed"] = True
    args.output.write_text(json.dumps(report, indent=2) + "\n")


if __name__ == "__main__":
    main()
