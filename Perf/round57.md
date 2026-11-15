# Round 57: reject NaN flock retry intervals before conversion

After the committed PTY correction, the adjacent system-module review reached
`zsystem flock -i`. Its range check used two rejection comparisons. NaN passes
both, reaching an undefined conversion to long. Both pristine Zsh 5.9.2 and the
preceding psh release module silently acquire a lock for `-t 0 -i NaN` on this
host. The initial module-only sanitizer probe diagnoses the conversion.
See [the finding and bounded reproducer](bugs/flock-nan-interval.md).

The patch requires the existing lower/upper comparisons to succeed. It reuses
the same diagnostic and status 1 for NaN. It changes neither rounding nor the
bounds: ordinary finite inputs have the same eligibility. The test expressions
are still evaluated once, preserving their side effects. Invalid input returns
before the file is opened, the descriptor variable assigned, or later options
processed. COMPATIBILITY.md records the observable rejection and migration.
The acquisition/retry loops, `-t` parsing, native ABI and PTY code are intact.

## Validation

All test locks are on a private temporary file with `-t 0`; no call can wait
for a contended lock. A pipe handshake keeps each shell alive while Python
checks the POSIX record lock independently and inspects its target-file handles.
The process is then allowed to unlock and exit. Each handshake/process has a
five-second limit. The harness verifies the actual loaded system module/hash.

The matrix has 276 cases: two locales, ordinary/FORCE_FLOAT/C_PRECEDENCES
arithmetic, attached/separate interval options, 18 existing controls and five
NaN forms. Controls include subnormal inputs, fractions below a microsecond,
large finite values near the retained conservative upper bound, zero/negative
inputs, infinities and expression side effects. The oracle checks return value,
descriptor assignment, expression effects, exact diagnostics, live lock state
and open handles. Allocated descriptor numbers are validated then normalized
for comparison. An initial FORCE_FLOAT oracle expectation was corrected to
retain its existing `1.` side-effect output before collecting final evidence.

| Build | Checks | Failures | Existing-control differences / 216 |
| --- | ---: | ---: | ---: |
| Pristine release module | 276 | 60 | 0 |
| Preceding psh release module | 276 | 60 | reference |
| Candidate release module | 276 | 0 | 0 |
| Candidate UBSan module | 276 | 0 | 0 |

The 60 reference failures are the five NaN forms acquiring a lock instead of
rejecting the interval. The candidate rejects them without leaving a target
handle open or changing the destination variable. Existing invalid controls
still reject; valid controls still hold a lock until explicitly released.
The initial preceding-module UBSan evidence is a single-case probe, not a
complete instrumented reference matrix. The candidate UBSan build instruments
only system.c, including float-to-integer conversion checks, not the whole core.

V14 adds a lasting regression: NaN leaves the descriptor variable untouched,
followed by a successful sub-microsecond interval and unlock. The full upstream
suite passes 62 scripts with zero failures and three skips. All 24 unchanged
OMZ terminal sessions match; the framework sources are unchanged. Results are
retained with the evidence. Validation is on
Linux x86-64 with a 64-bit C long. This does not certify other architectures,
NaN timeout (`-t`) handling, unlock descriptor parsing or every lock lifecycle.
No speedup is claimed. Installed rc2 remains active; full isolated packaging
and native-library verification are required before activation.

## Reproduction

```sh
python3 Perf/build.py --which candidate --profile release
python3 Perf/check-flock-interval.py --shell .work/release-candidate/Src/zsh \
  --modules .work/release-runtime/lib/zsh/5.9.2 \
  --output .work/round57/candidate.json --require-pass
make -C .work/release-candidate check
python3 Packaging/check-ohmyzsh.py --candidate .work/release-candidate/Src/zsh \
  --output .work/round57/ohmyzsh.json
```

Use `--reference FILE` to compare all existing controls. To instrument system.c,
compile with the matching generated/source include directories and errnames
object, `-shared -fPIC -O1 -g -fsanitize=undefined,float-cast-overflow`. The exact
build commands, source/module identities and results are retained under
`Perf/results/round57`. Framework code runs as the ordinary user.
