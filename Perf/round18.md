# Round eighteen: unfiltered hash scans, not adopted

**Both specializations were rejected.** They reduce scanner instructions but
give small, mixed results in the customer's apps. The source and development
executables are restored to round seventeen. The installed daily driver remains
`5.9.2-38c0e71e2244`; this investigation introduces no production optimization.

## Why investigate this path

After round seventeen, `scanmatchtable()` accounts for about 6.1% of zcoder
paste instructions and 10.3% of zchat paste instructions. Source annotation
shows unfiltered walks through the parameter and option tables. The sampled
runs call `scanhashtable()` 20,023 and 60,051 times respectively, making about
3.86 million and 11.55 million callbacks. Parameter-scope cleanup and option
emulation are the main callbacks in those runs.

The generic scanner tests two flag masks and an optional pattern per entry.
Those tests are unnecessary when both masks are zero and no pattern is supplied.
The investigation tries selecting an unfiltered loop once per call, preserving
the scan-status pointer and successor updates used by callback mutations.

Two prototype patches are retained for review:

- [Matcher split](results/round18/filter-hoist-source.patch): select an
  unfiltered loop inside the unsorted branch of `scanmatchtable()`.
- [Wrapper loop](results/round18/wrapper-source.patch): retain the generic matcher
  and specialize `scanhashtable()` for unsorted, unfiltered, non-generated tables.

Neither changes hash values, bucket/node order, table representation or public
interfaces. Module-generated table delegation stays on its original path.
The prototypes passed the focused checks below; they were rejected on
performance evidence. Neither patch is applied to the project source.

## Customer measurements

AMD Ryzen 9 5950X, Mageia Linux x86-64, GCC 15.2.0, `-O2 -g`, multibyte support
and debug assertions. Nine alternating fresh-process samples per build,
pinned to CPU 2 in C.UTF-8. Own builds, tests and profilers were idle during
timing. Every output/state comparison matches. Source and binary hashes and
all samples are retained in [the results](results/round18/).

Each prototype has its own paired baseline samples. The cells below show
previous → trial medians in milliseconds per complete batch. Baseline values
from different runs are not substituted for one another.

| Operation | Matcher split: previous → trial | Wrapper loop: previous → trial |
| --- | ---: | ---: |
| zcoder.zsh/coder-paste | 116.612 → 115.582 | 117.577 → 118.649 |
| zcoder.zsh/coder-layout | 5.824 → 5.803 | 5.786 → 5.795 |
| zcoder.zsh/coder-wide-layout | 94.409 → 95.447 | 94.675 → 95.208 |
| zchat.zsh/chat-paste | 214.671 → 217.045 | 209.956 → 210.011 |
| zchat.zsh/chat-layout | 5.890 → 5.908 | 5.826 → 5.926 |
| zchat.zsh/chat-wide-layout | 97.240 → 98.149 | 95.354 → 96.618 |
| endgame/endgame-world | 48.492 → 48.442 | 48.020 → 47.575 |
| z3dfx.mario/mario-race | 29.602 → 29.660 | 28.968 → 29.003 |
| z3dfx/shooter-step | 15.355 → 15.275 | 14.936 → 14.856 |
| z3dfx.agy/shooter-step | 15.076 → 15.160 | 14.909 → 14.967 |
| z3dfx.grok/shooter-step | 15.175 → 15.339 | 14.896 → 14.834 |
| zfetch/fetch-encode | 13.240 → 13.506 | 13.151 → 13.486 |
| z3dfx.drawing/drawing-binning | 14.742 → 14.852 | 14.664 → 14.551 |

The matcher split makes zcoder paste **0.9% faster** and zchat paste **1.1%
slower**. The wrapper makes zcoder paste **0.9% slower**, while zchat paste is
nearly unchanged. URL encoding is about **2.0% slower** with the matcher split
and **2.5% slower** with the wrapper. Other customer changes are small and mixed.
These are actual offline project functions, not complete interactive sessions,
startup or terminal painting. There is no aggregate score.

Warm application calls, milliseconds per call:

| Operation | Matcher split: previous → trial | Wrapper loop: previous → trial |
| --- | ---: | ---: |
| zjson-array | 100.231 → 99.003 | 100.136 → 100.790 |
| zjson-encode-array | 218.731 → 215.766 | 216.839 → 212.802 |
| zjson | 98.311 → 96.650 | 96.377 → 96.249 |
| navigation | 2.237 → 2.248 | 2.205 → 2.162 |

Warm parser/library calls, milliseconds per call:

| Operation | Matcher split: previous → trial | Wrapper loop: previous → trial |
| --- | ---: | ---: |
| html-comment-1m | 132.515 → 130.014 | 133.183 → 133.768 |
| html-prose-100k | 131.291 → 131.002 | 132.127 → 130.038 |
| json-repair-100k | 20.036 → 19.959 | 19.829 → 19.815 |
| html-clean-128 | 101.881 → 100.490 | 100.680 → 100.200 |

Some library medians improve by roughly 1–2%; others remain flat or regress.
That does not establish a clear enough benefit to adopt either variant for the
first customer's workloads. The pilot's approximately 2% zcoder paste gain did
not persist at that size in the full run. The pilot is retained too.
All 31 scalar count/slice controls for each prototype remain in the two
`*-slice-benchmarks.json` files, including every slower sample and control.
No separate cause was isolated for the small wall-time differences.

## Instruction profiles

Matched Callgrind runs include startup, loading, construction and warm-up:

| Kernel / build | Total instructions | Combined scanner self instructions |
| --- | ---: | ---: |
| coder / previous | 1,440,165,752 | 87,899,879 |
| coder / filter-hoist | 1,408,147,547 | 55,402,710 |
| coder / wrapper | 1,407,268,102 | 55,002,250 |
| chat / previous | 2,486,024,155 | 255,936,879 |
| chat / filter-hoist | 2,388,097,611 | 158,414,510 |
| chat / wrapper | 2,387,300,727 | 157,213,490 |

The matcher split reduces total instructions by **2.2% for zcoder** and **3.9%
for zchat**; the wrapper reduces them by **2.3%** and **4.0%**. Combined scanner
self instructions decrease by about 37–39%. Both scanner functions are counted
because the wrapper variant moves work from one function to the other.

These profiles establish less scanner bookkeeping. Instruction counts are not
cycles, and their measurement boundaries differ from the warm-call timers.
The customer wall-time results remain the adoption criterion.
[Commands, environments, binary/source hashes and matching output state](results/round18/accepted-profile-commands.json)
are retained with compressed raw profiles and flat reports. The `accepted-`
filename prefix comes from the profiling harness; neither candidate is adopted.

## New regression coverage

The [public-API native fixture](hash-scan-module.c) uses pristine configured
headers and public table operations. Its expected callback sequences and
return counts are specified independently of either prototype loop.

**1,924,992 scenarios across 16 Memcheck processes pass, with zero memory
errors**, leak checking disabled. These runs cover pristine and prototype
hosts, the installed daily driver, and matching-header no-multibyte builds,
in C and C.UTF-8. Each host/locale runs 120,312 scenarios across both runtime
multibyte settings and queued/unqueued contexts.

Coverage includes 23 table sizes from 1 through 257, empty/sparse/dense/colliding
tables, sorted/unsorted scans, both public scan APIs, nine flag-mask pairs,
five pattern states and three callback-flag values. Callback tests delete or
replace the current entry or a successor, add entries in current/future buckets,
change selection flags during filtered scans, suppress resizing while scanning,
and verify that later insertion can resize again. Sorted controls cover
current removals and replacements. A read-only nested scan is also covered;
this is not a guarantee for unrestricted mutation across nested scans.

Generated-table cases verify delegation, ignored masks/sorting when no pattern
is supplied, the released return-count behavior, and ordinary filtering when
a pattern is supplied. Callback traces, generations, flags, final membership,
return counts and signal-queue levels are checked.

The standalone [scope regression](hash-scope.ztst) tests 129 shadowed/unset
locals through nested scopes, temporary-parameter removal, array/hash type
restoration and exported values. It passes on pristine Zsh, round seventeen,
both prototypes and the installed host. The existing B02 typeset and V10 private
parameter scripts also pass on all five hosts: **15 script runs, no skips**.
This round ran these focused checks; it did not rerun the full bundled suites.

## Restored state

All **1,847 pristine source hashes** and the previous snapshot are verified.
All current packaged core inputs match the active round-seventeen build's
fingerprint. Both prototypes and the restored host retain **1,055 exported
names/types**; seven generated public declaration files match pristine headers.
The checked `.text`, `.rodata` and `.data` sections of the rebuilt original
source match the accepted executable. The development executables were then
restored byte-for-byte from the accepted snapshot.

The existing installed-package verification passes again, including component
loading, native change-gutter rendering and login startup. Its suite receipts
are from the round-seventeen installation. The installed payload manifest,
**11,828 protected Zsh/startup entries**, account login shell and `/etc/shells`
remain unchanged. No installer or activation was run in this investigation.

[Restoration, API totals, profiles and protection proof](results/round18/proof.json)
and the raw validation logs are retained. This is a focused review of two
scanner paths, not a complete source audit. Parameter-scope teardown still
walks the full table; its asymptotic cost is unchanged.

To run the new native checks after [building the reference trees](README.md):

```sh
python3 Perf/check-hash-scan-module.py .work/baseline/Src/zsh ./psh \
  --memcheck --output .work/logs/hash-api.json
```

For a no-multibyte host, pass its matching `--headers-build` directory.
The scope case uses the normal upstream `.ztst` format; the saved validation
driver records the exact test-runner commands for all five hosts.
