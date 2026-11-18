# Round 84 — reuse one temporary heap mapping

The zcoder paste decoder calls shell functions repeatedly while processing a
10,000-byte paste. In round 83 that batch made 20,048 private anonymous
mappings. Most function scopes discarded a standard 16 KiB arena that the
next scope could have used immediately.

Round 84 keeps one standard mapping when `old_heaps` disposes of a scope.
It clears the whole mapping before retaining it, including bytes from
allocations already rewound by `freeheap` or `popheap`. A subsequent
standard allocation takes this mapping and initializes its header normally.
Both operations run under the existing signal queue. Suspended and active
scopes keep their own storage. Larger mappings, additional spare mappings,
and mappings rounded above 16 KiB by the OS follow the existing release
path. The change adds one internal pointer and preserves the module ABI.

## Application times

Two runs of nine alternating samples per host used CPU 13. The repeat
started with the opposite shell. Timing ran separately from building,
testing, tracing and memory sampling. All fourteen customer kernels
returned matching states in both comparisons.

| Milliseconds per batch | Round 83 | Round 84 | Round 83 repeat | Round 84 repeat |
| --- | ---: | ---: | ---: | ---: |
| zcoder paste | 112.65 | 82.18 | 110.83 | 82.31 |
| zcoder skill folding | 16.74 | 12.82 | 16.79 | 12.94 |
| z3dfx shooter step | 11.79 | 10.75 | 11.69 | 10.82 |
| zchat paste | 199.07 | 200.41 | 197.94 | 199.99 |
| Endgame world | 44.98 | 45.05 | 45.06 | 45.11 |

Paste spent 26–27% less time in zcoder and 0.7–1.0% more in zchat.
The other two shooter projects also improved in both runs. The archived
results include all fourteen controls. A five-sample comparison against
a pristine GCC release build took 131.72 ms for zcoder paste, versus
82.95 ms for this build. The installed rc2 took 97.38 ms versus 82.12 ms
in its own comparison. On zchat paste the installed rc2 was faster at
172.36 ms versus 198.74 ms. That 15.3% elapsed-time gap includes earlier
rounds and warrants more attention than the roughly 1% round 84 increment.

## Memory and mapping traffic

The final coder paste run made 30 private anonymous mappings requesting
511,568 bytes cumulatively, down from 20,048 mappings requesting
328,486,480 bytes. Successful whole-process unmaps went from 20,045 to
26. Skill folding fell from 4,015 mappings to 811, wide layout from 190
to 177 and the transcript batch from 239 to 207. These figures describe
system call traffic. The following measurements show physical footprint.

Linux smaps and process status were sampled with each application still
running and the result live. These are median levels in KiB across three
alternating samples per host at cycle 20. The transcript row uses five
samples at cycle 100, equal-length executable paths and a 64 KiB payload.
Each cell shows round 83 followed by the final round 84 build.

| Workload | Anonymous | Private | RSS | Peak RSS | Virtual size |
| --- | ---: | ---: | ---: | ---: | ---: |
| zcoder wide layout | 1,392 → 1,412 | 2,344 → 2,380 | 4,956 → 4,964 | 5,508 → 5,508 | 92,576 → 92,580 |
| zcoder paste | 464 → 488 | 1,420 → 1,460 | 4,000 → 4,068 | 4,000 → 4,068 | 91,708 → 91,712 |
| zcoder skill folding | 392 → 416 | 1,344 → 1,372 | 3,940 → 3,984 | 3,940 → 3,984 | 91,708 → 91,712 |
| Endgame world | 1,324 → 1,348 | 2,276 → 2,304 | 4,888 → 4,884 | 4,888 → 4,884 | 92,516 → 92,520 |
| zcoder transcript | 1,096 → 1,108 | 2,040 → 2,052 | 4,648 → 4,660 | 6,060 → 6,176 | 92,340 → 92,344 |

The cache itself holds at most 16 KiB per shell. Whole-process private
memory rose by 28–40 KiB on the four 20-cycle workloads. The transcript
cost 12 KiB private and 116 KiB peak RSS in the equal-path run. In the
first final-build comparison its private and peak RSS increases were
4 KiB and 192 KiB respectively. The earlier reuse build retained 80 KiB
more private memory in that fixture. The resident results depend on
process layout. The repeatable speed gains on the decoder and skill
folding justify the measured cost on this host.

## Smaller first arena

A separate build from round 83 started eligible scopes at 8 KiB. During
coder paste the cumulative sizes requested in private anonymous mappings
fell from 328,486,480 to 164,548,176 bytes, while their count increased
from 20,048 to 20,053. At 200 nested calls it reduced virtual growth
from 4,308 to 2,700 KiB. Both builds grew by 2,000 KiB of resident memory.

In two nine-sample comparisons the smaller arena made coder wide layout
about 5% faster, coder paste 4–5% slower and drawing binning 19–20%
slower. The 64 KiB transcript fixture retained 144 KiB more anonymous
memory at cycle 100 in this comparison. These results favor the existing
default arena size. The small-arena patch and its results are archived in
`results/round84/small/`.

## Verification and reproduction

The upstream suite passed 64 scripts with two skips. The final binary
matched stable Zsh across 24 interactive Oh My Zsh sessions, including
completion, history, highlighting, prompt updates, asynchronous work and
reference handback. All seven native-loader cases passed. An initial run
of the smaller-arena control timed out during Ctrl-C recovery on the
stable reference handback. A separate run of the same unmodified gate
completed all 24 sessions.

The native heap probe used matching headers for each host and exercised
nested scopes, suspended heaps, push/reset/pop, large-block growth and
release, and a subshell. It passed directly and under Memcheck. The
last-argument and large-append fixtures produced identical output in C and
C.UTF-8 on pristine Zsh, round 83 and the candidate, including under
Memcheck. The instrumented Valgrind build keeps the original unmapping
behavior and passed 500 nested function calls under Memcheck. Preprocessing
the allocator for the non-mmap and instrumented Valgrind paths produced
the same normalized source as round 83 in each case.

Run the mapping profile from the checkout with
`python3 Perf/heap-map-profile.py --shell BASE --shell CANDIDATE --zcoder PROJECT --output maps.json`.
It counts successful whole-process private anonymous mappings and checks
the resulting project state. The timing harness is
`Perf/customer-benchmark.py`. The memory drivers are
`Perf/memory-checkpoints.py`, `Perf/results/round81/transcript-memory.py`
and `Perf/results/round84/nesting.py`. Compile `Perf/heap-probe.c` with
`cc -shared -fPIC -O2 -g -Wall -Werror -DMODULE -DHAVE_CONFIG_H` and the
matching build and source `Src` include paths as `heap_probe.so`. Add its
directory to `module_path` and run `zmodload heap_probe && heap-probe`.

Individual measurements and build identities are in `results/round84/`.
The `reuse` directory holds the first reuse experiment. The `final`
directory holds the independent rebuild after preserving the instrumented
Valgrind path. Both release builds were measured. The installed rc2 was
used as a control. Activation is a separate packaging operation.
