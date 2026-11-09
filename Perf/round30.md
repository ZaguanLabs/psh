# Round 30: fused decimal lexer, not adopted

**Neither decimal lexer prototype is adopted.** The active daily driver remains
`1.0.0-rc0-56f97a85e8cb`, with twenty-six accepted optimizations. The selected
prototype reduces Endgame instructions by 3.09% and its installed warm runtime
by 2.1–2.4% in two complete paired groups. However, coder paste takes 3.5–4.8%
more time, chat paste 2.4–3.1% more, and JSON encoding 1.2–1.7% more. These
customer regressions outweigh the narrower improvement.

Production source is restored byte-for-byte to parent
`4b5ff817082a7b045304811f61064acc8b7d52da`. The developer executable is also
byte-identical to the preceding accepted build. No release was activated and no
compatibility difference is introduced. The current accepted report remains
[round 28](round28.md).

## Profile and prototypes

Fresh profiles of the exact accepted installed release cover Endgame, chat paste,
JSON array encoding and JSON validation. Endgame spends substantial work in
arithmetic parsing and evaluation. The experiment targets `lexconstant()` in
`Src/math.c`: normal decimal tokens are first scanned for their shape and then
scanned again during integer conversion. This round tries fusing those walks.

The initial prototype recognizes only complete positive one-digit literals
1–9, preserving live character-table and continuation exceptions. Matched
private-build profiles reduce Endgame instructions from 1,144,450,115 to
1,136,852,272 (0.66%). Its source, profile and pilot validation receipts remain
under [one-digit](results/round30/one-digit/). It was not packaged or timed as an
installed candidate; no installed-performance claim is made for it.

The selected prototype consumes ordinary positive decimals beginning with 1–9,
up to 18 digits for a 64-bit zlong or 9 digits for a 32-bit zlong. Each accepted
prefix fits signed zlong. It returns directly only for a complete ordinary
decimal token, preserving FORCEFLOAT conversion. Leading zero, signs, bases,
underscores, floats, exponents, longer integers and live classification exceptions
retain the original conversion path. The global input pointer remains unchanged
on fallback; the original classification walk resumes from the validated prefix.
No cache, allocation, ownership, ABI, declaration or signal-boundary change is made.

The [unapplied proposal](results/round30/proposed-with-fixtures.patch) includes
source and fixtures. The source checks reconstruct it against its recorded
parent and verify that removing the added prefix block and continuation label
recovers the original function exactly. Every other production function and the
public headers/declarations remain unchanged in the trial.

Matched private release-profile instruction counts have identical customer
source and output-state hashes:

| Kernel | Parent instructions | Trial instructions | Reduction |
| --- | ---: | ---: | ---: |
| endgame | 1,144,450,047 | 1,109,043,838 | 3.09% |
| mario | 430,983,244 | 429,961,562 | 0.24% |
| json-encode | 2,653,577,764 | 2,650,680,947 | 0.11% |

Instruction reductions are not wall-time speedups. Compressed raw profiles and
flat summaries remain in the evidence.

## Exact installed-release measurements

The decisive pairs compare the accepted installed release with inactive trial
`1.0.0-rc0-363dc2fc22b0`. Both are dynamic, multibyte/PCRE release-profile builds,
DEBUG off, `-O2 -g`, explicit `LDFLAGS=-g`, stripped with separate debug files.
The trial is 850,584 bytes versus 846,488 bytes, retaining the same 1,056 dynamic
exported names/types. The additional page of file size is not a memory-use claim.

Nine alternating fresh-process samples per pair run on CPU 13, after own builds,
tests and profilers finish. Customer, library, parser, search, hardware and token
controls use C.UTF-8; array controls use C. A single pre-run aggregate observation
found CPU 13 idle and its sibling about 1% busy. This is not a continuous activity
audit. Warm timers exclude startup, loading and fixture construction; output/state
hashes match. Positive percentages mean more time. Small differences alone do not
establish a useful general benefit.

### Customer kernels

| Case | Parent ms | Trial ms | Change | Repeat parent | Repeat trial | Repeat change |
| --- | ---: | ---: | ---: | ---: | ---: | ---: |
| zcoder.zsh/coder-paste | 120.435 | 126.236 | +4.8% | 119.534 | 123.723 | +3.5% |
| zcoder.zsh/coder-layout | 5.893 | 5.815 | -1.3% | 5.826 | 5.799 | -0.5% |
| zcoder.zsh/coder-wide-layout | 66.702 | 65.369 | -2.0% | 66.683 | 65.633 | -1.6% |
| zchat.zsh/chat-paste | 214.167 | 220.870 | +3.1% | 216.055 | 221.286 | +2.4% |
| zchat.zsh/chat-layout | 5.800 | 5.778 | -0.4% | 5.822 | 5.784 | -0.7% |
| zchat.zsh/chat-wide-layout | 66.452 | 65.536 | -1.4% | 66.934 | 65.814 | -1.7% |
| endgame/endgame-world | 44.870 | 43.813 | -2.4% | 45.475 | 44.498 | -2.1% |
| z3dfx.mario/mario-race | 20.581 | 20.717 | +0.7% | 21.249 | 21.163 | -0.4% |
| z3dfx/shooter-step | 12.195 | 12.166 | -0.2% | 12.397 | 12.331 | -0.5% |
| z3dfx.agy/shooter-step | 12.218 | 12.106 | -0.9% | 12.340 | 12.422 | +0.7% |
| z3dfx.grok/shooter-step | 12.194 | 12.166 | -0.2% | 12.331 | 12.639 | +2.5% |
| zfetch/fetch-encode | 13.874 | 13.724 | -1.1% | 14.238 | 14.038 | -1.4% |
| z3dfx.drawing/drawing-binning | 13.128 | 12.925 | -1.5% | 13.233 | 13.232 | -0.0% |

### Library operations

| Case | Parent ms | Trial ms | Change | Repeat parent | Repeat trial | Repeat change |
| --- | ---: | ---: | ---: | ---: | ---: | ---: |
| zjson-array | 95.174 | 96.161 | +1.0% | 96.821 | 98.488 | +1.7% |
| zjson-encode-array | 208.975 | 212.554 | +1.7% | 212.827 | 215.450 | +1.2% |
| zjson | 92.886 | 93.824 | +1.0% | 93.022 | 93.618 | +0.6% |
| navigation | 1.985 | 2.012 | +1.4% | 1.974 | 2.033 | +3.0% |

### Parser controls

| Case | Parent ms | Trial ms | Change |
| --- | ---: | ---: | ---: |
| html-comment-1m | 133.284 | 132.842 | -0.3% |
| html-prose-100k | 132.810 | 133.570 | +0.6% |
| json-repair-100k | 19.830 | 19.897 | +0.3% |
| html-clean-128 | 103.224 | 104.747 | +1.5% |

### Search controls

| Case | Parent ms | Trial ms | Change |
| --- | ---: | ---: | ---: |
| tiny-first | 17.362 | 16.795 | -3.3% |
| first | 1.753 | 1.707 | -2.6% |
| middle | 13.328 | 13.332 | +0.0% |
| last | 26.584 | 26.584 | +0.0% |
| missing | 26.594 | 26.603 | +0.0% |
| start-middle | 0.896 | 0.875 | -2.3% |
| start-last | 0.898 | 0.864 | -3.8% |
| start-beyond | 0.873 | 0.840 | -3.8% |
| negative-start | 19.088 | 19.184 | +0.5% |
| backward | 19.009 | 19.118 | +0.6% |

### Array controls

| Case | Parent ms | Trial ms | Change |
| --- | ---: | ---: | ---: |
| first / size 10 / iterations 20000 | 10.114 | 10.489 | +3.7% |
| first / size 1000 / iterations 20000 | 10.193 | 10.577 | +3.8% |
| first / size 10000 / iterations 20000 | 10.238 | 10.598 | +3.5% |
| first / size 100000 / iterations 20000 | 10.143 | 10.511 | +3.6% |
| middle / size 10 / iterations 20000 | 10.245 | 10.604 | +3.5% |
| middle / size 1000 / iterations 20000 | 13.750 | 14.308 | +4.1% |
| middle / size 10000 / iterations 20000 | 44.431 | 45.194 | +1.7% |
| middle / size 100000 / iterations 20000 | 372.820 | 372.463 | -0.1% |
| last / size 10 / iterations 20000 | 10.311 | 10.683 | +3.6% |
| last / size 1000 / iterations 20000 | 13.723 | 14.378 | +4.8% |
| last / size 10000 / iterations 20000 | 44.539 | 45.089 | +1.2% |
| last / size 100000 / iterations 20000 | 373.826 | 375.673 | +0.5% |
| slice / size 10 / iterations 20000 | 18.163 | 17.898 | -1.5% |
| slice / size 1000 / iterations 20000 | 18.134 | 17.886 | -1.4% |
| slice / size 10000 / iterations 20000 | 18.134 | 17.965 | -0.9% |
| slice / size 100000 / iterations 20000 | 18.227 | 17.936 | -1.6% |
| append / size 0 / iterations 16000 | 8.263 | 8.118 | -1.8% |
| scalar / size 10000 / iterations 20000 | 9.116 | 9.496 | +4.2% |
| prefix / size 100000 / iterations 20000 | 10.492 | 10.748 | +2.4% |
| past-prefix / size 100000 / iterations 20000 | 374.912 | 376.192 | +0.3% |

### Arithmetic token controls

| Case | Parent ms | Trial ms | Change |
| --- | ---: | ---: | ---: |
| 1 / normal | 1.884 | 1.878 | -0.3% |
| 1 / float | 1.875 | 1.863 | -0.6% |
| 99 / normal | 1.645 | 1.586 | -3.6% |
| 99 / float | 1.656 | 1.582 | -4.5% |
| 123456 / normal | 1.754 | 1.671 | -4.7% |
| 123456 / float | 1.753 | 1.644 | -6.2% |
| 999999999999999999 / normal | 2.068 | 1.889 | -8.7% |
| 999999999999999999 / float | 2.082 | 1.895 | -9.0% |
| 1234567890123456789 / normal | 2.153 | 2.326 | +8.0% |
| 1234567890123456789 / float | 2.139 | 2.342 | +9.5% |
| -9 / normal | 1.683 | 1.680 | -0.2% |
| -9 / float | 1.699 | 1.686 | -0.8% |
| 0 / normal | 1.975 | 2.017 | +2.1% |
| 0 / float | 1.986 | 2.012 | +1.3% |
| 01 / normal | 1.733 | 1.785 | +3.0% |
| 01 / float | 1.724 | 1.800 | +4.4% |
| 1.25 / normal | 3.095 | 3.435 | +11.0% |
| 1.25 / float | 3.124 | 3.433 | +9.9% |
| 0.125 / normal | 3.375 | 3.376 | +0.0% |
| 0.125 / float | 3.389 | 3.427 | +1.1% |
| 1_000 / normal | 1.774 | 1.909 | +7.6% |
| 1_000 / float | 1.785 | 1.927 | +8.0% |
| 16#ff / normal | 1.904 | 1.838 | -3.5% |
| 16#ff / float | 1.896 | 1.835 | -3.2% |
| 1e2 / normal | 2.453 | 2.646 | +7.9% |
| 1e2 / float | 2.469 | 2.664 | +7.9% |

The arithmetic controls include interpreter dispatch in warm repeat batches of
30,000 literal evaluations, excluding function definition and warmup. Ordinary
18-digit literals take about 9% less time, while the 19-digit fallback takes
8–9.5% more and the `1.25` control takes about 10–11% more. This supports rejecting
the general fast path; it does not isolate the cause of each customer regression.

### Hardware controls

Counters cover user-space exec through exit, setup and inherited tasks, a
different scope from warm timers. Every event is fully scheduled.

| Case | Parent cycles | Trial cycles | Parent instructions | Trial instructions |
| --- | ---: | ---: | ---: | ---: |
| zcoder.zsh/coder-paste | 698,438,617 | 711,464,312 | 1,385,395,621 | 1,379,858,833 |
| endgame/endgame-world | 404,031,750 | 395,163,759 | 1,143,872,287 | 1,108,466,115 |
| z3dfx.mario/mario-race | 187,722,177 | 187,712,758 | 430,138,281 | 429,108,156 |
| z3dfx.drawing/drawing-binning | 166,391,073 | 163,412,480 | 421,900,276 | 418,987,822 |

### Interrupted first pass

The first installed timing batch ended with SIGTERM (status 143) after completing
customer and library groups, during the parser stage. The cause was not
established; the logs report no failed state comparison. Every completed JSON,
partial log and command receipt is retained in
[interrupted-timing](results/round30/interrupted-timing/). Its Endgame median is
44.902 → 44.100 ms, chat paste 217.545 → 224.607 ms, and JSON encoding
208.802 → 212.573 ms. These values are not mixed into the final complete groups.
The rerun streams child progress and completes all nine groups successfully.

## Native arithmetic coverage and validation

The committed native fixture calls `matheval()` and the existing internal
`mathevalarg()` with exact allocations at offsets zero/three and selected
terminators directly before inaccessible pages. It checks unchanged input,
compares numeric types and bits, argument endpoints, error state, errno,
floating-point exceptions, lastbase, outputradix, outputunderscore and lastmathval.
It tests four rounding modes, eight FORCEFLOAT/OCTALZEROES/CPRECEDENCES
combinations and five live character-table configurations. ASCII successors,
embedded NULs and fixed expressions exercise ordinary integers, floats, bases,
underscores, format controls, short circuiting and long-number fallback.
Normal single-digit results also have independent expected-value assertions.
The fixture restores its modified interpreter state; its internal declarations
are test-only and do not create a supported native API.

There are 1,677,760 counted API observations per host/locale. The final candidate
matrix passes **16,777,600 checks across ten Memcheck processes**: pristine/GCC
in C and UTF-8; Clang old/new in UTF-8; pristine/DEBUG in UTF-8; and exact installed
old/new in UTF-8. These repeat the matrix rather than representing sixteen million
distinct expressions. Leak checks are disabled; memory errors are zero.
The restored pristine/DEBUG comparison passes another 3,355,520 checks separately.
Pilot receipts remain separate and bind their own fixture fingerprints.

Candidate validation also passes:

- GCC release: 63 upstream scripts, zero failures, two skips. Clang parent and
  trial each pass 63/0/2. DEBUG developer passes 62/0/3, with PCRE absent in its
  default configuration. The restored developer build passes 62/0/3 again.
- Eleven differential groups: arrays 5,192; search 193,236; patterns 159,600;
  scalars 704,585 across five encodings; substitution 2,640; combined arithmetic
  syntax/operators 180,960 across five locales; native floating-point 200,832
  scenarios under Memcheck; accessor 20; PTY completion 36; emulation frontend
  512; and customer correctness including 24 kernel/locale pairs and five
  original project suites.
- Seven inactive-package suites, including all 190 zdraw tests, rebuilt native
  components, installed core/login/startup checks and 24 genuine interactive
  Oh My Zsh sessions with re5et, git and syntax highlighting.
- Release identity, matching source inputs, fallback reconstruction, unchanged
  declarations and dynamic exports. All 1,847 pristine release files are verified.

The initial fixture used DEBUG headers for a release host and failed module
loading due to the DEBUG-only `queue_in` reference. The driver now builds a
fixture against each host's matching SDK. An initial Mario profile used two steps
and tripped the reference workload's speed invariant; the final profile uses its
authored 120-step case. An evidence move temporarily hid the local previous-release
snapshot; it was restored before repeating that check. Logs remain under
`setup-failures/`. These were harness/setup failures, not discovered C semantic
regressions; no correctness check was removed to adopt a change.

These results cover exercised cases, not all shell behavior. No fresh
non-multibyte or other-operating-system certification was performed. The structural
index had partial coverage; focused source reads and byte comparisons support the
source claims. The complete source audit remains unfinished.

## Restored state

Active prefix: `/usr/local/psh/releases/1.0.0-rc0-56f97a85e8cb`.

Active ELF SHA-256: `9981ba37c0d6b467e11cb7ce8aacd10a89f95133b7958c7e3aad654cb47e0b72`.

All 1,853 current packaged inputs match the accepted
release. The restored developer SHA-256 is `86c7153edc3e45bf994bc02236213dab83a836f00028392c1cbc9bcc8c4acae6`.

The normal-user package verifier passes again with a fresh 24-session interactive
OMZ gate. Historical seven-suite receipts are reused only for the unchanged
accepted artifacts; they are not seven newly rerun suites. The three transient
Vendor module outputs were restored from the exact previously tested active
payload before verification, preserving trial bytes in the inactive prefix.
Neither installed release was modified and no verifier was weakened.

All 1,603 active-release entries and
11,828 protected stable-Zsh/startup entries remain
unchanged. `/etc/shells`, account login shell, personal startup files and framework
sources are untouched. Package `latest.json` points to the accepted active build.
The inactive trial `1.0.0-rc0-363dc2fc22b0` remains available
locally with ELF SHA-256 `33cd257f6a495bf5da91bea4c7d2dbf1a0c1ae262b286cff61028328c4926165`.

The project stays `1.0.0-rc0`. The private repository, original rc0 tag, draft and
seven historical assets remain unchanged. No new accepted source patch or release
archive is created. The [evidence index](results/round30/README.md) distinguishes
inactive-proposal receipts from restored-state proof and retains slower controls,
unsuccessful prototypes and the interrupted timing pass. Local private snapshots
and previous-release manifests are excluded.
