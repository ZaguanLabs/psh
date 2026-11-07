"""Exercise the real builtin in isolated shells, including a real PTY."""
import errno
import ctypes
import fcntl
import os
from pathlib import Path
import pty
import re
import select
import struct
import subprocess
import tempfile
import termios
import time
import unittest

ROOT = Path(__file__).resolve().parents[1]
CACHE = ROOT / ".build" / os.environ.get("ZMDOWN_BUILD_NAME", "")
SHELL = os.environ.get("ZSH_TEST_SHELL", str(CACHE / "zsh/Src/zsh"))
MODULES = str(CACHE / "modules")
LOAD = 'module_path=("$1"); shift; zmodload zmdown || exit; '
ENV = dict(os.environ, LC_ALL="C.UTF-8", TERM="xterm-256color")
ENV.pop("NO_COLOR", None)
SGR = re.compile(rb"\x1b\[[0-9;]*m")


def shell(code, *args, data=None, env=None):
    return subprocess.run([SHELL, "-dfc", LOAD + code, "zmdown-test", MODULES, *args],
                          input=data, capture_output=True, env=env or ENV, timeout=15)


def render(text, *options):
    return shell('zmdown "$@"', "--plain", *options, data=text.encode() if isinstance(text, str) else text)


class ModuleTests(unittest.TestCase):
    def good(self, text, *options):
        result = render(text, *options)
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(result.stderr, b"")
        return result.stdout.decode()

    def document(self, text, *options):
        p = shell("typeset -A document; zmdown --spans document \"$@\" || exit; "
                  "printf '%s\\0' \"${(@kv)document}\"", *options, data=text.encode() if isinstance(text, str) else text)
        self.assertEqual(p.returncode, 0, p.stderr)
        self.assertEqual(p.stderr, b"")
        fields = p.stdout.decode().split("\0")
        self.assertEqual(fields.pop(), "")
        self.assertEqual(len(fields) % 2, 0)
        return dict(zip(fields[::2], fields[1::2]))

    def assert_document(self, text, width=80, policy="unicode", cluster_styles="preserve"):
        options = ("--width", str(width), "--width-policy", policy, "--cluster-styles", cluster_styles)
        d = self.document(text, *options, "--color", "always")
        self.assertEqual(d["schema"], "1")
        self.assertEqual(d["width_policy"], "unicode-17.0.0-egc-" +
                         ("wcwidth-sum" if policy == "wcwidth-sum" else "max-wcwidth-emoji2"))
        self.assertEqual(d["width_policy_name"], policy)
        self.assertEqual(d["cluster_styles"], cluster_styles)
        rows = []
        for i in range(1, int(d["line_count"])+1):
            key = f"line,{i}"
            spans = [f"{key},span,{j}" for j in range(1, int(d[key+",span_count"])+1)]
            self.assertEqual("".join(d[s+",text"] for s in spans), d[key+",text"])
            self.assertEqual(sum(int(d[s+",cells"]) for s in spans), int(d[key+",cells"]))
            self.assertLessEqual(int(d[key+",cells"]), width)
            rows.append(d[key+",text"])
        self.assertEqual("".join(row+"\n" for row in rows), self.good(text, *options))
        self.assertFalse(any("\x1b" in value for value in d.values()))
        return d

    def test_wcwidth_sum_graphemes(self):
        libc = ctypes.CDLL(None)
        libc.wcwidth.argtypes = [ctypes.c_wchar]
        libc.wcwidth.restype = ctypes.c_int
        clusters = ("e\u0301", "👩‍💻", "👍🏽", "🇳🇴", "👨‍👩‍👧‍👦", "❤️", "1️⃣", "क्ष")
        self.assertEqual(sum(max(0, libc.wcwidth(cp)) for cp in "👩‍💻"), 4)
        for cluster in clusters:
            expected = sum(w if (w := libc.wcwidth(cp)) >= 0 else 1 for cp in cluster)
            for mode in ("preserve", "first-base"):
                with self.subTest(cluster=cluster, mode=mode):
                    d = self.assert_document(cluster+cluster, expected, "wcwidth-sum", mode)
                    self.assertEqual(d["line_count"], "2")
                    self.assertEqual(d["line,1,text"], cluster)
                    self.assertEqual(d["line,1,cells"], str(expected))
                    if expected > 1:
                        p = render(cluster, "--width-policy", "wcwidth-sum", "--width", str(expected-1),
                                   "--cluster-styles", mode, "--color", "always")
                        self.assertEqual(p.returncode, 1)
                        self.assertEqual(p.stdout, b"")
        self.assertEqual(self.good("👩‍💻", "--width", "2"), "👩‍💻\n")
        self.assertEqual(self.good("1️⃣", "--width", "1", "--width-policy", "wcwidth-sum"), "1️⃣\n")
        # A long single cluster must not overflow a byte-sized width field.
        long_cluster = "👩" + "\u200d👩" * 129
        self.assertEqual(self.assert_document(long_cluster, 260, "wcwidth-sum")["line,1,cells"], "260")
        self.assertEqual(render(long_cluster, "--width", "4", "--width-policy", "wcwidth-sum").returncode, 1)
        # U+0378 is unassigned: negative wcwidth contributes one cell.
        self.assertEqual(libc.wcwidth("\u0378"), -1)
        self.assertEqual(self.assert_document("\u0378", 1, "wcwidth-sum")["line,1,cells"], "1")

    def test_policy_failures_are_atomic(self):
        for options, expected in ((("--width-policy", "unknown"), 2),
                                  (("--cluster-styles", "unknown"), 2),
                                  (("--width-policy", "wcwidth-sum", "--width", "2"), 1)):
            for destination in ("--spans", "--variable"):
                declaration = 'typeset -A output=(keep old)' if destination == '--spans' else 'typeset output=old'
                p = shell(
                          declaration + '; before=${(kv)output}; zmdown "$@" --text 👩‍💻; '
                          'rc=$?; print -r -- $rc; [[ ${(kv)output} == $before ]]',
                          destination, 'output', *options)
                self.assertEqual(p.returncode, 0, p.stderr)
                self.assertEqual(p.stdout, str(expected).encode()+b'\n')
        p = shell('zmdown --features')
        self.assertIn(b'width-policies=unicode,wcwidth-sum', p.stdout.split())
        self.assertIn(b'cluster-styles=preserve,first-base', p.stdout.split())
        self.assertIn(b'span-roles=1', p.stdout.split())
        for option in ('--width-policy', '--cluster-styles'):
            p = render('hi', option)
            self.assertEqual(p.returncode, 2)
            self.assertEqual(p.stdout, b'')

    def test_first_base_styles(self):
        cases = [("***e***\u0301", "e\u0301", 3), ("**e**\u0301", "e\u0301", 1), ("e**\u0301**", "e\u0301", 0),
                 ("`👩`\u200d💻", "👩‍💻", 4), ("\u0600**A**", "\u0600A", 1),
                 ("**\u0301**\u0308", "\u0301\u0308", 1), ("**क**्ष", "क्ष", 1)]
        for policy in ('unicode', 'wcwidth-sum'):
            for markdown, text, style in cases:
                with self.subTest(policy=policy, markdown=markdown):
                    preserve = self.assert_document(markdown, 20, policy)
                    d = self.assert_document(markdown, 20, policy, 'first-base')
                    self.assertEqual(d['line,1,text'], text)
                    self.assertEqual(d['line,1,span_count'], '1')
                    self.assertEqual(d['line,1,span,1,style'], str(style))
                    self.assertGreater(int(preserve['line,1,span_count']), 1)
                    ansi = self.good(markdown, '--width-policy', policy, '--cluster-styles', 'first-base',
                                     '--color', 'always')
                    self.assertIn(text, ansi)  # No SGR transitions inside the cluster.
        preserve = self.assert_document('`👩`\u200d💻', 4, 'wcwidth-sum')
        self.assertEqual(preserve['line,1,span,1,cells'], '2')
        self.assertEqual(preserve['line,1,span,2,cells'], '2')
        # Include generated indentation in the first-base decision.
        d = self.assert_document('- **\u0301**x', 20, 'wcwidth-sum', 'first-base')
        self.assertEqual(d['line,1,text'], '- \u0301x')
        self.assertEqual(d['line,1,span_count'], '2')
        self.assertEqual(d['line,1,span,1,style'], '0')
        self.assertEqual(d['line,1,span,1,role'], 'decoration')
        self.assertEqual(d['line,1,span,2,role'], 'content')

    def test_width_policy_layout_consistency(self):
        samples = ["- 👩‍💻 more\n  - **👍🏽**", "> 👩‍💻 x", "---", "",
                   "| **A** | B |\n|---|---|\n| `👩`\u200d💻 | `👍🏽` |",
                   "| 👩‍💻 |\n|---|\n| 🇳🇴 |", "```zsh\n👩‍💻\tX\n```"]
        libc = ctypes.CDLL(None)
        libc.wcwidth.argtypes = [ctypes.c_wchar]
        for policy in ('unicode', 'wcwidth-sum'):
            for mode in ('preserve', 'first-base'):
                for width in (8, 16, 30):
                    for text in samples:
                        with self.subTest(policy=policy, mode=mode, width=width, text=text):
                            d = self.assert_document(text, width, policy, mode)
                            if policy == 'wcwidth-sum':
                                for key, value in d.items():
                                    if key.startswith('line,') and key.endswith(',text'):
                                        expected = sum(w if (w := libc.wcwidth(cp)) >= 0 else 1 for cp in value)
                                        self.assertEqual(int(d[key[:-4]+'cells']), expected)
        default = self.assert_document('```\n👩‍💻\tX\n```', 20)
        summed = self.assert_document('```\n👩‍💻\tX\n```', 20, 'wcwidth-sum')
        self.assertEqual(default['line,2,text'], '| 👩‍💻  X')
        self.assertEqual(summed['line,2,text'], '| 👩‍💻    X')
        self.assertEqual(default['line,2,cells'], '7')
        self.assertEqual(summed['line,2,cells'], '11')

    def test_structured_semantics_and_reconstruction(self):
        samples = ["# Version **1**\n\nA ***nested*** ~~deletion~~ and [link](https://example.org).",
                   "Literal `**code** $x` and **bold *nested* text**.",
                   "- outer\n  - **inner**\n\n> quoted *text*", "", "---",
                   "| **A** | B |\n| --- | --- |\n| `a b` | 👩‍💻 test |"]
        for text in samples:
            for width in (7, 20, 80):
                with self.subTest(text=text, width=width):
                    self.assert_document(text, width)
        d = self.assert_document("***both*** `**literal**` ~~gone~~ [link](url)")
        semantics = {d[k]: int(d[k[:-4]+"style"]) for k in d if ",span," in k and k.endswith(",text")}
        self.assertEqual(semantics["both"], 3)
        self.assertEqual(semantics["**literal**"], 4)
        self.assertEqual(semantics["gone"], 8)
        self.assertEqual(semantics["link"], 64)

    def test_structured_code_metadata(self):
        text = "```python\nprint('long code')\n\t# comment\n```\n\n    indented\n\n```zsh\nprint ok\n```"
        d = self.assert_document(text, 9)
        code = [i for i in range(1, int(d["block_count"])+1) if d[f"block,{i},kind"] == "code"]
        self.assertEqual(len(code), 3)
        expected = [("python", "1", "print('long code')\n    # comment\n"),
                    ("", "0", "indented\n"), ("zsh", "1", "print ok\n")]
        for i, (language, fenced, content) in zip(code, expected):
            self.assertEqual(d[f"block,{i},language"], language)
            self.assertEqual(d[f"block,{i},fenced"], fenced)
            self.assertEqual(d[f"block,{i},text"], content)
            linked = [j for j in range(1, int(d["line_count"])+1) if d[f"line,{j},block"] == str(i)]
            self.assertTrue(linked)
            self.assertTrue(all(d[f"line,{j},role"] in ("content", "code-label") for j in linked))
        self.assert_document("```zsh\n\x1b]52;c;evil\x07\n```", 20)

    def test_structured_atomic_destinations(self):
        for declaration in ("typeset document=old", "typeset -a document=(old)",
                            "typeset -Ar document=(keep old)",
                            "typeset -Au document=(keep old)"):
            p = shell(declaration + '; before=${(kv)document}; zmdown --spans document --text hello; '
                      'rc=$?; [[ $rc == 2 && ${(kv)document} == $before ]]')
            self.assertEqual(p.returncode, 0, (declaration, p.stderr))
            self.assertEqual(p.stdout, b"")
        for name in ("missing", "bad-name", 'document[$(print BAD)]', "commands"):
            p = shell('typeset -A document=(keep old); zmdown --spans "$1" --text hi; '
                      'rc=$?; [[ $rc == 2 && $document[keep] == old ]]', name)
            self.assertEqual(p.returncode, 0, p.stderr)
            self.assertEqual(p.stdout, b"")
        p = shell('typeset -A document=(keep old); zmdown --spans document --width 1 --text 👩‍💻; '
                  'rc=$?; [[ $rc == 1 && $document[keep] == old && ${#document} == 1 ]]')
        self.assertEqual(p.returncode, 0, p.stderr)
        p = shell('typeset -A document=(keep outer); f() { local -A document=(stale yes); '
                  'zmdown --spans document --text hi || return; '
                  '[[ $document[schema] == 1 && ! -v "document[stale]" ]]; }; '
                  'f && [[ $document[keep] == outer ]]')
        self.assertEqual(p.returncode, 0, p.stderr)
        self.assertEqual(p.stdout, b"")

    def test_structured_limits_preserve_destination(self):
        # 65,000 width-one rows would require over 500,000 association entries.
        p = shell('typeset -A document=(keep old); zmdown --spans document --width 1; '
                  'rc=$?; [[ $rc == 1 && $document[keep] == old && ${#document} == 1 ]]',
                  data=b'a ' * 65000)
        self.assertEqual(p.returncode, 0, p.stderr)
        self.assertIn(b'resource limits', p.stderr)
        self.assertEqual(p.stdout, b'')
        p = shell('typeset -A document=(keep old); zmdown --spans document; '
                  'rc=$?; [[ $rc == 1 && $document[keep] == old && ${#document} == 1 ]]',
                  data=b'a' * (4*1024*1024+1))
        self.assertEqual(p.returncode, 0, p.stderr)
        self.assertIn(b'4 MiB', p.stderr)

    def test_structured_hostile_data_and_feature_query(self):
        d = self.assert_document(b"# $((1+1)) $(print BAD) `literal`\n\n\x1b[2J\x9b\x00\xff", 20)
        self.assertNotIn("BAD\n", d.values())
        p = shell('zmdown --features')
        self.assertEqual(p.returncode, 0, p.stderr)
        self.assertIn(b"spans=1", p.stdout.split())
        self.assertIn(b"code-blocks=1", p.stdout.split())

    def test_extended_grapheme_wrapping(self):
        for cluster in ("e\u0301", "👩‍💻", "👍🏽", "🇳🇴", "👨‍👩‍👧‍👦", "❤️", "1️⃣", "क्ष"):
            with self.subTest(cluster=cluster):
                self.assertEqual(self.good(cluster+cluster, "--width", "2").replace("\n", ""), cluster+cluster)
                if cluster != "e\u0301" and cluster != "क्ष":
                    self.assertEqual(self.good(cluster+cluster, "--width", "2"), cluster+"\n"+cluster+"\n")
                    p = render(cluster, "--width", "1")
                    self.assertEqual(p.returncode, 1)
                    self.assertEqual(p.stdout, b"")
                self.assert_document(cluster+" x", 2)
        # A style boundary may fall inside one cluster: preserve its semantics
        # without introducing a line break; the continuation contributes 0 cells.
        d = self.assert_document("**e**\u0301 x", 1)
        self.assertEqual(d["line,1,text"], "e\u0301")
        self.assertEqual(d["line,1,span,1,cells"], "1")
        self.assertEqual(d["line,1,span,2,cells"], "0")
        self.assert_document("`👩‍💻\tX`", 8)
        # Prepend+space is one cluster; trimming a trailing space must not split it.
        self.assertEqual(self.good("\u0600 x", "--width", "1"), "\u0600 \nx\n")
        self.assert_document("| X |\n|---|\n| \u0600 |", 8)

    def test_load_unload_and_features(self):
        p = shell('zmdown --version; zmodload -u zmdown || exit; '
                  '(( $+builtins[zmdown] == 0 )) || exit 9; '
                  'zmodload -F zmdown b:zmdown || exit; zmdown --text "**again**"')
        self.assertEqual(p.returncode, 0, p.stderr)
        self.assertIn(b"0.1.0-dev", p.stdout)
        self.assertTrue(p.stdout.endswith(b"again\n"))

    def test_headings_paragraphs_and_inline(self):
        self.assertEqual(self.good("# Hello\n\nA **bold** and *emphasized*\nparagraph."),
                         "Hello\n\nA bold and emphasized paragraph.\n")
        self.assertEqual(self.good("Setext\n======\n\n***nested*** and file_name_part"),
                         "Setext\n\nnested and file_name_part\n")

    def test_lists_nested_ordered_and_tasks(self):
        self.assertEqual(self.good("- one\n  - nested\n- two"), "- one\n  - nested\n- two\n")
        self.assertEqual(self.good("3. three\n4. four"), "3. three\n4. four\n")
        self.assertEqual(self.good("- [x] done\n- [ ] pending"), "- [x] done\n- [ ] pending\n")
        self.assertEqual(self.good("- one\n\n- two"), "- one\n\n- two\n")

    def test_list_continuation(self):
        self.assertEqual(self.good("- one two three four five", "--width", "12"),
                         "- one two\n  three four\n  five\n")
        self.assertIn("- > quote", self.good("- > quote"))
        self.assertIn("> - item", self.good("> - item"))

    def test_quotes_and_rules(self):
        self.assertEqual(self.good("> first\n>\n> second"), "> first\n\n> second\n")
        self.assertEqual(self.good("---", "--width", "12"), "------------\n")

    def test_code_preserves_whitespace(self):
        self.assertEqual(self.good('```zsh\nprint "**literal**"\n  indented\n```'),
                         'zsh\n| print "**literal**"\n|   indented\n')
        self.assertEqual(self.good("    a\n    b"), "code\n| a\n| b\n")
        self.assertEqual(self.good("`` `literal` ``"), "`literal`\n")
        self.assertEqual(self.good("```\na\tb\n```"), "code\n| a   b\n")

    def test_code_block_layout_and_roles(self):
        cases = [
            ("```\nabc  \n\n```", "", "1", "abc  \n\n", ["code", "| abc  ", "| "]),
            ("~~~py&amp;\nabc\n~~~", "py&", "1", "abc\n", ["py&", "| abc"]),
            ("````zsh\n```\n````", "zsh", "1", "```\n", ["zsh", "| ```"]),
            ("```\nabc", "", "1", "abc\n", ["code", "| abc"]),
            ("```\n```", "", "1", "", ["code"]),
            ("    abc", "", "0", "abc\n", ["code", "| abc"]),
            ("> - ```\n>   abc\n>   ```", "", "1", "abc\n", ["> - code", ">   | abc"]),
        ]
        for markdown, language, fenced, code, expected in cases:
            for policy in ('unicode', 'wcwidth-sum'):
                for mode in ('preserve', 'first-base'):
                    with self.subTest(markdown=markdown, policy=policy, mode=mode):
                        d = self.assert_document(markdown, 20, policy, mode)
                        self.assertEqual([d[f'line,{i},text'] for i in range(1, int(d['line_count'])+1)], expected)
                        block = next(i for i in range(1, int(d['block_count'])+1) if d[f'block,{i},kind'] == 'code')
                        self.assertEqual(d[f'block,{block},language'], language)
                        self.assertEqual(d[f'block,{block},fenced'], fenced)
                        self.assertEqual(d[f'block,{block},text'], code)
                        for i in range(1, int(d['line_count'])+1):
                            key = f'line,{i}'
                            self.assertEqual(d[key+',block'], str(block))
                            spans = [f'{key},span,{j}' for j in range(1, int(d[key+',span_count'])+1)]
                            content = ''.join(d[s+',text'] for s in spans if d[s+',role'] == 'content')
                            if d[key+',role'] == 'code-label':
                                self.assertEqual(content, '')
                            else:
                                self.assertEqual(content, expected[i-1].split('| ', 1)[1])

    def test_code_wrapping_and_narrow_widths(self):
        for width, expected in [(1, 'c\no\nd\ne\na\nb\nc\n'),
                                (2, 'co\nde\nab\nc\n'),
                                (3, 'cod\ne\n| a\n| b\n| c\n'),
                                (4, 'code\n| ab\n| c\n')]:
            with self.subTest(width=width):
                d = self.assert_document('```\nabc\n```', width)
                self.assertEqual(self.good('```\nabc\n```', '--width', str(width)), expected)
                self.assertEqual(d['block,2,text'], 'abc\n')
        # A leading combining mark may share a grapheme with the gutter's
        # space; style normalization must never turn content into decoration.
        for mode in ('preserve', 'first-base'):
            d = self.assert_document('```\n\u0301👩‍💻\tX\n```', 10, 'unicode', mode)
            spans = [f'line,2,span,{j}' for j in range(1, int(d['line,2,span_count'])+1)]
            content = ''.join(d[s+',text'] for s in spans if d[s+',role'] == 'content')
            self.assertEqual(content, '\u0301👩‍💻  X')
        self.assertEqual(self.good('A `x` and `` `y` ``.'), 'A x and `y`.\n')

    def test_links_images_and_forward_references(self):
        self.assertEqual(self.good("A [reference][id].\n\n[id]: https://example.org"),
                         "A reference (https://example.org).\n")
        self.assertEqual(self.good("<https://example.org>"), "https://example.org\n")
        self.assertEqual(self.good("![A cat](cat.png)"), "[Image: A cat] (cat.png)\n")
        self.assertEqual(self.good("[label](target)", "--links", "hide"), "label\n")

    def test_entities_and_escapes(self):
        self.assertEqual(self.good(r"\*literal\* &amp; &#x754C; &NotEqualTilde;"), "*literal* & 界 ≂̸\n")
        self.assertEqual(self.good("[x](a?b=1&amp;c=2)"), "x (a?b=1&c=2)\n")
        self.assertEqual(self.good("&#0;"), "�\n")

    def test_breaks(self):
        self.assertEqual(self.good("one\ntwo\n\nthree  \nfour"), "one two\n\nthree\nfour\n")

    def test_preserve_soft_breaks(self):
        text = "**one\ntwo**\n\n```text\nleft  \nright\n```"
        for dialect in ("commonmark", "gfm"):
            for width in (12, 80):
                options = ("--soft-breaks", "newline", "--dialect", dialect, "--width", str(width))
                self.assertTrue(self.good(text, *options).startswith("one\ntwo\n"))
                d = self.document(text, *options)
                self.assertEqual(d["soft_breaks"], "newline")
                self.assertEqual(d["line,1,text"], "one")
                self.assertEqual(d["line,2,text"], "two")
                for row in (1, 2):
                    self.assertTrue(int(d[f"line,{row},span,1,style"]) & int(d["style,strong"]))
                code = [d[f"block,{b},text"] for b in range(1, int(d["block_count"])+1)
                        if d[f"block,{b},kind"] == "code"]
                self.assertEqual(code, ["left  \nright\n"])
        table = "| A | B |\n| --- | --- |\n| x | y |"
        self.assertEqual(self.good(table), self.good(table, "--soft-breaks", "newline"))
        self.assertEqual(self.good("one\ntwo", "--soft-breaks", "space"), "one two\n")

    def test_table_layout_alignment_and_styles(self):
        text = "| Name | Value |\n| :--- | ---: |\n| **one** | 22 |\n| two | 300 |"
        self.assertEqual(self.good(text),
                         "+------+-------+\n| Name | Value |\n+------+-------+\n"
                         "| one  |    22 |\n| two  |   300 |\n+------+-------+\n")
        p = render(text, "--color", "always")
        self.assertIn(b"\x1b[0;1mone", p.stdout)
        self.assertEqual(SGR.sub(b"", p.stdout).decode(), self.good(text))

    def test_table_wrap_and_narrow_fallback(self):
        text = "| Key | Description |\n| --- | --- |\n| a | longer description of a |"
        for width in [1, 5, 10, 15, 20, 35]:
            out = self.good(text, "--width", str(width))
            self.assertTrue(all(len(line) <= width for line in out.splitlines()), out)
            compact = "".join(out.split()).replace("|", "").replace("+", "").replace("-", "")
            self.assertIn("longerdescriptionofa", compact)
        self.assertIn("Key: a", self.good(text, "--width", "10"))

    def test_dialect_switch(self):
        self.assertEqual(self.good("~~gone~~"), "gone\n")
        self.assertEqual(self.good("~~gone~~", "--dialect", "commonmark"), "~~gone~~\n")

    def test_unicode_width_and_combining_marks(self):
        self.assertEqual(self.good("**界界界**", "--width", "4"), "界界\n界\n")
        self.assertEqual(self.good("**ééé**", "--width", "2"), "éé\né\n")
        p = render("界", "--width", "1")
        self.assertEqual(p.returncode, 1)
        self.assertEqual(p.stdout, b"")
        self.assertIn(b"complete character", p.stderr)

    def test_terminal_controls_and_invalid_utf8(self):
        p = render(b"safe\x1b]52;c;payload\x07\x08\x00\xff")
        self.assertEqual(p.returncode, 0, p.stderr)
        self.assertNotIn(b"\x1b", p.stdout)
        self.assertNotIn(b"\x07", p.stdout)
        self.assertIn(b"\\u001B", p.stdout)
        p.stdout.decode("utf-8", "strict")
        self.assertEqual(self.good("&#x1b;[31m"), "\\u001B[31m\n")
        self.assertIn("\\u009B", self.good("\u009b31m"))

    def test_raw_html_is_literal(self):
        self.assertIn("<b>x</b>", self.good("<b>x</b>"))
        self.assertIn("<script>", self.good("<script>not executed</script>"))

    def test_empty_incomplete_and_literal_shell_syntax(self):
        self.assertEqual(self.good(""), "")
        self.assertEqual(self.good("A **partial"), "A **partial\n")
        text = "$(print injected) ${HOME} `**literal**`"
        self.assertEqual(self.good(text), "$(print injected) ${HOME} **literal**\n")
        p = shell('zmdown --plain --text "$1"', "- **text**")
        self.assertEqual(p.stdout, b"- text\n")

    def test_scalar_assignment_preserves_newline_and_local_scope(self):
        p = shell('result=outer; f() { local result; '
                  'zmdown -v result --text "$1" || return; '
                  '[[ $result == $\'Hello\\n\' ]] || return 8; print -rn -- "$result"; }; '
                  'f "# Hello" || exit; [[ $result == outer ]]')
        self.assertEqual(p.returncode, 0, p.stderr)
        self.assertEqual(p.stdout, b"Hello\n")
        p = shell('local result; zmdown --color always -v result --text "**Hi**"; print -rn -- "$result"')
        self.assertIn(b"\x1b[0;1mHi", p.stdout)

    def test_scalar_assignment_binary_shell_encoding(self):
        p = shell('zmdown --plain -v result --text "$1"; print -rn -- "$result"', "**界 é**")
        self.assertEqual(p.returncode, 0, p.stderr)
        self.assertEqual(p.stdout, "界 é\n".encode())
        p = shell("zmdown --plain --text $'a\\0b'")
        self.assertEqual(p.stdout, "a�b\n".encode())

    def test_invalid_targets_and_failure_preserve_variable(self):
        for declaration in ["typeset -r result=before", "typeset -a result=(before)",
                            "typeset -i result=42", "typeset -U result=before",
                            "typeset -u result=before"]:
            # -U has no effect on an ordinary scalar; test that separately.
            if "-U" in declaration:
                continue
            p = shell(declaration + '; zmdown -v result --text hi; print -r -- "$?"')
            self.assertEqual(p.stdout, b"2\n", (declaration, p.stderr))
        for name in ["PATH", "reply[1]", "x[$(touch should-not-exist)]", "1bad"]:
            p = shell('zmdown -v "$1" --text hi', name)
            self.assertEqual(p.returncode, 2, p.stderr)
        p = shell('result=before; zmdown -v result --width 1 --text 界 2>/dev/null; '
                  '[[ $? == 1 && $result == before ]]')
        self.assertEqual(p.returncode, 0, p.stderr)

    def test_files_and_stdin(self):
        with tempfile.TemporaryDirectory() as temp:
            path = Path(temp) / "- a 'file' 界.md"
            path.write_text("# File", encoding="utf-8")
            p = shell('zmdown --plain -- "$1"', str(path))
            self.assertEqual(p.stdout, b"File\n")
        p = shell('zmdown --plain -', data=b"# stdin")
        self.assertEqual(p.stdout, b"stdin\n")
        p = shell('zmdown "$1"', str(Path(temp) / "missing"))
        self.assertEqual(p.returncode, 1)

    def test_invalid_options(self):
        for args in [("--width", "0"), ("--width", "4097"), ("--width", "1+2"),
                     ("--width", "999999999999999999"), ("--color", "bad"),
                     ("--dialect", "bad"), ("--text", "a", "file"), ("--width",),
                     ("--unknown",), ("--text", "a", "--text", "b"),
                     ("--soft-breaks", "bad"), ("--soft-breaks",)]:
            p = shell('zmdown "$@"', *args)
            self.assertEqual(p.returncode, 2, (args, p.stderr))
            self.assertEqual(p.stdout, b"")

    def test_resource_limits(self):
        p = render(b"x" * (4 * 1024 * 1024 + 1))
        self.assertEqual(p.returncode, 1)
        self.assertIn(b"4 MiB", p.stderr)
        p = render("> " * 140 + "deep")
        self.assertEqual(p.returncode, 1)
        self.assertEqual(p.stdout, b"")

    def test_color_policy(self):
        self.assertNotIn(b"\x1b", render("**bold**").stdout)
        self.assertIn(b"\x1b", render("**bold**", "--color", "always").stdout)
        env = dict(ENV, NO_COLOR="1")
        p = shell('zmdown --color always --text "**bold**"', env=env)
        self.assertIn(b"\x1b", p.stdout)

    def test_shell_options_are_unchanged(self):
        p = shell('setopt shwordsplit ksharrays globsubst; '
                  'zmdown --plain --text "**one two**" || exit; '
                  '[[ -o shwordsplit && -o ksharrays && -o globsubst ]]')
        self.assertEqual(p.returncode, 0, p.stderr)
        self.assertEqual(p.stdout, b"one two\n")

    def test_pty_color_detection_width_and_no_color(self):
        for no_color in [False, True]:
            master, slave = pty.openpty()
            fcntl.ioctl(slave, termios.TIOCSWINSZ, struct.pack("HHHH", 24, 16, 0, 0))
            env = dict(ENV)
            if no_color:
                env["NO_COLOR"] = "1"
            p = subprocess.Popen([SHELL, "-dfc", LOAD + 'zmdown --text "**one two three four five**"',
                                  "zmdown-pty", MODULES], stdin=slave, stdout=slave, stderr=slave, env=env)
            os.close(slave)
            chunks = []
            deadline = time.monotonic() + 10
            try:
                while time.monotonic() < deadline:
                    ready, _, _ = select.select([master], [], [], 0.2)
                    if not ready:
                        if p.poll() is not None:
                            break
                        continue
                    try:
                        data = os.read(master, 65536)
                    except OSError as exc:
                        if exc.errno == errno.EIO:
                            break
                        raise
                    if not data:
                        break
                    chunks.append(data)
                p.wait(timeout=2)
            finally:
                if p.poll() is None:
                    p.kill()
                    p.wait()
                os.close(master)
            output = b"".join(chunks)
            self.assertEqual(p.returncode, 0, output)
            self.assertEqual(b"\x1b" in output, not no_color)
            plain = SGR.sub(b"", output).replace(b"\r\n", b"\n")
            self.assertEqual(plain, b"one two three\nfour five\n")


if __name__ == "__main__":
    unittest.main(verbosity=2)
