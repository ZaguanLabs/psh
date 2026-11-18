"""Compare source execution and cross-build wordcode loading against the first shell."""
import argparse
import hashlib
import json
from pathlib import Path
import shutil
import subprocess
import tempfile


def run(shell, command, *args, cwd, locale):
    result = subprocess.run(
        [shell, "-dfc", command, "fixture", *args], cwd=cwd,
        env={"LC_ALL": locale, "PATH": "/usr/bin:/bin", "HOME": str(cwd)},
        capture_output=True, timeout=15, check=True,
    )
    if result.stderr:
        raise RuntimeError(f"{shell}: {result.stderr!r}")
    return result.stdout


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("shells", type=Path, nargs="+")
    shells = [p.resolve(strict=True) for p in parser.parse_args().shells]
    fixture = Path(__file__).with_name("words.zsh").resolve()
    rows = []
    with tempfile.TemporaryDirectory() as temp:
        work = Path(temp)
        for locale in ("C", "C.UTF-8"):
            options = {"cwd": work, "locale": locale}
            expected = run(shells[0], 'source "$1"', fixture, **options)
            if expected.count(b"\0") <= 60 or b"sig\0" not in expected:
                raise ValueError(f"Incomplete reference output for {locale}")
            for reader in shells[1:]:
                if run(reader, 'source "$1"', fixture, **options) != expected:
                    raise ValueError(f"Source execution differs for {reader}, {locale}")
            for producer in shells:
                for mode in ("-R", "-M"):
                    source = work / "words"
                    shutil.copyfile(fixture, source)
                    run(producer, 'zcompile "$1" words', mode, **options)
                    source.unlink()
                    for reader in shells:
                        data = run(reader, "source ./words", **options)
                        if data != expected:
                            raise ValueError(f"Wordcode differs for {producer}, {reader}, {mode}, {locale}")
                        rows.append(dict(locale=locale, mode=mode, producer=str(producer),
                                         reader=str(reader), output_bytes=len(data),
                                         sha256=hashlib.sha256(data).hexdigest()))
                    (work / "words.zwc").unlink()
    print(json.dumps(rows, indent=2))


if __name__ == "__main__":
    main()
