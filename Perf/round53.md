# Round 53: separate negative poll waits from duration conversion

The user asked for overflow checks that preserve negative waits. Round 52
checked both numeric bounds of poll's millisecond argument. Its negative lower
bound was unnecessary: poll assigns the same indefinite-wait meaning to every
negative timeout. This round handles that meaning before narrowing the number.

## Implementation

For integer poll timeouts, negative seconds select the sentinel `-1` directly.
Only nonnegative values go through the existing checked seconds-to-milliseconds
conversion. For floating timeouts, the first ordered comparison rejects NaN,
infinities and oversized positive values. All finite values at or below -1
second select `-1` without multiplying or casting their magnitude. Values
between -1 and zero retain multiplication and truncation; that bounded product
cannot overflow. Thus `-0.0001` still becomes zero, and `-0.001` still requests
an indefinite wait. Negative zero remains zero.

The upper bound checks and the existing poll/retry loop remain in place.
Select keeps round 52's conversion checks and existing negative-timeval error
behavior; this change does not unify backend policies. Expressions still
execute once and failed checks still precede I/O. No native ABI changes.

This deliberately supersedes round 52's rejection of very large finite negative
poll inputs. They now have the explicit indefinite-wait meaning rather than
depending on old overflow/wraparound. For example, `-4294967296` used to wrap
to zero on the tested pristine build, was rejected in round 52, and now waits
for input. Use zero explicitly for immediate polling. NaN and both infinities
remain errors. `COMPATIBILITY.md` and the module manual describe the distinction.

## Verification

The independent range/state oracle passes 244 cases per instrumented backend,
with zero sanitizer diagnostics. The normal release-profile poll build also
passes all 244. All 88 previously supported poll controls and 160 select controls
match round 52 exactly. The oracle now compares the intersection with reference
controls so newly accepted finite negative values are tested against their
explicit expected behavior rather than the old rejection.
Additional cases cover the minimum shell integer (constructed arithmetically),
the largest finite negative double, adjacent values around -0.001, and the
smallest negative subnormal. The initial 224-case reports are retained too.

The delayed-input/EOF/signal probe now covers 70 cases per build. The poll
candidate passes 14 negative-wait observations, including huge negative integer
and float values plus SIGUSR1 retries. Its other 56 observations match round 52.
All 58 previous select observations match; the added negative cases retain its
range/error policy. Both instrumented probes have zero harness timeouts and
zero sanitizer diagnostics. Delayed input is supplied after READY while the
writer remains open; an immediate poll cannot satisfy the expected successful
read. These are bounded functional observations, not timing benchmarks.

Pristine Zsh and rc2 are run through the expanded probe, and their raw results
are retained. Controls involving undefined conversions are observations only,
not a contract to preserve. Instrumented builds cover system.c, not the whole
shell. Select is forced in a private source copy on Linux x86-64, not tested on
a separate non-poll operating system. Loaded module paths and hashes are checked.

The universal V14 rejection fixture now uses `-Inf` instead of `-1e300`, since
the latter is intentionally accepted on poll. Real delayed-input checks cover
the accepted behavior. The upstream suite passes 62 scripts with zero failures
and three skips (privileged/optional-module coverage); all 24 unchanged OMZ
terminal sessions and the instrumented select V14 suite pass. Results are
retained under `Perf/results/round53/`.

## Reproduction

```sh
python3 Perf/build.py --which candidate --profile release
python3 Perf/check-sysread-timeout-ranges.py --shell .work/release-candidate/Src/zsh --backend poll --output ranges.json --require-pass
python3 Perf/probe-system-timeouts.py --shell .work/release-candidate/Src/zsh --output waits.json
make -C .work/release-candidate check
python3 Packaging/check-ohmyzsh.py --candidate .work/release-candidate/Src/zsh --output ohmyzsh.json
```

Instrumented source copies and compiler commands are included with the evidence;
pass their module root with `--modules`, and use `--backend select` for the forced
fallback. No installed release is changed and no performance gain is claimed.
The full packaging/native gate remains required before activation.
