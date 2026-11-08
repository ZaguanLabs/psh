# Round twenty-three: inline the arithmetic operand pop

The twenty-first accepted optimization adds one `inline` hint to `pop()` in
`Src/math.c`. Its complete body is unchanged. In the measured GCC build the
compiler incorporates it into `op()`, removing repeated calls and combining
operand-stack bookkeeping. The fixed operand stack, lazy parameter retrieval,
assignment handling, error checks and signal queue boundaries retain their
source paths. No expression/value cache, allocation protocol, public structure,
export or intended shell-language change is introduced.

The [incremental patch](0023-arithmetic-operand-pop-inline.patch) applies after
`0414178359bc40c627127cc2bf4b0595d6f155ab`. Other compilers can ignore the hint;
correctness does not depend on inlining. The project remains **1.0.0-rc0**.

## Why this path

Fresh profiles use the actual preceding installed release,
`1.0.0-rc0-ac4028c278e1`, and the author's Endgame, zchat paste and JSON workloads.
Endgame spends **48,655,080 self instructions (4.05% of the complete process)**
in `pop()`. Arithmetic remains its largest cost after the array-bound work.

`op()` retrieves the right operand with `pop(0)` and the left with
`pop(what == EQ)`. Each pop may resolve a deferred variable, then decrements
`sp` and returns either its number or the error result. Keeping those exact
operations while exposing them to the caller lets GCC specialize the retrieval
flag and remove call/return and repeated stack bookkeeping. The previous
out-of-line helper is absent from the measured candidate. This is a compiler
hint to existing code, not a replacement arithmetic evaluator.

GCC's `op()` grows from 2,998 to 3,641 bytes and its separate 130-byte `pop()`
disappears: a net **513 bytes** within those two functions. The installed
stripped executable remains the same file size, 846,488 bytes. No process-RSS
reduction is claimed.

## Timing conditions and retained uncertainty

Ryzen 9 5950X, Mageia x86-64, GCC 15.2.0, release assertions disabled,
`-O2 -g`, explicit `LDFLAGS=-g`, multibyte/PCRE enabled. Both comparison builds
use the same configuration and private runtimes. The previous source is an
immutable reconstruction of the parent commit. This isolates the incremental
change rather than relabeling the prior pristine-Zsh results as new tests.

The initial nine-sample matrix is retained as `*-benchmarks.json`. Some batches
alternate between roughly 12 and 24 ms. An unrelated C build was observed in
the same measurement window, including compiler activity on CPU 2. Those
samples are not treated as clean latency evidence; no external process was
paused, killed or reconfigured. Local unrelated-process paths are not published.

After compilation ended and own tests/profilers finished, two nine-sample
matrices ran sequentially with alternating binary order on CPU 2, C.UTF-8.
Own builds, tests and profilers were idle. Loading, construction and warm-up
precede the warm timers; preparation/reset costs retain each workload's existing
definition. Outputs/states match. These are offline function batches, not
application-startup, terminal-frame, GPU or network measurements.

The first idle zcoder wide-layout medians are **64.668 → 68.565 ms** (candidate
6.0% slower); its samples also vary substantially. The confirmation returns to
**63.348 → 63.157 ms**, and complete-process hardware cycles improve about 0.7%.
The residual variation's cause was not isolated. Both runs remain visible;
no stable wide-editor gain or regression is claimed.

## Customer results

| Kernel | First idle before → after ms | Confirmation before → after ms | Confirmation ratio |
| --- | ---: | ---: | ---: |
| zcoder.zsh/coder-paste | 114.980 → 113.202 | 115.161 → 113.754 | 1.01x |
| zcoder.zsh/coder-layout | 5.500 → 5.483 | 5.513 → 5.494 | 1.00x |
| zcoder.zsh/coder-wide-layout | 64.668 → 68.565 | 63.348 → 63.157 | 1.00x |
| zchat.zsh/chat-paste | 206.359 → 206.065 | 211.754 → 204.645 | 1.03x |
| zchat.zsh/chat-layout | 5.497 → 5.510 | 5.470 → 5.444 | 1.00x |
| zchat.zsh/chat-wide-layout | 63.021 → 62.675 | 62.980 → 62.633 | 1.01x |
| endgame/endgame-world | 44.775 → 42.748 | 44.577 → 42.638 | 1.05x |
| z3dfx.mario/mario-race | 19.797 → 19.991 | 19.884 → 19.824 | 1.00x |
| z3dfx/shooter-step | 11.528 → 11.477 | 11.587 → 11.574 | 1.00x |
| z3dfx.agy/shooter-step | 11.549 → 11.558 | 11.579 → 11.527 | 1.00x |
| z3dfx.grok/shooter-step | 11.555 → 11.613 | 11.499 → 11.550 | 1.00x |
| zfetch/fetch-encode | 13.260 → 13.066 | 13.198 → 12.960 | 1.02x |
| z3dfx.drawing/drawing-binning | 12.495 → 12.448 | 12.580 → 12.481 | 1.01x |

Endgame's warm duration falls **4.53% and 4.35%**, about a 1.05x ratio in both
runs. zcoder paste improves about 1.2–1.5%; zchat paste is less consistent.
Most other kernels stay close. Mario is about 1.0% slower in the first idle
run and 0.3% faster on confirmation; Grok is about 0.5% slower in both. These
small differences are retained without assigning every median a causal story.
No aggregate application score is used.

## Library and parser controls

| Operation | First idle before → after ms/call | Confirmation before → after ms/call |
| --- | ---: | ---: |
| zjson-array | 98.918 → 99.300 | 97.744 → 98.660 |
| zjson-encode-array | 203.909 → 209.514 | 204.509 → 210.692 |
| zjson | 98.776 → 99.032 | 93.564 → 95.124 |
| navigation | 1.917 → 1.910 | 1.887 → 1.898 |
| html-comment-1m | 123.596 → 125.164 | 124.686 → 126.088 |
| html-prose-100k | 125.967 → 127.431 | 127.267 → 126.779 |
| json-repair-100k | 18.637 → 18.562 | 18.872 → 18.444 |
| html-clean-128 | 98.173 → 99.098 | 98.382 → 97.906 |

**JSON array encoding is 2.7% and 3.0% slower**, and large HTML-comment conversion
is 1.3% and 1.1% slower. Array parsing is 0.4%/0.9% slower; JSON validation is
0.3%/1.7% slower. These repeated slower controls are part of the adoption
tradeoff. Navigation and prose vary around their baseline; repair/cleaning
improve slightly in the confirmation. An instruction reduction in arithmetic
does not establish a speedup in every interpreter workload. Code layout or
other effects behind the JSON slowdown were not isolated.

## Hardware and instruction evidence

The Linux launcher counts user-space events from exec through exit, including
inherited tasks and setup. Its scope differs from the warm timers. All recorded
counter events were fully scheduled.

| Kernel | Before cycles | After cycles | Cycle reduction | Instruction reduction |
| --- | ---: | ---: | ---: | ---: |
| zcoder.zsh/coder-paste | 724,711,302 | 719,916,015 | 0.66% | 0.05% |
| endgame/endgame-world | 429,534,941 | 413,663,538 | 3.70% | 2.60% |
| z3dfx.mario/mario-race | 189,166,620 | 189,414,663 | -0.13% | 0.56% |
| z3dfx.drawing/drawing-binning | 170,072,331 | 168,977,877 | 0.64% | 0.69% |
| zcoder.zsh/coder-wide-layout | 550,385,544 | 546,365,095 | 0.73% | 0.20% |
| zchat.zsh/chat-wide-layout | 550,263,938 | 545,289,690 | 0.90% | 0.20% |

Matched Callgrind totals include startup and warm-up too. Source and final
state hashes match within each pair.

| Kernel | Before instructions | After instructions | Reduction |
| --- | ---: | ---: | ---: |
| endgame | 1,200,619,641 | 1,169,456,775 | 2.60% |
| mario | 445,341,767 | 442,877,953 | 0.55% |

Endgame's combined self instructions in `op()` and `pop()` fall from
**173,776,232 to 142,613,408**, about 17.9%. This accounts for essentially its
entire complete-process reduction. Mario's same group falls from **19,502,104
to 17,067,142**. This counts the work moved into the caller; disappearance of
the helper symbol alone is not used as evidence. Compressed raw profiles,
flat reports, disassemblies, commands and hashes are retained.

## Compatibility evidence

- GCC and Clang release candidates each pass **63 upstream scripts, zero
  failures, two expected skips**. The preceding Clang build passes too.
- The refreshed local development `./psh`, with debug assertions enabled, passes
  **62 scripts, zero failures, three expected skips**. Its extra skip is the
  PCRE module, disabled by development configure defaults.
- Normal GCC comparisons retain **110,100 arithmetic syntax**, **704,585 scalar**,
  **5,192 array/append**, **193,236 search**, **159,600 pattern** and **2,640
  substitution** checks. Native accessor fixtures pass 20 cases, PTY completion
  covers 36 buffers, and 24 customer kernel/locale states plus five original
  Endgame/AGY/Grok suites match the preceding shell.
- New `math-compare.py --operators` coverage passes **51,696 comparisons per
  host pair**, across native/ksh/sh modes, default/FORCEFLOAT/OCTALZEROES/
  C precedence settings, and C/C.UTF-8/French Belgian UTF-8. It covers binary
  and assignment operators, lazy scalar/array/hash lvalues, increments, deleted
  and retyped parameters, callback traces, recursive math functions,
  short-circuit side effects, and 98/99/100/101/128 nesting boundaries around
  the fixed operand-stack limit. Expected errors retain their diagnostics and
  statuses. GCC release, Clang release, the default debug build and the exact
  installed pair all pass this expanded corpus. Its callbacks run only with
  the explicit option; the default generated corpus remains unchanged.
- Native reference fixtures pass **200,832 scenarios per host pair** across six
  Memcheck processes, in each of those four groups: **803,328 scenarios total**.
  They compare result/type bits, four rounding modes, floating exceptions,
  errno, global/private thread locales, input bytes, exact allocation ends and
  classification/option variations. **Zero memory errors; leak checks disabled.**
- All **1,056 dynamic exports** retain their names/types. The implementation
  assertion verifies that reverting the single `inline` token reconstructs
  the preceding complete `Src/math.c`. No public structure changes or new
  native ownership constraint are introduced; round twenty-two's existing
  array contract continues to apply.

These are focused compatibility checks, not a proof for every program,
compiler, asynchronous signal schedule or platform. No-multibyte and other
operating-system configurations are not newly certified by this round.

## Installed private rc0

Build **`1.0.0-rc0-ea2b25dd07ef`** is active through `/usr/local/bin/psh`.
Its executable SHA-256 is
`e21f6be583dab7548e2f25a9b8e4b1992613fe251e824c6bfe642bdd74d1190d`.
The stripped executable remains **846,488 bytes**; split debugger symbols,
module identities, private install paths and the project version are preserved.
The prior release remains at `/usr/local/psh/releases/1.0.0-rc0-ac4028c278e1`.

The exact installed shell passes the upstream suite and all six bundled project
suites, including **190 zdraw terminal tests**. Final verification also passes
installed change-gutter rendering, login/all five startup filenames, module
inventory, invocation/version checks, release-profile checks and split symbols.
**24 unchanged Oh My Zsh sessions pass**, including the configured re5et/git/
syntax-highlighter stack, extra plugins, login, inherited FPATH, completion
cache handoffs, completion buffers, history, rendered highlighting, prompt,
async callbacks and Ctrl-C recovery. The certificate binds the exact installed
executable and current gate helpers. Framework/highlighter source hashes remain
unchanged; personal startup files and secrets are not sourced by the gate.

`Packaging/verify.py verify` passed before activation, and the privileged
installer consumed its matching evidence. Post-activation checks preserve all
**11,828 protected Zsh/startup entries**, `/etc/shells`, the account login shell
and all **1,604 files/links** in the preceding release. The rc0 tag/draft and
historical artifacts are retained; no public release is created.

[Full evidence](results/round23/) includes all samples and the initial noisy run.
Arithmetic parsing, numeric lexing and parameter-scope scans remain profiling
targets. This round does not claim a completed source audit.
