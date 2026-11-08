# Round twenty-two: cache confirmed array bounds

The twentieth accepted optimization avoids repeated pointer-list scans when
reading ordinary indexed arrays. A private 64-slot cache remembers a prefix
already validated for a particular parameter and vector. A later query inside
that prefix needs no scan; a query beyond it resumes at the validated boundary
and still stops at the null terminator. It never counts beyond the requested
bound merely to populate metadata.

The [incremental patch](0022-confirmed-array-bounds.patch) applies after
`4d82600983d23820b56be336e687b2cac2af0cea`. Project version remains
**1.0.0-rc0**. This is a private development iteration, not a public release
or a replacement for the original rc0 tag/draft.

## Finding the actual caller

The release-build drawing profile in round twenty-one spent 14.5% of its
instructions in `arrlen_ge()`. Following the call edges showed that its major
caller was `arrlen_le()` during ordinary indexed reads. This was not solely an
array-existence-test cost. The initial `issetvar()`-only sketch is retained;
the measured implementation also covers scalar reads, slice bounds and the
scalar extraction checks in `paramsubst()`.

The ordinary read can validate the same bound once in substitution and again
in `getstrvalue()`. Repeated or ascending accesses then scan the same pointer
prefixes again. The public `arrlen_ge()` and `arrlen()` helpers themselves are
unchanged. Full length expansion, construction, append, negative-index
normalization and many other array operations retain their linear work.

## Ownership and invalidation

The cache occupies 1,536 bytes of static storage on this host and allocates
no memory. Entries contain a parameter pointer, its vector pointer and a
confirmed positive bound. Hash collisions evict entries and cause another
bounded scan. Queries below 64 do not populate an empty entry; an existing
larger confirmed prefix can still serve them. The threshold is a performance
heuristic, not an array-layout or cache-line guarantee.

Eligibility requires the standard immutable GSU descriptor, an ordinary named
array, no special/tied/hash-element flag, no tied name and no mutable native
loan. Anonymous expansion temporaries and custom getter/setter paths retain
scanning. Internal read-only helpers preserve custom getter dispatch/counts;
eligibility is captured before arbitrary callbacks. A cached `Value` snapshot
that differs from the parameter's current vector also falls back to scanning.

Cache reads and publication additionally require an **already queued** signal
region. Unqueued calls, including ordinary `[[ -v ... ]]`, take the scanning
path. No queue/unqueue operation or signal-delivery boundary is added. This
matters because a trap can change arrays or another cache slot; a three-field
entry must not be consumed or published across such an interruption.

The standard setter and parameter destructor invalidate entries. Same-vector
setters invalidate too. Public mutable getters (`getaparam()`, `arrgetfn()` and
whole-array `getarrvalue()`) mark the allocation exposed using private parameter
flag bit 30, `PM_ARRAY_EXPOSED`. The marker lives on the parameter, so eviction
cannot accidentally make a retained native loan cacheable. It survives a
same-vector setter and the append path that temporarily clears `u.arr` before
an in-place realloc/setter. Replacing the allocation can clear the marker;
uncertain cases conservatively retain it. Internal consumers that only read or
copy ordinary vectors use separate helpers.

`struct param` remains 80 bytes and `struct value` 40 bytes in the compared
SDKs, with matching field offsets. All 1,053 preceding release exports remain;
three internal helper symbols are added. Header contents are not claimed
identical: the new flag and generated declarations are explicit additions.

**Native integration constraint:** bypassing both the getters and setter while
changing a vector through a raw `pm->u.arr` alias is unsupported. The negative
control records its differing result and the getter migration in
[COMPATIBILITY.md](../COMPATIBILITY.md#native-array-ownership). The allocation
and tail stay alive in that reproducer. This is an explicit native contract,
not universal compatibility with independently compiled Zsh modules. Supported
mutable loans retain normal scanning; memory corruption and unsafe ownership
remain bugs. The bundled modules use the matching SDK.

## Retained alternatives and setup failures

The first measured prototype counted the full array on a second nontrivial
query, then reused that length. Its wide-editor batches improved substantially,
but an added cold control exposed unnecessary work: two reads at element 64
of a 262,144-element array took **26 → 110 µs**. The corresponding prefix-only
prototype took **26 → 28 µs**. These microsecond medians include the query loop
only, not array construction. They are controls, not application latency.

The intermediate prefix cache answered known bounds but restarted every larger
scan at the beginning. It improved wide layout about 1.2x while leaving much
of the ascending-index work. The selected implementation resumes at the known
boundary, using the same ownership proof required to trust a cached bound.
The variants' samples, slower controls, patches and binary/source
identities remain in [the evidence directory](results/round22/).

The first advancing-prefix build still accessed metadata with signals
unqueued. A debugger audit observed queue level zero in `issetvar()` and
metadata writes during bare `[[ -v ]]` calls. That build was rejected. The
selected guard retains the queued expansion/read benefit and bypasses caching
in those unqueued calls. A debugger regression checks cold and warm conditions:
the rejected binary changes metadata in all three probes; the final binary
changes none. This is concrete boundary evidence, not an exhaustive audit of
every asynchronous trap schedule.

Two early fixture mistakes failed on the reference interpreter: ambiguous
`$i[100]` interpolation and brace expansion disabled by sh emulation. The
fixtures now delimit `${i}` and enable brace expansion for their authored data
while retaining the indexing/emulation options. Original failure logs remain;
these were test-setup failures, not suppressed psh regressions.

## Measurements

Ryzen 9 5950X, Mageia x86-64, GCC 15.2.0 release profile, CPU 2, C.UTF-8. Nine alternating fresh-process samples per binary in each run. Own builds, test suites and profilers were idle during timing. Setup and warm-up precede the warm timers; every state/output comparison passes. Full samples, source/binary/worker hashes and commands are retained. These are offline function batches, not whole-application startup, terminal-visible frame rates, GPU or network measurements.

| Customer kernel | First before → after ms | Repeat before → after ms | Repeat ratio |
| --- | ---: | ---: | ---: |
| zcoder.zsh/coder-paste | 128.189 → 127.079 | 117.975 → 117.616 | 1.00x |
| zcoder.zsh/coder-layout | 6.546 → 5.788 | 5.763 → 5.577 | 1.03x |
| zcoder.zsh/coder-wide-layout | 95.744 → 63.705 | 94.306 → 62.962 | 1.50x |
| zchat.zsh/chat-paste | 211.995 → 217.094 | 211.477 → 217.067 | 0.97x |
| zchat.zsh/chat-layout | 5.733 → 5.483 | 5.701 → 5.517 | 1.03x |
| zchat.zsh/chat-wide-layout | 94.745 → 63.571 | 94.283 → 63.186 | 1.49x |
| endgame/endgame-world | 45.918 → 44.922 | 45.962 → 45.424 | 1.01x |
| z3dfx.mario/mario-race | 20.411 → 20.231 | 20.087 → 20.158 | 1.00x |
| z3dfx/shooter-step | 12.305 → 11.971 | 11.900 → 11.821 | 1.01x |
| z3dfx.agy/shooter-step | 12.040 → 11.882 | 11.772 → 11.819 | 1.00x |
| z3dfx.grok/shooter-step | 11.958 → 12.090 | 11.589 → 11.671 | 0.99x |
| zfetch/fetch-encode | 14.271 → 13.480 | 13.223 → 13.303 | 0.99x |
| z3dfx.drawing/drawing-binning | 14.885 → 12.993 | 14.404 → 12.616 | 1.14x |

Wide zcoder/zchat layout consistently improves about **1.5x**, and drawing **1.14–1.15x**. Ordinary layout improves less; the first zcoder layout baseline is noticeably higher than its repeat, so its initial 13% difference is not presented as a stable effect. Paste gains are not claimed: **zchat paste is 2.4% slower initially and 2.6% slower on repeat**. Grok is about 1.1%/0.7% slower. Repeated Mario, AGY and URL encoding are slightly slower; their first/repeat variation is retained. Endgame wall medians improve slightly, but its executed instruction count is essentially unchanged. No aggregate application score is used.

| Library/parser control | Before ms/call | After ms/call | Ratio |
| --- | ---: | ---: | ---: |
| zjson-array | 104.956 | 106.164 | 0.99x |
| zjson-encode-array | 221.333 | 218.154 | 1.01x |
| zjson | 98.585 | 99.639 | 0.99x |
| navigation | 2.042 | 1.935 | 1.06x |
| html-comment-1m | 126.843 | 126.647 | 1.00x |
| html-prose-100k | 129.998 | 130.537 | 1.00x |
| json-repair-100k | 19.661 | 19.567 | 1.00x |
| html-clean-128 | 101.711 | 101.709 | 1.00x |

JSON array parsing is about **1.2% slower**, validation **1.1% slower**, and prose conversion **0.4% slower**. Encoding and navigation improve in this run; the other parser controls stay close. All results are included in the adoption tradeoff.

| Bound control | Before ms/batch | After ms/batch |
| --- | ---: | ---: |
| cold-shallow-large | 0.026000 | 0.028000 |
| cold-deep-large | 0.125000 | 0.105000 |
| repeated-in-range | 5.094000 | 3.636000 |
| repeated-out-of-range | 0.096000 | 0.099000 |

The shallow-large control stays close at **26 → 28 µs**, rather than paying the full-count prototype’s extra scan. Repeated out-of-range reads are **96 → 99 µs**, about 3.1% slower. These short controls have microsecond resolution and are not application measurements.

All 23 array read/slice/length controls are retained in `final/array-length-benchmarks.json`. The eight-element middle-read batch is **2.547 → 2.687 ms**, about **5.5% slower**; the first-element batch is **4.1% slower**. Empty length is about 2.7% slower. Large out-of-range reads are about 2.1% slower. The large late slice improves **3.369 → 0.252 ms**, while negative-index reads improve **6.486 → 3.522 ms** by avoiding redundant bounds scans after the still-linear negative-index normalization. Full large-array length remains close, **4.495 → 4.509 ms**. The cache adds ownership/lookup checks, so its benefits do not extend to every small or unsuccessful read.

### Hardware and instruction evidence

The Linux launcher counts user-space events from exec through exit, including inherited tasks and setup. This differs from the warm-timer scope. All recorded counter events were fully scheduled.

| Kernel | Before cycles | After cycles | Cycle reduction | Hardware instruction reduction |
| --- | ---: | ---: | ---: | ---: |
| zcoder.zsh/coder-wide-layout | 836,092,422 | 546,146,195 | 34.68% | 46.55% |
| zchat.zsh/chat-wide-layout | 837,442,329 | 544,973,382 | 34.92% | 46.54% |
| endgame/endgame-world | 438,745,882 | 430,514,749 | 1.88% | -0.00% |
| z3dfx.drawing/drawing-binning | 189,129,897 | 170,275,670 | 9.97% | 13.95% |

Matched Callgrind profiles include startup/setup too. Drawing uses three warm iterations; the wide-editor profile uses ten, versus two in its wall/hardware workload. Compare each matched pair, not absolute totals across scopes.

| Profile | Before instructions | After instructions | Reduction |
| --- | ---: | ---: | ---: |
| drawing | 505,759,203 | 435,343,500 | 13.92% |
| coder-wide | 13,130,736,629 | 6,979,074,614 | 46.85% |

Wide-editor self instructions in `arrlen_ge()` fall from **6,177,545,458 to 3,954,218**; drawing falls from **73,449,906 to 620,303**. New cache checks add work in `array_length_ge()` and its callers; the complete-process reductions above include that cost. Compressed raw profiles, flat reports and hashes are retained. Reduced scans support the measured gain; disappearance of a helper name alone is not used as evidence.


## Compatibility checks

The final GCC release candidate is compared with the preceding psh source at
`4d82600`, reconstructed into an immutable source tree. Both use `-O2 -g`,
explicit `LDFLAGS=-g`, multibyte support and disabled debug assertions. This
isolates the incremental change; the original pristine-Zsh evidence remains
historical evidence rather than being relabeled as a fresh comparison.

- GCC 15.2.0 and Clang 20.1.8 candidates each pass **63 upstream test scripts,
  zero failures, two expected skips** on this Mageia x86-64 host. The preceding
  Clang build passes the same suite. This round does not certify other platforms
  or a no-multibyte configuration.
- Final GCC differential groups pass **110,100 arithmetic**, **704,585 scalar**,
  **5,192 array/append**, **193,236 search**, **159,600 pattern** and **2,640
  substitution** comparisons, with recorded encodings/emulations and diagnostics.
- Native accessor/callback fixtures pass **20 cases**; PTY completion checks
  cover **36 buffers**. The numeric API fixture passes **200,832 scenarios**
  across six Memcheck processes in C, C.UTF-8 and French Belgian UTF-8.
- The debugger regression verifies three unqueued probes leave all 64 cache
  entries unchanged, including after a queued expansion has populated one.
  The rejected unguarded binary is retained as the corresponding negative
  control. Existing signal queueing is preserved.
- The array-cache fixture is built against the preceding SDK and loaded by
  both shells. GCC, Clang and the exact installed pair each pass **48 processes**:
  ordinary malloc plus Memcheck, three locales, retained mutable loans and
  mutation scripts in native/ksh/sh modes. The ordinary-malloc runs observe
  three in-place reallocations per lifetime process; Memcheck observes moved
  reallocations instead. Loan safety is checked after warming, 192-array cache
  eviction, temporary shortening, same-pointer setters and append/realloc.
  Mutation coverage includes sparse replacement, deletion, shift, unique and
  formatting attributes, transforms, local shadows, unset/recreation, type
  changes and 500 transient scopes. Memcheck reports zero memory errors;
  leak checking is disabled. The explicit unsupported raw-field negative
  control and its getter migration have separate expectations.
- Twenty-four customer kernel/locale state comparisons match the preceding
  shell, along with five original Endgame/AGY/Grok suites. Timed customer and
  library states and parser output bytes match too.

## Installed daily driver

Private release **`1.0.0-rc0-ac4028c278e1`** is active through `/usr/local/bin/psh`.
The installed executable SHA-256 is
`4f5adb8cfd11c89a081ab4903d45f427c8003057b03189eb2eb905e7e1badd39`.
It remains **846,488 bytes**, identical in file size to the preceding release;
its 1,536-byte private cache is BSS, not a claim about process RSS. Split debugger
symbols and the release assertion setting are preserved.

The exact installed ELF passes the upstream suite and all six bundled project
suites, including **190 zdraw terminal tests**. The final verifier also passes
installed change-gutter source/native rendering, private module inventory,
interactive login/all five startup filenames, release-profile checks and split
symbol preservation. The exact installed pair passes the preceding-SDK native
loan/mutation fixture, and GDB confirms its unqueued probes leave metadata alone.

**24 real Oh My Zsh sessions pass unchanged**, bound to this executable and the
current gate helpers: configured/login/extra-plugin/inherited-FPATH profiles,
cold/warm/cross-interpreter completion caches, completion buffers, history,
rendered highlighting, prompt/async callbacks and Ctrl-C recovery. The configured
stack is `re5et` plus `git`, with the existing syntax highlighter. OMZ remains at
`b509b1c6ed0c1ba37de12cbd37f30b2b2f61193a` and the highlighter at
`e0165eaa730dd0fa321a6a6de74f092fe87630b0`. All source fingerprints are unchanged;
personal startup files and secrets are not sourced by the gate. This is concrete
coverage, not a universal guarantee for every OMZ configuration or future update.

`Packaging/verify.py verify` passed before activation; the installer consumed
its exact-shell evidence. Post-activation checks preserve all **11,828 protected
Zsh/startup entries**, `/etc/shells`, the account login shell and all **1,604 files
and links** in the preceding release. That release remains available at
`/usr/local/psh/releases/1.0.0-rc0-1d099d21957d`. The initial rc0 tag/draft and
historical artifacts are retained. Nothing is published.


The next profile targets remain concrete: arithmetic parsing in simulation,
uncached array/length work in JSON and other read paths, and parameter-table
scope walks. These are future investigations, not additional accepted changes
or a completed interpreter audit.
