#!/usr/bin/env python3
"""Compare real global startup locale and command discovery with system Zsh."""
import argparse
import hashlib
import json
import os
from pathlib import Path
import subprocess
import tempfile

from startup import distribution, snapshot


def sha(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--candidate', type=Path, required=True)
    parser.add_argument('--reference', type=Path, default=Path('/usr/bin/zsh'))
    parser.add_argument('--output', type=Path, required=True)
    args = parser.parse_args()
    args.output.unlink(missing_ok=True)
    shells = dict(reference=args.reference.resolve(strict=True), candidate=args.candidate.resolve(strict=True))
    before = snapshot()
    hashes = {name: sha(path) for name, path in shells.items()}
    rows, mismatches = [], []
    settings = [{}, {'LANG': ''}, {'LANG': 'C'}, {'LANG': 'en_US.UTF-8'},
                {'LANG': 'en_GB.UTF-8'}, {'LC_ALL': 'C'}, {'LC_CTYPE': 'C'},
                {'LANG': 'C', 'LC_ALL': 'en_US.UTF-8'}, {'LANG': 'C', 'LC_SOURCED': '1'}]
    with tempfile.TemporaryDirectory(prefix='psh-startup-') as temporary:
        home = Path(temporary)
        (home / '.zshrc').write_text('# Isolated home; suppress new-user wizard.\n')
        (home / 'bin').mkdir()
        probe = home / 'bin/psh-startup-path-probe'
        probe.write_text('#!/bin/sh\nprintf "PATH_PROBE_OK\\n"\n')
        probe.chmod(0o755)
        code = '''print -r -- LANG=${LANG-unset} LC_ALL=${LC_ALL-unset} LC_CTYPE=${LC_CTYPE-unset}
locale charmap
if (( ${+commands[psh-startup-path-probe]} )); then
    psh-startup-path-probe
else
    print -r -- PATH_PROBE_ABSENT
fi
'''
        for overrides in settings:
            for flags in ['-dfc', '-fc', '-lc', '-ic', '-lic', '-fic', '-flic']:
                observations = {}
                for name, shell in shells.items():
                    env = dict(HOME=temporary, ZDOTDIR=temporary, PATH='/usr/bin:/bin', TERM='xterm-kitty', **overrides)
                    result = subprocess.run([str(shell), flags, code], env=env,
                                            capture_output=True, text=True, timeout=30)
                    observations[name] = dict(status=result.returncode, stdout=result.stdout, stderr=result.stderr)
                # Distribution scripts can emit unrelated alias diagnostics.
                # Retain stderr as evidence; compare the tested environment and status.
                reference, candidate = observations.values()
                matched = (reference['status'] == candidate['status'] == 0
                           and reference['stdout'] == candidate['stdout'])
                rows.append(dict(settings=overrides, flags=flags, matched=matched, observations=observations))
                if not matched:
                    mismatches.append(len(rows) - 1)
    assert before == snapshot(), 'startup inputs changed during verification'
    assert hashes == {name: sha(path) for name, path in shells.items()}, 'shell changed during verification'
    report = dict(passed=not mismatches, distribution=distribution(), startup_snapshot=before,
                  shells={name: str(path) for name, path in shells.items()}, binary_sha256=hashes,
                  driver_sha256=sha(Path(__file__)), policy_sha256=sha(Path(__file__).with_name('startup.py')),
                  runs=rows, mismatches=mismatches, personal_startup_sourced=False)
    args.output.write_text(json.dumps(report, indent=2) + '\n')
    if mismatches:
        raise SystemExit('global startup differs from system Zsh; review Packaging/install.py startup and ' + str(args.output))
    print(f'{len(rows)} global startup locale/PATH comparisons passed')


if __name__ == '__main__':
    main()
