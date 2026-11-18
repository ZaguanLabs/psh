# Round 91 — reuse saved interpreter contexts

Round 91 uses a static record for the outermost interpreter context.
All 14 customer workloads had lower median times than round 90 in both
run orders. The clearest memory effect is lower allocation traffic.

Both paste handlers read the last six characters of their input buffer as
each byte arrives. Zsh saves its history, lexer and parser state while it
parses that subscript, then restores the state. On round 90, DHAT traced
20,012 allocations of a 328-byte context record to this path in one zchat
process, including warmup and the measured 10,000-byte paste. These
allocations alone totaled 6,563,936 bytes.

## Direct execution and sourcing

The first trial gave the outermost context a static record and kept the
old allocation and release path for deeper contexts. This avoided about
20,000 allocations per paste benchmark process when the worker ran as a
script. When the shell sourced the same worker, the enclosing operation
held the static record. The trial then avoided just three context
allocations on each project.

The second trial keeps one inactive record in a private pointer. A save
takes it before saving any state, or obtains a new record when all are
in use. A restore finishes restoring the requested state before making
its record available. If another record is already available, it frees
the one it has just restored. Both operations run under the existing
signal queue. Active contexts stay independent at every nesting depth.
The first save uses the allocator, and subsequent operations can retain
up to one record per process. Both trials preserve the public save and restore interfaces and the
storage exposed to native modules.

## Measurement

The release builds used the packaging pipeline's profile training and
link-time optimization. Application timings used nine alternating samples
per host on CPU 13 and a second run with the starting order reversed.
The sourced comparison used 12 samples per shell, rotating and reversing
the order across three builds. All comparisons checked the full resulting
application state. DHAT ran separately from timing. Its totals include
startup, warmup and validation. The executable paths in the final DHAT
comparisons have equal lengths.

## Results

| Direct paste, milliseconds per batch | Round 90 | Outer record | Round 90 repeat | Outer record repeat |
| --- | ---: | ---: | ---: | ---: |
| zcoder | 68.118 | 66.708 | 68.455 | 67.103 |
| zchat | 116.853 | 115.343 | 115.017 | 113.522 |

With the worker sourced, zcoder took 69.35 ms on round 90, 68.08 ms
on the outer record and 69.02 ms on the spare. Zchat took 116.23 ms,
115.39 ms and 116.26 ms respectively. A separate direct comparison of
the two trials over 15 samples also favored the outer record on zcoder
paste (67.23 vs 68.06 ms), zchat paste (114.06 vs 115.77 ms) and
Endgame (36.75 vs 36.89 ms). This and the smaller retained private-memory
deltas favored keeping the outer record. Against pristine release Zsh,
zcoder paste took 67.29 vs 131.77 ms and zchat paste 113.28 vs 234.42
ms. Those comparisons include gains from earlier rounds.

| Cumulative DHAT allocation, bytes | Round 90 | Outer record | Spare record |
| --- | ---: | ---: | ---: |
| zcoder, script | 26,985,356 | 20,368,940 | 20,369,268 |
| zchat, script | 36,040,399 | 29,420,703 | 29,421,031 |
| zcoder, sourced | 24,914,126 | 24,913,142 | 18,297,710 |
| zchat, sourced | 33,188,621 | 33,187,637 | 26,568,925 |

The accepted build removed 20,172 malloc calls on direct zcoder paste
and 20,182 on direct zchat paste. Peak live heap matched round 90 at
161,784 bytes and 163,874 bytes respectively. The 328-byte static
record is outside DHAT's heap accounting. Linker BSS grew by 352 bytes
including alignment. The spare build kept one additional 328-byte heap
block at process exit in all four comparisons.

Linux memory checkpoints sampled five fresh processes per shell after
20 workload cycles and repeated with the initial host order reversed.
Across both runs of all four workloads the accepted build's retained
private memory stayed within 8 KiB of round 90, and virtual size matched.
On zchat paste, median peak RSS was 88 and 200 KiB lower. On zcoder
paste it was 108 and 68 KiB higher. There was no consistent overall
resident-memory saving. The spare's retained private memory ranged from
equal to 16 KiB higher than round 90 and its virtual size was 4 KiB higher.

The compiler controls produced the same eight bytecode dumps as round 90.
Compiling zcoder's 48 libraries took 24.44 vs 24.57 ms with identical
retained private memory (5,128 KiB). Zchat's 19 libraries took 6.64 vs
6.67 ms and private memory was 4 KiB higher.

## Compatibility and reproduction

The native probe exercises all 64 pairs of outer and inner masks,
including empty, partial and full saves. It changes state at both
levels and checks that each restore recovers only its requested
components. It also checks the history command stack address and depth.
The probe runs directly, in a child shell and inside eval. Build and
run it as a native module using the matching shell headers.


The probe passed on pristine Zsh, round 90 and both trials, including
under Memcheck. Each trial passed 2,640 substitution comparisons against
pristine Zsh, all 24 interactive Oh My Zsh sessions, seven paired
native-loader cases and 64 upstream scripts with two skips. Bundled zjson
passed 14,237 checks in each of C and C.UTF-8.

For the sourced timings, run `Perf/results/round91/sourced.py` with
Python and supply each binary with `--shell`, the project directory with
`--labs`, a CPU number and an output path. For allocation profiles, run
the release shell under `valgrind --tool=dhat` with `-df
Perf/customer-workload.zsh chat-paste PROJECT 1`, or with `-dfc
'source "$@"' caller` followed by those same script arguments. The
profiles, patches, timings, memory samples and binary identities are in
`Perf/results/round91/`.
