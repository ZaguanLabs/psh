from pathlib import Path
import json
import re
import shlex
import subprocess
import sys

root = Path.cwd()
logs = root / '.work/logs/round37'
sys.path.insert(0, str(root / 'Packaging'))
from elf import allocated_sections, dynamic_exports

def relocations(obj):
    text = subprocess.check_output(['readelf', '-rW', str(obj)], text=True)
    chosen = next(chunk for chunk in text.split('Relocation section ')
                  if chunk.startswith("'.rela.text'"))
    return [' '.join(line.split()[0:1] + line.split()[2:])
            for line in chosen.splitlines() if re.match(r'^[0-9a-f]{8,}\s', line)]

def preprocessed(host, source):
    line = next(line for line in (logs / (host + '-build.log')).read_text().splitlines()
                if ' -c ' in line and line.endswith('/Src/math.c'))
    command = shlex.split(line)
    index = command.index('-o')
    del command[index:index + 2]
    command[command.index('-c')] = '-E'
    command.insert(1, '-P')
    command[-1] = str(source)
    output = subprocess.check_output(command, cwd=root / '.work/round37' / host / 'Src', text=True)
    # Preserve quoted text and distinguish multi-character C operators.
    return re.findall(r'(?:L|u8|u|U)?"(?:\\.|[^"\\])*"|(?:L|u|U)?\x27(?:\\.|[^\x27\\])*\x27|[A-Za-z_][A-Za-z_0-9]*|[0-9]+(?:[A-Za-z_0-9.]*)|>>=|<<=|\.\.\.|->|\+\+|--|<<|>>|<=|>=|==|!=|&&|\|\||\*=|/=|%=|\+=|-=|&=|\^=|\|=|##|\S', output)

records = []
for compiler, old, new in [('gcc', 'previous', 'paired'), ('clang', 'clang-previous', 'clang-paired')]:
    a = root / '.work/round37' / old / 'Src/math.o'
    b = root / '.work/round37' / new / 'Src/math.o'
    same_sections = allocated_sections(a) == allocated_sections(b)
    same_relocations = relocations(a) == relocations(b)
    before = preprocessed(old, root / '.work/round37/previous-source/Src/math.c')
    after = preprocessed(new, root / 'Src/math.c')
    same_tokens = before == after
    assert same_sections and same_relocations and same_tokens, (
        compiler, same_sections, same_relocations, same_tokens)
    exports = dynamic_exports(root / '.work/round37' / old / 'Src/zsh')
    assert exports == dynamic_exports(root / '.work/round37' / new / 'Src/zsh')
    records.append(dict(compiler=compiler, allocated_sections_identical=True,
                        text_relocations_identical=True,
                        preprocessed_translation_unit_tokens_identical=True,
                        tokens=len(before), existing_exports_identical=len(exports)))
(logs / 'code-identity.json').write_text(json.dumps(dict(passed=True, records=records), indent=2) + '\n')
print('GCC and Clang: identical preprocessed tokens, runtime object sections, text relocations and exports.')
