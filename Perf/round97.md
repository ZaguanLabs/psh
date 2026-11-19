# Round 97 — share the token scan for long literal patterns

Round 97 adopts the shared scan. It reduced the time for height-only
updates on zcoder's long wide buffer by 23.9–24.6% across both run orders. The
cost on sustained wide-layout work was 4 KiB of retained private memory.

Zcoder compares its input buffer to the previously wrapped text when the
viewport height changes. On round 96, Callgrind attributed 65.0 million
instructions to `patcompile()` in the wide-buffer worker. Identifying a
literal required checking the token classification of each input byte.

## Change

The pattern compiler now shares the token search used by `untokenize()`.
It checks the first 64 bytes individually. If at least 1,024 bytes remain,
it reads the current token classification table and searches the remaining
string with `strcspn()`, in groups of up to 15 token values. The smallest
offset found in any group is the first token. Short tails use a byte scan.
With no tokens the helper returns the terminator. It needs 16 bytes of
temporary token storage and keeps no cache between calls.

Filename patterns retain their component scan, which must also stop at a
slash. Quoting, token conversion, fallback to wildcard compilation and the
compiler's buffer-sizing rule still use their existing semantics.

## Application timings

| Zcoder, 128 height changes | Round 96 | Round 97 | Pristine Zsh |
| --- | ---: | ---: | ---: |
| 64 ASCII characters | 0.857 ms | 0.907 ms | 2.200 ms |
| 10,000 ASCII characters | 2.649 ms | 2.244 ms | 6.725 ms |
| 10,000 wide characters | 9.332 ms | 7.098 ms | 24.758 ms |

Each build ran 12 samples per input on CPU 13. With the development
builds in reverse starting order, long ASCII took 2.676 vs 2.223 ms
and wide text took 9.330 vs 7.032 ms. The small 64-character control
went the other way on repeat (0.914 vs 0.896 ms). Both builds returned
the same text, rows, offsets, cursor and viewport.

Two nine-sample runs covered all 14 customer workloads, with the starting
shell reversed. Zcoder paste took 1.7–2.1% less time and zchat paste took
0.9–1.7% less. Zcoder's forced wide-layout rebuild took 0.2–1.2% more
time, and the drawing binning workload took 1.8–2.3% more. All customer
runs checked application state.

The separate 31-case scalar-assignment benchmark used seven samples per
build. Whole ASCII assignment of 64 characters took 2.9% more time. At
1,024 characters it took 16.4% less time, and the million-character case
was within 0.1%.

## Memory and instruction counts

After 120 cycles of two forced wide-layout rebuilds, round 97 retained
2,200 KiB of private memory vs 2,196 KiB on round 96. Anonymous RSS was
1,368 vs 1,364 KiB, total RSS was 4,916 KiB on both, and peak RSS was
5,756 vs 5,712 KiB. Both kept 1,084 KiB resident in a 1,132 KiB main
heap. These are medians over five processes per build.

The separate 20-cycle comparison also measured 4 KiB more private
resident memory on wide layout. Peak RSS varied with the run, falling
252 KiB on that shorter comparison. Zcoder paste, zchat paste and
Endgame had identical retained private memory and main-heap sizes
after 20 cycles. The executable gained 1,544 bytes of text, and process
virtual size was 4 KiB higher on all four workloads.

After 128 height-only updates, glibc reported 445,328 bytes in use on
both builds. After switching to a small literal, both used 395,776 bytes.
At each point, 948 KiB of the 964 KiB main heap was resident. These
figures are medians over six processes per build. Callgrind counted
466.81 vs 411.31 million instructions for the complete wide viewport
worker, including the initial wrap and final state checks.

DHAT recorded the same 6,667,628 requested bytes over 82,031 events on both
builds. Peak live heap was 659,529 bytes, and 356,396 bytes were live at
exit.

## Native behavior

The pattern probe exercises eight token positions, from an empty prefix
through 4,096 bytes. For each position it toggles the classification of
the wildcard byte and checks both ordinary and filename patterns. It
verifies the compiled literal flag, returned end pointer and actual match.
In the filename cases, the slash after the wildcard ends the component.
In the ordinary cases the trailing `/z` participates in the match.

The Linux release binary retains all 1,071 earlier dynamic symbol names
and adds `findtoken`, which is shared between the two core files. The
public `untokenize()` and pattern entry points keep their signatures.

The native conversion fixture matched pristine Zsh on 78,732 inputs per
locale under Memcheck, including the allocation bytes past the resulting
terminator. The bounded pattern fixture passed 3,920 checks per shell
across C and C.UTF-8, both multibyte settings and both signal queue modes.
The extended differential suite matched pristine on 63,840 pattern checks
and 2,640 substitutions.

All 24 Oh My Zsh terminal sessions passed, covering the configured re5et
theme, git plugin and syntax highlighter, completion, history, asynchronous
prompts and Ctrl-C recovery. All seven paired native-loader cases passed.
Upstream passed 64 scripts and skipped privileged mode and GDBM. Bundled
zjson passed 14,237 checks in each locale.

## Reproduction

The packaging compiler trained both PGO/LTO releases independently. The
measurement commands, raw samples, binary hashes, profiles and gate
results are under `Perf/results/round97/`. The viewport worker and the
allocator probe are under `Perf/results/round94/`. Builds, timing,
profiling and compatibility runs used separate intervals.
