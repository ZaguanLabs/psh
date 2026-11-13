#!/usr/bin/env python3
"""Data-only activation evidence tests; never call the privileged installer."""
import argparse
import hashlib
import json
from pathlib import Path
import sys
import tempfile

ROOT = Path(__file__).resolve().parents[3]
sys.path.insert(0, str(ROOT / "Packaging"))
from install import validated_native_loaders


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--build", type=Path, required=True)
    parser.add_argument("--output", type=Path, required=True)
    args = parser.parse_args()
    args.output.unlink(missing_ok=True)
    build = json.loads(args.build.read_text())
    shell = Path(build["prefix"]) / "bin/psh"
    receipt = json.loads((Path(build["work"]) / "native-loaders.json").read_text())
    scenarios = [("missing", None), ("valid", receipt),
        ("failed", dict(receipt, passed=False)),
        ("wrong-binary", dict(receipt, binary_sha256={"candidate": "wrong"})),
        ("wrong-shell", dict(receipt, shells={"candidate": "wrong"})),
        ("stale-runner", dict(receipt, driver_sha256="wrong")),
        ("stale-library", dict(receipt, library_source_sha256="wrong"))]
    rows = []
    with tempfile.TemporaryDirectory(prefix="psh-native-evidence-") as temp:
        folder = Path(temp)
        for label, value in scenarios:
            path = folder / "native-loaders.json"
            path.unlink(missing_ok=True)
            if value is not None:
                path.write_text(json.dumps(value))
            try:
                validated_native_loaders(folder, shell)
                accepted = True
            except RuntimeError:
                accepted = False
            assert accepted == (label == "valid"), label
            rows.append(dict(case=label, accepted=accepted))
    sha = lambda p: hashlib.sha256(p.read_bytes()).hexdigest()
    args.output.write_text(json.dumps(dict(passed=True, privileged_actions_run=False,
        shell=str(shell), shell_sha256=sha(shell), driver_sha256=sha(Path(__file__)),
        installer_sha256=sha(ROOT / "Packaging/install.py"), cases=rows), indent=2) + "\n")


if __name__ == "__main__":
    main()
