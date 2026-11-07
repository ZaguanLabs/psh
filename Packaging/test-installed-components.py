#!/usr/bin/env python3
"""Exercise zdraw's installed reusable components without source-tree libraries."""
import argparse
import hashlib
import json
import os
from pathlib import Path
import subprocess
import sys
import tempfile
import unittest

ROOT = Path(__file__).resolve().parent.parent


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--prefix", type=Path, default=Path("/usr/local/psh/current"))
    args = parser.parse_args()
    prefix = args.prefix.resolve()
    shell = prefix / "bin/psh"
    draw = prefix / "share/psh/5.9.2/scripts/zdraw"
    files = json.loads((ROOT / "Vendor/sources.json").read_text())["zdraw"]["files"]
    required = {name: digest for name, digest in files.items()
                if name.startswith("examples/components/")}
    os.environ["ZSH_TEST_SHELL"] = str(shell)
    os.environ.pop("FPATH", None)
    # Reuse the upstream PTY driver and rendering assertions. Only the fixture
    # is taken from the checkout; all code under test loads from the install.
    sys.path.insert(0, str(ROOT / "Vendor/zdraw/tests"))
    from test_drawing import drawing_session

    class InstalledComponents(unittest.TestCase):
        def test_files_and_relative_library_dependencies(self):
            self.assertTrue(required, "no pinned components found")
            for name, digest in required.items():
                with self.subTest(file=name):
                    installed = draw / name
                    self.assertTrue(installed.is_file(), f"not packaged: {installed}")
                    if installed.is_file():
                        self.assertEqual(hashlib.sha256(installed.read_bytes()).hexdigest(), digest)
            script = r'''
setopt errexit
zmodload zsh/parameter
for component in change-gutter linked-detail status-strip; do
  source "$PSH_ZDRAW_ROOT/examples/components/$component.zsh"
done
for name in zdraw-change-gutter zdraw-linked-detail zdraw-status-strip zdraw-ui-theme; do
  (( $+functions[$name] ))
done
print -r -- 'INSTALLED COMPONENTS OK'
'''
            with tempfile.TemporaryDirectory(prefix="psh-components-load-") as cwd:
                result = subprocess.run([str(shell), "-dfc", script], cwd=cwd,
                                        env={"PATH": "/usr/bin:/bin", "LC_ALL": "C.UTF-8",
                                             "PSH_ZDRAW_ROOT": str(draw)},
                                        text=True, capture_output=True, timeout=15)
            self.assertEqual(result.returncode, 0, result.stderr)
            self.assertEqual(result.stdout, "INSTALLED COMPONENTS OK\n")
            self.assertEqual(result.stderr, "")

        def test_installed_change_gutter_rendering(self):
            original = (ROOT / "Vendor/zdraw/tests/ui-change-gutter.zsh").read_text()
            source = 'source "${0:A:h:h}/examples/components/change-gutter.zsh"'
            self.assertEqual(original.count(source), 1, "upstream fixture source path changed")
            fixture = original.replace(source, 'source "$PSH_ZDRAW_ROOT/examples/components/change-gutter.zsh"')
            with tempfile.TemporaryDirectory(prefix="psh-gutter-render-") as directory:
                path = Path(directory) / "installed-change-gutter.zsh"
                path.write_text(fixture)
                drawing_session(self, "wide", modules=prefix / "lib/psh/5.9.2",
                                env={"PSH_ZDRAW_ROOT": str(draw)}, fixture=str(path),
                                marker=b"CHANGE GUTTER PASS")

    result = unittest.TextTestRunner(verbosity=2).run(unittest.defaultTestLoader.loadTestsFromTestCase(InstalledComponents))
    raise SystemExit(0 if result.wasSuccessful() else 1)


if __name__ == "__main__":
    main()
