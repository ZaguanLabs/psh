#!/usr/bin/env python3
"""Regression checks for additive installation and missing-global detection."""
import json
import os
from pathlib import Path
import subprocess
import tempfile
import unittest

import startup

ROOT = Path(__file__).resolve().parent


class StartupTests(unittest.TestCase):
    def test_preserve_custom_files_and_dangling_links(self):
        with tempfile.TemporaryDirectory() as name:
            directory = Path(name)
            custom = directory / 'zprofile'
            custom.write_text('# administrator customizations\n')
            custom.chmod(0o600)
            (directory / 'zshrc').symlink_to(directory / 'absent')
            before = custom.stat()
            startup.apply(startup.plan('almalinux', directory), directory)
            self.assertEqual(custom.read_text(), '# administrator customizations\n')
            self.assertEqual(custom.stat(), before)
            self.assertTrue((directory / 'zshrc').is_symlink())
            self.assertFalse((directory / 'absent').exists())

    def test_fresh_install_and_repeat(self):
        for identity in ['mageia', 'almalinux']:
            with self.subTest(identity=identity), tempfile.TemporaryDirectory() as name:
                directory = Path(name) / 'etc'
                startup.apply(startup.plan(identity, directory), directory)
                for file in directory.iterdir():
                    self.assertEqual(file.stat().st_mode & 0o777, 0o644)
                    subprocess.run(['/usr/bin/zsh', '-dfn', str(file)], check=True)
                before = {file.name: (file.read_bytes(), file.stat()) for file in directory.iterdir()}
                startup.apply(startup.plan(identity, directory), directory)
                self.assertEqual(before, {file.name: (file.read_bytes(), file.stat()) for file in directory.iterdir()})

    def test_file_created_after_preview_is_not_overwritten(self):
        with tempfile.TemporaryDirectory() as name:
            directory = Path(name)
            proposal = startup.plan('mageia', directory)
            (directory / 'zshrc').write_text('# appeared since preview\n')
            with self.assertRaises(FileExistsError):
                startup.apply(proposal, directory)
            self.assertEqual((directory / 'zshrc').read_text(), '# appeared since preview\n')
            self.assertFalse(list(directory.glob('.psh-startup-*')))

    def test_unknown_distribution_has_no_guessed_defaults(self):
        self.assertEqual(startup.defaults('unknown'), {})

    def test_generated_defaults_match_host_startup_phases(self):
        templates = startup.defaults(startup.distribution())
        if not templates:
            self.skipTest('no characterized defaults for this distribution')
        with tempfile.TemporaryDirectory() as name:
            homes = [Path(name) / 'reference', Path(name) / 'generated']
            for home in homes:
                home.mkdir()
                (home / '.zshrc').touch()
                (home / 'bin').mkdir()
                probe = home / 'bin/psh-startup-template-probe'
                probe.write_text('#!/bin/sh\nprintf "FOUND\\n"\n')
                probe.chmod(0o755)
            for file, text in templates.items():
                (homes[1] / ('.' + file)).write_text(text)
            code = 'print -r -- LANG=${LANG-unset} LC_ALL=${LC_ALL-unset} LC_CTYPE=${LC_CTYPE-unset}; locale charmap; if (( ${+commands[psh-startup-template-probe]} )); then psh-startup-template-probe; else print ABSENT; fi'
            for settings in [{}, {'LANG': 'C'}, {'LC_ALL': 'C'}, {'LANG': 'C', 'LC_SOURCED': '1'}]:
                for flags in ['-dfc', '-fc', '-lc', '-ic', '-lic', '-fic', '-flic']:
                    results = []
                    for index, home in enumerate(homes):
                        # Substitute the generated globals with equivalent
                        # startup phases in an isolated home, bypassing host globals.
                        command = ['/usr/bin/zsh'] + (['-d'] if index else []) + [flags, code]
                        env = dict(HOME=str(home), ZDOTDIR=str(home), PATH='/usr/bin:/bin', TERM='xterm-kitty', **settings)
                        result = subprocess.run(command, env=env, capture_output=True, text=True, timeout=20)
                        results.append((result.returncode, result.stdout))
                    self.assertEqual(results[0], results[1], (settings, flags))

    def test_global_startup_regression_is_detected(self):
        if startup.distribution() not in ('mageia', 'almalinux'):
            self.skipTest('requires a characterized distribution startup policy')
        with tempfile.TemporaryDirectory() as name:
            directory = Path(name)
            # Reproduce rc1's missing environment initialization, irrespective
            # of whether this host's psh configuration has already been repaired.
            shell = directory / 'no-globals'
            shell.write_text('#!/bin/sh\nexec /usr/bin/zsh -d "$@"\n')
            shell.chmod(0o755)
            output = directory / 'report.json'
            result = subprocess.run(['python3', str(ROOT / 'check-startup.py'),
                                     '--candidate', str(shell), '--output', str(output)],
                                    capture_output=True, text=True, timeout=120)
            self.assertNotEqual(result.returncode, 0)
            report = json.loads(output.read_text())
            self.assertFalse(report['passed'])
            self.assertTrue(report['mismatches'])
            self.assertTrue(all(row['matched'] for row in report['runs'] if row['flags'] == '-dfc'))


if __name__ == '__main__':
    unittest.main()
