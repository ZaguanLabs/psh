# Round 68: one-pass separator construction, not adopted

This investigates the small avenue nominated after round 67: `sepsplit()` called
`wordcount()` and then rediscovered separators while materializing fields. The
trial eliminated that repeated discovery for explicit nonempty separators,
building their pointer vector and fields in one pass.

The prototype was corrected during private development and then rejected on
customer timing. **No production C change is adopted.** No new cache, allocation
lifetime, native structure or language behavior is part of the retained source.
The final code at commit `c8e20df` remains unchanged.

## Trial and allocation ownership

The trial begins with an eight-pointer vector and retains the same `zhalloc` or
`zalloc` choice as the original caller. It grows the pointer vector before its
final slot is needed, preserves the used index across growth, and leaves the
terminating NULL in a valid slot. Heap-backed growth allocates another arena
vector and copies the private prefix; permanent-backed growth uses `zrealloc()`.
The pointer array is not published until complete. Field strings use the
original allocation mechanism and exact copied byte ranges. `NULL` and empty
separators stay on their existing legacy paths.

This deliberately does not retain vector capacity after return, expose raw
parameter arrays to native code differently, or introduce geometric array
storage. `wordcount()` and all other callers remain available and unchanged.
The retained prototype is `Perf/results/round68/candidate.patch.gz`.

Private development exposed several bugs in the prototype and its fixtures.
The prototype originally lacked `t = s`; upstream then failed while reading its
test file, and one candidate handoff rejected the OMZ fixture's `keepsuffix` call.
The unrelated preceding build passed all 24 OMZ sessions. A pointer-vector
growth review also moved capacity checking before the potential final-slot write.
These were repaired before the accepted validation results; no failing core or
interactive result is presented as successful.

The private native fixture also initially accepted an invalid dash-containing
module name, used a mismatched `zsfree()` argument, and retained no base pointer
when freeing strings. Its hardcoded case-loop count exceeded its array. The fixed
fixture derives count from `sizeof`, frees the original base separately, and uses
a filename Zsh accepts. The completed probe below, not those fixture failures,
verifies production allocation behavior. No bug is attributed to pristine Zsh or
the customer's OMZ installation from these development mistakes.

## Correctness evidence

The existing splitter checker additionally includes 8, 16 and 64-separator growth
cases. Ordinary enumeration therefore covers 21,840 observations per host: every
one-byte separator, selected multibyte separators, empty/repeated fields,
backslashes, Unicode and invalid bytes, in C/C.UTF-8 and zsh/ksh/sh emulations.
The complete `count\0element\0...` output is compared, not only joined strings.
Pristine Zsh, the preceding psh and the repaired candidate all match.

The keyed 840-case Memcheck subset adds the new growth cases to the former sample
without weakening comparison: explicit locale/emulation/separator/subject keys
reject missing cases and permit only byte-identical duplicate reference records.
There are no status/output differences in the final instrumented run. Error-exit
behavior from Valgrind remains enabled; leak checks remain disabled. This is not
a leak-freedom or every-case-instrumented claim.

A separate native fixture calls the existing generated `sepsplit()` declaration
against matching SDK headers. It exercises both heap values, empty and Nularg
inputs, multibyte text, invalid raw bytes and a genuine 64-separator growth case.
All eight preceding/candidate, C/C.UTF-8, plain/Memcheck executions return status
zero with the same raw-output SHA-256. Load and unload also complete; no native
public field or interface was added or modified.

The repaired candidate passes 63 upstream scripts with zero failures and three
skips, plus all 24 unchanged OMZ sessions. These include real completion, editor,
history, prompt, syntax-highlighting, async callbacks and Ctrl-C recovery. No
framework code, user startup file or active installation was changed.

## Timers and rejection

Matched development profiles of coder layout include loading, setup, operation,
validation and output, and have identical resulting state. Total instructions
fall from 131,875,782 to 130,715,172, **0.88%**. This matched development pair is
not compared numerically to the installed PGO+LTO profile retained in round 67.

All own builds, tests and profilers finished before timing. Focused measurements
use nine alternating fresh processes on CPU 13, C.UTF-8, with complete split-state
verification. Their internal warm batch timing is recorded separately from full
process elapsed time.

| Focused case | Previous -> candidate batch ms |
| --- | ---: |
| Short fields | 17.326 -> 16.428 |
| Long subject | 146.568 -> 103.308 |
| No matching separator | 18.215 -> 16.848 |
| Spaces | 16.527 -> 16.795 |
| Unicode text, ASCII separator | 20.639 -> 18.134 |
| Multibyte separator | 20.409 -> 17.953 |

These are all faster, with the long-subject process elapsed median improving from
149.553 to 105.967 ms (about **29%**). This is a focused helper workload, not a
customer application speedup.

Two exact-binary comparisons cover all thirteen existing customer kernels with
nine alternating samples each and identical states. Selected costs are:

| Customer workload | First, previous -> candidate | Repeat |
| --- | ---: | ---: |
| Coder paste | 115.738 -> 119.759 ms (**3.5% slower**) | 118.450 -> 124.586 ms (**5.2% slower**) |
| Chat paste | 213.306 -> 219.458 ms (**2.9% slower**) | 215.836 -> 218.102 ms (**1.1% slower**) |
| Coder ASCII layout | 5.542 -> 5.479 ms (1.1% faster) | 5.574 -> 5.568 ms (essentially flat) |
| Chat ASCII layout | 5.577 -> 5.516 ms (1.1% faster) | 5.647 -> 5.547 ms (1.8% faster) |

The primary paste regression is clear enough to reject the prototype despite
focused gains and the small instruction reduction. Layout improvements and every
unchanged/slower control remain in the stored full reports; there is no aggregate
score. This is not evidence of identical compiler layout or NV/GPU startup
speedups. Native renderer, external network and complete interactive application
timings remain separate uncovered scopes.

The one production hunk was removed surgically, restoring `Src/utils.c` exactly.
The rebuilt executable matches its pre-trial hash. Only the expanded test corpus,
trial evidence and research notes are committed; no additional interpreter
optimization is claimed. No candidate package, tag, archive, publication,
activation or account-shell change is produced.

## Reproduction

Run the ordinary checker against a chosen reference, then a candidate:

```sh
python3 Perf/check-separator-split.py --shell .work/round66/previous-build/Src/zsh \
  --output .work/round68/before.json
python3 Perf/check-separator-split.py --shell .work/release-candidate/Src/zsh \
  --reference .work/round68/before.json --output .work/round68/candidate.json
```

Apply the retained patch to an isolated source copy for the prototype, or read its
native source/results archive for exact allocation behavior. Timing comparisons
must use the same source roots, no concurrent builds/tests/profilers, and the
customer benchmark's complete source/state checks. All artifacts are under
`Perf/results/round68`.
