# Round 95 — copy long literal runs during quote-marker removal

Round 95 adopts the bulk copy. It cut the time for zcoder's wide-buffer
viewport updates by 35% in two runs, with equal peak live heap and equal
private resident memory after sustained layout work.

Zcoder's height-only update checks that the text still matches the
previously wrapped buffer. On round 94, Callgrind attributed 165.4 million
of the wide-viewport process's 628.4 million instructions to
`remnulargs()`. Most of those instructions ran in the byte-by-byte copy
after the first removable marker. The profile includes the initial wrap,
updates and output checks. Its biggest allocation site was the command
stack for nested subscript parsing during layout. This change targets the
copy inside quote processing.

## Behavior

Zsh represents some quoting information as internal bytes. Before the
first removal, `Bnullkeep` is preserved. After a removal, subsequent
`Bnullkeep` bytes must become backslashes. Removing every byte produces
the shell's `Nularg` representation of an empty argument.

When at least 512 bytes follow the first removal, the candidate builds
a set of bytes requiring further processing from the live `INULL` flags
and `Bnullkeep`. It uses `strcspn` to locate the end of the first literal
run and `memmove` to shift it left. The existing loop handles the
remainder, including dense marker sequences. The set is constructed
once per eligible call and fits all 255 nonzero byte values and the
terminator. Short tails continue through the scalar loop. The threshold
uses round 11's existing 512-byte cutoff for scanning long strings.

## Timings

| Zcoder, 128 viewport height changes | Round 94 | Round 95 | Pristine Zsh |
| --- | ---: | ---: | ---: |
| 64 ASCII characters | 0.916 ms | 0.897 ms | 2.256 ms |
| 10,000 ASCII characters | 3.839 ms | 2.708 ms | 6.817 ms |
| 10,000 wide characters | 16.472 ms | 10.596 ms | 24.944 ms |

The 12-sample test rotated the three binaries on CPU 13. Every run
returned identical text, rows, visual lengths, offsets, cursor and
viewport geometry. On the wide input, the batch saved 5.88 ms, or about
46 microseconds per height change. This is a kernel measurement of the
project's layout function.

Repeating with the development builds in reverse starting order gave
16.366 vs 10.663 ms on the wide buffer and 3.862 vs 2.764 ms on long
ASCII. On inputs of 508–514 ASCII characters the new median ranged from
1.3% slower to 5.5% faster. At 64 characters the two runs disagreed on
direction, with differences below 0.025 ms per batch.

Across two nine-sample runs of all 14 project workloads, with the starting
order reversed, rebuilding zcoder's wide layout took 1.2–1.4% less time.
Endgame world generation took 36.58 vs 36.86 ms and 36.84 vs 37.03 ms.
Zcoder paste took 0.8% more time in both runs, and zchat paste took
0.7–1.0% more. Against pristine Zsh, rebuilding the wide layout took
55.31 vs 122.11 ms, including earlier gains. Five-sample scalar-write
controls included slower whole assignments at 1,088 and 1,089 bytes
(4.0% and 6.1% more time).

## Memory

The 20-cycle runs sampled five fresh processes per build and workload.
Median retained anonymous RSS was identical on zcoder paste (464 KiB),
zcoder wide layout (1,360 KiB) and zchat paste (484 KiB). Endgame went
from 1,348 to 1,344 KiB. Main-heap size and main-heap RSS matched on
all four workloads, as did total virtual size. Median peak RSS fell 44 KiB
on wide layout and rose 76 KiB on zchat paste.

In the longer comparison the shell ran two forced wide layouts per cycle,
with the initial shell order reversed. At cycle 120, median private
resident memory was 2,212 KiB on both builds. Round 94 and round 95 used
1,368 and 1,364 KiB of anonymous RSS, 5,492 and 5,384 KiB peak RSS, and
92,516 KiB of virtual address space. Both had a 1,132 KiB main heap with
1,084 KiB resident. These process figures are medians from five shells.

DHAT recorded 6,667,628 allocated bytes over 82,031 events on both builds.
Both had 659,529 bytes live at peak and 356,396 bytes live at exit. Separately, Callgrind counted 628.4 million
instructions on round 94 and 492.8 million on round 95 for that worker.
Self instructions in `remnulargs()` fell from 165.4 million to 5.9
million. The total includes the library routines it calls. In these two
PGO/LTO binaries the compiler increased the stack adjustment in the
function's nonempty path by 16 bytes. Executable text grew 256 bytes,
and data and BSS sizes matched.

## Verification and reproduction

The native fixture compares the entire allocation to pristine Zsh,
including alignment guards and bytes after the new terminator. Round 95
adds 800 cases at eight alignments with 510, 511, 512, 513 and 1,024 bytes
in the tail under the default classification. They cover an entirely literal
tail and backslashes at the beginning, middle and end. Five configurations
vary the exported byte classification, including the full set and a
`Bnullkeep` with its `INULL` bit cleared.

All 31,003 marker cases matched pristine Zsh on round 94 and round 95 in
C and C.UTF-8 under Memcheck. Round 95 also matched pristine Zsh on
63,840 pattern and 2,640 substitution comparisons. The release passed
24 Oh My Zsh terminal sessions with the configured re5et theme, git
plugin, syntax highlighter, completion, history and async prompt checks.
All seven paired native-loader cases passed. Upstream passed 64 scripts
and skipped the privileged-mode and GDBM tests. Bundled zjson passed
14,237 checks per locale. The two development builds exported the same
1,071 dynamic symbol names.

The release uses the packaging compiler's PGO training and LTO flags.
The build and measurement commands, binary hashes, raw samples, profiles
and gate results are under `Perf/results/round95/`. The viewport driver
and worker are under `Perf/results/round94/`. Timing, profiling and
compatibility runs were separate. The customer benchmark validated
application state in both run orders.
