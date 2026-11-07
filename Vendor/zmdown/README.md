# zmdown

Render Markdown directly in Zsh scripts with a standalone compiled module.
Load it once, then use the `zmdown` builtin with files, stdin, or strings.

```zsh
zmodload zmdown

zmdown README.md
print -r -- '# Hello **world**' | zmdown
zmdown --text "$message"

# Assign directly, without command substitution or losing trailing newlines.
local rendered
zmdown -v rendered --text "$message"
print -rn -- "$rendered"

# Native lines, semantic spans, widths, and complete code-block contents.
local -A document
zmdown --spans document --width 60 --text "$message"
print -r -- "$document[line,1,text]"
```

**Status: working development version, 0.1.0-dev.** The C module includes its
pinned MD4C parser and its own terminal renderer. Rendering needs no external
commands, shared Markdown library, curses session, or application framework.
The project is independent of other Zsh modules.

## Build and try

Development requirements: Zsh, a C11 compiler, GNU Make, and standard Unix build
tools. Tests also use Python 3 and a UTF-8 locale. Obtain the public Zsh sources
for a reproducible isolated build:

```sh
mkdir -p .build/downloads .build/sources
curl -fL https://www.zsh.org/pub/zsh-5.9.2.tar.xz \
  -o .build/downloads/zsh-5.9.2.tar.xz
printf '%s  %s\n' \
  36fa734374b44783582cec09bcd67822e2f992c779ec1624ab5596df078d2f81 \
  .build/downloads/zsh-5.9.2.tar.xz | sha256sum -c -
tar -xJf .build/downloads/zsh-5.9.2.tar.xz -C .build/sources
make test
```

The checksum comes from the publisher's [SHA256SUM](https://www.zsh.org/pub/SHA256SUM).
Alternatively set `ZSH_BUILD_ROOT` to an extracted release or configured in-tree
Zsh build. The build makes a private copy in `.build/zsh` and stages the module
in `.build/modules`. It does not install or modify the supplied sources.

Start the matching test shell:

```sh
.build/zsh/Src/zsh -df
```

Then, from the project root:

```zsh
module_path=("$PWD/.build/modules" $module_path)
zmodload zmdown
zmdown examples/demo.md
source examples/help.zsh
```

To use the module in an existing installation, build against the sources and
configuration matching that shell's ABI, place the module in a directory on
its `module_path`, and call `zmodload zmdown`. A matching version number alone
does not guarantee ABI compatibility. The default build/tests use their own
matching shell. Linux with private Zsh 5.8 and 5.9.2 builds is tested.
See [matching builds and Zsh 5.8 configuration](docs/building.md) for isolated
build caches, compiler compatibility flags, and build diagnostics.

## API

```text
zmdown [options] [FILE|-]
zmdown [options] --text MARKDOWN
```

With no input argument, read stdin through EOF. One input document is accepted
per call. `--` ends option processing for filenames beginning with a dash.

| Option | Behavior |
| --- | --- |
| `--text MARKDOWN` | Render the quoted string. |
| `-v NAME`, `--variable NAME` | Assign to an ordinary writable scalar without printing. Function-local variables work. |
| `--spans NAME` | Atomically replace a declared writable association with schema 1 lines, spans, widths, and block metadata. No stdout or ANSI. |
| `--features` | Print feature/schema tokens for capability detection. |
| `-w N`, `--width N` | Width in terminal cells, 1–4096. Defaults to stdout's terminal width, or 80. |
| `--width-policy NAME` | `unicode` (default) or `wcwidth-sum` compatibility accounting; both keep graphemes intact. |
| `--cluster-styles MODE` | `preserve` (default) or `first-base` to use one semantic style per grapheme. |
| `--soft-breaks MODE` | `space` (default) or `newline` to preserve paragraph line breaks, useful for chat input. Code, tables and block parsing are unchanged. |
| `-c MODE`, `--color MODE` | `auto`, `always`, or `never`. |
| `--plain` | Disable ANSI styling, keeping the formatted document. |
| `--dialect NAME` | `gfm` (default) or `commonmark`. |
| `--links MODE` | `show` (default) or `hide` destinations. |
| `--help`, `--version` | Print help or version information. |

Auto color enables styling on a terminal, except when `TERM=dumb` or a nonempty
`NO_COLOR` is set. Pipes and variable assignment default to plain output. Use
`--color always` for ANSI output in a variable or an ANSI-capable pager:

```zsh
zmdown --color always README.md | less -R
zmdown --width 60 --color always -v rendered --text "$message"
```

Exit status is **0** for success, **1** for input/render/output failures, and
**2** for invalid arguments or an invalid output variable. Diagnostics go to
stderr. Rendering completes before output or assignment starts; parse/layout
failures leave the destination variable unchanged. A write failure can leave
partial stdout output. Empty input produces an empty string; nonempty rendered
documents end in a newline.

The [structured API reference](docs/structured-output.md) documents all keys,
style bit flags, code metadata, cell measurement, and limits, with examples.
`zmdown --features` advertises `spans=1` and the supported width/style choices.
Applications whose drawing backend sums scalar widths can opt in independently:

```zsh
zmdown --spans document --width 78 \
  --width-policy wcwidth-sum --cluster-styles first-base --text "$message"
```

`wcwidth-sum` sums each scalar's locale `wcwidth` (negative results count as one),
without forcing emoji to two cells. `first-base` applies the first base
character's flags to the whole grapheme, falling back to its first scalar when
no base exists. These are compatibility choices, not a guarantee about every
curses implementation or terminal; the backend must still clip whole graphemes.

Scalar output variables must be simple names (`[A-Za-z_][A-Za-z0-9_]*`). Special,
readonly, array, numeric, tied, case-converting, and justification-formatted
parameters are rejected. The builtin never evaluates Markdown as shell code.

## Markdown support

- CommonMark parsing: ATX/Setext headings, paragraphs, nested lists and quotes,
  thematic breaks, escapes/entities, emphasis/strong emphasis, inline/indented/
  fenced code, links and reference links, image descriptions, hard/soft breaks.
- GFM extensions: pipe tables, alignment, strikethrough, task lists, and
  permissive autolinks. This is the selected extension set, not a claim to
  implement every behavior on GitHub's website.
- Styled word wrapping, hanging list indents, and width-aware tables. Tables
  switch to stacked header/value output when a readable grid cannot fit.
- Code whitespace is preserved, with tabs expanded to four-cell stops and long
  lines wrapped. All code blocks have a language header (or `code` when
  unlabelled) and an ASCII `| ` gutter. Raw HTML is displayed as literal text.
- Terminal controls and invalid UTF-8 are made visible or replaced. ANSI output
  contains only renderer-generated SGR styles. No remote resources are fetched.

## Current limits

The renderer reads the complete document before producing output. There is no
incremental streaming interface, persistent document handle, or pager. These
are ordinary builtin calls with per-call state.

Code blocks have distinct styling but no built-in syntax highlighting.
Structured output exposes their language, identity within a result, and full
sanitized parsed contents before wrapping for an application's highlighter.
Span roles distinguish content from layout decoration, including code headers
and gutters; `--features` advertises `span-roles=1`. Copy complete code from
`block,B,text`, which excludes decoration and visual wrapping. Applications
choose their own colors and attributes from semantic styles and roles.
Links show their destinations as text, without OSC 8 hyperlinks. Images use alt
text and their destination; image protocols, rendered mathematics, Mermaid,
footnotes, and additional Markdown extensions are not implemented.

Use a UTF-8 locale. Wrapping preserves Unicode 17 extended grapheme clusters,
including combining marks, emoji modifiers, flags, and ZWJ sequences. Cluster
width defaults to the maximum locale `wcwidth` of its scalars, with specified emoji
clusters using two cells. A cluster that cannot fit causes atomic rendering
failure. Ambiguous widths and terminal-specific shaping can still differ;
see the [exact measurement policy](docs/structured-output.md#graphemes-and-cell-measurement).
Widths smaller than a structural prefix cause that prefix to be omitted.

Resource limits: 4 MiB input, 32 MiB copied node strings/output buffer, 100,000
nodes, nesting depth 128, 256 table columns, 50,000 cells, and 2,097,152 glyphs
per inline buffer. Structured output additionally caps rows at 100,000, spans
at 200,000, key/value pairs at 500,000, and combined key/value strings at 32 MiB.
These bound native allocations and fail with a diagnostic.

## Verification and internals

`make test` runs 38 actual builtin tests, including PTY behavior and native
structured parameters, three build-diagnostic tests, and the 652-example CommonMark 0.31.2 corpus. Parser conformance compares normalized HTML
through MD4C's test-only HTML renderer; code whitespace stays significant.
The terminal renderer separately runs those inputs at four widths with and
without color, checking cell budgets, UTF-8, and terminal-control handling.
Another 20,864 layouts verify that ordered spans reconstruct plain rows exactly
across all four width/style combinations and both soft-break modes.
All 766 Unicode 17 grapheme-boundary corpus cases pass; tests also check emoji
widths, negative scalar widths, cross-style and combining-only clusters, code
metadata, tab stops, large cluster widths, and atomic failures.
Code layout tests cover unlabelled/language-labelled, backtick/tilde, longer,
empty, and unclosed fences, indented and nested code, narrow widths, and roles
across all four width/style choices. The structured corpus also checks that
role provenance survives style normalization. No syntax-highlighter or
application integration is tested.
The Unicode data hashes and generated table reproducibility are verified.
The base-character and both emoji properties are also checked against the
original vendor ranges at all 1,114,112 Unicode code points.
These checks do not compare screenshots or guarantee identical font shaping
across terminals.

`make sanitize` runs deterministic malformed-input and Unicode table stress
tests with AddressSanitizer and UndefinedBehaviorSanitizer: 4,000 deterministic
inputs and 99 Unicode table widths across all four policy combinations in
both scalar and structured modes, plus large allocations and glyph/node/input
limit boundaries. If the default
compiler lacks sanitizer runtimes, use `make sanitize SANITIZER_CC=clang` with
an available Clang toolchain.

`make bench` measures the standalone core and matching Zsh builtin, writing
sample timings to `.build/bench/results.json`. See the
[profiling report](docs/performance.md) for measured improvements, benchmark
methodology, reproduction commands, and exact baseline comparison coverage.

`src/zmdown.c` implements the shell boundary; `src/render.c` implements a
per-call document tree, text normalization, cell layout, tables, and both ANSI
and structured output. `src/grapheme.c` implements grapheme segmentation using
pinned Unicode data.
The renderer can be tested independently of Zsh. The module does not call back
into shell functions or own an event loop.

See [MD4C provenance](vendor/md4c/README.md),
[Unicode data provenance](vendor/unicode/README.md), and
[CommonMark fixture attribution](tests/fixtures/README.md).
