# Profiling and optimization, 2026-09-12

The optimized renderer preserves the public API, exact output bytes (including
SGR sequences), structured pair order, width/style policies, and resource limits.
All 82 measured cases improved against commit
`8bb1390f2636e7f7fc46032d222e981b1fe8ccce` in this run. The changes focus on the
independent C core and generated Unicode tables, with unnecessary terminal
queries removed at the shell boundary. Pinned vendor sources are unchanged.

## Measurements

These are milliseconds per complete call, including freeing the returned result.
Each number is the median of seven warmed batch averages. The machine was an
AMD Ryzen 9 5950X running Linux x86_64/Mageia, GCC 15.2.0 with `-O2`, a private
matching Zsh 5.9.2 build, and `LC_ALL=C.UTF-8`. Both suites ran on CPU 2, baseline
then optimized. There was no Valgrind instrumentation during timing.

| C core workload | Before, ms | After, ms | Speedup |
| --- | ---: | ---: | ---: |
| Small document, plain | 0.0036 | 0.0014 | 2.50× |
| Prose, plain | 3.432 | 0.861 | 3.99× |
| Prose, ANSI | 3.477 | 0.851 | 4.09× |
| Prose, structured | 9.209 | 1.636 | 5.63× |
| Unicode, plain | 1.426 | 0.693 | 2.06× |
| Unicode, structured | 4.942 | 1.739 | 2.84× |
| Code block, plain | 5.308 | 0.811 | 6.55× |
| Code block, structured | 14.571 | 2.642 | 5.51× |
| Table, plain | 1.966 | 0.882 | 2.23× |
| Table, structured | 4.634 | 1.301 | 3.56× |
| Stacked table, structured, width 12 | 8.359 | 2.216 | 3.77× |
| 128-column table, width 4096 | 142.421 | 6.065 | 23.48× |

The default width is 80 with `unicode`/`preserve` in this table. The complete
82-case results cover all four width/style combinations in plain, ANSI, and
structured modes, plus native scalar assignment, association assignment,
stdout redirected to `/dev/null`, and file input. Raw batch timings and
environment details are in [performance-results.json](performance-results.json).
The smallest measured improvement was 1.23× for the small document's native
file-input path, where shell and file overhead represent much of the total.

| Native Zsh builtin workload | Before, ms | After, ms | Speedup |
| --- | ---: | ---: | ---: |
| Small document → scalar | 0.0067 | 0.0042 | 1.58× |
| Prose → scalar | 3.678 | 1.052 | 3.50× |
| Prose → association | 12.523 | 5.143 | 2.43× |
| Prose file → scalar | 3.521 | 0.889 | 3.96× |
| Unicode → association | 8.098 | 4.636 | 1.75× |
| Code block → scalar | 5.781 | 1.135 | 5.09× |
| Code block → association | 18.807 | 6.098 | 3.08× |
| Table → association | 6.760 | 3.355 | 2.02× |

The builtin measurements include loop/dispatch overhead, argument handling,
rendering, publication, and destruction of the previous assigned value. The
module loads once. File input is warm in the filesystem cache; string input is
read before timing. Output to a real terminal, cold process/module startup,
disk latency, and terminal repainting are outside these measurements. Values
are batch averages, not individual-call tail latencies or performance guarantees
for other machines. No elapsed-time threshold is imposed on the test suite.

## What the profiles showed

Callgrind attributed 50.8% of baseline plain-prose instructions to grapheme and
emoji classification, with another 5.6% in `wcwidth`. ASCII was taking the full
Unicode path and scalar widths were calculated during both decoding and layout.
Structured output repeated decoding/measurement and formatted each numeric key
and value through general-purpose printf functions.

The table-fitting loop removed one cell from the widest column, then scanned
all columns again. For 128 long columns at width 4096 this meant tens of millions
of comparisons before emitting the table.

The changes address those costs:

- Printable ASCII runs bypass UTF-8 decoding and control sanitization work;
  non-ASCII and controls still use the complete safe path. ASCII-only glyph
  buffers and final lines avoid Unicode clustering and repeated width work.
  Mixed buffers retain the full state machine, including Prepend, combining
  marks, keycaps, and cross-style graphemes.
- Unicode properties use two indexed loads into deduplicated 128-code-point
  pages. The four properties fit in one byte. The read-only tables occupy
  30,080 bytes and are regenerated from the same pinned Unicode 17 sources.
  Locale-sensitive scalar widths are calculated during layout without a
  persistent cache, so changes in the process locale remain observable.
- Emission batches text by style and writes padding and SGR sequences in
  chunks. It preserves the original reset sequences and style boundaries.
- Tree nodes/text and structured strings use separate per-call/per-result
  arenas. Aligned nodes and byte strings share bounded chunks, and oversized
  strings do not enlarge later ordinary chunks. Cleanup frees chunks rather
  than thousands of individual strings. Public results still use
  `zmd_document_free`.
- Structured keys reuse row/block prefixes and use bounded decimal conversion.
  ASCII style normalization and measurement avoid allocating temporary glyphs.
- Table widths are leveled in `O(columns × log(width))`, preserving the
  original left-to-right tie rule. A single rendered row is stored directly
  in its table cell, avoiding an allocation for the common case. Glyph indices
  use the existing 2,097,152-glyph bound, reducing each glyph from 24 to 20 bytes
  on this platform.
- The builtin queries terminal width only when `--width` is omitted, and
  detects automatic color only for stdout rendering. With an explicit width,
  100 scalar assignments required 103 `ioctl` calls before and three after in
  `strace`; the remaining three came from shell startup. Default terminal
  sizing and explicit color options keep their behavior.

For the same two-call profiling harness, plain-prose instructions fell from
134,631,705 to 24,653,870, and structured prose with `wcwidth-sum`/`first-base`
fell from 480,152,610 to 44,967,425. These totals include harness/startup work;
they are instruction counts, not timing estimates.

Massif measured peak requested heap for the structured table at 9,793,232 bytes
before and 7,134,493 after, a 27% reduction. Both totals include the harness's
fixed 4 MiB input allocation. This measures live heap allocation, not RSS or
allocator-retained pages.

The native structured-output profile now spends much of its time in Zsh/libc
allocation, hashing, metafication, and replacement of the previous association.
Those parameters retain Zsh's ordinary ownership and setter behavior. The
independent core and small shell integration remain separate.

## Reproduce

```sh
make test
make sanitize SANITIZER_CC=clang
make bench
```

`make bench` builds an optimized standalone C driver and exercises the matching
private shell. Fixtures and raw samples stay under `.build/bench/`. The generated
workloads include a small document, repeated styled prose, mixed CJK/combining/
emoji text, tabbed code, aligned tables, and the deliberately demanding wide
table. There is one warmup batch and seven measured batches: 2,000 calls per
batch for the small document, three for the wide table, and ten otherwise.
`BENCH_CFLAGS` defaults to `-O2 -g`; changing it does not reconfigure Zsh.

For an existing matching build or a saved baseline executable/module:

```sh
python3 scripts/benchmark.py --binary .build/bench/baseline \
  --module-dir .build/bench/baseline-modules \
  --output .build/bench/baseline.json
python3 scripts/benchmark.py --module-dir .build/modules \
  --output .build/bench/optimized.json
```

On Linux, optionally prefix each command with `taskset -c 2`, as in this report.
Use an available CPU on the test machine and run the suites serially. Named
Zsh caches are supported through `ZMDOWN_BUILD_NAME`; `--shell` and
`--module-dir` must always refer to matching ABIs.

To build a reference C core from the recorded commit without changing the
working tree:

```sh
mkdir -p .build/bench/reference
git archive 8bb1390f2636e7f7fc46032d222e981b1fe8ccce src vendor |
  tar -x -C .build/bench/reference
cc -std=c11 -O2 -g -fPIC -shared \
  -I.build/bench/reference/src -I.build/bench/reference/vendor/md4c \
  .build/bench/reference/src/render.c .build/bench/reference/src/grapheme.c \
  .build/bench/reference/vendor/md4c/md4c.c \
  .build/bench/reference/vendor/md4c/entity.c -o .build/bench/reference.so
LC_ALL=C.UTF-8 python3 tests/differential.py .build/bench/reference.so
```

To produce a baseline benchmark executable, use the same reference sources with
`tests/benchmark.c`, omitting `-fPIC -shared`. The differential runner requires
both cores to use the same public `render.h` ABI.

Profiling commands, after `make bench` has generated fixtures:

```sh
LC_ALL=C.UTF-8 valgrind --tool=callgrind \
  --callgrind-out-file=.build/bench/prose.callgrind \
  .build/bench/render-bench .build/bench/prose.md 0 80 0 0 1 1
callgrind_annotate --auto=no .build/bench/prose.callgrind
LC_ALL=C.UTF-8 valgrind --tool=massif \
  --massif-out-file=.build/bench/table.massif \
  .build/bench/render-bench .build/bench/table.md 2 80 0 0 1 1
```

The driver arguments are input path, mode (`0` plain, `1` ANSI, `2` structured),
width, width policy, cluster-style policy, calls per batch, and measured batches.

## Compatibility checks actually run

- `make test`: 35 builtin tests, three build-diagnostic tests, all 652 CommonMark
  parser examples, 5,216 terminal renders, and 10,432 structured layouts.
- All 766 Unicode grapheme-boundary corpus cases; exhaustive base-character and
  both emoji-property checks against the vendor ranges for all 1,114,112 code
  points; original data hashes and generated-table reproducibility.
- 173,672 baseline comparisons of scalar bytes, ordered key/value strings,
  status, and error text. These cover the CommonMark corpus, ten targeted
  Unicode/control cases, four widths, both dialects, both link modes, both
  colors, all four width/style combinations, 2,000 deterministic malformed
  inputs, and 100 randomized table layouts. Both the normal test library and
  the optimized `-O2` library passed this comparison.
- Clang ASan/UBSan with leak detection: 4,000 malformed inputs and 99 Unicode
  table widths across all policy combinations and both output APIs, plus
  oversized odd-length arena strings, glyph/input boundaries, and node-limit
  failure cleanup.
- The 35 real builtin tests passed against private matching Zsh 5.8 and 5.9.2
  builds. The embedded benchmark shell script passed `zsh -n`.

These checks preserve observed behavior across the covered inputs. They do not
exhaust every Markdown document, inject every allocation failure, validate
every terminal's font shaping, or establish ABI compatibility on other systems.
