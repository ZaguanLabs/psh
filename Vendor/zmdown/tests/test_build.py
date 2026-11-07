"""Exercise early build diagnostics without compiling a second fake shell."""
import os
from pathlib import Path
import subprocess
import tempfile
import unittest
ROOT = Path(__file__).resolve().parents[1]
class BuildDiagnostics(unittest.TestCase):
    def attempt(self, module_entry, makefile='DL_EXT = so\n', in_tree=True):
        with tempfile.TemporaryDirectory(prefix='build-check-', dir=ROOT/'.build') as directory:
            cache = Path(directory)
            source = cache/'source'
            build = cache/'zsh'
            for tree in (source, build):
                (tree/'Src/Modules').mkdir(parents=True)
                (tree/'configure').touch()
                (tree/'config.status').touch()
                (tree/'Src/zsh.h').touch()
                (tree/'Makefile').write_text('sdir = .\n' if in_tree else 'sdir = /elsewhere\n')
                (tree/'Src/Makefile').write_text(makefile)
                (tree/'config.modules').write_text(module_entry)
            (cache/'source-root').write_text(str(source)+'\n')
            env = dict(os.environ, ZSH_BUILD_ROOT=str(source), ZMDOWN_BUILD_NAME=cache.name, MAKE='true')
            return subprocess.run(['zsh','-df','scripts/build.zsh'], cwd=ROOT, env=env,
                                  capture_output=True, timeout=15)
    def test_disabled_dynamic_module(self):
        p = self.attempt('name=zmdown link=no load=no\n')
        self.assertNotEqual(p.returncode, 0)
        self.assertIn(b'dynamic module is disabled', p.stderr)
        self.assertIn(b'config.log', p.stderr)
        self.assertIn(b'docs/building.md', p.stderr)
    def test_missing_shared_object(self):
        p = self.attempt('name=zmdown link=dynamic load=no\n')
        self.assertNotEqual(p.returncode, 0)
        self.assertIn(b'shared module was not produced', p.stderr)
    def test_nonrelocatable_configuration(self):
        p = self.attempt('name=zmdown link=dynamic load=no\n', in_tree=False)
        self.assertNotEqual(p.returncode, 0)
        self.assertIn(b'in-tree build', p.stderr)
if __name__ == '__main__':
    unittest.main(verbosity=2)
