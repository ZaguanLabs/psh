#!/usr/bin/env python3
"""Build the minimal module against matching Zsh headers; record exact results."""
import argparse
import hashlib
import json
import os
from pathlib import Path
import subprocess


def sha(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--source', type=Path, required=True)
    parser.add_argument('--build', type=Path, required=True)
    parser.add_argument('--shell', type=Path, required=True)
    parser.add_argument('--output', type=Path, required=True)
    args = parser.parse_args()
    source, build, shell = (p.resolve(strict=True) for p in
                            (args.source, args.build, args.shell))
    here = Path(__file__).resolve().parent
    folder = args.output.resolve()
    folder.mkdir(parents=True, exist_ok=True)
    module = folder / 'hash_reentry.so'
    compile_command = ['cc', '-O2', '-g', '-shared', '-fPIC', '-DMODULE',
                       '-DHAVE_CONFIG_H', '-I' + str(build / 'Src'),
                       '-I' + str(source / 'Src'),
                       str(here / 'hash_reentry.c'), '-o', str(module)]
    subprocess.run(compile_command, check=True)
    rows = []
    for locale in ('C', 'C.UTF-8'):
        for memcheck in (False, True):
            env = {'PATH': '/usr/bin:/bin', 'LC_ALL': locale}
            command = [str(shell), '-df', str(here / 'reproduce.zsh'), str(folder)]
            if memcheck:
                command = ['valgrind', '--error-exitcode=97', '--leak-check=no',
                           '--track-origins=yes', *command]
            result = subprocess.run(command, env=env, capture_output=True, timeout=60)
            label = locale + ('-memcheck' if memcheck else '-plain')
            (folder / (label + '.stdout.txt')).write_bytes(result.stdout)
            (folder / (label + '.stderr.txt')).write_bytes(result.stderr)
            rows.append(dict(locale=locale, memcheck=memcheck, command=command,
                             status=result.returncode, stdout=result.stdout.decode(),
                             stderr=result.stderr.decode()))
    config = subprocess.check_output([str(build / 'config.status'), '--config'],
                                     text=True).strip()
    report = dict(shell=str(shell), binary_sha256=sha(shell), configure=config,
                  source_params_sha256=sha(source / 'Src/params.c'),
                  build_config_sha256=sha(build / 'config.h'),
                  reproducer_sha256={p.name: sha(p) for p in
                                     (here / 'hash_reentry.c', here / 'reproduce.zsh',
                                      Path(__file__).resolve())},
                  compile_command=compile_command, module_sha256=sha(module),
                  compiler=subprocess.check_output(['cc', '--version'], text=True).splitlines()[0],
                  uname=list(os.uname()), runs=rows)
    (folder / 'evidence.json').write_text(json.dumps(report, indent=2) + '\n')
    for row in rows:
        print(row['locale'], 'memcheck' if row['memcheck'] else 'plain',
              'status=' + str(row['status']))
        print(row['stdout'], end='')


if __name__ == '__main__':
    main()
