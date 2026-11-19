# Round 96 — skip an unused length scan during literal matching

Round 96 adopts the matcher change. Zcoder's height-only updates on a
10,000-character wide buffer used 10.8–10.9% less time in two run orders.
Peak live heap and sustained private memory matched round 95.

Zcoder checks that the input buffer still equals its wrapped copy when
only the viewport height changes. Zsh can compare those strings in its
internal byte representation, where a Meta prefix and a following byte
encode one original byte. The round 95 matcher also counted the decoded
bytes in the input. The profile of the wide-buffer viewport case
attributed 26.2 million instructions to the inlined length scan in
`patallocstr()`.

## Matcher behavior

After the usual input normalization, `pattryrefs()` can use the original
bytes for a literal or match-all program when the caller supplies no
decoded buffer and the program has no path exclusion. The matcher uses its existing
encoded length and skips the call that counted the decoded bytes. Match length, dot-file handling,
match references and globbing flags still go through the existing match
logic.

Native callers can request the decoded byte count from `patallocstr()`
even when it returns a null buffer. They can also force decoding and
pass that buffer back to the matcher. Both paths retain their original
length units. The test module checks these cases with exact-size,
unterminated spans containing an encoded NUL and Meta byte. It covers
an equal literal, an extra suffix, an unanchored match, and a leading
dot with and without dot-file protection.

## Application timings

| Zcoder, 128 height-only updates | Round 95 | Round 96 | Pristine Zsh |
| --- | ---: | ---: | ---: |
| 64 ASCII characters | 0.912 ms | 0.892 ms | 2.202 ms |
| 10,000 ASCII characters | 2.702 ms | 2.679 ms | 6.830 ms |
| 10,000 wide characters | 10.537 ms | 9.401 ms | 25.068 ms |

Each build ran 12 samples per case on CPU 13 in rotated and reversed
order. The worker checked the text, rows, offsets, cursor and viewport.
The smaller effect on long ASCII is consistent with the previous length
scan already using a bounded library search to skip inputs without Meta
escapes.

The two-build repeat reversed the starting order and reproduced the wide
result at 10.677 vs 9.508 ms, a 10.9% reduction. Long ASCII took 2.722 vs
2.710 ms. Among the short ASCII controls, the 513-character case was 1.7%
slower, or 0.018 ms for all 128 updates.

Two nine-sample runs covered all 14 customer workloads. Zcoder's forced
wide rebuild took 55.282 vs 55.356 ms and 55.496 vs 55.530 ms. Zcoder
paste took 0.7–0.8% less time and Endgame 1.4% less in both orders.
Mario race took 0.2–0.6% more. Zchat paste moved in opposite directions
across the two runs. All comparisons produced matching application state.

## Memory

After 20 workload cycles the median retained private memory was the same
on both builds for zcoder wide layout (2,260 KiB), zchat paste (1,380 KiB)
and Endgame (2,240 KiB). Zcoder paste went from 1,364 to 1,360 KiB.
Main-heap resident pages, reserved main-heap size and total virtual size
matched on all four workloads. Peak process RSS moved in both directions,
from 24 KiB lower on wide layout to 28 KiB higher on zchat paste. Each
comparison used five fresh processes per shell.

After 120 cycles of two forced layouts each, with the starting build order
reversed, both builds retained 2,260 KiB private and 1,364 KiB anonymous
RSS. The main heap held 1,084 KiB resident in 1,132 KiB of virtual space.
Median peak process RSS was 5,580 KiB on round 95 and 5,496 KiB on round
96.

During height-only updates, glibc reported 445,328 bytes in use on both
builds after 128 updates, dropping to 395,776 bytes after the next small
literal. At both checkpoints, 948 KiB of the 964 KiB main heap was
resident. These are medians across six fresh processes per build.

DHAT recorded identical totals for the wide viewport worker on both
builds, with 6,667,628 bytes requested over 82,031 allocation or resize
events, 659,529 bytes live at peak, and 356,396 at exit. Callgrind
measured 492.83 vs 466.81 million instructions for the complete process,
including the initial wrap and final state checks. Instructions attributed
to the inlined scan in `patallocstr()` fell from 26.20 to 0.18 million.

## Compatibility

Round 96 passed 24 interactive Oh My Zsh sessions, including the
configured re5et theme, git plugin, syntax highlighter, completion,
history, async prompt and interrupt recovery. All seven paired
native-loader cases passed. Pristine Zsh and round 96 agreed on 63,840
pattern checks and 2,640 substitution checks. Upstream passed 64 scripts
with two skips (privileged mode and GDBM). Bundled zjson passed 14,237
checks in each of C and C.UTF-8.

The bounded native pattern fixture passed 3,664 checks per build under
Memcheck across C and C.UTF-8, multibyte on and off, and both signal queue
modes. It ran on pristine Zsh and both development binaries. The two
development binaries exported the same 1,071 dynamic symbol names.

## Reproduction

The measurements used independently trained PGO/LTO release builds. Build
commands, exact binary hashes, raw samples, profiler output and test
results are under `Perf/results/round96/`. The viewport and allocator
drivers are under `Perf/results/round94/`. Timing ran separately from
builds, profilers and compatibility checks.
