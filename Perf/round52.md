# Round 52: explicit timeout conversion bounds

The timeout correction uses range validation at the existing backend boundary.
It rejects values the old conversion cannot represent, rather than introducing
clamping, chunked waits, or a new clock/deadline mechanism. This leaves ordinary
poll/select and interruption loops intact. It is a correctness change with no
claimed performance gain.

## Implementation and compatibility

For poll's integer path, check the seconds against INT_MIN/1000 and INT_MAX/1000
before narrowing and multiplying. For the floating path, ordered comparisons
check the seconds before multiplication and the resulting milliseconds before
the integer cast. The second check covers rounding at the boundary. The open
bounds allow fractions whose truncated result is representable. Ordered tests
also reject NaN and infinities without converting them to int.

Select checks integer/floating seconds before the existing int conversion.
Fractional microseconds and the existing kernel error for negative timeval
fields retain their path. The descriptor-set guard from round 51 remains first.
Arithmetic expressions execute once; failed range checks precede I/O and
assignments to read-result/count variables. An error emits `timeout out of
range: EXPRESSION` and returns parameter error status 1. Status-dependent script
flow changes accordingly. ERRNO has no specified value for that parameter error.

On this platform, poll accepts integer seconds through 2147483, with a larger
fractional boundary determined by truncated milliseconds fitting a 32-bit int.
Select retains int-second limits even though Linux's timeval may be wider;
this preserves the existing conversion's defined range. Existing negative
millisecond waits remain indefinite on poll; negative timeval fields retain
select's OS error. `-0.0001` still truncates to zero milliseconds on poll.

Scripts relying on oversized values becoming zero, negative, or a shorter wait
must use explicit supported timeouts. Longer waits can be implemented by the
application with bounded waits and its own deadline. No universal negative
timeout policy or implicit timeout cap is added. `COMPATIBILITY.md` and the
module manual document the change. Installed rc2 remains active.

## Evidence

`Perf/check-sysread-timeout-ranges.py` independently computes conversion bounds
and expected file state. Each backend has 224 cases: signed integer boundaries,
adjacent binary floats, NaN/infinities, large magnitudes, expression side
effects, FORCE_FLOAT, C and C.UTF-8. Ready seekable stdin makes representable
long and negative waits bounded; Python inspects its shared offset afterward.
Instrumentation covers system.c using undefined/float-cast-overflow sanitizers,
not the entire shell. The select branch is forced in a private source copy on
Linux, with matching generated headers and error-name object.

| Backend | Preceding instrumented failures | Candidate failures | Unchanged representable controls |
| --- | --- | --- | --- |
| poll | 136 / 224 | 0 / 224 | 88 |
| select | 64 / 224 | 0 / 224 | 160 |

Pristine Zsh and installed rc2 also fail the same 136 poll rejection cases.
The normal release-profile candidate passes all 224. Original failing oracle
attempts are retained: FORCE_FLOAT made the side-effect counter print `1.`;
the expected output was corrected rather than changing the shell.

The existing 58-case timeout probe separately checks delayed pipe input, EOF,
SIGUSR1 retry behavior and arithmetic errors on both instrumented backends.
These bounded observations are not measurements of exact timeout duration.
Representable observations are compared with round 51; newly rejected inputs
are checked for parameter errors and untouched result/count values.
All 38 retained poll observations and 44 retained select observations match
round 51 exactly, including the tested signal retries. The remaining 20 poll
and 14 select observations now give explicit parameter errors. Both instrumented
probes finish with zero sanitizer diagnostics and zero harness timeouts.

The full upstream suite passes 62 scripts with zero failures and three skips
(privileged/optional-module coverage). All 24 unchanged OMZ terminal sessions
and the instrumented forced-select system-module suite pass. The 280-case
error-context matrix also passes, with its 112 controls matching pristine Zsh.
Results are retained under `Perf/results/round52/`. No deployment or publication occurs;
the full packaging/native gate remains required before activation.

## Reproduction

```sh
python3 Perf/build.py --which candidate --profile release
python3 Perf/check-sysread-timeout-ranges.py --shell .work/release-candidate/Src/zsh --backend poll --output poll.json --require-pass
python3 Perf/probe-system-timeouts.py --shell .work/release-candidate/Src/zsh --output waits.json
make -C .work/release-candidate check
python3 Packaging/check-ohmyzsh.py --candidate .work/release-candidate/Src/zsh --output ohmyzsh.json
```

Instrumented compiler argument lists and source copies are retained with the
evidence. Pass the private module root via `--modules`; for the select build
also pass `--backend select` to the range oracle. Runtime module paths and
hashes are checked, preventing accidental fallback to another module.
