"""Compare scalar bytes, ordered structured pairs, and failures to a saved core.

Build both shared libraries with the same render.h ABI before running this.
This is intentionally opt-in: the baseline is a separately built reference,
never a checked-in executable or a second copy of the renderer.
"""
import argparse
import ctypes as C
from itertools import product
import json
import locale
from pathlib import Path
import random

ROOT = Path(__file__).resolve().parents[1]


class Options(C.Structure):
    _fields_ = [('width', C.c_uint)] + [(n, C.c_int) for n in
        ('color', 'gfm', 'links', 'width_policy', 'cluster_styles', 'hard_soft_breaks')]


class Document(C.Structure):
    _fields_ = [('pairs', C.POINTER(C.c_char_p)), ('count', C.c_size_t)]


class Renderer:
    def __init__(self, path):
        self.lib = C.CDLL(str(Path(path).resolve()))
        self.lib.zmd_render.argtypes = [C.c_char_p, C.c_size_t, C.POINTER(Options),
            C.POINTER(C.c_void_p), C.POINTER(C.c_size_t), C.POINTER(C.c_char_p)]
        self.lib.zmd_render_document.argtypes = [C.c_char_p, C.c_size_t, C.POINTER(Options),
            C.POINTER(C.POINTER(Document)), C.POINTER(C.c_char_p)]
        self.lib.zmd_document_free.argtypes = [C.POINTER(Document)]
        self.free = C.CDLL(None).free
        self.free.argtypes = [C.c_void_p]

    def render(self, text, options, structured):
        error = C.c_char_p()
        if structured:
            doc = C.POINTER(Document)()
            rc = self.lib.zmd_render_document(text, len(text), C.byref(options), C.byref(doc), C.byref(error))
            try:
                return rc, error.value, tuple(doc.contents.pairs[i] for i in range(doc.contents.count*2)) if doc else None
            finally:
                self.lib.zmd_document_free(doc)
        output, size = C.c_void_p(), C.c_size_t()
        rc = self.lib.zmd_render(text, len(text), C.byref(options), C.byref(output), C.byref(size), C.byref(error))
        try:
            return rc, error.value, C.string_at(output, size.value) if output else None
        finally:
            self.free(output)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('baseline')
    parser.add_argument('candidate', nargs='?', default=str(ROOT / '.build/conformance.so'))
    args = parser.parse_args()
    locale.setlocale(locale.LC_ALL, '')
    baseline, candidate = Renderer(args.baseline), Renderer(args.candidate)
    count = 0

    def check(text, settings):
        nonlocal count
        options = Options(*settings)
        for structured in (False, True):
            expected = baseline.render(text, options, structured)
            actual = candidate.render(text, options, structured)
            assert actual == expected, (text[:200], settings, structured, expected[:2], actual[:2])
            count += 1

    corpus = json.loads((ROOT / 'tests/fixtures/commonmark-0.31.2.json').read_text())
    cases = [example['markdown'].encode() for example in corpus]
    cases += [s.encode() for s in ('**a**́', '\u0600**a**', '*\u0600*abc', '**#**️⃣',
        '|\u0600|é|\n|---|---|\n|界|👩‍💻|\n', '```\n\u0600\tá\t🇳🇴\n```',
        'a\x1b[31m\x00\r\x7f\u009f', '́́ **x**', '**a**\u200d界', '\u0600\u0600a')]
    for text in cases:
        for settings in product((1, 7, 20, 80), range(2), range(2), range(2), range(2), range(2)):
            check(text, settings)
    rng = random.Random(0x5A4D)
    alphabet = list('abc XYZ0123*_*`~\\[]()!<>|:#&;=+-\n\t\r\x1b\x07界́\u0600👩\u200d💻🇳🇴')
    for i in range(2000):
        size = rng.randrange(2048)
        text = (bytes(rng.randrange(256) for _ in range(size)) if i % 3 == 0 else
                ''.join(rng.choice(alphabet) for _ in range(size)).encode())
        check(text, (rng.randrange(1, 100), *(rng.randrange(2) for _ in range(5))))
    # Uneven and equal column sizes exercise the original left-to-right tie rule.
    for _ in range(100):
        columns = rng.randrange(1, 40)
        text = ('|' + ' h |'*columns + '\n|' + '---|'*columns + '\n|' +
                '|'.join('x'*rng.randrange(1, 300) for _ in range(columns)) + '|\n').encode()
        check(text, (rng.randrange(1, 4097), 1, 1, 1, rng.randrange(2), rng.randrange(2)))
    print(f'{count} differential checks match: bytes, ordered pairs, status and errors')


if __name__ == '__main__':
    main()
