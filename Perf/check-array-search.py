#!/usr/bin/env python3
"""Memcheck the large forward-search boundary corpus on two shell builds."""
import argparse
import hashlib
import importlib.util
import json
from pathlib import Path
import subprocess


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("baseline", type=Path)
    parser.add_argument("candidate", type=Path)
    parser.add_argument("--locale", action="append", dest="locales")
    parser.add_argument("--output", type=Path, required=True)
    args = parser.parse_args()
    source = Path(__file__).with_name("search-compare.py")
    spec = importlib.util.spec_from_file_location("search_compare", source)
    corpus = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(corpus)
    sha = lambda p: hashlib.sha256(p.read_bytes()).hexdigest()
    shells = [p.resolve(strict=True) for p in [args.baseline, args.candidate]]
    fingerprints = {str(p): sha(p) for p in shells + [source]}
    args.output.parent.mkdir(parents=True, exist_ok=True)
    args.output.unlink(missing_ok=True)
    rows = []
    for locale in args.locales or ["C", "C.UTF-8"]:
        for index, (label, script, count, _) in enumerate(corpus.large_cases()):
            values = []
            for host, shell in enumerate(shells):
                log = args.output.with_name(f"{args.output.stem}-{locale}-{index}-{host}.memcheck.log")
                command = ["valgrind", "--error-exitcode=97", "--leak-check=no",
                           "--log-file=" + str(log.resolve()), str(shell), "-dfc", script, "comparison"]
                result = subprocess.run(command, capture_output=True, timeout=300,
                    env={"PATH": "/usr/bin:/bin", "LC_ALL": locale})
                if result.returncode or result.stderr or not result.stdout.endswith(b"matrix-done\n"):
                    raise RuntimeError((label, locale, host, result.returncode, result.stderr[-1000:], str(log)))
                values.append(result.stdout)
            if values[0] != values[1]:
                raise RuntimeError((label, locale, "different output"))
            rows.append(dict(case=label, locale=locale, checks=count, status=0,
                script_sha256=hashlib.sha256(script.encode()).hexdigest(),
                stdout_sha256=hashlib.sha256(values[0]).hexdigest()))
        print(locale, "large search boundaries matched under Memcheck", flush=True)
    if fingerprints != {str(p): sha(p) for p in shells + [source]}:
        raise RuntimeError("test inputs changed")
    args.output.write_text(json.dumps(dict(passed=True, fingerprints=fingerprints,
        checks=sum(row["checks"] for row in rows), runs=rows), indent=2) + "\n")


if __name__ == "__main__":
    main()
