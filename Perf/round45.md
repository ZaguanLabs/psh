# Round 45: stop bounded array copies at their requested limit

The parent is `86e4a66`. This round follows a measured cost in the user's zjson
object parser instead of extending the previous glob change. The baseline is
release `1.0.0-rc1-fcff3fb31d43`, SHA-256
`95998d2dd8b1ee105777fc942d5bdfdb3239b64dd60e57f0b974f3569c6f4e77`.
The candidate is `1.0.0-rc1-345edd03d312`, SHA-256
`46603868a3b9576e4ecc1cd79d35fb1aa49954fe66a61ab6f0234bdde524c0f4`.
Both are GCC 15.2 release-profile PGO+LTO builds, 883,312 bytes. The active rc0,
stable Zsh, startup files and account login shell are unchanged.

## Cost and bounded change

`getarrvalue_internal()` calls `arrdup_max()` to copy a selected array range.
Despite its maximum argument, the helper previously called `arrlen()` on the
entire remaining array before copying the requested prefix. Repeated small
slices therefore paid for scanning many pointers that would never be copied.
The real zjson parser materializes small ranges of its `ZJSON_CHARS` array for
string and number tokens. Counting the rest of that document for each token is
the relevant repeated work; no user script is rewritten to obtain the gain.

The new counting loop stops at the earlier of the requested maximum and the
NULL terminator. For length N and limit M, both implementations allocate and
duplicate exactly `min(N, M)` elements, in the same order. Only the counting
work changes, from O(N) to O(min(N, M)). Starting-index normalization, negative
indices, getters, allocation size, string duplication and heap ownership remain
unchanged. There is no cache or new representation.

Limits greater than INT_MAX retain the original full-length path, including
the native UINT_MAX sentinel case. This preserves the existing signed length
calculation for oversized native requests and prevents the bounded loop's signed
counter from overflowing. The zero limit still reads no source element. All
1,070 dynamic symbols and the existing native interface remain unchanged.

## Current-release profile

A fresh Callgrind run of `object-workload.zsh zjson-object ... 1` on the installed
baseline records 2,554,921,835 instructions. `arrlen()` contributes 250,015,479
self instructions; 250,015,472 come from 8,006 calls by `arrdup_max()`.

The exact candidate records 2,305,299,498 instructions, **9.77% fewer** for the
complete process. Both processes include source loading, fixture construction,
warmup, the operation and validation. Complete result-state bytes match after
discarding the elapsed-time line; their SHA-256 is
`11b44c12f947778364f10fbb21cf9e9db72a17c70df41b3c58b905dcd29302df`.
These instruction counts explain the target, not an elapsed-time speedup.

## Compatibility checks

Before editing the production helper, `check-array-copy.py` compares pristine
5.9.2 and the accepted psh. The native fixture builds with pristine headers and
checks 429 copy invocations per locale: lengths from zero to 16,384, offsets at
the start/middle/terminator, zero/small/full/oversized maxima, INT_MAX and
UINT_MAX. It checks exact contents, NULL termination, a separate pointer vector
and separately owned strings by mutating source strings after duplication.

The shell matrix has 48 groups per locale, each checking 36 slices. It covers
plain, unique, tied and special arrays under zsh/sh/ksh emulation, both C and
C.UTF-8, empty values, whitespace, newline, NUL, invalid bytes and Unicode.
Thus each host has 3,456 shell-slice observations and 858 native-copy checks
across the two locales. The final three-host run uses Memcheck and compares
complete byte output, diagnostics and status against both reference hosts.

The focused timer's first smoke check incorrectly expected an empty array for
a quoted range beyond the end. Pristine/accepted Zsh instead return one empty
element for that tested two-position range. The expectation was corrected;
the production code was not changed to alter it. The final worker verifies
this result and all 15 benchmark states independently before timing.

The existing broad array matrix and native mutation/cache fixtures provide
additional coverage. The latter retains the explicitly documented pre-existing
raw-array difference and exercises the supported getter migration separately.
No checks are removed or reclassified to permit a new difference.

## Other lead, not changed

The preceding glob profile also identifies an unconditional `VARARR` scratch
allocation in `exalias()`. On this release configuration, VARARR uses Zsh's
heap even though the compiler supports variable-length arrays. The scratch
buffer is used only for tokenized strings, so avoiding unnecessary storage
deserves a separate investigation. ZLE callbacks, token text and pointer-based
restoration rules make that a different ownership problem. No lexer or glob
code changes in this round, and no additional memory improvement is claimed.

The source review is targeted, not exhaustive. Existing packaging/OMZ edits and
the previously sent hash-getter report remain untouched and excluded from this
round's commit. Package provenance includes those existing builder/gate edits.

## Verification and adoption

The candidate is **adopted as the 29th core optimization**, with the performance
costs below retained explicitly. No intentional compatibility difference is
added. The final Memcheck matrix passes all 98 groups on pristine Zsh, preceding
psh and candidate psh. Both 5,192-case array comparisons pass, and the native
mutation/cache fixture passes with its pre-existing raw-alias contract intact.

All seven core/bundled suites pass, including 190 zdraw tests and 63 upstream
scripts with zero failures and two skips. The core suite runs after the other
tests and profilers finish, avoiding the concurrent timing problem encountered
in round 44. Full package verification passes 24 unchanged OMZ sessions and
14 native-library observations, plus component rendering, module isolation and
11,829 protected-entry/account-shell checks. No candidate is activated or
public release published.

## Application gains and costs

Two separate nine-sample runs alternate the exact installed releases on CPU 13,
C.UTF-8. All builds, tests and profilers finish before timing. Warm array-copy
timing excludes construction, validation and output; complete state bytes are
compared. The customer and JSON drivers retain their existing warmup and full
result checks and verify source/binary hashes.

| Workload | First run, previous → candidate | Less time across both runs |
| --- | ---: | ---: |
| zjson, parse 2,000-field object | 177.091 → 162.405 ms/call | 7.1–8.3% |
| zcoder ASCII layout | 5.151 → 4.899 ms/batch | 4.2–4.9% |
| zchat ASCII layout | 5.211 → 4.995 ms/batch | 4.2–5.0% |
| Copy two-element prefix of 32,768-element array | 6.621 → 0.996 ms/1,000 copies | about 85% |

The narrow copy workload is not a general shell speedup. Full 32,768-element
copies take 1.4% more time in the first run and 0.03% more in the second. Across
the three tested sizes, full-copy medians range from unchanged to 1.4% slower.
Negative-index and beyond-end controls are retained unchanged in scope.

URL encoding and drawing binning vary across the first two runs: each has one
roughly 3% slowdown and one small improvement. A focused **21-sample** comparison
records 11.317 → 11.534 ms/batch for URL encoding (**1.9% more time**) and
11.358 → 11.596 ms/batch for drawing binning (**2.1% more time**). These are
measured costs of this release comparison, not dismissed as noise. The repeated
JSON/parser and editor/chat layout gains justify retaining the small change;
it is not uniformly faster across workloads. Other controls, including slower
wide layout, simulation and JSON-encoding cases, remain in the complete table.

See [timings](results/round45/timings.md) and the
[evidence index](results/round45/README.md) for every case, repeat and raw sample.
