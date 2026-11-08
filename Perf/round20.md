# Round twenty: inline the arithmetic token check

The accepted production change is one word in `Src/math.c`: `checkunary()` is
now `static inline void`. Its entire body is unchanged. In the measured GCC
build, the compiler incorporates this operand/operator check into `mathparse()`
and removes the repeated C call after arithmetic tokens. Correctness does not
require a compiler to honor the inline hint.

The [incremental patch](0020-arithmetic-token-check-inline.patch) applies after
`3312d28`. It includes four diagnostic regressions and an expanded differential
arithmetic corpus. This is the **nineteenth accepted optimization**, following
the round-nineteen locale optimization and round-eighteen rejected trials.

## Why this path

The preceding Endgame profile spent 63,145,764 self instructions, **4.94% of the
complete process**, in `checkunary()`. Disassembly showed a separate call with
register saves and a stack frame on the normal valid-input path. Its error
branch formats excerpts, counts metafied bytes and calls `zerr()`, making the
whole function large enough that GCC did not inline it automatically.

Two extracted error-handler variants were tested first. Splitting the diagnostic
worker with a guarded no-inline hint reduced instruction counts and improved
Endgame, but the customer run slowed zchat paste about 3.2%, and several library
controls also worsened. Adding a cold attribute to that worker improved Endgame
further but slowed URL encoding about 5.0%, large HTML-comment conversion 5.0%
and malformed-UTF-8 JSON repair 9.2%. Both variants were rejected. Their complete
nine-sample project/library/scalar matrices, hardware counts, source diffs and
hashes remain under `results/round20/split-*` and `cold-*`.

The selected inline hint keeps the original checker and its error handling
together. It adds no allocation, cached syntax, parameter cache, public symbol
or representation change. Operator precedence, short-circuit parsing, `noeval`,
recursive callbacks, signal queueing, lvalue evaluation and error-state updates
retain their existing source paths. All floating-locale guards from round
nineteen remain intact.

## Measurements and timing variability

Ryzen 9 5950X, Mageia Linux x86-64, GCC 15.2.0, `-O2 -g`, debug assertions and
multibyte support. Nine alternating fresh-process samples per build, CPU 2,
C.UTF-8. Own runtime suites, builds and profilers were idle during timing.
Loading, construction and warm-up precede the warm timers; preparation/reset
costs retain the existing workload definitions. Outputs/states match.
[Every sample and source/binary/worker hash](results/round20/) is retained.

The first selected-build project run had highly variable editor samples in both
binaries. For ordinary zcoder layout the medians were **7.143 → 10.237 ms**,
while the repeated run returned to **5.864 → 5.797 ms**. The first wide-layout
medians were **112.503 → 102.514 ms**, versus **95.480 → 94.685 ms** on repeat.
The large first differences did not reproduce; their cause was not isolated.
They are retained and are not presented as established gains or regressions.
A read-only source-provenance check overlapped the beginning of the repeat;
that is another limitation on interpreting its small editor differences.

Customer warm batches below show the complete repeated run and each first-run
ratio. **Do not treat the repeated run as a replacement for the first evidence.**
No aggregate project score or application-startup claim is made.

| Kernel | Previous, repeat ms | Candidate, repeat ms | Repeat ratio | First ratio |
| --- | ---: | ---: | ---: | ---: |
| zcoder.zsh/coder-paste | 117.603 | 117.748 | 1.00x | 0.99x |
| zcoder.zsh/coder-layout | 5.864 | 5.797 | 1.01x | 0.70x |
| zcoder.zsh/coder-wide-layout | 95.480 | 94.685 | 1.01x | 1.10x |
| zchat.zsh/chat-paste | 213.604 | 210.245 | 1.02x | 0.99x |
| zchat.zsh/chat-layout | 5.826 | 5.747 | 1.01x | 1.01x |
| zchat.zsh/chat-wide-layout | 96.325 | 96.565 | 1.00x | 1.00x |
| endgame/endgame-world | 50.389 | 49.816 | 1.01x | 1.04x |
| z3dfx.mario/mario-race | 20.419 | 20.081 | 1.02x | 1.00x |
| z3dfx/shooter-step | 11.959 | 11.823 | 1.01x | 1.01x |
| z3dfx.agy/shooter-step | 11.912 | 11.979 | 0.99x | 1.00x |
| z3dfx.grok/shooter-step | 11.971 | 11.791 | 1.02x | 1.02x |
| zfetch/fetch-encode | 13.353 | 13.346 | 1.00x | 1.00x |
| z3dfx.drawing/drawing-binning | 15.037 | 14.338 | 1.05x | 1.02x |

Endgame improves **3.5%** in the first warm run and **1.1%** in the repeat;
drawing improves **1.9%** and **4.6%** respectively. Paste is less consistent:
zcoder is 1.1% slower initially and 0.1% slower on repeat; zchat is 1.5% slower
initially and 1.6% faster on repeat. No repeatable paste gain is claimed.
The repeated AGY median is about 0.6% slower; wide zchat layout about 0.2% slower.
URL encoding remains close in both runs. Complete application, graphics,
terminal and network behavior are outside these offline kernels.

Warm library calls, milliseconds per call, one nine-sample paired run:

| Operation | Previous psh | Candidate | Ratio |
| --- | ---: | ---: | ---: |
| zjson-array | 100.662 | 101.660 | 0.99x |
| zjson-encode-array | 220.288 | 223.542 | 0.99x |
| zjson | 97.802 | 98.723 | 0.99x |
| navigation | 2.062 | 2.059 | 1.00x |
| html-comment-1m | 130.886 | 132.526 | 0.99x |
| html-prose-100k | 131.960 | 132.410 | 1.00x |
| json-repair-100k | 20.149 | 20.076 | 1.00x |
| html-clean-128 | 101.900 | 101.581 | 1.00x |

JSON array encoding is **1.5% slower**, array parsing **1.0% slower**, validation
**0.9% slower**, and large HTML-comment conversion **1.3% slower**. Prose,
repair, navigation and cleaning remain close. These slower controls are part
of the adoption tradeoff. All 31 scalar/count controls are also retained; the
late-Unicode slice is **10.532 → 11.028 ms**, about **4.7% slower**. Large differences in short
controls, such as the repeated-NUL count, are not assigned a causal
mechanism without further evidence.

## Hardware and instruction evidence

The [round-nineteen Linux launcher](round19.md#hardware-evidence-and-instruction-profiles)
counts user-space events from exec through exit, including inherited tasks.
These totals include startup, construction and warm-up; the warm timers above
have a different scope. All recorded final events were fully scheduled.
No privilege or system-setting change is required on this host.

Median user-space cycles:

| Kernel | Previous cycles | Candidate cycles | Reduction |
| --- | ---: | ---: | ---: |
| zcoder.zsh/coder-paste | 743,765,816 | 728,107,420 | 2.11% |
| endgame/endgame-world | 454,012,140 | 436,630,201 | 3.83% |
| z3dfx.mario/mario-race | 194,469,396 | 192,309,489 | 1.11% |
| z3dfx.drawing/drawing-binning | 193,467,872 | 190,384,278 | 1.59% |

Endgame's cycle median falls **3.8%** and its hardware instruction median falls
**3.0%**, from 1,276,663,132 to 1,237,746,059. The other three measured kernels
also use fewer instructions and cycles in this run. These counts support a
reduction in executed work, while wall-time variability limits claims about
small per-project latency differences.

Matched Callgrind totals include startup and warm-up too:

| Kernel | Previous instructions | Candidate instructions | Reduction |
| --- | ---: | ---: | ---: |
| mario | 461,512,333 | 455,061,610 | 1.40% |
| shooter | 370,723,623 | 366,955,686 | 1.02% |
| endgame | 1,277,039,363 | 1,238,122,369 | 3.05% |
| coder | 1,439,684,383 | 1,435,815,024 | 0.27% |

For Endgame, combined self instructions in `mathparse()` and `checkunary()` fall
from **268,467,746 to 229,550,639**, a 14.5% reduction within those functions.
`checkunary()` no longer has a separate symbol in the measured candidate; its
work appears inside `mathparse()`. The rest of `math.c` has the same self total
in this matched profile. This is stronger evidence for reduced call/check
bookkeeping than disappearance of the helper's name alone. Disassemblies,
flat reports, exact commands and compressed raw profiles are retained.

## Compatibility evidence

- **62 development upstream scripts pass, zero failures, three expected skips.**
  The four new diagnostic regressions pass on pristine Zsh as well. They cover
  nine/ten/eleven-byte suffix boundaries, operator/operand wording and ellipses.
- **110,100 arithmetic comparisons** match pristine stdout, stderr and status
  across C, C.UTF-8, French, Norwegian and Turkish; native/ksh/sh emulation; and
  default, FORCEFLOAT, OCTALZEROES and C precedence contexts. The corpus includes
  valid/invalid token pairs, whitespace/newlines, Unicode/Meta/DEL suffixes,
  nested parentheses, short-circuit contexts, assignment effects and recursive
  or locale-changing math callbacks.
- The driver now requires every expected subshell completion marker. Its first
  no-multibyte run correctly stopped at **zero completed cases** because the
  private runtime lacked `zsh/mathfunc`. Installing the matching stock modules
  repaired the test setup; the affected **44,040 arithmetic comparisons** and
  **281,834 scalar comparisons** then passed. The original failed log/receipt
  is retained alongside [the explicit repair](results/round20/validation-repair.json)
  and [aggregate validation summary](results/round20/validation-summary.json).
  There was no core change for this repair.
- Forced locale-API fallback and no-`setlocale()` builds each pass their
  arithmetic upstream script, **44,040 syntax comparisons** and **133,888 native
  numeric scenarios across four Memcheck processes**. The no-locale pair uses
  matching baseline configuration headers and the release's plain conversion
  sequence as oracle.
- Normal and no-multibyte builds each pass **535,552 numeric reference scenarios
  across sixteen Memcheck processes**. These cover value/type bits, all four
  rounding modes, exceptions, errno, global/private thread locales, input bytes,
  exact allocation ends and classification/option variations. **Zero memory
  errors**, leak checks disabled. No-multibyte substitution, conditional and
  arithmetic scripts pass too.
- Normal scalar/array/search/pattern/substitution comparisons retain the earlier
  **704,585 / 5,192 / 193,236 / 159,600 / 2,640** checks, with 20 native accessor
  cases and 36 PTY completion buffers. Twenty-four customer kernel/locale
  comparisons match pristine state. Original zjson, zoup, shooter, Endgame and
  AGY/Grok suites match; all 307 zhtml2md checks pass using its child-shell override.
- All **1,847 pristine hashes**, the complete round-nineteen snapshot,
  **1,055 exported names/types** and eight public declaration files match their
  respective references. The patch reconstructs all three changed files.

These checks are focused compatibility evidence, not a complete-shell
behavioral-equivalence proof or certification of other compiler/platform pairs.
The inline qualifier allows other compilers to retain the original call.

## Daily driver and next lead

Private release **`5.9.2-e37ef44ddb53`** contains the accepted source and matching
native modules. Its **63 upstream scripts pass with two expected skips**, along
with all six bundled project suites, 190 zdraw tests, installed change-gutter
rendering and login startup in a PTY. Installed/pristine hosts match another
**44,040 syntax comparisons** and **200,832 native scenarios across six Memcheck
processes**. Across all five host/configuration groups above, the syntax total
is **286,260 comparisons** and the native total **1,539,712 scenarios**.

[The installation record](results/round20/installed-package.json) retains the
release/module hashes and protection checks. All **11,828 protected Zsh/startup
entries**, `/etc/shells`, the account login shell and the full preceding release
manifest are unchanged. The previous release remains available to existing
sessions and for rollback. Start a new psh process to use the active release.
Its compiled private paths/configuration differ from the timing executable.

The next arithmetic lead is integer literal handling: `lexconstant()` scans
candidate digits before `zstrtol_underscore()` scans them again. Numeric bases,
underscores, truncation warnings, end pointers, options, classification and
callback/error ordering constrain any shortcut. That is research for a separate
candidate; the [review map](audit.md) still records repeated parsing, parameter
lookup, array-bound walks, scope scans and allocation as open work.

Development timing SHA256:
`a0ff493b8f67adfcff6e1b89c44965904c16190672379742847581dc2a4d3d31`.
Previous timing SHA256:
`f7e6d87f5c5ceaad3460862dc39dc3009826ec7b258e8e8173552bb5e1b4b7ff`.

Reproduction commands are in [the workflow](README.md#per-token-arithmetic-validation).
Protected-file snapshots and full private logs stay local under
`.work/logs/round20/` and `.work/package/5.9.2-e37ef44ddb53/`.
