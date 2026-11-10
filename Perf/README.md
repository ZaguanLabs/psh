# Local performance workflow

`build.py` builds an immutable-source baseline and the working-tree candidate
with identical `-O2 -g`, multibyte support and Zsh debug assertions. Compiler
and configure output is retained under `.work/logs/`. The candidate is published
atomically as the real executable `../psh`, with private native modules under
the configured `.work/runtime` prefix. The pristine baseline uses
`.work/baseline-runtime`; both builds install their own default native modules
as well as their per-build `modules` directories. Normal builds retain upstream target
names internally. Nothing is installed system-wide.

Keep those default runtimes separate: a pristine shell cannot load psh-aware
modules from the candidate's SDK. Run `python3 Perf/build.py --which baseline`
to refresh an older baseline configured with the previously shared prefix.

Clean clones reconstruct `.work/pristine` from the `upstream/zsh-5.9.2` tag and
verify its exact file list and contents against `upstream-sha256.json`. Existing
snapshots are verified against that committed manifest too. The tag is an import
of the supplied release snapshot, and retains the release's generated files.
For shallow clones, fetch it with `git fetch origin tag upstream/zsh-5.9.2`.
Historical experiment binaries stay local; their source patches, build settings,
hashes and measurements are committed so revisions can be rebuilt.

For a release-profile core trial, use `python3 Perf/build.py --which candidate
--profile release`. Assertions are disabled, symbols are retained, and its build
and modules live under `.work/release-candidate` and `.work/release-runtime`.
The reference release build uses `.work/release-baseline` and
`.work/release-baseline-runtime`. Debug remains the default for development;
profile-specific directories keep their native SDKs from replacing one another.
The complete bundled installer uses `Packaging/build.py`, which splits symbols.

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


## Deeper arithmetic and locale review

[Round nineteen](round19.md) follows arithmetic execution, locale conversion,
array-bound walks, allocation and scope scanning using real project kernels.
Its accepted change replaces eligible global-locale switching with an immutable
C conversion locale. Feature detection requires declarations and linking for
the entire API; unavailable APIs retain the released conversion sequence.

```sh
python3 Perf/math-compare.py .work/baseline/Src/zsh ./psh \
  --output .work/logs/math-comparison.json
python3 Perf/check-math-locale-module.py .work/baseline/Src/zsh ./psh \
  --memcheck --output .work/logs/math-native.json
python3 Perf/test-count-command.py --cpu 2 \
  --output .work/logs/counter-validation.json
python3 Perf/hardware-benchmark.py /path/to/previous/psh ./psh --cpu 2 \
  --labs /path/to/labs --challenge /path/to/challenge \
  --output .work/logs/hardware-benchmarks.json
python3 Perf/scaling-benchmark.py /path/to/previous/psh --cpu 2 \
  --zjson /path/to/zjson --output .work/logs/json-scaling.json
```

The native fixture requires the POSIX locale-object API and four standard
rounding modes on its test host, even when testing a deliberately disabled
core fast path. Its default eight installed locales include French, Norwegian,
Turkish, EUC-JP, GB18030 and EUC-TW. Each process also tests a private French
thread locale, retaining the original evaluation errors where applicable.
Select locales with repeated `--locale`; select matching alternative-build
headers with `--headers-build`. The small failure interposer can be compiled
with `cc -shared -fPIC Perf/math-locale-failure.c -ldl -o /tmp/fail-locale.so`
and selected using `--preload /tmp/fail-locale.so`. It fails only creation of
the C locale; other private locale requests continue to libc.

Hardware measurements require Linux perf_event_open permission for user-space
events, without root or system-setting changes. The launcher measures from
exec through exit and inherits child tasks. It records enabled/running times
and separately reports process rusage and the worker's warm-batch timer. These
are different scopes; instruction totals are not wall times. The self-test
checks counter inheritance and command status using a deterministic worker.
Keep builds, tests and profilers idle during all accepted timing runs.


## Per-token arithmetic validation

[Round twenty](round20.md) adds an inline hint to the existing arithmetic
operand/operator checker. Its body, state updates and diagnostics are unchanged.
The measured compiler removes repeated calls without introducing a cache or
changing the parser's evaluation and signal boundaries.

```sh
python3 Perf/math-compare.py .work/baseline/Src/zsh ./psh --syntax \
  --output .work/logs/arithmetic-syntax.json
```

`--syntax` adds token pairs, malformed and valid operands/operators, nested
parentheses, short-circuit contexts and diagnostic-prefix boundaries, including
Unicode, Meta bytes and whitespace. Defaults cover five locales and three
emulations with four option contexts. The driver checks that every expected
subshell completion marker appears before accepting matching output/status;
a failed setup cannot be counted as completed coverage.

The corpus explicitly loads `zsh/mathfunc`. Before using alternative builds,
install their matching stock modules into their private configured prefixes.
For the recorded no-multibyte pair this is:

```sh
make -C .work/no-mb-candidate \
  MODDIR="$PWD/.work/no-mb-runtime/lib/zsh/5.9.2" install.modules
```

This is a private test runtime, separate from the daily driver. The initial
round-twenty run caught this missing test dependency; its original failure and
successful targeted repair are retained with the validation records.


## Release candidates

The current project identity is `psh 1.0.0-rc0 (zsh 5.9.2)`. `$ZSH_VERSION`
and native module identities retain the upstream version. The
[compatibility policy](../COMPATIBILITY.md) distinguishes that language target
from intentional identity/integration changes and unverified cases.

An attached source release contains `Perf/upstream/zsh-5.9.2.tar.xz`. The build
helper uses that archive without needing Git history and verifies the complete
pristine file set and every hash. A clone obtains the same baseline from its
upstream tag. The default private package build splits debugger symbols while
checking unchanged allocated ELF sections and dynamic exports.

See [RC notes](../Releases/1.0.0-rc0.md) for the actual installed-host test harness,
additional compiler/locale coverage, binary-size measurements and source-archive
validation. Historical round timings remain measurements of their recorded
binaries; they are not new startup or cross-platform performance claims for rc0.

The [private rc0 release-profile iteration](../Releases/rc0-release-profile.md)
keeps the project version unchanged and makes daily-driver packaging default
to `--profile release`, without Zsh debug assertions. The `Perf/build.py`
development builds retain their existing assertions. Debugger symbols are
independent of that setting. Compare matched profiles for new performance
claims; older debug-build timings remain historical evidence.

The [round-twenty-one contract and profiles](round21.md) make unchanged Oh My
Zsh a required interactive activation gate. Broad Zsh compatibility remains
useful, while measured, documented breaking changes are allowed. Private
iterations stay on rc0. The new profiles identify array bounds, arithmetic and
scope bookkeeping as targets; they are not new speedup measurements.

The [round-twenty-two cache](round22.md) accelerates confirmed array bounds
inside existing queued signal regions. Native mutable loans and unqueued calls
retain scanning. Reproduce the focused ownership, cold-query and signal checks
with matching release-profile builds:

```sh
python3 Perf/check-array-cache.py /path/to/previous/Src/zsh /path/to/candidate/Src/zsh \
  --headers-build /path/to/previous --headers-source /path/to/previous-source \
  --memcheck --raw-contract --output .work/logs/array-cache.json
python3 Perf/check-array-cache-signals.py /path/to/candidate/Src/zsh \
  --output .work/logs/array-cache-signals.json
python3 Perf/array-bound-benchmark.py /path/to/previous/Src/zsh /path/to/candidate/Src/zsh \
  --cpu 2 --output .work/logs/array-bound-benchmarks.json
```

The raw-contract mode expects the documented unsupported raw-field difference
and passing getter migration. The signal check requires GDB and available debug
symbols; `--expect-writes` is only for the rejected unguarded prototype. Run
timings after builds, tests and profilers finish. The 23-case
`array-length-benchmark.py` supplies empty, small/large, negative/out-of-range,
slice and length controls alongside the actual project benchmarks.

## Arithmetic operand stack

[Round twenty-three](round23.md) adds an inline hint to the existing `pop()`
helper and retains complete timing/control matrices, including an initial
noisy run. New operator coverage complements the malformed-token corpus:

```sh
python3 Perf/math-compare.py /path/to/previous/Src/zsh /path/to/candidate/Src/zsh \
  --operators --locale C --locale C.UTF-8 --locale fr_BE.UTF-8 \
  --output .work/logs/arithmetic-operators.json
```

This checks valid operators, lazy lvalues, parameter replacement/retyping,
callback traces, recursion, short-circuit side effects and operand-stack limits.
It includes expected errors and compares status/diagnostics as well as values.
The extra fixtures run only with `--operators`; the default generated corpus
retains its existing behavior. `--syntax` remains available independently or
in combination. Compare compiler/profile pairs and retain slower controls;
the hint does not guarantee a speedup with every compiler or workload.

## Forward search prefix reuse (round twenty-four)

The [round twenty-four report](round24.md) measures repeated distant positive
array search starts against the preceding psh. The new path reuses the existing
confirmed-prefix metadata; it adds no native ownership rule. The matching loop,
callbacks, captures and occurrence handling remain unchanged.

```sh
python3 Perf/search-compare.py /path/to/previous/Src/zsh /path/to/candidate/Src/zsh \
  --scalars --large --output .work/logs/large-search.json
python3 Perf/check-array-search.py /path/to/previous/Src/zsh /path/to/candidate/Src/zsh \
  --output .work/logs/search-memcheck.json
python3 Perf/check-array-cache.py /path/to/previous/Src/zsh /path/to/candidate/Src/zsh \
  --headers-build /path/to/previous --headers-source /path/to/previous-source \
  --memcheck --output .work/logs/cache-lifetimes.json
python3 Perf/check-array-cache-signals.py /path/to/candidate/Src/zsh \
  --search --output .work/logs/search-signals.json
```

`--large` adds 169,344 comparisons across C/C.UTF-8, native/ksh/sh emulation,
multibyte modes, prefix boundaries, cold/warm repetitions and starts up to the
signed 64-bit maximum. Combined with `--scalars` there are 362,580 comparisons.
The default corpus stays unchanged. `check-array-search.py` runs the additional
boundary corpus under Memcheck on both shells (168 processes); completion
markers, exact bytes and statuses must match, with no memory errors.

The lifetime fixture now includes forward searches around native vector loans,
shortening, setter invalidation and append reallocations. Omit `--raw-contract`
when comparing two releases that both already implement the round-twenty-two
ownership rule; that optional mode expects a pre-cache baseline. The GDB
`--search` probe checks all cache entries at three unqueued calls, including
after a queued call has warmed the cache. These debugger checks require symbols.

## Classification branch merge (round twenty-five)

The [round twenty-five report](round25.md) follows the live class tests in
`itype_end()`. The native fixture compares against the original release function,
including converter state after each call, changed public classification tables,
combined class masks, exact-ending allocations and four `once` values.

```sh
python3 Perf/check-itype-module.py /path/to/previous/Src/zsh /path/to/candidate/Src/zsh \
  --headers-build /path/to/previous --headers-source /path/to/previous-source \
  --memcheck --locale C --locale C.UTF-8 --locale ja_JP.eucjp \
  --locale zh_CN.GB18030 --locale zh_TW.EUC-TW \
  --output .work/logs/classifier.json
```

Use configured headers matching the host profile. The default paths refer to
the pristine debug baseline; release hosts omit debug-only exports required by
a fixture built from debug headers. No native interface change is introduced.
The expanded fixture performs 1,299,456 checks per host/locale on this build.

## Decimal conversion (round twenty-six)

The [round twenty-six report](round26.md) compares the public conversion API
with the unchanged original release function. The native fixture covers integer
bounds, bases, underscore flags, changed classification, exact-ending allocations,
optional end pointers, errno seeds and diagnostic bytes. No warning-producing
input is timed by the separate 64-bit-host API benchmark.

```sh
python3 Perf/check-strtol-module.py /path/to/previous/Src/zsh /path/to/candidate/Src/zsh \
  --headers-build /path/to/previous --headers-source /path/to/previous-source \
  --memcheck --output .work/logs/strtol-native.json
python3 Perf/strtol-benchmark.py /path/to/previous/Src/zsh /path/to/candidate/Src/zsh \
  --headers-build /path/to/previous --headers-source /path/to/previous-source \
  --cpu 2 --output .work/logs/conversion-benchmarks.json
```

The functional driver compares reference/actual modes on each host in C/C.UTF-8,
including completion markers and all stdout/stderr bytes. This build performs
1,663,728 conversion calls per process. Memcheck logs remain beside its report;
large synthetic result/diagnostic streams are represented by hashes and byte
counts. All test inputs and host binaries are fingerprinted.

The timing driver records nine alternating samples per case, one million calls
per sample, with module setup outside the native timer. A matching digest is
required. It includes 19-digit and underscore continuation controls; an early
restart implementation regressed these despite improving short conversions.
Run timing after builds, tests and profilers finish. These native loop ratios
are separate from the actual project-kernel measurements.

## Arithmetic state contract (round thirty-seven)

The [state and ownership map](arithmetic-internals.md) distinguishes the nine
paired recursive save/restore fields from wrapper-owned token state, shared
numeric results/formatting and shell-owned options/errors. The private field
list keeps the old flat locals and emits both assignment sequences; GCC and
Clang release builds preserve the runtime arithmetic object bytes and relocations.

```sh
python3 Perf/math-compare.py /path/to/reference/zsh /path/to/candidate/psh \
  --state-frames-only --memcheck --timeout 600 --locale C --locale C.UTF-8 \
  --output .work/logs/arithmetic-state.json
```

The focused corpus contains 54 expressions in native/ksh/sh modes and four
option contexts, 648 paired comparisons per locale. It covers nested precedence,
radix, floating results, lazy lvalues, native math-function arguments, recursion
limits, short circuiting and recovery after errors. `--state-frames` adds these
cases to a broader selected corpus. Its callbacks run unchanged on pristine Zsh.
The [round 37 report](round37.md) includes the larger typed-record trial and
object-only alternatives; those are not the selected implementation.

## Option emulation scans (round twenty-seven)

The [round twenty-seven report](round27.md) measures using existing scanner
selection masks to skip private option setters that would do nothing. Generated
scanners ignore masks, so the original setter predicate remains intact.

```sh
python3 Perf/emulation-compare.py /path/to/previous/Src/zsh /path/to/candidate/Src/zsh \
  --output .work/logs/emulation-front.json
python3 Perf/check-emulation-module.py /path/to/previous/Src/zsh /path/to/candidate/Src/zsh \
  --headers-build /path/to/previous --headers-source /path/to/previous-source \
  --memcheck --output .work/logs/emulation-native.json
```

The frontend driver compares 512 complete scenarios across C/C.UTF-8: initial
and target emulations, altered options, full/partial/local defaults, function
restoration, traces, sticky functions and autoloads. Each scenario compares
complete option listings and trace bytes with completion markers.

The native fixture uses the existing exported internal installation entry point
and the public option table. This does not add a supported module interface.
It compares the original release predicate with actual byte arrays, in queued
and unqueued contexts, on the canonical table and synthetic ordinary/generated
tables. Its 56,722 scenarios per host/locale include all current flag-bit
combinations, negative option-name aliases, duplicate destinations, special
options, generated callback flags/order and output aliases that change later
node flags. Configured headers must match the host profile; the defaults refer
to the pristine debug baseline.

[Round thirty-six](round36.md) adds 1,536 deterministic nested-provider cases,
bringing the current fixture to 58,258 scenarios per host/locale. A generated
provider recursively installs defaults into another buffer through either an
ordinary or generated inner table. Both buffers, shared setter state, callback
traces and queue levels must match the original oracle. The loop-fusion trials
remain unadopted; these regression cases apply to the unchanged core as well.

## Confirmed prefixes before append

[Round twenty-eight](round28.md) resumes the pre-append length count after an
already confirmed owned prefix. Eligible ordinary assignments record the prefix
they constructed; no additional cache field or native-module interface is added.
The existing mutable-getter loan contract applies.

```sh
python3 Perf/check-append-prefix.py .work/baseline/Src/zsh ./psh \
  --headers-build .work/baseline --headers-source .work/pristine \
  --memcheck --output .work/logs/append-prefix.json
```

This compares complete states in native/ksh/sh emulation, including 17 initial
lengths, repeated append, deletion, sparse/key-value writes, scope restoration,
uniqueness, readonly/tied/special fallbacks, cache churn and native getter loans
that truncate a previously cached vector before further append. Its fixture
uses public APIs and is compiled against the selected matching SDK. Continue
running `check-array-cache.py --memcheck` for the existing ordinary-malloc and
Memcheck lifetime/realloc cases, plus upstream and required OMZ checks.

## Native string hashing investigation

[Round twenty-nine](round29.md) rejects two grouped-hashing prototypes after
actual installed-build customer measurements. The original hash function and
current twenty-six accepted optimizations remain in use.

```sh
python3 Perf/check-hash-module.py .work/baseline/Src/zsh ./psh \
  --memcheck --output .work/logs/hash-values.json
python3 Perf/hash-benchmark.py /path/to/reference/psh /path/to/trial/psh \
  --cpu 2 --output .work/logs/hash-timing.json
```

The native fixture compares 538,428 inputs per host/locale against the original
release recurrence, including all nonzero one/two-byte strings at eight offsets,
selected triples, exact allocations, protected/read-only mappings, long keys and
embedded NULs. It checks unchanged errno. Default headers come from the pristine
build; use `--headers-build` and `--headers-source` for another matching SDK.
The performance driver prepares its fixture before sampling, checks unsigned
checksums, and uses nine alternating fresh processes per key length. Its timers
cover repeated hot native calls; they exclude allocation, module loading and
interpreter dispatch. Measure the actual installed builds and customer kernels
before adopting a faster microbenchmark.

## Decimal lexer investigation

[Round thirty](round30.md) rejects decimal classification/conversion fusion after
mixed installed-build customer results. Production arithmetic is unchanged.

```sh
python3 Perf/check-math-small-module.py .work/baseline/Src/zsh ./psh \
  --candidate-headers-build .work/candidate --candidate-headers-source . \
  --memcheck --output .work/logs/math-tokens.json
python3 Perf/math-token-benchmark.py /path/to/reference/psh /path/to/trial/psh \
  --cpu 2 --output .work/logs/math-token-timing.json
```

The native fixture makes 1,677,760 counted API observations per host/locale.
It compares numeric bits, argument endpoints, arithmetic globals, errno and
floating-point exceptions under four rounding modes, option combinations and
live character-table mutations. It checks exact allocations and terminators
beside inaccessible pages. Each host's fixture must use its matching SDK;
DEBUG and release headers can produce different signal-queue references.
`--headers-build`/`--headers-source` select the reference SDK and the candidate
defaults to that SDK unless explicitly overridden. These are test-only internal
API calls, not a new supported module interface.

The timing driver uses nine alternating fresh processes for thirteen literal
forms in normal and FORCEFLOAT modes. Timers cover warm shell repeat batches,
excluding definition and warmup; they include interpreter dispatch. Result
fingerprints must match. These controls do not replace customer measurements.

## Arithmetic descriptor lifetime investigation

[Round thirty-one](round31.md) retains three unadopted private trials involving
descriptor allocation and inlining. No new package or activation is produced.

```sh
python3 Perf/math-compare.py .work/baseline/Src/zsh ./psh \
  --syntax --operators --descriptors --output .work/logs/math-descriptors.json
python3 Perf/math-compare.py /path/to/reference/psh /path/to/trial/psh \
  --descriptors-only --memcheck --timeout 600 --locale C.UTF-8 \
  --output .work/logs/math-descriptor-memory.json
```

`--descriptors` extends the existing corpus with repeated scalar, integer, array
and hash lookups, recursive callbacks, retyping, side-effecting subscripts,
short-circuit cases and nested assignments. `--descriptors-only` selects that
focused extension and its callback setup. Each expression runs in native, ksh
and sh modes with four option configurations, preserving subshell isolation.
Results, variable state, callback traces, diagnostics and completion counts must
match between hosts. The full combined corpus has 38,472 comparisons per locale;
the focused extension has 2,292. The combined corpus deduplicates expressions
that also appear in its existing cases.

`--memcheck` instruments both hosts and their forked subshells, disables leak
checks and rejects any reported memory error. Quiet Memcheck logs must be empty;
completed state comparisons are required too. `--timeout` bounds each host and
locale, defaulting to 300 seconds. Instrumented forks can make the broad corpus
exceed that limit. An incomplete timeout is not a passing memory receipt; retain
it separately when using the focused extension or a longer explicit allowance.

## Structural scope and power scaling

[Round thirty-two](round32.md) measures existing algorithms without changing the
production shell. `scope-observer-module.c` reads the visible parameter table
under queued signals without invoking parameter getters. Compile it against the
measured host's matching SDK before timing:

```sh
mkdir -p .work/scope-observer
cc -O2 -g -shared -fPIC -DMODULE -DHAVE_CONFIG_H \
  -I/path/to/matching/core/Src Perf/scope-observer-module.c \
  -o .work/scope-observer/psh_scope_observer.so
python3 Perf/scope-scaling.py /path/to/psh \
  --module-dir .work/scope-observer --cpu 2 --output .work/logs/scope-scaling.json
python3 Perf/scope-customer-scaling.py /path/to/psh \
  --module-dir .work/scope-observer --labs /path/to/labs --cpu 2 \
  --output .work/logs/scope-customer.json
python3 Perf/power-scaling.py /path/to/psh \
  --cpu 2 --output .work/logs/power-scaling.json
```

For a separate build/source layout, also add the matching source `Src` include
directory. DEBUG and release SDKs can differ in signal-queue references. The
observer reports all visible table nodes, including unset placeholders, excludes
hidden shadow-chain nodes and is used only in isolated test processes.

The scope driver runs nine rotated/reversed samples for dense and emptied
namespaces, loop-only/empty/local/emulation/nested cases, and checks table and
binding restoration outside its timers. The project wrapper adds either zero or
512 globals before unchanged coder/chat paste kernels, with identical result
states. This measures namespace sensitivity, not an achieved speedup or a full
application session. Setup and final observations are outside warm timers.

The power driver uses bases 0/1/-1 and nonnegative exponents to avoid overflow.
Expected results and state hashes are checked. All raw samples and input hashes
remain in JSON. Keep timing separate from builds, checks and profilers; the
reported costs do not measure an optimized replacement.

[Round thirty-three](round33.md) implements and shelves logarithmic integer
powers after repeated installed customer regressions. The unapplied source and
upstream test blocks live under `results/round33/initial/`; the installed shell
retains its preceding implementation. Two new drivers remain useful:

```sh
python3 Perf/check-power-module.py /path/to/reference/psh /path/to/trial/psh \
  --headers-build /path/to/reference/build \
  --headers-source /path/to/reference/source \
  --candidate-headers-build /path/to/trial/build \
  --candidate-headers-source /path/to/trial/source \
  --memcheck --output .work/logs/power-check.json
python3 Perf/power-benchmark.py /path/to/reference/psh /path/to/trial/psh \
  --cpu 2 --output .work/logs/power-timing.json
```

The native fixture compiles separately against each host SDK and runs only in
fresh child shells. It checks values/types, compound assignments, arithmetic
globals, errno and FP exceptions under four rounding modes. Its independent
integer oracle uses unsigned repeated multiplication; wrapping observations on
the tested builds do not define portable signed C overflow. `--huge` adds
candidate-only closed-form checks and should be used only with a trial known to
handle very large exponents efficiently. Leave it off for the current linear
implementation. The common matrix has 60,832 observations per host/locale;
the huge matrix adds 160 per candidate/locale. Memcheck disables leak checks.

The timer retains nine alternating samples, worker/binary hashes and result
states for bounded small powers, large integer powers and unchanged floating
controls. Its warm batches include parsing/dispatch; the very short optimized
large-exponent batches are not general shell speedups. Run native compilation,
tests and profiling before timing, never alongside it.

[Round thirty-four](round34.md) tests and shelves a live-level scope scanner.
The native fixture exercises actual `endparamscope()` calls with independent
callback-sequence expectations, including promotion/demotion, successor mutation,
generated providers, special restoration, queue nesting and growth suppression:

```sh
python3 Perf/check-scope-cleanup-module.py /path/to/reference/psh /path/to/trial/psh \
  --headers-build /path/to/reference/build --headers-source /path/to/reference/source \
  --candidate-headers-build /path/to/trial/build --candidate-headers-source /path/to/trial/source \
  --memcheck --output .work/logs/scope-check.json
python3 Perf/scope-pair-benchmark.py /path/to/reference/psh /path/to/trial/psh \
  --baseline-module-dir /path/to/reference/observer \
  --candidate-module-dir /path/to/trial/observer \
  --cpu 2 --output .work/logs/scope-pair.json
```

The callback matrix has 1,008 scenarios per host/locale and runs only in fresh
child shells. Compile each observer separately against its matching SDK using
the round-32 command before timing. The paired timer reuses `scope-workload.zsh`,
alternates hosts, rotates/reverses all 42 cases over nine samples and verifies
table/binding restoration. Warm timing includes dispatch/body work; setup,
warmup and native observations are excluded. All dense/sparse/loop controls
remain. No localization journal, new scope scanner or native ABI change is
adopted; the unapplied proposal is retained under `results/round34/`.

[Round thirty-five](round35.md) adopts indexed parameter-scope buckets and
extends the native fixture to 1,092 scenarios per host/locale. The earlier
round-34 count describes that historical fixture. Current native checks can
exercise opt-in, legacy and opaque-constructor modes:

```sh
python3 Perf/check-scope-cleanup-module.py /path/to/reference/psh /path/to/new/psh \
  --headers-build /path/to/reference/build --headers-source /path/to/reference/source \
  --candidate-headers-build /path/to/new/build --candidate-headers-source /path/to/new/source \
  --aware --memcheck --output .work/logs/indexed-scope.json
```

Leave off `--aware` to exercise an unacknowledged module. Add `--opaque` to
preload a constructor which changes a parameter's level without notification;
the later aware module must retain legacy behavior. The matrix uses standard
hash keys chosen for controlled bucket order and adds promotion into a later
previously unmarked bucket. It also compares errno.

`scope-observer-module.c` opts in as a read-only observer and adds the diagnostic
`psh-scope-tracking` builtin. Its normal JSON shape stays unchanged for the
paired timer. `scope-growth.zsh` tests actual rehashing, retained capacity,
caller locals and name reuse under Memcheck. `scope-load-signal-module.c`
supports the signal-unload lifecycle test; these are isolated test modules,
not additions to the installed shell's builtins. The SDK cooperation contract
and fallback are documented in [COMPATIBILITY.md](../COMPATIBILITY.md).
