from pathlib import Path
import hashlib
import json
import re
import subprocess
import tempfile

root = Path.cwd()
logs = root / '.work/logs/round37'
read = lambda p: json.loads(p.read_text())
sha = lambda p: hashlib.sha256(p.read_bytes()).hexdigest()
parent = read(logs / 'parent.json')['commit']
before = subprocess.check_output(['git', 'show', parent + ':Src/math.c'], text=True)
current = (root / 'Src/math.c').read_text()
fields = re.findall(r'^    APPLY\((\w+), (\w+)\)', current, re.M)
assert fields == [(n, 'x' + n) for n in
                  ['lastbase', 'noeval', 'unary', 'ptr', 'yyval', 'yylval', 'sp', 'stack', 'prec']]
start = current.index('/* The same field list drives recursive saves and restores.')
end = current.index('enum prec_type {', start)
restored = current[:start] + current[end:]
for old_start, stop, macro in [
    ('\txlastbase = lastbase;', '\n    } else {', '\tMATH_EVAL_SAVE_FIELDS(SAVE_MATH_FIELD)'),
    ('\tlastbase = xlastbase;', '\n    }', '\tMATH_EVAL_SAVE_FIELDS(RESTORE_MATH_FIELD)'),
]:
    start = before.index(old_start)
    end = before.index(stop, start)
    restored = restored.replace(macro, before[start:end])
restored = restored.replace('#undef MATH_EVAL_SAVE_FIELDS\n#undef SAVE_MATH_FIELD\n#undef RESTORE_MATH_FIELD\n\n', '')
assert restored == before
changed = subprocess.check_output(['git', 'diff', '--name-only', parent, '--',
                                   'Src', 'Test', 'Vendor', 'Packaging'], text=True).splitlines()
assert changed == ['Src/math.c'], changed
build = read(root / '.work/package/latest.json')
old = read(logs / 'previous-package.json')
assert set(build['core_source_sha256']) == set(old['core_source_sha256'])
assert [n for n, h in build['core_source_sha256'].items()
        if h != old['core_source_sha256'][n]] == ['Src/math.c']
assert all(sha(root / n) == h for n, h in build['core_source_sha256'].items())
assert all(sha(root / n) == h for n, h in read(logs / 'frozen-inputs.json').items())
manifest = read(root / 'Perf/upstream-sha256.json')
assert all(sha(root / '.work/pristine' / n) == h for n, h in manifest.items())
headers = {}
for compiler, old_host, new_host in [('gcc', 'previous', 'paired'),
                                    ('clang', 'clang-previous', 'clang-paired')]:
    old_src = root / '.work/round37' / old_host / 'Src'
    new_src = root / '.work/round37' / new_host / 'Src'
    names = sorted(p.relative_to(old_src) for p in old_src.rglob('*')
                   if p.is_file() and p.suffix in {'.epro', '.mdh'})
    assert all((old_src / n).read_bytes() == (new_src / n).read_bytes() for n in names)
    headers[compiler] = len(names)
tracked = ['Src/math.c', 'Perf/math-compare.py', 'Perf/build.py', 'Perf/README.md']
new = 'Perf/arithmetic-internals.md'
data = subprocess.check_output(['git', 'diff', '--binary', parent, '--', *tracked])
extra = subprocess.run(['git', 'diff', '--no-index', '--', '/dev/null', new], capture_output=True)
assert extra.returncode == 1
data += extra.stdout
patch = root / 'Perf/0037-arithmetic-state-contract.patch'
patch.write_bytes(('Round 37: paired arithmetic state contract\nParent: ' + parent + '\n\n').encode() + data)
with tempfile.TemporaryDirectory() as td:
    target = Path(td)
    for name in tracked:
        path = target / name
        path.parent.mkdir(parents=True, exist_ok=True)
        path.write_bytes(subprocess.check_output(['git', 'show', parent + ':' + name]))
    subprocess.run(['patch', '-p1', '--batch', '--input', str(patch)],
                   cwd=target, capture_output=True, check=True)
    assert all((target / n).read_bytes() == (root / n).read_bytes() for n in tracked + [new])
assert '#define DEBUG 1' in (root / '.work/candidate/config.h').read_text().splitlines()
proof = dict(passed=True, parent=parent, saved_fields=fields,
             original_math_source_reconstructed_exactly=True,
             only_canonical_change='Src/math.c', canonical_inputs_match=len(build['core_source_sha256']),
             pristine_files_verified=len(manifest), unchanged_generated_native_headers=headers,
             patch_replayed=True, patch_sha256=sha(patch),
             fixtures={n: sha(root / n) for n in tracked + [new]},
             development_DEBUG=True, development_sha256=sha(root / 'psh'),
             optimization_count=27)
(logs / 'source-checks.json').write_text(json.dumps(proof, indent=2) + '\n')
print('State list, original source reconstruction, all inputs, SDK headers and five-file patch verified.')
