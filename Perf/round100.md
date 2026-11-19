# Round 100 — release arithmetic lookup storage after a read

Reading a variable in shell arithmetic requires a descriptor for its parameter
and subscript. Endgame's world-generation profile on round 99 recorded more
than 328,000 calls to the shell heap allocator from that lookup. The workload
generates a 2,736-tile world and checks the resulting terrain, landmarks,
creatures, party and game state.

Round 100 stores a fresh descriptor in the lookup function's C frame when a
binary operation consumes an operand or the evaluator reads its final result.
Nested numeric evaluation runs while that frame is still live. The descriptor
never leaves the call. Compound assignment keeps the left operand's descriptor
on the shell heap, so an expression such as `a[++i] += x` can write back
through the subscript it already evaluated. The existing evaluation order,
unary updates and short-circuit checks still apply. In the x86-64 release
binary the lookup function reserves 80 bytes of stack space vs 16 previously,
in addition to the same saved register. That 64-byte cost recurs for each
simultaneously active lookup and is released on return.

## Application timings

Each of the 14 project workloads ran nine alternating samples per build on
CPU 13, followed by a second run with the starting build reversed. The
harness compares the complete resulting state. All times below are medians
in milliseconds per batch. The pristine comparison used five samples.

| Workload | Round 99 | Round 100 | Round 99, reversed | Round 100, reversed | Pristine |
| --- | ---: | ---: | ---: | ---: | ---: |
| Endgame world generation | 36.502 | 37.486 | 36.686 | 37.471 | 53.887 |
| Mario race steps | 16.753 | 16.377 | 16.726 | 16.456 | 33.665 |
| Shooter steps | 8.903 | 8.684 | 8.959 | 8.722 | 16.826 |
| Zcoder paste | 64.322 | 63.882 | 64.443 | 63.829 | 135.446 |
| Zcoder wide layout | 56.552 | 55.371 | 56.515 | 55.461 | 122.833 |
| Zchat paste | 110.795 | 109.855 | 110.789 | 109.710 | 237.373 |

Twelve workloads took less time in both orders. Endgame took 2.1–2.7% more
time, and zcoder skill folding took 0.2–0.7% more. Endgame remained 1.43× as
fast as pristine in its paired comparison.

## Memory while arithmetic is running

The matched Endgame profiles counted 328,888 shell arena allocations from
`getmathparam()` on round 99 and 11,100 on round 100, including recursive
calls. Each descriptor is 40 bytes on this build. That removes 317,788 arena
requests, or 12.1 MiB of cumulative requested space, over the warmup, measured
work and result checks. Total instructions rose from 1,037.38 to 1,038.65
million. DHAT counted 141,579 system allocator events on both builds and
about 712,000 bytes live at peak. Shell arena requests can reuse existing
pages, so their cumulative size is much larger than the process footprint.

A separate scaling fixture sums a variable repeatedly in one expression.
A shell-defined math function pauses just before the final addition. The
parent reads Linux process memory before evaluation, at the pause, and after
return. It verifies the sum after resuming. The table gives the median
within-process increase in anonymous resident memory from the first checkpoint
to the pause, across six fresh processes per build and size.

| Reads in one expression | Pristine Zsh | Round 99 | Round 100 |
| ---: | ---: | ---: | ---: |
| 64 | 12 KiB | 12 KiB | 8 KiB |
| 8,192 | 376 KiB | 378 KiB | 56 KiB |
| 65,536 | 2,960 KiB | 2,964 KiB | 396 KiB |

At 65,536 reads the live private-memory increase also fell by 2,568 KiB.
Virtual size grew by 400 KiB vs 2,976 KiB on round 99. After the expression
returned, the two builds had broadly similar footprints again. This workload
illustrates the effect of keeping many reads in one shell evaluation.

All six project workloads had equal mapped and resident main-heap sizes
between builds after 20 cycles. At 120 Endgame cycles, both kept 1,068 KiB
resident in a 1,072 KiB main heap and used 92,460 KiB of virtual space.
Private memory was 2,240 vs 2,284 KiB, and both RSS and reported peak RSS
were 4,772 vs 4,780 KiB (round 100 vs round 99). After 20 Endgame cycles
the peak RSS went the other way, rising by 24 KiB. These are medians over
five processes per build.

## Compatibility

The arithmetic corpus matched pristine Zsh on 78,240 comparisons across C and
C.UTF-8, covering Zsh, ksh and sh emulations, option combinations, expression
values, diagnostics, side effects and status. All 144 focused stack tests
matched on pristine Zsh, round 99 and round 100. They cover subscripted
assignment, nested arithmetic, callback reentry, stack limits and recovery
after an error. A further 2,292 descriptor cases matched round 99 under
Memcheck, with zero reported errors. A native module exercised recursive
getters, setters, custom hash callbacks and queued signal delivery under
Memcheck on all three builds. All eight modes agreed. The Linux release
binary retained all 1,074 previously exported symbol names.

All 24 Oh My Zsh terminal sessions passed with the user's re5et theme, git
plugin and syntax highlighter. They exercise completion, history, prompt
redraw, asynchronous callbacks and interrupt recovery. All seven paired
native-loader cases passed. Upstream passed 64 scripts and skipped privileged
mode and GDBM. Bundled zjson passed 14,237 checks in each locale.

## Reproduction

The two development interpreters used independently trained PGO/LTO builds.
The timing driver ran separately from builds, memory checkpoints, profilers
and compatibility tests. Raw samples, exact binary and source hashes,
profiles and gate results are in `Perf/results/round100/`.

To repeat on this machine, extract this revision into
`.work/round100/trial/build/`, create `.work/round100/trial/logs/`, and
unpack `build.py.gz` into `.work/round100/`. With round 99 and pristine Zsh
at the locations in `run.sh`, run these commands from the repository root.

```sh
python3 .work/round100/build.py trial
bash Perf/results/round100/run.sh
```
