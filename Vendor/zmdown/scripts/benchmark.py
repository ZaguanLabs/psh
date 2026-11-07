"""Repeatable warm renderer and builtin benchmarks; artifacts stay in .build/."""
import argparse
import json
import os
from pathlib import Path
import statistics
import subprocess

ROOT = Path(__file__).resolve().parents[1]
WORK = ROOT / '.build/bench'
CACHE = ROOT / '.build' / os.environ.get('ZMDOWN_BUILD_NAME', '')


def fixtures():
    WORK.mkdir(parents=True, exist_ok=True)
    sources = {
        'tiny': '# Hello **world**\n\nA [link](https://example.org) and `code`.\n',
        'prose': ('The quick brown fox jumps over the lazy dog. A simple paragraph '
                  'with **strong**, *emphasis*, and [a link](https://example.org).\n\n') * 512,
        'unicode': ('# Unicode\n\n界 日本語 café é 👩‍💻 🇳🇴 👍🏽 1️⃣ **bold e**́\n\n') * 512,
        'code': '```zsh\n' + ('\tlocal value="hello world" # preserve whitespace\n') * 2048 + '```\n',
        'table': '| Name | Value | Details |\n|:---|---:|:---:|\n' +
                 '| **item** | 12345 | wrapped words and `code` |\n' * 512,
        'wide-table': '|' + ' column |' * 128 + '\n|' + '---|' * 128 + '\n|' + ('x' * 4096 + '|') * 128 + '\n',
    }
    for name, source in sources.items():
        (WORK / (name + '.md')).write_text(source)
    return sources


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--binary', default=str(WORK / 'render-bench'))
    parser.add_argument('--module-dir', help='Also benchmark the matching private Zsh builtin')
    parser.add_argument('--shell', default=str(CACHE / 'zsh/Src/zsh'))
    parser.add_argument('--samples', type=int, default=7)
    parser.add_argument('--output', default=str(WORK / 'results.json'))
    args = parser.parse_args()
    env = dict(os.environ, LC_ALL='C.UTF-8')
    timer = WORK / 'timer/zsh'
    if args.module_dir:
        timer.mkdir(parents=True, exist_ok=True)
        target = timer / 'datetime.so'
        target.unlink(missing_ok=True)
        target.symlink_to(Path(args.shell).resolve().parent / 'Modules/datetime.so')
    result = {}
    for name, source in fixtures().items():
        iterations = 2000 if name == 'tiny' else 3 if name == 'wide-table' else 10
        cases = [(mode, 80, policy, styles) for mode in range(3)
                 for policy in range(2) for styles in range(2)]
        if name == 'table': cases.append((2, 12, 0, 0))
        if name == 'wide-table': cases = [(0, 4096, 0, 0)]
        for mode, width, policy, styles in cases:
            key = f'{name}/{["plain", "ansi", "spans"][mode]}/{width}/{policy}/{styles}'
            path = str(WORK / (name + '.md'))
            values = subprocess.check_output([args.binary, path, str(mode), str(width), str(policy),
                str(styles), str(iterations), str(args.samples)], env=env, text=True)
            samples = [float(v) for v in values.split()]
            result[key] = {'bytes': len(source.encode()), 'samples_ms': samples,
                           'median_ms': statistics.median(samples)}
            print(f'{key:36} {statistics.median(samples):10.4f} ms', flush=True)
        if args.module_dir and name != 'wide-table':
            for mode in ('scalar', 'spans', 'stdout', 'file'):
                # Constant shell source; Markdown is passed as data from a file.
                script = '''module_path=("$1" "$2" $module_path)
zmodload zmdown || exit
zmodload zsh/datetime || exit
typeset input=$(<"$3") rendered
typeset -A document
integer i sample iterations=$4 samples=$5
typeset -F start
for (( sample=-1; sample<samples; ++sample )); do
  start=$EPOCHREALTIME
  for (( i=0; i<iterations; ++i )); do
    if [[ $6 == scalar ]]; then
      zmdown --width 80 --plain -v rendered --text "$input" || exit
    elif [[ $6 == spans ]]; then
      zmdown --width 80 --spans document --text "$input" || exit
    elif [[ $6 == stdout ]]; then
      zmdown --width 80 --plain --text "$input" > /dev/null || exit
    else
      zmdown --width 80 --plain -v rendered "$3" || exit
    fi
  done
  (( sample >= 0 )) && print -r -- $(( (EPOCHREALTIME-start)*1000/iterations ))
done
'''
                values = subprocess.check_output([args.shell, '-dfc', script, 'benchmark',
                    args.module_dir, str(timer.parent),
                    str(WORK / (name + '.md')), str(iterations), str(args.samples), mode], env=env, text=True)
                samples = [float(v) for v in values.split()]
                key = f'{name}/builtin-{mode}'
                result[key] = {'samples_ms': samples, 'median_ms': statistics.median(samples)}
                print(f'{key:36} {statistics.median(samples):10.4f} ms', flush=True)
    Path(args.output).write_text(json.dumps(result, indent=2) + '\n')


if __name__ == '__main__':
    main()
