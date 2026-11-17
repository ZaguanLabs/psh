# Round 76: linear compaction of floating-point underscores

Accepted into the development source. `lexconstant()` previously called
`chuck()` for every underscore in a floating-point literal. Each call shifted
the remaining expression, so long underscore spans or long expression tails
caused repeated copying. The replacement compacts the numeric span in one pass
and moves the remaining expression once, including its terminating NUL.

This is a narrow algorithmic improvement for supported arithmetic syntax, not
a claim of a large general application speedup. The same full expression copy
is allocated on the existing heap; ownership, conversion, evaluation order,
options, diagnostics and native interfaces remain unchanged. No memory saving
or intentional incompatibility is claimed.

## Benefit and cost

A few percent of runtime can be a reasonable price for a substantial memory
reduction or a simpler implementation. The decision is based on that balance,
not a requirement that every benchmark improve. Round 74 remains a useful
example. Round 75 remains rejected because it added bookkeeping for a small
idle-prompt benefit without additional memory savings; its raw slower controls
and unsuccessful implementation remain available.

This change removes repeated work with a small implementation. Both focused
runs use nine alternating samples on CPU 13, after compilation and correctness
checks, without concurrent own tests or profiling. Times below are median
milliseconds for the entire indicated synthetic batch, including repeated
evaluation of a trailing named parameter and incrementing side effect.

| Underscores | Trailing `+0` terms | Evaluations | Round 74 → candidate | Repeat |
| ---: | ---: | ---: | ---: | ---: |
| 0 | 0 | 10,000 | 15.448 → 15.343 | 15.594 → 15.480 |
| 4 | 0 | 10,000 | 15.753 → 15.561 | 15.991 → 15.492 |
| 64 | 0 | 3,000 | 8.791 → 5.043 | 8.765 → 5.061 |
| 1,024 | 0 | 100 | 13.556 → 0.327 | 13.623 → 0.298 |
| 16,384 | 0 | 3 | 91.531 → 0.088 | 91.737 → 0.085 |
| 64 | 4,096 | 100 | 22.503 → 10.478 | 22.446 → 10.516 |

The zero-underscore control remains on its original path. All complete result
states match. Peak resident memory for these fresh processes stays around
3.7–3.8 MiB; small page-count differences do not establish an allocation saving.

Both customer comparisons cover all thirteen kernels, with nine alternating
samples each and identical complete states. The first run ranges from roughly
flat to 4% faster; the repeat has small mixed differences, including endgame
46.079 → 46.266 ms and drawing 12.956 → 12.967 ms. Chat paste is
215.380 → 214.271 ms in the repeat. These normal workloads do not establish
that this rare syntax path explains their small changes. All results, including
slower controls, are retained in `results/round76/customer*.json`.

Separate memory runs cover all thirteen customer kernels with three alternating
samples per host. Fresh-process median peak RSS ranges from 3,828–5,600 KiB
for the control and 3,812–5,708 KiB for the candidate. Retained-memory probes
preserve and verify live results through twenty cycles. At cycle twenty,
candidate medians range from 3,988–4,940 KiB resident and 1,316–2,304 KiB private.
Anonymous resident memory differs from the control by at most one 4 KiB page
per case. Both hosts show the same modest workload-related growth, such as
116 KiB between cycles one and twenty for coder wide layout. There is no
observed memory benefit or material retention penalty from this change.

Virtual sizes are roughly 90 MiB and match between hosts at these boundaries;
they are address-space measurements, not physical memory consumption. The
probe records RSS, private, anonymous, proportional, peak and virtual values
separately. It does not measure allocator reservations or claim that all
virtual space is an allocator reservation.

Separate Callgrind runs evaluate the 1,024-underscore expression twenty times
plus one warm evaluation, with identical final values and side effects:

| Binary | Whole-process instructions |
| --- | ---: |
| Actual installed rc2 release | 61,089,435 |
| Matched round-74 GCC/LTO control | 60,989,916 |
| Round-76 GCC/LTO candidate | 3,113,138 |

The installed release spends 57,921,024 instructions in `chuck()`. GCC/LTO
attributes the corresponding control work to the inlined `lexconstant()`.
The installed release uses its own release configuration; only the matched
round-74/candidate pair is used to attribute the source change. These counts
are instruction evidence, not elapsed-time measurements.

## Correctness and native behavior

- Full upstream suite: 64 successful scripts, zero failures, two skips.
  The new arithmetic regression exercises long underscore spans, exponent
  syntax, following identifiers and side effects with FORCEFLOAT/OCTALZEROES.
- 3,432 exact stdout/stderr/status observations match pristine Zsh, accepted
  round 74 and the candidate. Cases include generated underscore placements,
  malformed input, expression tails, signed zero, range extremes, C/C.UTF-8
  locales and option modes.
- A 96-observation subset matches the control and candidate under Memcheck
  (192 shell executions), with no reported memory errors.
- The existing native arithmetic fixture now includes sixteen more fixed
  inputs. Its strict expected count increases to 1,693,120 checks per
  host/locale: 6,772,480 checks across two hosts and two locales, with matching
  digests. It compares result bits, endpoint/tail text, errno, floating-point
  exceptions, rounding modes, options, character-table mutations, unchanged
  original input and guard-page behavior. Each module uses its host's SDK.
- The unchanged OMZ terminal gate passes all 24 sessions, including the active
  configuration and genuine interactive behavior; framework/startup sources
  remain unchanged. The native-loader gate passes fourteen observations
  (seven matched comparisons).

No checks were relaxed. The native fixture count was increased to account for
the additional inputs. Full native-fixture Memcheck coverage is not claimed.

## Reproduction and disposition

`Perf/check-float-underscores.py` drives the differential checks;
`Perf/float-underscore-benchmark.py` and its Zsh worker retain binary hashes,
alternating samples and result checks. Existing customer and memory drivers
provide application controls. Logs, complete observations, instruction profiles,
patches and identities are retained under `Perf/results/round76/`; larger
evidence is gzip-compressed.

The private build is `.work/round76/build`, with matching source and runtime
under `.work/round76/`. It uses GCC 15.2.0, `-O2 -g -flto`, multibyte and PCRE,
with debug-shell mode disabled. Candidate binary SHA-256:
`ac175cb55b03f56fcf7a8cd0555933a8e6e8522cd7a2abf32172250d305e73a0`.
The promoted core and upstream regression are byte-identical to the tested
private source. The initial configure launch raced snapshot extraction and
failed to find `configure`; its log is retained. The properly ordered retry,
build and private installation succeeded.

The active installed release remains unchanged. This round is source
development only; `Packaging/verify.py verify` is required before activation.
