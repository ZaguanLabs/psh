# Local performance workflow

`build.py` builds an immutable-source baseline and the working-tree candidate
with identical `-O2 -g`, multibyte support and Zsh debug assertions. Compiler
and configure output is retained under `.work/logs/`. The candidate is published
atomically as the real executable `../psh`, with private native modules under
the configured `.work/runtime` prefix. Normal builds retain upstream target
names internally. Nothing is installed system-wide.

Clean clones reconstruct `.work/pristine` from the `upstream/zsh-5.9.2` tag and
verify its exact file list and contents against `upstream-sha256.json`. Existing
snapshots are verified against that committed manifest too. The tag is an import
of the supplied release snapshot, and retains the release's generated files.
For shallow clones, fetch it with `git fetch origin tag upstream/zsh-5.9.2`.
Historical experiment binaries stay local; their source patches, build settings,
hashes and measurements are committed so revisions can be rebuilt.

## Rebuild and verify

Run from the project root:

```sh
python3 Perf/build.py
make -C .work/baseline check
make -C .work/candidate check
python3 Perf/compare.py .work/baseline/Src/zsh ./psh \
  --output .work/logs/differential.json
```

`compare.py` compares stdout and stderr as bytes and process exit status across
4,200 isolated cases in C and C.UTF-8. It covers native/ksh/sh emulation,
empty values, negative/zero/out-of-range indices, insertion/deletion, the
32-element boundary, unique/tied/exported/readonly/special arrays, dynamic
scope, evaluation effects, and literal NUL/non-ASCII bytes. Invocation names
are normalized to `comparison` for diagnostics. This is focused array coverage,
not a claim to cover every Zsh behavior.

The new upstream-format regression cases live in `Test/D06subscript.ztst`.
To check their expected behavior using the untouched baseline executable:

```sh
(
  cd .work/baseline/Test
  ZTST_srcdir=../../../Test ZTST_exe=../Src/zsh \
    ZTST_testlist=../../../Test/D06subscript.ztst \
    ../Src/zsh +Z -f ../../../Test/runtests.zsh
)
```

## Measure

Keep other builds, test suites and profilers idle during timings. Choose an
available CPU appropriate to the machine; the recorded local run uses CPU 2.

```sh
python3 Perf/benchmark.py .work/baseline/Src/zsh ./psh --cpu 2 \
  --output .work/logs/array-benchmarks.json
python3 Perf/applications.py .work/baseline/Src/zsh ./psh --cpu 2 \
  --zjson /path/to/zjson --z3dfx /path/to/z3dfx \
  --output .work/logs/application-benchmarks.json
```

Nine fresh-process samples per build, alternating execution order. Setup and a
warm-up call precede each timed section. Timers use native `SECONDS`; process
startup and fixture construction are excluded. Array workloads check resulting
values and lengths. Application kernels compare resulting state byte-for-byte
through SHA-256 digests and record hashes of source files. These are synchronous
offline kernels, not terminal-visible frame measurements or whole applications.
The application driver sources explicitly supplied, trusted project code.

`benchmark.py` includes tiny and large arrays, early/middle/late writes,
two-element slices, append and scalar controls, and indices 32/33. Retain every
sample and assess controls alongside improvements; avoid treating a small
change in one median as a proven regression or improvement.

## First change

`setarrvalue()` already replaces ordinary array elements in place when the
array's size is unchanged, but first scans the entire old array to determine
its length. For short nonnegative slices, the new path checks only that the
array contains the slice. Equal replacement/slice lengths then establish that
the size stays unchanged. The same setter, special/unique and tied-parameter
restrictions as the existing in-place path apply. Incoming strings transfer
ownership and the incoming pointer vector is freed exactly as before.

The prefix scan stops at 32 elements. An unrestricted bounded scan made distant
writes slower than the original `arrlen()` loop in measurements, so that version
was rejected. If the prefix scan encounters the array terminator, its discovered
length is reused by the original extension path. No persistent metadata, new
exported symbols, public structures or module interfaces are introduced.

32 is a conservative performance heuristic, not a cache-line/header boundary or
an assumption about application layouts. The measurements rejected an unlimited
scan; they did not establish 32 as the optimal cutoff. Safety does not depend on
this particular number: the bounded scan stops at the null terminator. Ordinary
padding and extension rules still apply when a replacement outruns the array.

See `results.md` for measurements and explicit validation limits. Raw local
evidence lives under `.work/logs/`; reviewable source changes are also available
in `0001-short-prefix-array-replacement.patch`.

## Scalar slicing

The second change computes the selected byte count before allocating/copying a
scalar slice. It retains the existing formatting and index normalization,
including negative and multibyte indices. It does not remove the earlier
length scan or the work needed to translate character indices to byte offsets.

The first psh executable is preserved under `.work/round1/psh` so that timings
can isolate this change. Before overwriting that snapshot, retain its binary,
source and test hashes with the measurements that use it.

```sh
python3 Perf/scalar-compare.py .work/baseline/Src/zsh .work/candidate/Src/zsh \
  --output .work/logs/round2/scalar-differential-pristine.json
python3 Perf/slice-benchmark.py .work/round1/psh .work/candidate/Src/zsh --cpu 2 \
  --output .work/logs/round2/slice-benchmarks.json
python3 Perf/parser-benchmark.py .work/round1/psh .work/candidate/Src/zsh --cpu 2 \
  --zhtml2md /path/to/zhtml2md --zjson /path/to/zjson --zoup /path/to/zoup \
  --output .work/logs/round2/parser-benchmarks.json
```

`scalar-compare.py` checks 12,266 scalar reads and formatting/evaluation cases in
C and C.UTF-8. Range matrices share a process but preserve the source value;
completion markers ensure an aborted matrix is not counted as successful.
The driver compares raw output bytes, diagnostics and exit status. Special
formatting cases include integer/float, justification, case conversion and
readonly parameters.

`slice-benchmark.py` measures prefix, middle, suffix, empty and full ranges, plus
Unicode, NUL and out-of-range controls. Large distant-index cases use shorter
batches because character-to-byte offset traversal already dominates their
cost; iteration counts are retained per case. Compare per-call values when
comparing cases with different batch lengths.

`parser-benchmark.py` generates comment/repair/cleaner inputs outside timing,
builds 100 KiB of prose from complete authored seed units, and measures complete warm
calls, including input/output file operations for the converter. Every sample's
result must match the other build byte-for-byte; the comment and JSON repair
also have explicit expected bytes. Parser sources and input/output hashes are
recorded. Library loading, setup and warm-up are excluded.

See `round2.md` and `0002-bounded-scalar-copy.patch` for the second experiment.

## Scalar index traversal

The third experiment retains the traversal and its offset calculations, while
avoiding the general conversion function for its existing ASCII and byte-mode
fast cases. ASCII bytes have width one. With multibyte disabled, a Meta escape
has width two and other bytes width one. Remaining multibyte characters still
use `MB_METACHARLEN()`; conversion-state initialization stays in place.

The second psh is preserved as `.work/round2/psh`. Run the same scalar/parser
benchmarks against that binary to isolate the third change:

```sh
python3 Perf/scalar-compare.py .work/baseline/Src/zsh .work/candidate/Src/zsh \
  --assignments --output .work/logs/round3/scalar-assignments-pristine.json
python3 Perf/slice-benchmark.py .work/round2/psh .work/candidate/Src/zsh \
  --cpu 2 --indices --output .work/logs/round3/slice-benchmarks.json
python3 Perf/parser-benchmark.py .work/round2/psh .work/candidate/Src/zsh --cpu 2 \
  --zhtml2md /path/to/zhtml2md --zjson /path/to/zjson --zoup /path/to/zoup \
  --output .work/logs/round3/parser-benchmarks.json
```

`--assignments` adds 16,128 mutation checks to the 12,266 scalar-read checks.
Each potentially invalid assignment runs in an isolated subshell; stdout,
diagnostics and the mutation status are compared and completion markers guard
against prematurely terminated matrices. Both C and C.UTF-8, native/ksh/sh
emulation and multibyte on/off are covered.

`--indices` adds late ASCII reads with multibyte enabled, all-non-ASCII and
mixed-text controls, a dense NUL control, and negative-index reads. The regular
matrix retains tiny/large inputs, early/late/full/empty/out-of-range cases.

The third change was also built with `--disable-multibyte`. The untouched
baseline and candidate each pass the eight available substitution test scripts;
the UTF-8 script is skipped in this configuration. An additional 12,266 scalar
read comparisons match across these two builds. Their configure/build/test logs
are under `.work/logs/round3/no-mb-*`.

See `round3.md` and `0003-scalar-index-widths.patch` for the third experiment.

## Array append length reuse

The fourth experiment passes the already-computed destination length from an
ordinary whole-array list append into a private assignment helper. The public
`setarrvalue()` signature and exported symbol remain unchanged and always use
the unknown-length path. The hint is a local argument, not persistent metadata.

Eligibility requires the exact standard array accessors, no special/tied flags,
and no tied scalar name. It is checked **before** invoking the getter, since a
custom getter can replace itself. Signals remain queued, both original getter
calls remain, and the setter/error/ownership logic is retained. Scalar append,
partial slices, special arrays and custom accessors keep the existing scans.

```sh
python3 Perf/compare.py .work/baseline/Src/zsh .work/candidate/Src/zsh --appends \
  --output .work/logs/round4/append-differential-pristine.json
python3 Perf/check-append-module.py .work/baseline/Src/zsh .work/candidate/Src/zsh \
  --output .work/logs/round4/native-module-pristine.json
python3 Perf/append-benchmark.py .work/round3/psh .work/candidate/Src/zsh --cpu 2 \
  --output .work/logs/round4/append-benchmarks.json
python3 Perf/applications.py .work/round3/psh .work/candidate/Src/zsh --cpu 2 \
  --arrays --zjson /path/to/zjson --z3dfx /path/to/z3dfx \
  --output .work/logs/round4/application-benchmarks.json
```

`--appends` extends the original 4,200 comparisons to 5,192 cases, covering
empty/self appends, scalar-to-array conversion, uniqueness, readonly/tied/
exported/special/associative arrays, indexed assignments, scope, deletion and
recreation. `check-append-module.py` builds one test-only module against pristine
configured headers and checks the same binary on both shells. It verifies
getter/setter counts, changing/self-replacing getters, direct public API calls
and unload cleanup against explicit expected values. It does not install the
fixture into the runtime module directory.

`append-benchmark.py` measures growing/prepopulated arrays and batch appends,
with scalar, unique, duplicate, tied and replacement controls. `applications.py
--arrays` adds parsing a 2,000-number JSON array and encoding an already decoded
4,000-string array. Loading/preparation/warm-up are excluded; complete-call
times and resulting state hashes are retained. Array encoding also checks an
explicit expected JSON string. The existing validation/navigation controls
remain in the run.

See `round4.md` and `0004-array-append-length.patch` for this experiment.

## Forward array pattern searches

The fifth experiment avoids counting the whole array before a forward pattern
search with a nonnegative start. The scan stops safely at a match or the array
terminator; reaching the terminator supplies the original missing index. Pattern
compilation, match order, occurrence counting, capture updates and getter calls
remain in their original order. Negative starts and backward searches keep the
length-based path. Scalar and associative searches keep their existing paths.

```sh
python3 Perf/search-compare.py .work/baseline/Src/zsh .work/candidate/Src/zsh \
  --output .work/logs/round5/search-differential-pristine.json
python3 Perf/check-append-module.py .work/baseline/Src/zsh .work/candidate/Src/zsh \
  --search --output .work/logs/round5/native-module-pristine.json
python3 Perf/search-benchmark.py .work/round4/psh .work/candidate/Src/zsh --cpu 2 \
  --output .work/logs/round5/search-benchmarks.json
```

`search-compare.py` checks 69,180 searches across C/C.UTF-8, native/ksh/sh,
multibyte on/off, empty arrays/elements, Unicode/NUL patterns, start bounds,
positive/negative/zero occurrence counts, both directions, index/value results
and capture state. It includes scalar/hash controls, syntax diagnostics,
arithmetic effects and a range using two searches. Completion markers guard
against prematurely aborted matrices. All result bytes and statuses must match.

The native checker adds 15 search cases to its five existing append/API cases.
It verifies returned custom-getter snapshots, accessor replacement, callback
counts and unload cleanup. Value reads retain their additional getter calls.

`search-benchmark.py` records nine alternating fresh-process samples on a chosen
CPU, with warm-up and array construction excluded. Expected indices are checked
outside the timing loop. Cases cover tiny/large arrays, early/middle/late/missing
matches, positive offsets through and beyond the end, and negative/backward
controls. No profiler, build or test suite should run concurrently with timing.

See `round5.md` and `0005-forward-array-search.patch` for this experiment.

## Scalar pattern search from the beginning

The sixth experiment avoids a full character count before a forward scalar
pattern search with normalized start zero. The existing check has established
that the string is nonempty, so a lower bound of one character is enough to
validate that start. Other starts and backward searches retain the full count.
Raw byte length, conversion-state initialization, matcher calls, capture state
and returned byte-offset conversion remain on their existing paths.

```sh
python3 Perf/search-compare.py .work/baseline/Src/zsh .work/candidate/Src/zsh \
  --scalars --output .work/logs/round6/search-differential-pristine.json
python3 Perf/scalar-search-benchmark.py .work/round5/psh .work/candidate/Src/zsh \
  --cpu 2 --output .work/logs/round6/scalar-search-benchmarks.json
```

`--scalars` adds 124,056 checks to the previous 69,180 array search comparisons,
for 193,236 total. Scalar cases include both directions, occurrence/start flags,
captures, paired range searches, formatting, malformed/incomplete UTF-8, embedded
NUL and byte mode, across C/C.UTF-8 and native/ksh/sh emulation. Completion
markers and raw output/status comparisons guard the matrices as before.

`scalar-search-benchmark.py` records nine alternating fresh-process samples on
one CPU. Construction and warm-up precede timing, and each batch's result must
match an explicit expected index or string. The large early-match cases use
100,000 characters; late/missing/backward cases use 2,000 characters because
the underlying matching work makes large batches expensive. Sizes and call
counts are recorded per case. Unicode, NUL, invalid-byte, byte-mode, range,
positive/negative offset and backward controls are included.

See `round6.md` and `0006-scalar-search-length.patch` for this experiment.

Expanded Memcheck coverage found a pre-existing scalar-search terminator read
in both pristine Zsh and psh. The [issue note](upstream-terminator-read.md)
includes a minimal reproducer and links the full comparison evidence. Round
six's Memcheck results must not be described as clean. Mikael Magnusson's
subsequent two-guard fix is now backported separately; the saved 84-matrix
corpus reports zero errors with that correction. See the issue note for
provenance and current evidence.

## Metafied byte-length prefix scanning

The seventh experiment changes `ztrsub()`, used by matching and some editor
callers. A bounded `memchr()` finds the first Meta escape. If none exists, the
pointer difference is already the decoded byte length. If one exists, the
original escape-pair loop starts there, with the original length and diagnostics.
The span need not be NUL-terminated. This helper counts bytes, not Unicode
characters, and its signature and exported symbol remain unchanged.

```sh
python3 Perf/check-ztrsub-module.py .work/baseline/Src/zsh .work/candidate/Src/zsh \
  --memcheck --output .work/logs/round7/ztrsub-module-final.json
python3 Perf/pattern-compare.py .work/baseline/Src/zsh .work/candidate/Src/zsh \
  --output .work/logs/round7/pattern-differential-pristine.json
python3 Perf/scalar-search-benchmark.py .work/round6/psh .work/candidate/Src/zsh \
  --cpu 2 --output .work/logs/round7/scalar-search-benchmarks.json
```

The new native fixture is compiled against pristine headers and the same module
is loaded into both builds. It checks 132,615 spans per run: every logical byte
boundary pair in all-byte, plain, dense-NUL and alternating-Meta inputs, plus
large spans without a NUL delimiter, a Meta outside the requested range, and an
empty span at the allocation boundary. C and C.UTF-8 runs pass under Memcheck
with no errors. The fixture is test-only and is not installed into the runtime.

`pattern-compare.py` adds 14,364 conditional/substitution checks across C/C.UTF-8,
native/ksh/sh and multibyte on/off. It compares literal and extended patterns,
case folding, exclusions, capture arrays, whole-match parameters and both
greedy/non-greedy prefix/suffix removal and single/global replacement. Payloads
include all 256 byte values, Unicode, incomplete UTF-8, late and dense Meta
escapes. The existing search and array/scalar comparison drivers remain useful.

See `round7.md` and `0007-metafied-length-prefix.patch` for this experiment.

## Terminal-star matching

The eighth experiment handles a `P_STAR` followed immediately by `P_END` before
allocating a backtracking bitmap. It retains traversal for multibyte conversion
state, inlining the converter's existing state-free ASCII case. Byte mode can
advance directly to the end. This does not replace the existing `PAT_ANY`
shortcut for a standalone star.

On heap-allocation builds, the fast path requires signals already queued.
Otherwise the original allocation, traversal and return remain, preserving the
allocator's potential signal dispatch. Stack-allocation builds do not have that
allocator boundary. Both native queue contexts are checked; the stack branch
also compiles, without a separate full stack-build runtime claim.

```sh
python3 Perf/check-pattern-module.py .work/baseline/Src/zsh .work/candidate/Src/zsh \
  --memcheck --output .work/logs/round8/pattern-module.json
python3 Perf/pattern-compare.py .work/baseline/Src/zsh .work/candidate/Src/zsh \
  --extended --locale C --locale C.UTF-8 --locale ja_JP.eucjp \
  --locale zh_CN.GB18030 --locale zh_TW.EUC-TW \
  --output .work/logs/round8/pattern-extended-pristine.json
```

The native fixture checks `pattryrefs()`, `pattrylen()` and a forced-unmetafication
cache. It verifies 196 results per run, split between queued and unqueued calls:
bounded input with a guard outside its end, empty suffixes, NUL, valid/incomplete/
invalid multibyte data, captured/uncaptured terminal stars, offsets and returned
match lengths. Capture arrays supplied through the API must leave shell capture
parameters untouched. The same pristine-header module runs on both shells in
C/C.UTF-8 with multibyte on/off; eight runs pass Memcheck without errors.

`--extended` adds approximation, exclusions, star chains, captures before and
around stars, per-pattern multibyte overrides and raw EUC/GB18030 fixtures.
`--locale` can be repeated; requested locales are verified with `locale charmap`
and recorded in the report. The five-locale run makes 109,200 comparisons.

Run `make check` jobs **sequentially within a build tree**: they share temporary
directories and module links. Independent differential processes do not use
those test directories. The round-eight no-multibyte checks were rerun
sequentially after two concurrent upstream jobs interfered.

See `round8.md` and `0008-terminal-star-matching.patch` for this experiment.

## Terminal-star ASCII runs

The ninth experiment extends the eighth path with bounded word loads. With
`UINT64_MAX` available and `CHAR_BIT == 8`, `memcpy()` reads a full `uint64_t`
only when that many input bytes remain. A repeated high-bit mask establishes
that all eight bytes have the converter's state-free ASCII width. Alignment and
endianness do not matter. Embedded NUL is included; no terminator is required.
Non-ASCII bytes still use `CHARINC()` with its existing conversion state.
The eighth experiment's signal-queue eligibility is retained.

Single ASCII bytes are handled before considering word loads, avoiding repeated
loads for alternating ASCII/non-ASCII input. Without the type/byte-width guard,
the scalar path remains. An isolated object compiled with `UINT64_MAX` undefined
was linked and run through the native and five-locale pattern checks.

```sh
python3 Perf/scalar-search-benchmark.py .work/round8/psh .work/candidate/Src/zsh \
  --cpu 2 --mixed --output .work/logs/round9/scalar-search-benchmarks.json
```

`--mixed` adds alternating ASCII/Unicode and a long ASCII run following Unicode
to the existing controls. The current native pattern fixture checks **844
results per run**, half queued and half unqueued. Added exact-size allocations
have no guard byte after their bounded spans: lengths 1–33 and 63–65 at eight
alignments, plus NUL/invalid/incomplete/valid multibyte sequences near word
boundaries. Eight runs cover both shells, C/C.UTF-8 and multibyte on/off under
Memcheck. The extended five-locale pattern matrix now has **159,600** comparisons;
the default two-locale matrix retains 14,364. These replace the fixture counts
recorded for the earlier experiment, whose archived results remain unchanged.

See [round9.md](round9.md) and
[0009-terminal-star-ascii-words.patch](0009-terminal-star-ascii-words.patch).

## Literal spans during substitution

The tenth experiment changes only the traversal between `stringsubst()`'s
existing handlers. The process-substitution pass can skip bytes other than
`Inang`, `OutangProc` and `Equals`. The ordinary pass can skip bytes other than
`String`, `Qstring`, `Tick` and `Qtick`; assignment-like arguments also stop at
literal `=` and `Equals`, preserving their no-splitting flag update. Each
current byte still takes the original handler path, and `strcspn()` skips the
following inert span. Handler order, node replacement and continuation pointers
are unchanged. The next loop header retains the error check before another
handler. No allocator or signal-queue boundary is removed.

The string remains NUL-terminated and metafied. This is a byte scan, independent
of locale: embedded user NUL is represented by Meta bytes, and the existing
handlers retain encoding interpretation. No word-load bounds assumptions,
ctype-table shortcuts or persistent cache are introduced.

```sh
python3 Perf/substitution-compare.py .work/baseline/Src/zsh .work/candidate/Src/zsh \
  --output .work/logs/round10/substitution-final.json
python3 Perf/scalar-write-benchmark.py .work/terminator-fixed/psh .work/candidate/Src/zsh \
  --cpu 2 --output .work/logs/round10/scalar-write-benchmarks.json
```

The differential driver checks 2,640 programs across C/C.UTF-8, native/ksh/sh
and multibyte on/off. It covers parameter, arithmetic, command and all three
process-substitution forms, assignment-like arguments, splitting flags, long
literal prefixes/suffixes, Unicode, NUL and every byte value. Output bytes,
diagnostics and status must match; completion markers detect aborted programs.
The same cases run against no-multibyte builds. A saved 440-matrix subset also
runs under Memcheck and matches the corrected ninth psh's output.

The scalar assignment benchmark includes a reset before each operation inside
timing. Input construction, loading and warm-up precede timing. Each sample
checks an independently constructed expected value before and after timing.
The tiny case, whole assignment and same-size replacement are controls for
assignment-copy behavior; all can still benefit from faster expansion.
Nine alternating fresh-process samples are retained, alongside complete-call
parser/application measurements. Keep all builds, suites and profilers idle.

Mikael Magnusson's correctness fix is a separate preceding commit and is
present in both timing builds. The pristine release source/tag remains the
behavioral reference. See [round10.md](round10.md) for measurements, rejected
copy-only work, and compatibility limits.

## Long inert prefixes during null-marker removal

The eleventh experiment changes `remnulargs()` only before its first removable
marker. A bounded 64-byte scalar probe handles short strings. When a longer
inert prefix remains, a standard-library length check requires at least 512
remaining bytes before constructing a reject set. The set is built from the
current `INULL` flags for all nonzero byte values, excluding `Bnullkeep`, and
`strcspn()` skips to the first removable marker or terminator. Medium tails
continue through the original scan. These are measured heuristics, not cache
or header-layout boundaries or claims of globally optimal cutoffs.

The original removal loop, original start pointer and collapsed-empty-string
rule remain unchanged. `Bnullkeep` before the first removed marker remains in
the prefix; later occurrences retain the original conversion to a backslash.
The 256-byte temporary set is rebuilt per eligible call, honoring classification
changes without a persistent cache. Strings remain NUL-terminated and metafied.
The additional length scan remains linear; gains depend on library routines
and workload size. No allocator or signal-queue boundary is removed.

```sh
python3 Perf/check-remnulargs-module.py .work/baseline/Src/zsh .work/candidate/Src/zsh \
  --memcheck --output .work/logs/round11/remnulargs-native.json
python3 Perf/check-completion-prefix.py .work/baseline/Src/zsh .work/candidate/Src/zsh \
  --output .work/logs/round11/completion-prefix.json
python3 Perf/scalar-write-benchmark.py .work/round10/psh .work/candidate/Src/zsh \
  --boundaries --cpu 2 --output .work/logs/round11/scalar-write-benchmarks.json
```

The same pristine-header native module runs on both shells in C and C.UTF-8.
Its 30,203 checks per run compare complete allocations, including bytes beyond
the resulting terminator. Cases cover every nonzero byte, prefix/suffix marker
positions, eight alignments, exact allocation boundaries, 1 MiB spans, default
classification, one added flag, one removed flag, an empty set and a full set.
The fixture restores classification state before returning or unloading.
Memcheck checks all four runs; leak checking is disabled.

The PTY driver uses upstream `Test/comptest` and checks 24 actual ZLE buffers
across eight prefix lengths and unquoted/single-quoted/double-quoted input. It
passes the binary path explicitly to the child shell. `--boundaries` adds 15
whole-assignment controls from 31 through 4,096 characters, including both
cutoffs, to the scalar benchmark's original 12 cases. Final timings use nine
alternating fresh-process samples with builds, suites and profilers idle.

See [round11.md](round11.md) and
[0011-null-marker-prefix.patch](0011-null-marker-prefix.patch), including the
rejected first cutoff and the complete application controls.

## Grouped token-prefix scanning

The twelfth experiment adds a long-prefix path to `untokenize()`. Sixteen groups
of four individually guarded byte steps probe at most 64 bytes. Early tokens
go to a private tail worker containing the original conversion loop;
terminators return immediately. After a complete
probe, at least 1,024 remaining bytes are required for the private scanner.
It rebuilds reject sets from current `ITOK` flags, up to 15 nonzero bytes per
set, and takes the minimum match offset across library scans. An empty set
skips to the known terminator; a zero offset can stop further scanning.
The original conversion loop still reads the live `ztokens` mapping and handles
`Nularg` as before. The null-marker helper uses the same grouped probe, retaining
its separate 512-byte remaining-length gate and original removal loop.

Small sets improve library scanning on the measured libc. These group sizes
are performance choices, not safety assumptions or guaranteed optima elsewhere.
There are no unchecked word loads: each byte is tested before advancing.
The tail worker handles both early tokens and long tails, keeping length/set
setup out of the public short-string path. A guarded GNU-family no-inline hint
keeps that separation in the measured build. The same code is separately compiled and tested
with the hint omitted. No public symbol, signature, representation or persistent
cache is added; private generated prototypes may change.

```sh
python3 Perf/check-untokenize-module.py .work/baseline/Src/zsh .work/candidate/Src/zsh \
  --memcheck --output .work/logs/round12/untokenize-final.json
python3 Perf/check-remnulargs-module.py .work/baseline/Src/zsh .work/candidate/Src/zsh \
  --memcheck --output .work/logs/round12/remnulargs-final.json
python3 Perf/check-completion-prefix.py .work/baseline/Src/zsh .work/candidate/Src/zsh \
  --output .work/logs/round12/completion-final.json
```

The token fixture checks 78,732 allocations per run on both shells in C and
C.UTF-8. Cases include every nonzero byte, eight alignments, 1 MiB input,
classification subsets of 0/2/15/16/29/30 tokens, changed mappings including a
NUL mapping, and token-group ordering. The mapping and classification tables
are restored before return. Complete allocations are compared, including bytes
past the resulting terminator. The existing null-marker fixture retains 30,203
checks per run. Both fixtures run under Memcheck with leak checking disabled.

The completion fixture now checks 36 actual PTY buffers, adding lengths around
1,088 bytes and a longer control. `--boundaries` now adds 19 controls to the
12 standard scalar-assignment cases, for 31 cases total. Existing archived
results and their counts remain unchanged. Final timing uses nine alternating
fresh-process samples and sequential drivers, with all this work's builds,
tests and profilers idle. See [round12.md](round12.md) for results and limits.


## Grouped array-length scans

The thirteenth candidate groups four individually guarded pointer checks in
`arrlen()` and `arrlen_ge()`. The other public predicates retain their original
composition, including unsigned wrap at `UINT_MAX`. No data beyond the NULL
slot or pointed-to element bytes is read. No length cache is introduced.

```sh
python3 Perf/check-array-length-module.py .work/baseline/Src/zsh ./psh \
  --memcheck --output .work/logs/array-length-native.json
python3 Perf/array-length-benchmark.py /path/to/previous/psh ./psh --cpu 2 \
  --output .work/logs/array-length-benchmarks.json
```

The native module uses pristine headers and known-length oracles for all five
helpers, exact allocation ends, eight offsets, empty element strings and
non-dereferenceable payload pointers. It checks no-read bounds with NULL and
one-past vectors and preserves the wrappers' existing unsigned behavior.

The benchmark measures reads, short slices and length queries at empty, small,
medium and large sizes. Setup and warm-up precede timing, and expected values
are checked before and after. Run timings with builds, tests and profilers
idle. See [round13.md](round13.md) for gains, unchanged controls and limits.


## Customer workloads and ASCII classification

Use [customer-projects.md](customer-projects.md) to see the measured project
kernels and the remaining native-module, graphics, terminal and network cases.
The round-fourteen ASCII shortcut is guided by those profiles and validated
against the original release scanner:

```sh
python3 Perf/check-itype-module.py .work/baseline/Src/zsh ./psh \
  --memcheck --output .work/logs/itype-native.json
python3 Perf/customer-benchmark.py /path/to/previous/psh ./psh --cpu 2 \
  --labs /path/to/labs --challenge /path/to/challenge \
  --output .work/logs/customer-benchmarks.json
```

The native fixture builds with pristine headers, reconstructs the original
scanner's private wide sets from public values, and checks classifications,
exact allocation ends, unchanged buffers and subsequent conversion state.
Defaults cover C and C.UTF-8; repeat `--locale` for other installed encodings.
The benchmark uses real project functions and independent expected-result
checks, records every sample/source hash, and compares resulting state.
See [round14.md](round14.md) for gains, controls and harness corrections.


## Whole metafied byte counts

Round fifteen changes `ztrlen()`: a standard-library search skips the prefix
before the first Meta escape, or an escape-free string uses `strlen()`. The
original pair loop and debug diagnostic remain in place. This counts bytes;
Unicode character and width conversion retain their existing paths.

```sh
python3 Perf/check-byte-length-module.py .work/baseline/Src/zsh ./psh \
  --memcheck --output .work/logs/byte-length-native.json
```

For an existing no-multibyte pair, select its matching headers with
`--headers-build .work/no-mb-baseline`. The checker keeps those modules in
separate folders so multibyte/no-multibyte checks can run independently. Known
raw lengths are the oracle; exact allocation ends, whole-buffer preservation,
byte-mode wrapper behavior and expected malformed-Meta diagnostics are checked.

The customer driver now includes UTF-8 wide-character layout in both editors.
See [round15.md](round15.md) for URL-encoding gains, the slower scalar controls,
all recorded samples and comparison evidence.

## Scalar indexing through ASCII groups

Round sixteen advances numeric scalar traversal eight characters at a time
when every stored byte is nonzero ASCII. The ordered short-circuit probe stops
at a NUL or non-ASCII byte before reading a later address. Other characters use
the existing converter or Meta width. Groups can resume after these characters;
the previous-character width is explicitly restored to one after a group.

```sh
python3 Perf/scalar-compare.py .work/baseline/Src/zsh ./psh \
  --assignments --prefixes --locale C --locale C.UTF-8 \
  --locale ja_JP.eucjp --locale zh_CN.GB18030 --locale zh_TW.EUC-TW \
  --output .work/logs/scalar-prefixes.json
python3 Perf/check-scalar-index-module.py .work/baseline/Src/zsh ./psh \
  --memcheck --output .work/logs/scalar-index-native.json
```

The extra scalar matrices include ASCII block boundaries, actual locale-encoded
wide characters, incomplete endings, ASCII tails, emulation modes and isolated
assignments. The native fixture uses custom getters returning exact-ending
allocations and original public converter boundaries as the oracle. It checks
input preservation and getter counts as well as selected bytes. Select matching
headers with `--headers-build .work/no-mb-baseline` for a no-multibyte pair.

The parser timing driver accepts repeated `--case` selections, such as
`--case json-repair-100k`, for investigating individual controls. Application
timings now retain binary/worker hashes and check that sources and binaries
stay unchanged. See [round16.md](round16.md) for all results, including slower
controls and the separately validated installed package.
