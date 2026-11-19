# Round 99 — skip zero-filling joined parameter expansions

On round 98, Callgrind counted 22,578 calls that constructed a parameter
expansion with surrounding text during zcoder's wide viewport workload.
The shell knew the expanded value's length. It allocated a zero-filled buffer,
copied the prefix and value, then copied the suffix. Zeroing the buffer
accounted for about six million instructions in this run.

Round 99 uses the same shell heap and allocation size. The prefix copy
still pads to its specified width. The value copy includes its terminator
so that optional glob tokenization sees only the expanded value. The suffix
copy follows tokenization and includes the final terminator. All destination
bytes are initialized by these copies. Byte lengths use `size_t` throughout
the join. The change is private to parameter substitution.

## Project timings

| Workload | Round 98 | Round 99 | Round 98, reversed | Round 99, reversed |
| --- | ---: | ---: | ---: | ---: |
| Zcoder paste | 65.032 ms | 63.904 ms | 65.352 ms | 64.706 ms |
| Zchat paste | 111.453 ms | 110.725 ms | 111.363 ms | 110.400 ms |
| Zcoder, 128 wide viewport updates | 6.945 ms | 6.809 ms | 6.956 ms | 6.863 ms |
| Zcoder, 128 long ASCII viewport updates | 2.222 ms | 2.210 ms | 2.224 ms | 2.223 ms |

Both release builds used the packaging compiler's profile training and
link-time optimization. The 14 customer cases used nine alternating samples
per build on CPU 13. A second run reversed the starting build. The viewport
comparison used 12 samples per input and build, rotating both development
builds and pristine Zsh. Both long viewport inputs contained 10,000
characters. Every run compared the resulting application state.

Zcoder's skill-fold operation took about 1.5% less time in both runs.
The three shooter-step workloads took 0.1–1.2% more time. The two runs
disagreed on the direction for forced wide-layout rebuilds in zcoder and
zchat, with differences under 0.4%.

When the same paste handlers were sourced, zcoder took 65.54 ms vs 66.60 ms
on round 98, and zchat took 113.24 vs 113.93 ms. Against pristine Zsh,
round 99 was 2.08× as fast on direct zcoder paste, 2.11× on direct zchat
paste and 1.47× on Endgame. Those ratios include gains from earlier rounds.

A separate control assigned either a whole variable or the same value
surrounded by literal text. Joining 32 ASCII bytes took 2.4% more time.
Joining 4,096 bytes, 65,536 bytes and 1 MiB took 3.1%, 5.3% and 2.8%
less time respectively. Whole-variable assignment at these three larger
sizes differed by at most 0.2%. Each comparison used 12 alternating samples
and verified the final bytes against an independently constructed result.

## Memory and instruction counts

After 120 cycles of forced wide-layout rebuilding, both builds had 1,016 KiB
resident in a 1,020 KiB main heap, 1,300 KiB of anonymous RSS and 92,408 KiB
of virtual address space. Median private memory fell from 2,244 to 2,236 KiB
and whole-process RSS fell from 4,792 to 4,748 KiB. Peak RSS increased from
5,396 to 5,492 KiB. The separate 20-cycle wide-layout run measured the
opposite direction for peak RSS. Each comparison used five processes per build.

After 20 cycles, all four workloads had equal resident main-heap sizes on both
builds. Private memory changed by −4 KiB on zcoder paste, +8 KiB on wide
layout, 0 KiB on zchat paste and −4 KiB on Endgame.

After the viewport's 128 height changes, glibc reported 395,520 bytes in
use and 987,136 bytes in the arena on both builds. DHAT recorded the same
6,617,564 bytes requested in 82,030 allocation events, a peak of 659,529 live
bytes and 306,588 live bytes at exit for the complete worker.

Callgrind's cache simulation counted 66.73 million data writes on round 99
vs 67.25 million on round 98. Simulated L1 data-cache write misses fell
from 614,722 to 405,674. Total instructions rose from 404.81 to 405.97
million. Those counts include the initial text wrap and final verification.

## Compatibility and reproduction

The focused expansion fixture compared complete argument counts and bytes
on pristine Zsh, round 98 and round 99. It covers empty scalars and array
elements, embedded NUL and invalid bytes, long values, glob substitution
with matching filenames, quoted suffixes, RC-style array expansion, padding,
reevaluation and side-effecting subscripts. Across C and C.UTF-8 it compared
16,923,826 bytes per build with identical results and zero Memcheck errors.
The fixture toggles multibyte mode in each locale.

All 24 Oh My Zsh terminal sessions passed, including the configured re5et
theme, git plugin and syntax highlighter, completion, history, prompt redraw,
async callbacks and Ctrl-C recovery. All seven paired native-loader checks
passed. The Linux binaries export the same 1,074 dynamic symbols.

The differential suites matched pristine Zsh on 2,640 substitutions and
63,840 pattern cases. Upstream passed 64 scripts and skipped privileged mode
and GDBM. Bundled zjson passed 14,237 checks in each locale.

Raw samples, exact interpreter hashes, profiles, build logs and compatibility
evidence are under `Perf/results/round99/`. To reproduce from this revision,
extract its source into `.work/round99/trial/build/`, create
`.work/round99/trial/logs/` and unpack `build.py.gz` into `.work/round99/`.
With the pristine and round 98 builds in the recorded locations, run from the
repository root.

```sh
python3 .work/round99/build.py trial
bash Perf/results/round99/run.sh
```

The driver runs timing, memory checkpoints, profiling and compatibility
tests in separate intervals.
