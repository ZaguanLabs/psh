# Round 89 — reduce the lexer's initial word buffer

The lexer reserves 16 bytes when it starts a word, down from 32. Longer
words grow through the same allocator, with the same zeroed extension and
room for the terminator. This matters when compiling a file because many
token allocations stay live in the same temporary heap.

The first trial changed the initial size alone. Compiling zcoder's 48
library files retained 652 KiB less anonymous memory, but took 31.52 ms
against 26.39 ms for round 88. An input containing 32,768 words of 16
bytes each took 9.55 ms against 7.05 ms. These words all cross the new
growth boundary.

The second trial also changed how `hrealloc` finds the owner of an
allocation. With signals queued, it checks whether the old allocation
ends exactly at the used extent of the current arena. A positive aligned
size strictly smaller than that extent also establishes that the
allocation starts inside the arena. On a match, the allocator already has
the owner and can skip the linked-list search. The existing resize logic
still decides whether to grow in place or move the data. A first allocation
in an arena takes the original search so that replacing or unlinking the
arena has the correct predecessor. This uses the existing arena pointer
and adds no per-allocation metadata.

## Compilation

The compiler fixture builds a single read-mode dump from every `lib/*.zsh`
in each customer project. A separate set of 32,768-word arrays measures
behavior on either side of the growth boundaries. Every measured build
produced byte-identical dumps for each input. Each release used the
packaging pipeline's profile training and link-time optimization. Timing
and memory were measured in separate processes on CPU 13. Timing includes
starting the shell and writing the dump. Each workload had a warmup and
nine alternating samples per host in each comparison.

The repeat reversed the starting order. All times below are medians in
milliseconds. Peak RSS is the process high-water mark. Private memory
is from Linux smaps after the dump was written, with the shell still
running. Memory values are KiB.

| Workload | Time, 88 → 89 | Repeat time, 88 → 89 | Peak RSS, 88 → 89 | Retained private, 88 → 89 |
| --- | ---: | ---: | ---: | ---: |
| zcoder, 48 libraries | 26.68 → 23.95 | 26.43 → 23.83 | 8,432 → 7,792 | 5,832 → 5,184 |
| zchat, 19 libraries | 6.77 → 6.63 | 6.71 → 6.59 | 4,948 → 4,772 | 2,336 → 2,160 |

The repeat measured 644 KiB less private memory on zcoder and 176 KiB
less on zchat. Virtual size fell by 736 and 208 KiB respectively in
both runs. Against pristine Zsh, a separate five-sample comparison put
zcoder at 29.13 → 24.77 ms and zchat at 7.24 → 6.54 ms.

The 16-byte word control still cost 3.4–3.8% more time and showed
essentially equal private memory. The seven-byte word control retained
512 KiB less anonymous memory in the first comparison, matching 16 bytes
saved on each of the 32,768 tokens. Longer-word timings benefited from
the quicker resize, including 53.27 → 36.95 ms on 127-byte words.

A separate Callgrind run on the 48 zcoder files counted 7.19 million self
instructions in `hrealloc` on round 88. Smaller buffers alone raised this
to 24.60 million. Checking the trailing allocation brought it down to
1.00 million. Total instructions for compilation fell from 169.61 to
163.09 million. System-call traces counted 274 successful private
anonymous mappings for zcoder on round 88 and 228 on round 89, totaling
736 KiB fewer bytes requested over the process lifetime. Zchat used
63 mappings versus 76, a cumulative reduction of 208 KiB.

## Application execution

Both comparisons used nine alternating samples per shell on CPU 13, with
opposite starting orders. All fourteen customer workloads produced the
same application state. Zcoder paste took 68.83 ms against 67.05 ms on
round 88, then 68.83 ms against 67.24 ms in the repeat. Zchat paste took
116.06 ms against 114.54 ms, then 115.60 ms against 114.02 ms. Mario race
was slightly faster in both runs. The separate installed rc2 comparison
put zchat paste at 172.33 ms against 115.25 ms for round 89.

The memory checkpoints for running applications used five alternating
processes per shell and kept the verified state live for 20 workload
cycles. Retained private memory fell from 1,440 to 1,424 KiB on zchat
paste, 2,300 to 2,284 KiB on Endgame and 2,368 to 2,364 KiB on zcoder
wide layout. Virtual size was 16 KiB lower on each. Peak RSS was flat
on paste, 16 KiB higher on Endgame and 228 KiB higher on wide layout.
The sizable resident savings were specific to compilation.

## Compatibility and reproduction

The native heap probe grows a trailing allocation in place, resizes it
after another allocation, and grows it across an arena boundary. It
checks the preserved bytes, the adjacent allocation and the outer scope.
Existing cases exercise replacing and removing a whole arena, switching
heaps, rewinding and forking. The probe passed on pristine Zsh, round
88 and both trials, including under Memcheck. Compiling the zcoder
libraries also passed Memcheck in both C and C.UTF-8.

Both candidates passed 328 differential lexer cases, 36 cross-build
compiled-file checks, 24 interactive Oh My Zsh sessions and seven paired
native-loader cases. The upstream suite passed 64 scripts with two skips.
The bundled zjson suite passed 14,237 checks in each locale.

Run `python3 Perf/results/round89/compile.py BASE CANDIDATE --labs LABS
--cpu CPU --mode time --samples 9 --output time.json` for the compiler
comparison. Use `--mode memory` for the Linux memory checkpoints. The
inputs, binary hashes, both experimental patches and raw samples are
recorded in `Perf/results/round89/`.
