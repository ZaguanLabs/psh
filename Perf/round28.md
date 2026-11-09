# Round 28: confirmed prefixes before array append

This accepts optimization 26 relative to parent
`b9ab35d3627c00568b893498e5a540cac4201175`. The project remains
`psh 1.0.0-rc0 (zsh 5.9.2)`. JSON array encoding takes 2.7% and 3.7% less time
in the two paired measurement groups. A 16,000-append control improves from
28.068 ms to 7.741 ms, about 3.63× faster. Other customer results are smaller
or mixed. No new language, ABI or ownership difference is intended; existing
native-array contract differences remain in [COMPATIBILITY.md](../COMPATIBILITY.md).

## Why this path

Fresh instruction profiles use the actual installed round-27 release and the
customer's Endgame, chat, JSON encoding and JSON validation kernels. In JSON
encoding, nearly all `arrlen()` instructions come from `assignaparam()`: 16,000
calls account for 160,084,000 instructions, about 5.7% of the whole profile.
They count the old array before whole-array append. The earlier optimization
already avoids recounting it inside the setter, but each subsequent append
still starts the next count from the beginning.

Matched parent/candidate release profiles have identical customer source and
resulting-state fingerprints. JSON encoding falls from 2,812,486,410 to
2,653,577,696 instructions, a 5.65% reduction. Total `arrlen()` instructions
fall from 160,832,580 to 822,660. Chat paste stays essentially flat:
2,363,618,238 to 2,363,622,274 instructions, with the same 404,974 instructions
in `arrlen()`. These are instrumented instruction totals, separate from timers.
[Profile receipts](results/round28/matched-profiles.json) and raw compressed
profiles retain the exact commands, hashes and complete output summaries.

## Implementation and invariants

`assignaparam()` now completes an eligible whole-array append count after an
already confirmed prefix. It still checks the remaining pointers through the
terminator; the prefix is not an assertion that the array ends there. After an
eligible assignment constructs or preserves an array of at least 64 elements,
`setarrvalue_len()` records the resulting prefix in the existing 64-entry cache.
No exact-length flag, larger cache, new allocation, public symbol or structure
layout is introduced. New helper `array_length_full()` is private.

Eligibility is established before reading the value: standard array GSU,
ordinary named parameter, no special/tied/hash-element state, no environment
tie, and no mutable native getter loan. The read also requires queued signals,
the current vector identity, matching parameter/vector cache identities and a
prefix representable as an `int`. Otherwise it counts from the beginning.
Only the existing callback-free setter path can publish a constructed prefix,
with signals already queued and uniqueness disabled. Unique arrays can shrink
when the setter removes duplicates, so they never publish the precomputed count.
Custom getters retain their original snapshots, callback counts and setter path.

Setters and destructors retain their original invalidation. Public mutable
getters still disable cache use through `PM_ARRAY_EXPOSED`, including persistent
loans across cache churn and in-place realloc. The existing raw-field bypass
migration remains necessary; this round adds no separate supported way to mutate
an array without that protocol. Signal delivery boundaries are unchanged.

This removes repeated prefix traversal from eligible append counting. It does
not promise constant-time allocation, capacity growth or all forms of array
processing: realloc can still move/copy a vector, incoming values must be
processed, cache collisions can require a fresh count, and ownership fallbacks
continue scanning.

The five-file [incremental patch](0028-append-confirmed-prefix.patch) reconstructs
exactly against the parent. [Source checks](results/round28/source-checks.json)
verify 1,847 pristine files and 1,853 package inputs, unchanged ownership/getter/
setter/destructor functions, public headers and exported parameter declarations.
Removing the private helper and restoring just `setarrvalue_len()` and
`assignaparam()` recreates the parent's entire `Src/params.c` byte-for-byte.

## Scanner revisit: rejected

The new release profile still puts substantial cost in `scanmatchtable()`.
A prototype hoisted the no-pattern/no-mask decision outside its unsorted inner
loop, retaining its live cursor and callback handling. Reviewing the prior work
showed that round eighteen had already rejected this idea under the then-current
DEBUG build. It was checked once against today's release build and changed
emulation workload, rather than assuming an instruction reduction would help.

The results remain mixed: coder paste takes 1.7% more time, chat paste 0.8% more,
JSON array parsing 1.0% more and encoding 0.4% more. Some individual layout
medians improve, including a 19.2% coder-layout outlier, but the broader customer
results do not justify adoption. Complete paired samples, build commands and
source diff remain under [scan-revisit](results/round28/scan-revisit/).
No new correctness or compatibility certification is claimed for that rejected
prototype. The generic scanner is restored byte-for-byte to the parent before
the selected array change is built and tested.

## Wall-time measurements

Matched GCC release builds use `-O2 -g`, explicit `LDFLAGS=-g`, dynamic modules,
multibyte/PCRE support and DEBUG off, with separate runtime directories.
Nine alternating fresh-process samples per pair run on CPU 2. Customer,
library, parser, search and hardware groups use `C.UTF-8`; the array control
driver uses `C`. Own builds, tests and profilers were idle throughout these
timing groups. Unrelated system activity was not continuously audited. Warm
operation timers exclude setup/warmup. Output/state checks matched.
Positive percentage changes below mean more time. Small or mixed differences
are not presented as established improvements or regressions.

### Customer kernels

| Case | Parent ms | Candidate ms | Change | Repeat parent | Repeat candidate | Repeat change |
| --- | ---: | ---: | ---: | ---: | ---: | ---: |
| zcoder.zsh/coder-paste | 115.085 | 113.186 | -1.7% | 112.671 | 111.935 | -0.7% |
| zcoder.zsh/coder-layout | 5.565 | 5.573 | +0.1% | 5.580 | 5.514 | -1.2% |
| zcoder.zsh/coder-wide-layout | 63.997 | 63.656 | -0.5% | 62.312 | 62.023 | -0.5% |
| zchat.zsh/chat-paste | 202.370 | 203.890 | +0.8% | 204.067 | 200.934 | -1.5% |
| zchat.zsh/chat-layout | 5.507 | 5.416 | -1.7% | 5.477 | 5.407 | -1.3% |
| zchat.zsh/chat-wide-layout | 63.070 | 62.208 | -1.4% | 62.014 | 61.622 | -0.6% |
| endgame/endgame-world | 42.361 | 42.667 | +0.7% | 42.164 | 42.034 | -0.3% |
| z3dfx.mario/mario-race | 19.308 | 19.282 | -0.1% | 19.823 | 19.588 | -1.2% |
| z3dfx/shooter-step | 11.358 | 11.330 | -0.2% | 11.375 | 11.278 | -0.9% |
| z3dfx.agy/shooter-step | 11.314 | 11.270 | -0.4% | 11.551 | 11.480 | -0.6% |
| z3dfx.grok/shooter-step | 11.350 | 11.335 | -0.1% | 11.414 | 11.358 | -0.5% |
| zfetch/fetch-encode | 12.869 | 12.963 | +0.7% | 12.896 | 13.005 | +0.8% |
| z3dfx.drawing/drawing-binning | 12.374 | 12.239 | -1.1% | 12.435 | 12.227 | -1.7% |

### Library operations

| Case | Parent ms | Candidate ms | Change | Repeat parent | Repeat candidate | Repeat change |
| --- | ---: | ---: | ---: | ---: | ---: | ---: |
| zjson-array | 89.102 | 88.287 | -0.9% | 89.833 | 88.078 | -2.0% |
| zjson-encode-array | 204.870 | 199.250 | -2.7% | 204.543 | 197.021 | -3.7% |
| zjson | 87.853 | 87.322 | -0.6% | 87.292 | 87.087 | -0.2% |
| navigation | 1.812 | 1.817 | +0.3% | 1.827 | 1.828 | +0.1% |

### Parser controls

| Case | Parent ms | Candidate ms | Change |
| --- | ---: | ---: | ---: |
| html-comment-1m | 125.738 | 125.379 | -0.3% |
| html-prose-100k | 124.886 | 124.341 | -0.4% |
| json-repair-100k | 18.769 | 18.482 | -1.5% |
| html-clean-128 | 96.034 | 95.025 | -1.1% |

### Search controls

| Case | Parent ms | Candidate ms | Change |
| --- | ---: | ---: | ---: |
| tiny-first | 15.963 | 15.851 | -0.7% |
| first | 1.641 | 1.613 | -1.7% |
| middle | 12.237 | 12.401 | +1.3% |
| last | 24.745 | 24.778 | +0.1% |
| missing | 24.777 | 24.774 | -0.0% |
| start-middle | 0.821 | 0.817 | -0.5% |
| start-last | 0.825 | 0.829 | +0.5% |
| start-beyond | 0.792 | 0.802 | +1.3% |
| negative-start | 17.754 | 17.819 | +0.4% |
| backward | 17.763 | 17.752 | -0.1% |

### Array controls

| Case | Parent ms | Candidate ms | Change |
| --- | ---: | ---: | ---: |
| first / size 10 / iterations 20000 | 9.387 | 9.468 | +0.9% |
| first / size 1000 / iterations 20000 | 9.352 | 9.411 | +0.6% |
| first / size 10000 / iterations 20000 | 9.598 | 9.491 | -1.1% |
| first / size 100000 / iterations 20000 | 9.498 | 9.408 | -0.9% |
| middle / size 10 / iterations 20000 | 9.379 | 9.495 | +1.2% |
| middle / size 1000 / iterations 20000 | 12.888 | 12.703 | -1.4% |
| middle / size 10000 / iterations 20000 | 41.835 | 41.316 | -1.2% |
| middle / size 100000 / iterations 20000 | 348.201 | 347.588 | -0.2% |
| last / size 10 / iterations 20000 | 9.431 | 9.493 | +0.7% |
| last / size 1000 / iterations 20000 | 12.929 | 12.742 | -1.4% |
| last / size 10000 / iterations 20000 | 41.430 | 41.279 | -0.4% |
| last / size 100000 / iterations 20000 | 347.767 | 347.500 | -0.1% |
| slice / size 10 / iterations 20000 | 17.031 | 17.167 | +0.8% |
| slice / size 1000 / iterations 20000 | 16.957 | 17.045 | +0.5% |
| slice / size 10000 / iterations 20000 | 17.050 | 16.979 | -0.4% |
| slice / size 100000 / iterations 20000 | 16.949 | 17.015 | +0.4% |
| append / size 0 / iterations 16000 | 28.068 | 7.741 | -72.4% |
| scalar / size 10000 / iterations 20000 | 8.654 | 8.483 | -2.0% |
| prefix / size 100000 / iterations 20000 | 9.650 | 9.791 | +1.5% |
| past-prefix / size 100000 / iterations 20000 | 347.389 | 350.729 | +1.0% |

URL encoding takes 0.7% and 0.8% more time in its two groups. Chat paste is
0.8% slower in the first group and 1.5% faster in the repeat. Endgame also has
mixed small changes. Search middle and start-beyond medians are 1.3% slower.
Every control and sample remains in the evidence. These are offline kernels,
not whole-application startup, terminal frame latency or a universal shell score.

### Hardware controls

The scope is user-space exec through exit, including setup and inherited tasks,
which differs from warm operation timers. All counters were fully scheduled.

| Case | Parent cycles | Candidate cycles | Parent instructions | Candidate instructions |
| --- | ---: | ---: | ---: | ---: |
| zcoder.zsh/coder-paste | 713,817,211 | 698,116,939 | 1,387,634,602 | 1,387,638,245 |
| endgame/endgame-world | 405,418,996 | 404,642,276 | 1,144,138,244 | 1,144,139,047 |
| z3dfx.mario/mario-race | 184,646,855 | 184,091,391 | 430,234,583 | 430,316,898 |
| z3dfx.drawing/drawing-binning | 167,120,225 | 166,184,513 | 422,759,579 | 422,090,336 |

## Validation

- GCC release candidate: 63 upstream scripts passed, zero failures, two skips.
  Clang parent and candidate: each 63 passed, zero failures, two skips.
  Refreshed DEBUG developer build: 62 passed, zero failures, three skips
  (default developer configuration lacks PCRE).
- New append-prefix fixture: 21,930 counted state snapshots across 30 Memcheck
  processes, plus readonly/tied/special/unique and native-loan output checks.
  Each process tests 17 initial lengths and 14 mutation actions in native, ksh
  or sh emulation. Primary pristine/GCC checks run in C and UTF-8; Clang,
  pristine/DEBUG and exact previous/new installed releases run in UTF-8.
  This repeats one matrix across hosts/modes/locales; it is not 21,930 distinct
  source programs. Zero Memcheck errors, leak checks disabled.
- Three public mutable getter loans (`getaparam`, direct getter and
  `getarrvalue`) truncate a previously cached large vector before further
  appends; the final seven elements must match. The native fixture's added
  `trim` operation frees removed strings and uses public getter-loan semantics.
- Existing cache lifetime/mutation checks pass under ordinary malloc and
  Memcheck, including in-place/moved realloc, scope destruction, uniqueness,
  setters, cache churn and loans. Unqueued search probes leave metadata
  unchanged, as verified with GDB. Native array-length and custom accessor
  fixtures also pass, preserving self-replacing getter behavior.
- Eleven broad groups pass: arrays 5,192; search 193,236; patterns 159,600;
  scalar cases 704,585 across five encodings; substitution 2,640; arithmetic
  syntax 110,100; native floating-point 200,832 scenarios under Memcheck;
  accessor 20; PTY completion 36; 512 emulation frontend cases; and customer
  correctness. Customer checks include 24 kernel/locale pairs and five original
  project suites. Commands and exact per-group receipts remain in the evidence.
- Seven installed package suites pass, including all 190 zdraw tests and native
  modules rebuilt against this SDK. Normal-user package verification passes
  before activation, including 24 genuine interactive Oh My Zsh sessions with
  re5et, git, syntax highlighting, completion, history, prompts and async work.
  This establishes the exercised configuration, not every possible OMZ setup.

An initial automated source edit used an incorrect indentation needle and
stopped on an assertion before writing `params.c`. The successful edit driver
is retained. The first source reconstruction check mistakenly stopped removal
of the helper at its first blank line; correcting the checker to use the whole
function made the byte comparison pass. Neither setup issue changed production
semantics or hid a failing shell test. The initial pilot fixture was subsequently
extended to warm the readonly parameter before refusing its write; final native
runs bind the final source fingerprint.

## Installed checkpoint and limits

Active release: `/usr/local/psh/releases/1.0.0-rc0-56f97a85e8cb`.

Installed ELF SHA-256: `9981ba37c0d6b467e11cb7ce8aacd10a89f95133b7958c7e3aad654cb47e0b72`.

The stripped executable is 846,488 bytes, versus
846,488 previously, with the same 1,056 dynamic
export names/types. The installed release keeps DEBUG off and separate symbols;
the refreshed developer build keeps DEBUG on.

Post-activation checks preserve all 1,603 entries in previous release
`1.0.0-rc0-e84bb6129d9e` for rollback, along with
11,828 protected stable-Zsh/startup entries. `/etc/shells` and the account
login shell are unchanged. Personal startup files and framework sources were
not edited. The exact installed ELF passes release identity and native checks.

The repository remains private. The original rc0 tag, draft and seven historical
assets are unchanged; this iteration is identified by its commit/build digest
and binary hash. No new source archive is presented as the original tag.

This is a focused append/cache investigation, not a completed interpreter audit.
The structural index reported partial coverage; exact source reads and byte
comparisons underpin the source claims. Other operating systems and a new
non-multibyte build were not certified here. Existing native-array differences
and migration remain documented separately.

[Evidence index](results/round28/README.md) describes final receipts, the rejected
scanner branch and compressed profiles. Its manifest hashes archived files
except itself. Local-only startup snapshots and the private previous-release
manifest are excluded from the repository archive.
