# Round 92 — reuse pipeline names in nested command lists

Round 91 allocated a copy of the active pipeline's display name on entry to
every nested command list with a nonempty name. Most of the copies in the
direct paste benchmarks held the same 12-character name. Each allocation
lived until its command list returned. A parent shell sourcing the same
worker clears the name on many of these calls.

Round 92 lets a nested list borrow its parent's saved name if the strings
match. A different nonempty name takes the existing allocation path. An
empty name needs only a null pointer. On return, the list restores the
original text, frees any copy it owns and reinstates the parent's pointer.
No copy survives the return from the outermost list. These operations
use the existing signal queue. The job-text limit, rendering, trap save
records and exported symbols are unchanged.

The other trial put a buffer large enough for any job name in each executor
frame. It eliminates all heap allocations at this site. On this x86-64
release build the executor's stack reservation grew from 328 to 408 bytes
with the buffer and to 344 bytes with sharing. The raw disassembly figures
exclude saved registers. Both trials use the packaging compiler's normal
profile training and link-time optimization.

## Customer workloads

The 14 application operations ran on CPU 13, with nine alternating samples
per shell. A second set reversed the starting order. The benchmark checked
the resulting state of every sample. Timings below are medians in
milliseconds per batch.

| Workload | Round 91 | Shared | Round 91 repeat | Shared repeat |
| --- | ---: | ---: | ---: | ---: |
| zcoder paste | 67.141 | 66.091 | 67.073 | 66.118 |
| zchat paste | 114.163 | 113.154 | 113.689 | 112.036 |
| Endgame | 36.643 | 35.904 | 36.520 | 35.843 |
| zfetch encode | 11.432 | 11.159 | 11.464 | 11.208 |

Sharing had lower median times on 13 workloads in both orders. Zcoder's
short layout moved from 4.764 to 4.747 ms in the first run and 4.755 to
4.761 ms in the second. With the worker sourced, zcoder paste moved from
66.82 to 67.10 ms and zchat from 114.11 to 114.32 ms across 12 samples
per shell. The fixed buffer was 1.1% and 0.6% slower than its sourced
controls, respectively. On direct drawing binning it was 1.1–1.4% slower
than round 91.

Against pristine release Zsh, direct zcoder paste took 66.42 vs 132.65 ms,
zchat paste 112.08 vs 235.10 ms and Endgame 35.85 vs 53.53 ms. Those
figures include previous rounds. A separate Callgrind run counted
1.94 billion instructions on zchat paste with sharing, down from 1.98
billion on round 91. Installed-shell controls are in the raw results.

## Allocation traffic and process memory

DHAT measured fresh processes running the same workload, including shell
startup, warmup and result validation. All hosts produced identical paste
contents. The table counts only allocations directly attributed to saving
the pipeline name.

| Copies per process | Round 91 | Fixed buffer | Shared |
| --- | ---: | ---: | ---: |
| zcoder, script | 160,190 | 0 | 8 |
| zchat, script | 220,232 | 0 | 8 |
| zcoder, sourced | 28 | 0 | 28 |
| zchat, sourced | 28 | 0 | 28 |

Direct zchat paste requested 26,557,530 bytes across the entire process
with sharing, down from 29,420,703. Zcoder fell from 20,368,940 to
18,286,313 bytes. Peak live heap moved from 163,874 to 163,786 bytes on
zchat and from 161,784 to 161,787 bytes on zcoder.

Linux checkpoint runs alternated five fresh processes per shell and then
repeated in reverse order. After 20 cycles of zcoder wide layout, sharing
reduced median anonymous memory by 28 KiB in both runs. Retained private
memory fell by 20 and 36 KiB there. On zcoder paste, retained private
memory rose by 36 KiB in the first run and fell by 12 KiB in the second.
Zchat paste and Endgame had equal retained private memory in both
comparisons. Median virtual size matched round 91 for all four workloads.
Peak RSS on zchat paste rose by 268 KiB in the first run and fell by
164 KiB in the second, so the direction of the peak RSS change varied.

The depth probe runs six fresh shells per build at each depth and reads
the resident stack mapping before recursion, inside the last function and
after unwinding. At depth 128 the median stack was 630 KiB on round 91,
650 KiB with the fixed buffer and 632 KiB with sharing. At depth 256 the
medians were 1,240, 1,280 and 1,244 KiB respectively. The stack pages were
still resident at the checkpoint after return.

In a direct comparison of the two trials over 15 samples, the fixed buffer
won zcoder paste by 0.50 ms and zchat paste by 0.65 ms. Endgame was
0.04 ms faster with sharing. We kept sharing for its smaller stack cost
at depth and lower retained private memory on wide layout.

## Compatibility and reproduction

A native probe drives seven nested levels with identical, changed, empty
and maximum-length names. It reads the interpreter's saved execution state
before and after each nested command so an incorrect restore is observable.
The probe ran directly, in a subshell and inside eval on pristine Zsh,
round 91 and both trials. Memcheck reported zero errors. A separate
controlling-terminal fixture runs a signal trap, suspends a pipeline inside
its consumer, checks the suspended job, foregrounds it and verifies the
delivered payload and empty job table. All four shells produced the same
suspended-job record.

Each trial passed all 24 interactive Oh My Zsh sessions with the configured
theme and plugins, seven paired native-loader tests and 2,640 comparisons
against pristine Zsh across C and C.UTF-8. The upstream suite passed 64
scripts, skipping the privileged and GDBM tests. Bundled zjson passed
14,237 checks in each locale.

Run the application comparisons with `Perf/customer-benchmark.py`, the
Linux process checkpoints with `Perf/memory-checkpoints.py`, and the
sourced controls with `Perf/results/round91/sourced.py`. To reproduce the
stack measurements, run `Perf/results/round92/depth.py` with one
`--shell PATH` per build and `--output FILE`. The native probe's exact
build and run commands are in `Perf/results/round92/probe/commands.sh.gz`.
The raw samples, profiles, both patches and binary hashes are alongside
those files.
