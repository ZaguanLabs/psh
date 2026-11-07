"""Run the Unicode 17 extended grapheme boundary corpus against the C core."""
import ctypes
import hashlib
from pathlib import Path
root = Path(__file__).resolve().parents[1]
for entry in (root / 'vendor/unicode/SHA256SUMS').read_text().splitlines():
    digest, name = entry.split()
    assert hashlib.sha256((root / 'vendor/unicode' / name).read_bytes()).hexdigest() == digest, name
lib = ctypes.CDLL(str(root / '.build/conformance.so'))
class State(ctypes.Structure):
    _fields_ = [(name, ctypes.c_uint) for name in
                ('previous', 'have_previous', 'regional', 'indic', 'emoji')]
lib.zmd_grapheme_break.argtypes = [ctypes.POINTER(State), ctypes.c_uint]
lib.zmd_grapheme_break.restype = ctypes.c_int
count = 0
for lineno, line in enumerate((root / 'vendor/unicode/GraphemeBreakTest.txt').read_text().splitlines(), 1):
    tokens = line.split('#')[0].split()
    if not tokens:
        continue
    state = State()
    for i in range(0, len(tokens)-1, 2):
        expected, cp = tokens[i] == '÷', int(tokens[i+1], 16)
        actual = bool(lib.zmd_grapheme_break(ctypes.byref(state), cp))
        assert actual == expected, (lineno, hex(cp), tokens)
    count += 1
print(f'Unicode 17.0.0: {count} extended grapheme boundary cases passed')

# Check every packed-table page/offset against the original vendor ranges,
# independently of the generator's page interning and bit packing.
base = bytearray([1]) * 0x110000
pictographic = bytearray(0x110000)
presentation = bytearray(0x110000)
for filename in ('GraphemeBreakProperty.txt', 'emoji-data.txt'):
    for line in (root / 'vendor/unicode' / filename).read_text().splitlines():
        fields = [s.strip() for s in line.split('#')[0].split(';')]
        if len(fields) < 2:
            continue
        bounds, prop = fields[:2]
        a, b = (int(x, 16) for x in (bounds.split('..')[0], bounds.split('..')[-1]))
        if filename == 'GraphemeBreakProperty.txt' and prop in ('Extend', 'ZWJ', 'SpacingMark', 'Prepend'):
            base[a:b+1] = bytes(b-a+1)
        elif prop == 'Extended_Pictographic':
            pictographic[a:b+1] = bytes([1]) * (b-a+1)
        elif prop == 'Emoji_Presentation':
            presentation[a:b+1] = bytes([1]) * (b-a+1)
for name, expected in (('zmd_grapheme_base', base), ('zmd_extended_pictographic', pictographic),
                       ('zmd_emoji_presentation', presentation)):
    function = getattr(lib, name)
    function.argtypes = [ctypes.c_uint]
    function.restype = ctypes.c_int
    for cp, value in enumerate(expected):
        assert function(cp) == value, (name, hex(cp))
    assert function(0x110000) == (name == 'zmd_grapheme_base')
    assert function(0xffffffff) == (name == 'zmd_grapheme_base')
print('Unicode properties: all 1,114,112 code points match base and both emoji properties')
