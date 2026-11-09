# Round 33: logarithmic integer powers, not adopted

**The integer-power candidate is not adopted.** Replacing repeated multiplication
with exponentiation by squaring gives a large improvement for large nonnegative
integer exponents, with no behavioral mismatch found in the tested matrix.
However, two complete installed-build timing groups show coder paste taking
2.1–3.7% more time, chat paste 2.8–3.9% more, and several JSON kernels slowing.
Those customer results outweigh the isolated arithmetic improvement.

The daily driver remains `1.0.0-rc0-56f97a85e8cb`, with twenty-six accepted
optimizations. `Src/` and `Test/` are restored byte-for-byte to parent
`98a0bf506c05a333f07eea92791926f9f35fba6d`. The developer executable is also
byte-identical to its preceding accepted build. No candidate was activated,
no compatibility difference is introduced, and the project stays on rc0.

## Algorithm and compatibility boundaries

The earlier [structural investigation](round32.md) confirmed that integer `**`
performs one multiplication per exponent step. This trial changes only the
integer result branch in `op()` in `Src/math.c`, shared by `**` and `**=`:

```c
c.u.l = (b.u.l & 1) ? a.u.l : 1;
while ((b.u.l >>= 1)) {
    a.u.l *= a.u.l;
    if (b.u.l & 1)
        c.u.l *= a.u.l;
}
```

The exponent is nonnegative at this point: the existing negative-exponent
promotion and complete floating/libm branch remain unchanged. Zero exponent
still returns integer 1, including `0**0`. The final unnecessary square is
omitted, so `ZLONG_MAX**1` and a representable final product do not incur an
extra overflowing operation. Evaluation order, deferred parameter reads,
assignment setters, option handling and signal boundaries outside this local
calculation remain unchanged. There is no cache, allocator, ownership, structure
layout or supported native API change.

The [unapplied five-file proposal](results/round33/initial/proposed-with-fixtures.patch)
contains the source change, two upstream-style arithmetic test blocks and the
three new performance/native fixture files. The source-only check reconstructs
that proposal against the parent and recovers the original complete `math.c`
by restoring its single replaced loop. Public declarations remain unchanged.
The new test blocks pass against pristine Zsh as well as the trial; they remain
in the unapplied proposal so canonical package inputs return to their exact
previous hashes.

Both implementations use signed C integer multiplication. The independent
oracle uses unsigned repeated multiplication to check the current targets'
wrapping results. GCC and Clang checks pass on this machine; this does not
establish a portable signed-overflow contract, certify trapping/sanitized builds,
or certify another integer width, operating system or architecture.

## Exact installed timings

These comparisons use the previous installed release and inactive trial
`1.0.0-rc0-52a0aa60cf05`. Each case has nine alternating samples on CPU 13,
with identical resulting states and pinned input/binary hashes. Own builds,
tests and profiles finish before timing. Hardware launcher compilation finishes
before its event measurements. A one-second pre-observation found the selected
CPU and its sibling lightly loaded; external activity is not continuously
audited. Positive time change means slower.

| Kernel | First parent → trial (ms/batch) | Time change | Repeat parent → trial | Time change |
| --- | ---: | ---: | ---: | ---: |
| zcoder.zsh/coder-paste | 120.062 → 122.550 | +2.07% | 119.102 → 123.477 | +3.67% |
| zcoder.zsh/coder-layout | 5.820 → 5.813 | -0.12% | 5.822 → 5.821 | -0.02% |
| zcoder.zsh/coder-wide-layout | 66.460 → 66.352 | -0.16% | 66.507 → 66.314 | -0.29% |
| zchat.zsh/chat-paste | 216.382 → 224.752 | +3.87% | 218.526 → 224.687 | +2.82% |
| zchat.zsh/chat-layout | 5.804 → 5.805 | +0.02% | 5.802 → 5.800 | -0.03% |
| zchat.zsh/chat-wide-layout | 66.797 → 66.521 | -0.41% | 66.366 → 66.475 | +0.16% |
| endgame/endgame-world | 44.597 → 44.442 | -0.35% | 44.824 → 44.719 | -0.23% |
| z3dfx.mario/mario-race | 20.704 → 20.836 | +0.64% | 20.762 → 20.883 | +0.58% |
| z3dfx/shooter-step | 12.007 → 12.229 | +1.85% | 12.293 → 12.290 | -0.02% |
| z3dfx.agy/shooter-step | 12.015 → 12.231 | +1.80% | 12.183 → 12.319 | +1.12% |
| z3dfx.grok/shooter-step | 12.076 → 12.197 | +1.00% | 12.122 → 12.378 | +2.11% |
| zfetch/fetch-encode | 13.829 → 13.727 | -0.74% | 13.864 → 13.763 | -0.73% |
| z3dfx.drawing/drawing-binning | 13.153 → 13.126 | -0.21% | 13.135 → 13.089 | -0.35% |

| Kernel | First parent → trial (ms/call) | Time change | Repeat parent → trial | Time change |
| --- | ---: | ---: | ---: | ---: |
| JSON array | 95.1450 → 97.3150 | +2.28% | 95.8150 → 97.8880 | +2.16% |
| JSON array encoding | 207.9640 → 211.6010 | +1.75% | 211.3990 → 212.3480 | +0.45% |
| JSON validation | 92.2587 → 94.5953 | +2.53% | 93.4507 → 95.3297 | +2.01% |
| navigation | 1.9535 → 2.0109 | +2.94% | 1.9603 → 2.0229 | +3.19% |

Endgame is essentially flat; this round does not claim an application speedup.
Parser, search and array control groups, including all slower controls, remain
in the evidence alongside both customer/library groups.

The power-specific driver times warm batches including parsing and dispatch;
function definition, warmup and result validation are outside the timer:

| Expression | Mode | Powers/batch | Parent → trial (ms/batch) | Time change |
| --- | --- | ---: | ---: | ---: |
| `0**0` | normal | 30000 | 2.4320 → 2.3880 | -1.81% |
| `2**0` | normal | 30000 | 2.3470 → 2.3070 | -1.70% |
| `2**1` | normal | 30000 | 2.3180 → 2.2260 | -3.97% |
| `2**2` | normal | 30000 | 2.2810 → 2.2550 | -1.14% |
| `2**3` | normal | 30000 | 2.3180 → 2.2500 | -2.93% |
| `2**8` | normal | 30000 | 2.3110 → 2.2700 | -1.77% |
| `(-2)**31` | normal | 30000 | 2.8470 → 2.6640 | -6.43% |
| `2**60` | normal | 30000 | 3.1290 → 2.3190 | -25.89% |
| `1.25**2` | normal | 30000 | 4.3910 → 4.3580 | -0.75% |
| `0.0**2` | normal | 30000 | 3.2150 → 3.1840 | -0.96% |
| `2**-2` | normal | 30000 | 2.7300 → 2.6430 | -3.19% |
| `(-2)**3.0` | normal | 30000 | 4.1290 → 4.0400 | -2.16% |
| `2.0**0.5` | normal | 30000 | 4.8350 → 4.7760 | -1.22% |
| `1**65536` | normal | 50 | 2.1910 → 0.0170 | -99.22% |
| `1**1048576` | normal | 50 | 34.7900 → 0.0140 | -99.96% |
| `0**1048576` | normal | 50 | 34.7700 → 0.0150 | -99.96% |
| `(-1)**65537` | normal | 50 | 2.1920 → 0.0150 | -99.32% |
| `2**2` | float | 30000 | 2.5960 → 2.5400 | -2.16% |
| `1**65536` | float | 30000 | 2.6220 → 2.5170 | -4.00% |

For example, 50 evaluations of `1**1048576` drop from about 34.79 ms to 0.014 ms.
That ratio is specific to this batch; the new duration is only tens of
microseconds. It is not a general shell speedup. The bounded ordinary exponent
`2**60` improves by about 26%. Common small powers and floating controls remain
in the table rather than being inferred from the large-exponent result.

Matched private-release Callgrind totals remain nearly unchanged:

| Kernel | Parent instructions | Trial instructions |
| --- | ---: | ---: |
| Endgame | 1,144,450,051 | 1,144,468,297 |
| Mario | 430,983,248 | 431,071,620 |
| JSON array encoding | 2,653,577,700 | 2,653,593,694 |

These are whole-process instruction counts, distinct from warm batch timers.
The four installed hardware-counter cases are fully scheduled. Coder paste
instructions are effectively unchanged (1,385,395,497 → 1,385,395,576), while
median cycles rise from 704,387,865 to 727,007,298. This supports retaining the
latency concern; counters alone do not identify its cause. Raw profiles, flat
reports, event samples and output hashes are retained.

## Exploratory code-layout variant

The integer change increases the private GCC `op()` body by 27 bytes and shifts
following functions, including `mathparse()`, by 32 bytes. A second, GNU-guarded
variant requests 64-byte alignment for `mathparse()`. It also shifts other math
functions because it changes object-section alignment; it is not a controlled
experiment isolating only the parser entry. It has no new semantic algorithm.

A separate private parent/variant pilot has nine alternating samples per case:

| Kernel | Private parent → aligned trial (ms) | Time change |
| --- | ---: | ---: |
| zcoder.zsh/coder-paste | 119.586 → 121.602 | +1.69% |
| zcoder.zsh/coder-layout | 5.805 → 5.782 | -0.40% |
| zcoder.zsh/coder-wide-layout | 66.026 → 65.278 | -1.13% |
| zchat.zsh/chat-paste | 223.196 → 219.583 | -1.62% |
| zchat.zsh/chat-layout | 5.760 → 5.770 | +0.17% |
| zchat.zsh/chat-wide-layout | 65.899 → 65.340 | -0.85% |
| endgame/endgame-world | 44.816 → 44.464 | -0.79% |
| z3dfx.mario/mario-race | 20.880 → 20.711 | -0.81% |
| z3dfx/shooter-step | 12.453 → 12.309 | -1.16% |
| z3dfx.agy/shooter-step | 12.360 → 12.264 | -0.78% |
| z3dfx.grok/shooter-step | 12.379 → 12.215 | -1.32% |
| zfetch/fetch-encode | 13.863 → 13.786 | -0.56% |
| z3dfx.drawing/drawing-binning | 13.047 → 13.066 | +0.15% |
| JSON array | 98.3930 → 97.1120 | -1.30% |
| JSON array encoding | 215.1480 → 212.3360 | -1.31% |
| JSON validation | 96.8160 → 93.1037 | -3.83% |
| navigation | 2.0092 → 1.9949 | -0.71% |

Results are mixed, and coder paste remains 1.7% slower. This pilot compares
private executables, not the installed pair above, and has no repeated installed
certification. It neither proves layout caused the first regression nor
establishes that the hint fixes it. The variant is also shelved; its source,
binary fingerprint and all samples are retained. No arbitrary padding or
compiler alignment requirement is added to production.

## Validation of the first candidate

- GCC release candidate: 63 upstream scripts pass, zero failures, two skips.
  Clang parent and candidate each pass 63/0/2. The DEBUG development candidate
  passes 62/0/3. The pristine run of the added C01 blocks passes.
- The native power matrix records **730,944 observations in 18 Memcheck
  processes**, with zero reported errors (leak checks disabled). This includes
  repeated host/locale/compiler matrices, not that many distinct expressions.
  Each common run has 60,832 observations: integer/float operands, ordinary and
  compound powers, four rounding modes, FORCEFLOAT/CPRECEDENCES combinations,
  zero, signs, signed limits, fractional/negative exponents, nonfinite floating
  inputs and deterministic randomized integers. It compares result types/bits,
  parameter state, errno, FP exceptions and arithmetic globals. Per-host SDKs
  preserve DEBUG/release queue declarations.
- Candidate-only huge-exponent checks add 160 observations per selected run,
  including `ZLONG_MAX` exponents for bases 0, 1, -1, 2 and -2. Closed-form
  identities provide the oracle. The legacy host is deliberately not asked to
  evaluate these huge loops. Counts are 729,984 common plus 960 huge observations.
- High-level comparisons include 192,360 arithmetic observations across five
  locales, 704,585 scalar comparisons, 5,192 array checks, 193,236 search checks,
  159,600 pattern checks, 2,640 substitution checks, 200,832 native floating API
  observations, 20 accessor cases, 36 completion PTY cases and 512 emulation cases.
  Customer correctness includes 24 project/locale kernels and five original
  project test suites. These focused checks do not prove universal compatibility.
- All seven inactive-package suites pass against its exact release ELF, with
  the tested native zdraw/zcurl/zmdown modules staged into that prefix. Full
  package verification passes, including installed components and **24 actual
  Oh My Zsh sessions** using re5et, git and the syntax highlighter unchanged.
  The installed pair preserves all 1,056 dynamic export names/types; both
  stripped executables are 846,488 bytes. Native installed power checks pass.

One setup failure is retained: the first pristine C01 invocation used a temporary
working directory, so the harness could not find its expected `../Src/zsh`.
The corrected invocation uses the pristine build's Test directory and passes.
`additional-builds-final.json` reconciles the successful retry; original failure
receipts and logs remain under `initial/setup-failures/`.

## Restoration and next work

The inactive trial remains available for investigation, but active links never
changed. Transient Vendor module outputs were restored from the exact active
payload. All 1,853 canonical package input hashes match the active build again,
and the developer ELF returns to SHA-256
`86c7153edc3e45bf994bc02236213dab83a836f00028392c1cbc9bcc8c4acae6`.
The restored developer passes 62/0/3 and another 121,664 native power observations
under two zero-error Memcheck processes. Huge-exponent tests are not run against
the restored linear implementation.

Fresh normal-user `Packaging/verify.py verify` passes for the active release,
including 24 new interactive OMZ sessions, component/startup checks and 11,828
protected entries unchanged. Its historical seven suite receipts are reused
for the identical active artifacts; the full seven suites were rerun for the
inactive trial. The active release's 1,603-entry manifest, `/etc/shells`, login
shell and stable Zsh remain unchanged.

The [evidence index](results/round33/README.md) distinguishes the first fully
tested candidate, the exploratory alignment variant and restored state. The
original private rc0 draft, tag and seven assets are retained. No release asset
is replaced or published.

Future work should return to the measured whole-table scope teardown cost or
carefully guarded arithmetic execution plans. Logarithmic powers remain an
algorithmic opportunity, but this implementation needs a more reliable customer
performance case before adoption.
