# Round 58: lower bound for lock-descriptor table access

The next lock-lifecycle review found that the exported `zcloselockfd(int fd)`
checks only the upper bound before indexing the descriptor table. A plain
`zsystem flock -u -- -1` reports a normal error but still reads one byte before
the allocated table. Memcheck confirms this in both pristine Zsh 5.9.2 and the
preceding psh core. See [the finding and reproducer](bugs/negative-lock-descriptor.md).

A one-line lower-bound check in the helper rejects negative descriptors before
any table access. Keeping it in the exported helper also covers native callers.
The function still returns -1 without changing errno for rejected descriptors.
Its signature, table ownership, valid close behavior, lock counters and module
ABI are unchanged. The system-module caller keeps its existing diagnostics,
expression evaluation and fractional truncation. Unsafe negative results are
now deterministic errors rather than reads from unrelated memory.

## Validation

The Linux oracle creates two locks on separate private files and an unrelated
ordinary descriptor. After each attempted unlock, a pipe handshake pauses the
shell while Python checks both POSIX record locks independently and confirms
the ordinary descriptor is still open. It then lets the shell exit. Every
handshake/process has a ten-second limit; test locks use zero acquisition timeout.
Both close-on-exec and retained-on-exec lock registrations are exercised.

The shell matrix covers C/C.UTF-8, ordinary/FORCE_FLOAT/C_PRECEDENCES arithmetic,
valid closes of each lock, standard/ordinary/closed descriptors, INT_MAX,
negative integers through INT_MIN, negative fractions and expression effects.
There are 132 existing nonnegative-result controls and 96 negative-result cases.
`-0.9` remains a control: its truncation to descriptor zero is retained.

| Build/path | Cases | Failures | Existing-control differences |
| --- | ---: | ---: | ---: |
| Preceding psh core, shell controls | 132 | 0 | reference |
| Pristine release core, shell controls | 132 | 0 | 0 |
| Candidate core, shell matrix | 228 | 0 | 0 |
| Candidate core, direct native helper | 156 | 0 | n/a |

The test-only `lock_oracle` module calls the exported helper directly with
representable int values. It checks negative descriptors, unrelated/closed
ones and actual lock closes, while preserving a sentinel errno. It compiles
against the matching SDK and is never installed. The initial module name used
a hyphen, which Zsh disallows; that failed setup log is retained and the final
name uses an underscore. The direct-native matrix verifies 156 calls, including
60 negative calls, with independent lock state observations.

Original negative behavior is not used as an output oracle: it accesses memory
outside its object. The initial -1 reproducer is retained under Memcheck; larger
negative values are exercised only on the checked candidate. Ordinary controls
compare stdout, stderr, return status and state with both references. Incidental
descriptor numbers in control warnings are normalized; negative diagnostics are
retained verbatim. This is not an exhaustive diagnostic oracle.

The lasting V14 regression rejects a negative unlock, successfully unlocks the
real descriptor, and rejects a second close. All 228 shell-level and 156 direct
native cases also pass under Memcheck with zero reported errors. Leak checking
was disabled; no leak-freedom claim is made. The full upstream suite passes
62 scripts, zero failures, three skips. All 24 unchanged OMZ terminal sessions
match, with framework sources unchanged. Results are retained with the evidence. This correction has no
measured speedup claim. Installed rc2 remains active. Full isolated packaging
and native-library verification remain required before activation.

## Remaining boundaries

This fixes the helper's signed-int input domain. It does not validate the
system-module caller's conversion from a wider arithmetic result to int, or
float-to-zlong conversion in mathevali. Wide expressions can still alias valid
descriptors before reaching this helper. Those require a separate change and
characterization; the present test matrix intentionally uses representable
results. Timeout and retry-interval handling are unchanged. Validation is on
Linux x86-64, not a certification of other platforms.

## Reproduction

```sh
python3 Perf/build.py --which candidate --profile release
python3 Perf/check-lock-close.py --shell .work/release-candidate/Src/zsh \
  --modules .work/release-runtime/lib/zsh/5.9.2 \
  --output .work/round58/candidate.json
```

Use `--controls-only` for unchecked reference cores and `--reference FILE` to
compare controls. Add `--memcheck` for memory checking. Compile the test module
as `lock_oracle.so` with the matching generated/source includes and pass its
folder using `--native PATH`. Exact build commands, source/core/module hashes
and evidence are retained under `Perf/results/round58`.
