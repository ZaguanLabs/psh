# Round twenty-four: reuse array prefixes for forward search starts

The twenty-second accepted optimization avoids repeatedly walking an already
validated pointer prefix to locate a forward array pattern-search start.
`getarg()` reuses the existing round-twenty-two metadata, validates any remaining
prefix once, and then runs the original matching loop. Pattern compilation,
arithmetic flag evaluation, occurrence counting, captures and subsequent value
retrieval keep their order. No pattern results or parameter values are cached.

The [incremental patch](0024-forward-search-prefix-reuse.patch) applies after
`9d710a9d617d4458afd166577fe40d98b11140d7`. The project stays **1.0.0-rc0**.
The existing native ownership contract applies unchanged; no new public layout,
exported symbol, array representation or intended language difference is added.

## Measured source path

A line-level profile of the author's JSON validator attributes **504,252,054
instructions**, 12.6% of the whole process, to the loop that walks from the
array beginning to the requested forward-search start. A fresh profile of the
actual preceding release, `1.0.0-rc0-ea2b25dd07ef`, confirms the workload cost.

Round five removed the up-front full length count but still walked every
preceding pointer for a distant positive start. The round-twenty-two cache
already establishes that a named, interpreter-owned vector contains a prefix
of non-null entries. Reusing that fact avoids revisiting those entries.
A first cold query never counts beyond its requested start.

## Ownership, bounds and callbacks

Eligibility is captured **before** retrieving the array, so a custom getter
that changes its accessors cannot turn its returned snapshot into an owned
vector. The path requires a forward search, normalized start at least 64,
already queued signals, an eligible ordinary standard-GSU array, and the live
vector identity matching `pm->u.arr`. Special/tied/hash-element parameters,
anonymous temporaries, mutable native loans and different snapshots retain
scanning. Small, backward and negative-start searches retain the original path.

The helper starts from the smaller of a cached confirmed prefix and the desired
position. Otherwise it walks to the requested position or terminator once.
It records only entries actually confirmed non-null, without reducing a larger
existing bound. The terminator still yields the original length-plus-one
missing result; out-of-range queries do not pay a speculative full scan plus
another fallback walk. Requested starts remain `zlong`; only confirmed metadata
that fits its existing unsigned field is stored. No requested-start narrowing
or unchecked pointer jump is introduced.

The same setter/destructor invalidation, persistent native-loan marker and
64-slot/1,536-byte metadata table remain in use. Metadata is updated before
matching, not after arbitrary matcher/capture activity. No queue/unqueue call
or signal-delivery boundary is added. The 64-entry start cutoff is a performance
heuristic, separate from the table size, not a header/cache-line assumption.

The native [array ownership contract](../COMPATIBILITY.md#native-array-ownership)
continues to require getters for mutable vector loans and setters for ownership
transfer. This optimization does not certify raw field bypasses or independently
compiled Zsh modules. Matching-SDK bundled modules are rebuilt and tested.

## Measurements

Ryzen 9 5950X, Mageia x86-64, GCC 15.2.0, release assertions disabled,
`-O2 -g`, explicit `LDFLAGS=-g`, multibyte/PCRE enabled. The immutable reference
is the preceding commit, with the same configuration and private runtime.
Nine alternating fresh-process samples per binary per run, CPU 2, C.UTF-8.
Own builds, tests and profilers were idle during timing. Setup and warm-up
precede the warm timers; reset costs retain the existing workload definitions.
Every state/output comparison matches. These are offline function batches,
not application-startup, terminal-frame, GPU or network measurements.

### Customer libraries

| Operation | First before → after ms/call | Repeat before → after ms/call |
| --- | ---: | ---: |
| zjson-array | 98.390 → 89.947 | 99.722 → 91.575 |
| zjson-encode-array | 208.591 → 208.013 | 209.787 → 206.288 |
| zjson | 97.068 → 86.956 | 97.581 → 87.660 |
| navigation | 1.892 → 1.853 | 1.874 → 1.855 |

JSON array parsing warm duration falls **8.6% and 8.2%**; validation falls
**10.4% and 10.2%**. Encoding and navigation improve less and are not attributed
to eliminated start walks individually.

### Complete customer kernel matrix

| Kernel | First before → after ms | Repeat before → after ms | Repeat ratio |
| --- | ---: | ---: | ---: |
| zcoder.zsh/coder-paste | 113.092 → 111.530 | 116.165 → 114.490 | 1.01x |
| zcoder.zsh/coder-layout | 5.520 → 5.535 | 5.507 → 5.534 | 1.00x |
| zcoder.zsh/coder-wide-layout | 63.014 → 63.247 | 63.383 → 63.376 | 1.00x |
| zchat.zsh/chat-paste | 209.361 → 202.917 | 209.811 → 204.189 | 1.03x |
| zchat.zsh/chat-layout | 5.486 → 5.475 | 5.521 → 5.534 | 1.00x |
| zchat.zsh/chat-wide-layout | 62.834 → 63.067 | 63.617 → 63.614 | 1.00x |
| endgame/endgame-world | 42.798 → 43.342 | 43.255 → 43.827 | 0.99x |
| z3dfx.mario/mario-race | 19.752 → 19.701 | 20.341 → 20.120 | 1.01x |
| z3dfx/shooter-step | 11.560 → 11.519 | 11.721 → 11.648 | 1.01x |
| z3dfx.agy/shooter-step | 11.549 → 11.430 | 11.781 → 11.550 | 1.02x |
| z3dfx.grok/shooter-step | 11.520 → 11.464 | 11.656 → 11.689 | 1.00x |
| zfetch/fetch-encode | 13.224 → 13.209 | 13.064 → 13.298 | 0.98x |
| z3dfx.drawing/drawing-binning | 12.635 → 12.711 | 12.555 → 12.753 | 0.98x |

Coder paste improves about 1.4%; chat paste about 2.7–3.1%. Wide layouts stay
close. **Endgame is 1.3% slower in both runs**, while drawing is **0.6% and 1.6%
slower**. Repeated URL encoding is 1.8% slower; its first run stays close.
These slower controls are part of the adoption tradeoff. The new search
algorithm does not explain every small whole-binary timing shift; code layout
and other causes of the simulation differences were not isolated. No aggregate
application score or universal speedup is claimed.

### Parser controls

| Operation | Before ms/call | After ms/call | Ratio |
| --- | ---: | ---: | ---: |
| html-comment-1m | 125.070 | 124.002 | 1.01x |
| html-prose-100k | 127.304 | 125.083 | 1.02x |
| json-repair-100k | 18.556 | 18.756 | 0.99x |
| html-clean-128 | 98.332 | 97.525 | 1.01x |

Malformed-UTF-8 JSON repair is about 1.1% slower. The other three parser controls
improve modestly in this run; no direct start-walk mechanism is assigned to them.

### Search controls

| Case | Before ms/batch | After ms/batch | Ratio |
| --- | ---: | ---: | ---: |
| tiny-first | 16.330 | 16.314 | 1.00x |
| first | 1.658 | 1.658 | 1.00x |
| middle | 12.598 | 12.328 | 1.02x |
| last | 24.772 | 24.350 | 1.02x |
| missing | 25.166 | 24.527 | 1.03x |
| start-middle | 22.645 | 0.832 | 27.22x |
| start-last | 44.468 | 0.838 | 53.06x |
| start-beyond | 44.268 | 0.795 | 55.68x |
| negative-start | 17.888 | 17.765 | 1.01x |
| backward | 17.773 | 17.799 | 1.00x |

Repeated distant-start batches improve about **27–56x** after warm-up. This
includes missing starts beyond the end: once its prefix has been validated,
the next probe reaches the terminator directly. The first discovery still
walks the prefix. Matching a long suffix remains linear, and these ratios are
not whole-parser or whole-application speedups. Negative/backward controls stay
close. Every sample is retained.

## Instruction and hardware evidence

Matched Callgrind totals include setup, first discoveries and warm-up too.
Source and final state hashes match in each pair.

| Library profile | Before instructions | After instructions | Reduction |
| --- | ---: | ---: | ---: |
| json-validate | 3,992,875,434 | 3,490,322,920 | 12.59% |
| json-encode | 2,877,097,951 | 2,877,017,949 | 0.00% |

The raw profiles, flat reports and annotated original source lines identify the
removed start walk; instruction totals are not treated as wall times.

The Linux counter launcher measures user-space events from exec through exit,
including inherited tasks and preparation. This differs from warm timers.

| Kernel | Before cycles | After cycles | Cycle reduction | Instruction reduction |
| --- | ---: | ---: | ---: | ---: |
| zcoder.zsh/coder-paste | 714,725,355 | 704,749,326 | 1.40% | 0.01% |
| endgame/endgame-world | 413,759,686 | 414,534,572 | -0.19% | 0.01% |
| z3dfx.mario/mario-race | 190,332,364 | 189,161,041 | 0.62% | 0.02% |
| z3dfx.drawing/drawing-binning | 168,803,553 | 170,252,322 | -0.86% | 0.04% |

All events were fully scheduled. Endgame/drawing cycle medians are slightly
higher despite slightly lower instruction counts, consistent with retaining
those slower controls rather than claiming an across-the-board improvement.

## Compatibility and memory checks

- GCC and Clang release candidates each pass **63 upstream scripts, zero
  failures, two expected skips**; the preceding Clang build also passes.
  The refreshed debug development build passes **62 scripts, zero failures,
  three expected skips**, with PCRE disabled by its configure defaults.
- The extended search corpus passes **362,580 byte/status/capture comparisons
  per pair**, in GCC release, Clang release, debug development and the exact
  installed pair. Its additional 169,344 checks repeat cold/warm searches with
  sizes 63/64/65/127/128/129/1024, forward/backward/index/value flags, occurrences,
  captures, Meta/NUL strings, native/ksh/sh modes, multibyte on/off, and starts
  including **2^32−1, 2^32 and the signed 64-bit maximum**. Default small/scalar
  cases are retained rather than being replaced by the new cases.
- The large boundary corpus also matches under **168 Memcheck processes**,
  **169,344 comparisons**. Zero memory errors; leak checks disabled. The driver
  binds binaries, generated scripts, completion markers and output bytes.
- The reference-SDK native loan/mutation fixture passes **48 processes per
  pair**, with ordinary malloc and Memcheck, for those same four host groups.
  New searches are checked before/after temporary shortening, cache eviction,
  same-vector setters and in-place/moved append reallocations. Getter,
  `getaparam()` and whole-array `getarrvalue()` loans preserve the expected
  missing index after shortening. Mutation probes include forward index/value
  searches alongside replacement, deletion, shift, unique/formatting attributes,
  local shadows, unset/recreation and transient scopes. Zero Memcheck errors.
- GDB checks three unqueued search conditions leave all cache entries unchanged,
  including after a queued search has populated one. GCC/Clang, development and
  the exact installed executable pass. Public custom-getter/search fixtures
  retain **20 expected callback/snapshot cases**; no getter call is removed.
- Other GCC groups retain **110,100 arithmetic syntax**, **704,585 scalar**,
  **5,192 array/append**, **159,600 pattern**, **2,640 substitution**, 36 PTY
  completion buffers and **200,832 native numeric scenarios** under Memcheck.
  Twenty-four customer kernel/locale states and five original project suites
  match the preceding shell.
- All **1,056 dynamic exported names/types** remain. No public structure or
  native ownership change is introduced. The existing 1,847-file pristine
  snapshot remains verified; new tests use the preceding psh or the appropriate
  original debug reference, not an arbitrary distribution build.

Two fixture/setup failures are retained: an early launch preceded creation of
its generated build driver, and the new mutation probe initially used `$n`
inside an arithmetic start flag. The reference shell reported that flag syntax
as an error. The probe now uses the arithmetic variable name `n`; failed logs
remain, and the successful receipts bind the corrected fixture. Neither was
classified as a psh behavior regression.

These checks establish coverage, not universal compatibility for every native
extension, signal schedule or platform. No-multibyte and other operating-system
configurations are not newly certified by this round.

## Installed daily driver

The isolated package **`1.0.0-rc0-1ad2ab786b8a`** is active through
`/usr/local/bin/psh`. Its stripped executable remains **846,488 bytes**, with SHA-256
`1e26b9729f70cb819b662b2e101527950905ff796455af96af70b4abe0a59436`.
The preceding `ea2b25dd07ef` release remains available for rollback.

All seven package suites pass, including 190 zdraw tests. Normal-user package
verification passes the installed component checks, genuine login PTY checks
and **24 unchanged Oh My Zsh sessions** with the user's existing theme, git
plugin and syntax highlighter. The installer consumes the matching certificate
before activation. Post-activation inventories confirm **11,828 stable Zsh and
startup entries**, **1,604 preceding-release entries**, `/etc/shells` and the
account login shell remain unchanged.

The rc0 version, original annotated tag and draft checkpoint remain in place;
this private iteration does not publish a release or replace draft assets.

[All evidence](results/round24/) retains gains, slower controls, failures and
source/binary hashes. Arithmetic parsing, remaining JSON scans and scope-table
walks remain future profiling targets. The interpreter audit remains incomplete.
