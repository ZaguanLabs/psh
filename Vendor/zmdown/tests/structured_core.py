"""Compare structured and plain layouts over the complete CommonMark corpus."""
import ctypes
import json
from itertools import product
import locale
from pathlib import Path
root = Path(__file__).resolve().parents[1]
locale.setlocale(locale.LC_ALL, '')
lib = ctypes.CDLL(str(root / '.build/conformance.so'))
libc = ctypes.CDLL(None)
libc.free.argtypes = [ctypes.c_void_p]
class Options(ctypes.Structure):
    _fields_ = [('width', ctypes.c_uint), ('color', ctypes.c_int),
                ('gfm', ctypes.c_int), ('links', ctypes.c_int), ('width_policy', ctypes.c_int), ('cluster_styles', ctypes.c_int), ('hard_soft_breaks', ctypes.c_int)]
class Document(ctypes.Structure):
    _fields_ = [('pairs', ctypes.POINTER(ctypes.c_char_p)), ('count', ctypes.c_size_t)]
lib.zmd_render_document.argtypes = [ctypes.c_char_p, ctypes.c_size_t, ctypes.POINTER(Options),
                                   ctypes.POINTER(ctypes.POINTER(Document)), ctypes.POINTER(ctypes.c_char_p)]
lib.zmd_document_free.argtypes = [ctypes.POINTER(Document)]
lib.zmd_render.argtypes = [ctypes.c_char_p, ctypes.c_size_t, ctypes.POINTER(Options),
                          ctypes.POINTER(ctypes.c_void_p), ctypes.POINTER(ctypes.c_size_t), ctypes.POINTER(ctypes.c_char_p)]
count = 0
for example in json.loads((root / 'tests/fixtures/commonmark-0.31.2.json').read_text()):
    text = example['markdown'].encode()
    layouts = {}
    for width, policy, styles, breaks in product((1, 7, 20, 80), range(2), range(2), range(2)):
        plain, size, error = ctypes.c_void_p(), ctypes.c_size_t(), ctypes.c_char_p()
        options = Options(width, 0, 0, 1, policy, styles, breaks)
        rc = lib.zmd_render(text, len(text), ctypes.byref(options), ctypes.byref(plain), ctypes.byref(size), ctypes.byref(error))
        doc = ctypes.POINTER(Document)()
        options.color = 1  # Structured output must remain free of ANSI regardless.
        structured_rc = lib.zmd_render_document(text, len(text), ctypes.byref(options), ctypes.byref(doc), ctypes.byref(error))
        try:
            assert structured_rc == rc, (example['example'], width, error.value)
            if rc:
                assert not doc
                continue
            result = doc.contents
            d = {result.pairs[i*2].decode(): result.pairs[i*2+1].decode() for i in range(result.count)}
            assert len(d) == result.count
            assert d['width_policy_name'] == ('wcwidth-sum' if policy else 'unicode')
            assert d['cluster_styles'] == ('first-base' if styles else 'preserve')
            assert d['soft_breaks'] == ('newline' if breaks else 'space')
            rows, roles = [], []
            for i in range(1, int(d['line_count'])+1):
                key = f'line,{i}'
                spans = [f'{key},span,{j}' for j in range(1, int(d[key+',span_count'])+1)]
                row = d[key+',text']
                assert row == ''.join(d[s+',text'] for s in spans)
                assert int(d[key+',cells']) == sum(int(d[s+',cells']) for s in spans)
                assert int(d[key+',cells']) <= width
                assert int(d[key+',block']) <= int(d['block_count'])
                assert all(int(d[s+',style']) & ~127 == 0 for s in spans)
                assert all(d[s+',role'] in ('content', 'decoration') for s in spans)
                if d[key+',role'] == 'code-label':
                    assert all(d[s+',role'] == 'decoration' for s in spans)
                roles.append([d[s+',role'] for s in spans for _ in d[s+',text']])
                assert not any(ord(c)<32 for c in row)
                rows.append(row+'\n')
            rendered = ''.join(rows).encode()
            assert rendered == ctypes.string_at(plain, size.value), (example['example'], width)
            if styles:
                assert rendered == layouts[width, policy, breaks], (example['example'], width, policy, breaks)
                assert roles == layouts[width, policy, breaks, 'roles'], (example['example'], width, policy, breaks)
            else:
                layouts[width, policy, breaks] = rendered
                layouts[width, policy, breaks, 'roles'] = roles
            count += 1
        finally:
            libc.free(plain)
            lib.zmd_document_free(doc)
# Reject invalid C policy values before returning either kind of result.
for policy, styles, breaks in ((2, 0, 0), (0, 2, 0), (-1, 0, 0), (0, -1, 0), (0, 0, 2), (0, 0, -1)):
    options = Options(80, 0, 0, 1, policy, styles, breaks)
    doc, error = ctypes.POINTER(Document)(), ctypes.c_char_p()
    plain, size = ctypes.c_void_p(), ctypes.c_size_t()
    assert lib.zmd_render_document(b'x', 1, ctypes.byref(options), ctypes.byref(doc), ctypes.byref(error))
    assert not doc and error.value
    assert lib.zmd_render(b'x', 1, ctypes.byref(options), ctypes.byref(plain), ctypes.byref(size), ctypes.byref(error))
    assert not plain and error.value
print(f'CommonMark structured output: {count} layouts reconstruct plain output across all width, style and soft break modes')
