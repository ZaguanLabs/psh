"""Pinned CommonMark parser oracle plus terminal rendering invariants.

HTML conformance measures MD4C, not ANSI appearance. The separate module tests
assert the terminal presentation contract and Zsh integration.
"""
import ctypes
import json
import locale
from html.parser import HTMLParser
from pathlib import Path
import re

ROOT = Path(__file__).resolve().parents[1]
locale.setlocale(locale.LC_ALL, "")
lib = ctypes.CDLL(str(ROOT / ".build/conformance.so"))
libc = ctypes.CDLL(None)
libc.free.argtypes = [ctypes.c_void_p]
libc.wcwidth.argtypes = [ctypes.c_wchar]
libc.wcwidth.restype = ctypes.c_int
CALLBACK = ctypes.CFUNCTYPE(None, ctypes.c_void_p, ctypes.c_uint, ctypes.c_void_p)
lib.md_html.argtypes = [ctypes.c_char_p, ctypes.c_uint, CALLBACK, ctypes.c_void_p,
                        ctypes.c_uint, ctypes.c_uint]


class Options(ctypes.Structure):
    _fields_ = [("width", ctypes.c_uint), ("color", ctypes.c_int),
                ("gfm", ctypes.c_int), ("links", ctypes.c_int), ("width_policy", ctypes.c_int), ("cluster_styles", ctypes.c_int), ("hard_soft_breaks", ctypes.c_int)]


lib.zmd_render.argtypes = [ctypes.c_char_p, ctypes.c_size_t, ctypes.POINTER(Options),
                           ctypes.POINTER(ctypes.c_void_p), ctypes.POINTER(ctypes.c_size_t),
                           ctypes.POINTER(ctypes.c_char_p)]
examples = json.loads((ROOT / "tests/fixtures/commonmark-0.31.2.json").read_text())
failures = []
renders = 0


class HTMLTokens(HTMLParser):
    """Ignore indentation between HTML elements, but retain code whitespace."""
    def __init__(self):
        super().__init__(convert_charrefs=True)
        self.tokens = []
        self.literal = 0

    def handle_starttag(self, tag, attrs):
        self.tokens.append(("start", tag, tuple(sorted(attrs))))
        if tag in ("pre", "code"):
            self.literal += 1

    def handle_endtag(self, tag):
        self.tokens.append(("end", tag))
        if tag in ("pre", "code"):
            self.literal -= 1

    def handle_data(self, data):
        if not self.literal and data.isspace():
            return
        if not self.literal:
            data = data.strip("\n")
        self.tokens.append(("text", data))

    def handle_comment(self, data):
        self.tokens.append(("comment", data))

    def handle_decl(self, data):
        self.tokens.append(("decl", data))


def normalized(html):
    parser = HTMLTokens()
    parser.feed(html)
    parser.close()
    return parser.tokens


for example in examples:
    text = example["markdown"].encode()
    chunks = []

    @CALLBACK
    def collect(pointer, size, userdata):
        chunks.append(ctypes.string_at(pointer, size))

    rc = lib.md_html(text, len(text), collect, None, 0, 8)
    if rc or normalized(b"".join(chunks).decode()) != normalized(example["html"]):
        failures.append(f'parser example {example["example"]}: {example["section"]}')
    for width in [1, 7, 20, 80]:
        for color in [0, 1]:
            output = ctypes.c_void_p()
            length = ctypes.c_size_t()
            error = ctypes.c_char_p()
            rc = lib.zmd_render(text, len(text), ctypes.byref(Options(width, color, 0, 1)),
                                ctypes.byref(output), ctypes.byref(length), ctypes.byref(error))
            if rc:
                assert error.value == b"width is too small for a complete character", (example["example"], error.value)
                assert not output.value
                continue
            try:
                data = ctypes.string_at(output, length.value)
                plain = re.sub(rb"\x1b\[[0-9;]*m", b"", data) if color else data
                assert not any(byte < 32 and byte != 10 for byte in plain), (example["example"], plain)
                for line in plain.decode("utf-8", "strict").split("\n"):
                    cells = sum(max(0, libc.wcwidth(ch)) for ch in line)
                    assert cells <= width, (example["example"], width, cells, line)
                renders += 1
            finally:
                libc.free(output)
if failures:
    raise SystemExit("\n".join(failures))
print(f"CommonMark 0.31.2: {len(examples)}/{len(examples)} parser examples match; {renders} terminal renders checked")
