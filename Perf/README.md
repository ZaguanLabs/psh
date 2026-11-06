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
six's Memcheck results must not be described as clean.

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
