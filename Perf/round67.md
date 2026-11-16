# Round 67: refreshed profiles and a rejected separator shortcut

This round returns to performance after the descriptor/port corrections. It
profiles the actual installed rc2 and tests one narrowly bounded raw-byte
separator shortcut. The interpreter change is **not adopted**. Production source
is restored to commit `0d69c05`; only profiling/checking tools and evidence are
added here.

## Installed-release baseline

`Perf/profile-customer-release.py` selects an executable and existing customer
workload explicitly. It records source and bytecode inputs before/after, complete
process state, binary hashes, raw Callgrind output and caller summaries. It does
not launch a full interactive application or substitute an elapsed-time result
for an instruction profile.

The installed `1.0.0-rc2-b80aa8a9db05` private executable (SHA-256 starts
`3a4b0785c95b`) records:

| Actual project kernel | Instructions | State |
| --- | ---: | --- |
| Endgame world construction, two iterations | 1,068,345,589 | `6299c35a...` |
| zcoder ASCII layout, two iterations | 122,661,011 | `64924155...` |

The previous round-41 profile is not substituted for this new observation.
Function-level costs confirm that repeated arithmetic remains Endgame's main
area. `mathparse`/`op`/the arithmetic lexer have self costs of 13.32%, 12.61%
and 10.84%; `itype_end()` contributes 5.23% and integer conversion 4.13%.
Allocation and parameter lookup retain separate costs. Existing arithmetic
ownership, recursion, option and callback boundaries still constrain an
execution-plan experiment; no such architecture is attempted here.

For coder layout, the explicitly elapsed source is smaller. `findsep()` accounts
for 3.26% in this installed PGO+LTO profile and is selected for a bounded probe.
The new driver initially treated a dot in `zcoder.zsh` as a filename suffix and
could collide across coder cases. It now replaces both dots and slashes before
adding output suffixes; both final profiles were regenerated with that naming.
The earlier naming-collision attempt is retained separately, not as final evidence.

Raw debug/source annotations include the packager's stale source prefix. The
normalized Endgame copy maps only that prefix back to the existing `.work/rc2`
source tree; both raw and normalized profiles remain. `Src/math.c` there has the
same SHA-256 as the current checkout. Counts are not rescaled or rebased. No
current `utils.c` source equality is claimed after the subsequent descriptor
fixes.

## Separator characterization and probe

`findsep()` examines each separator by a short byte-comparison loop, then advances
the subject by the existing metafied/multibyte length helper. For a separator
whose entire value is one byte, the trial replaces only the inner loop with
`**s == sep[0]`. Pointer/result behavior at matches is unchanged, and every
nonmatch retains the original advancement call. Multi-character and empty
separators retain their original code. There is no cache, allocation change,
native structure change, getter shortcut or additional signal boundary.

`Perf/check-separator-split.py` invokes actual split expansions in zsh, ksh and sh
emulation under C and C.UTF-8. Complete element structure is emitted as
`count\0element\0...`, preserving empty fields and arbitrary non-NUL bytes.
The corpus covers every one-byte separator and selected multibyte separators,
with empty, matching, repeated, quoted/backslash, Unicode and invalid-byte
subjects. Null-containing C strings are not representable in the argv fixture;
the existing internal Nularg cases remain in the broader suite.

- Pristine Zsh and preceding psh match on **17,160 observations** before the
  change. The candidate also matches all 17,160 after it.
- A representative **660-case** Memcheck subset passes with zero result/status
  differences. Leak checking is disabled; this is not a leak-freedom claim.
- The sampler excludes instrumentation stderr from textual comparisons, while
  preserving its nonzero error-exit gate. Ordinary runs compare stderr too.
- The sample lookup uses explicit invocation keys rather than a full-corpus
  length or positional zip. There are 12 identically recorded duplicate
  invocations, not missing result states. Missing keys and identical invocations
  with conflicting results remain errors. Two comparison-only failed attempts
  are retained in the logs; neither is evidence about product correctness.

The full ordinary corpus and the instrumented subset are intentionally distinct
coverage claims, not a claim of one huge Memcheck matrix.

## Measurements and rejection

Matched development builds, with identical source/module inputs except the
prototype, have one matching coder-layout result:
`64924155cfb1997fe5d269955bb385bd181e75dc488e9aae98a9927289148866`.

`findsep()` self cost falls from 4,000,304 to 3,680,352 instructions, about 8%.
The complete fresh profiling process nevertheless falls from 131,875,804 to
131,555,865, only **0.24%**. These matched ordinary-development numbers are not
mixed with or compared directly to the installed PGO+LTO totals above.

After builds, tests, profilers and the initial unrelated host paging completed,
`Perf/separator-benchmark.py` ran nine alternating, CPU-13, fresh-process samples
per case. It also records the process's internal warm split batch time separately.
Every sample's complete split state matches.

| Case | Previous -> candidate elapsed ms | Internal batch ms |
| --- | ---: | ---: |
| Short fields | 19.053 -> 19.208 | 17.155 -> 17.320 |
| Long subject | 147.563 -> 165.646 | 144.791 -> 162.796 |
| No match | 20.614 -> 20.910 | 18.541 -> 18.932 |
| Space-separated fields | 18.540 -> 18.846 | 16.605 -> 16.795 |
| Unicode text, ASCII separator | 22.903 -> 23.232 | 20.628 -> 21.046 |
| Multibyte separator fallback | 22.439 -> 22.655 | 20.433 -> 20.584 |

All six focused cases are slower in this phase. The long subject takes about
**12.3% more process time** and **12.5% more internal batch time**. Combined with
only 0.24% fewer profiled instructions in the customer layout, this rejects the
change. No broad customer timer is run to justify retaining it, and no gain is
inferred from the helper-local reduction.

The one production hunk was removed surgically, leaving the unrelated
`Doc/zsh.texi` working-tree hunk untouched. The rebuilt release candidate again
has SHA-256 `907bc451e2e09e8ee34336da9db58225c8b357c29dbdb2839b1e09165a04384f`,
matching the pre-experiment executable. The installed active rc2 was never
changed, activated, repackaged or published. No accepted core-optimization count
changes.

## Reproduction

```sh
python3 Perf/profile-customer-release.py \
  --shell /usr/local/psh/releases/1.0.0-rc2-b80aa8a9db05/bin/psh \
  --labs /home/stig/dev/ai/zaguan/labs \
  --challenge /home/stig/dev/challenge \
  --case zcoder.zsh/coder-layout --output .work/round67/release-actual
python3 Perf/check-separator-split.py --shell /path/to/reference/zsh \
  --output .work/round67/separator-before.json
```

Apply the retained trial patch to an isolated source copy for a matching
candidate, and supply matching source roots to the profile driver. Run
`check-separator-split.py --reference ...` for differential behavior and
`separator-benchmark.py` for fresh-process timings. Timing requires no ongoing
builds, tests or profilers; recorded host resource pressure is not treated as
a universal performance claim. All raw results and source identities are in
`Perf/results/round67`.
