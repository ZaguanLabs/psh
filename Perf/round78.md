# Round 78 — allocate a private function lookup name only for autoload

Every invocation of `doshfunc()` used to copy the function name into the
caller's shell heap before entering the function's own heap. A native caller
can make many callbacks inside one command. All those copies then live until
the caller releases its heap. The installed release's coder paste profile in
round 72 shows over 20,000 calls into the function runner, and its wide-layout
allocation profile in round 73 also shows function dispatch on allocation
stacks.

The development build now reads the existing name when checking for
`TRAPEXIT`. For a preloaded ksh-style function with `EF_RUN`, it takes a
private copy immediately before executing the autoload file and uses the copy
for the subsequent lookup. This preserves the lookup key even if that file
deletes or replaces its own function. The copy lives in the function heap
through the lookup. Function stack entries, script names, positional arguments
and the special trap scope keep their existing ownership.

## Live memory

One fixture registers 4,096 hooks and runs a single builtin `cd`. Another
invokes 4,096 callbacks from a small native builtin in one heap scope, looking
the function up afresh each time. Both check the invocation count and stop
inside the final callback for a Linux memory reading. Each comparison used
three fresh processes per host with alternating order. The measurements
below are median **within-process growth in anonymous resident memory** from
ready to the final callback, in KiB. The baseline and candidate use matching
GCC builds with `-O2 -g -flto`.

| Entry point | Function name length | Round 76 | Round 78 |
| --- | ---: | ---: | ---: |
| Native callback | 24 bytes | 128 | 4 |
| Native callback | 1,024 bytes | 4,376 | 8 |
| Directory-change hook | 24 bytes | 488 | 360 |
| Directory-change hook | 1,024 bytes | 8,772 | 4,416 |

With 24-byte hook names, peak RSS growth was 500 → 372 KiB, and private
resident growth was also 500 → 372 KiB. Both builds returned to a median
580 KiB of anonymous memory after the hook command. This saving occurs while
the batch is live. The installed release reproduced the hook behavior in an
independent comparison (488 and 8,780 KiB of growth respectively). These
fixtures concentrate calls in a single scope and the long names amplify the
effect. Normal customer scripts use much smaller batches.

## Application behavior

All thirteen customer kernels produced the same complete outputs in two
serial timing runs. Each used nine alternating samples on CPU 13. The second
run reversed the initial host order. Median changes in both directions were
under 1% in each run, including coder paste at 114.834 → 115.376 ms and
114.228 → 114.292 ms. Memory profiling and compatibility checks ran outside
these timing comparisons.

At cycle twenty, median anonymous memory on the repeat was 1,392 → 1,400
KiB for coder wide layout and identical for chat wide layout (1,388 KiB),
coder paste (464 KiB) and endgame (1,324 KiB). Virtual size was identical
within each pair. Coder wide-layout peak RSS was 5,316 → 5,416 KiB in that
run. The native and hook fixtures account for the adoption decision; the
customer checkpoints show no consistent retained-memory saving. The initial
customer memory run overlapped an isolated C04 check and the repeat ran alone.

Separate Callgrind runs on coder paste recorded 1,270,488,817 → 1,268,947,191
instructions with the same state hash as the timed batch (a 0.12% decrease).

The upstream suite passed 64 scripts with two skips. The added C04 regression
then passed in a separate run. It checks a preloaded function that deletes
and replaces itself and another that deletes itself, including the diagnostic
and return status. A standalone fixture also compared self-removal, direct
TRAPEXIT and argument handling with pristine Zsh and round 76. Stdout, stderr
and status agreed across all three shells and under candidate Memcheck. All
24 interactive OMZ sessions and all seven native-loader comparisons passed.
The module probe was compiled against each shell's matching headers. Its
initial positional feature-table initializer failed compilation and was
replaced by a designated initializer before measurement.

## Reproduction

`Perf/check-function-call-memory.py` accepts `--shell` twice (control first),
`--mode chpwd` or `--mode native`, and `--output PATH`. Native mode takes
two matching `--module PATH/call_probe.so` arguments in the same order.
Compile `Perf/function-call-probe.c` with `cc -shared -fPIC -O2 -g -Wall
-Werror -DMODULE -DHAVE_CONFIG_H` and include the matching build and source
`Src` directories. Hook mode uses the builtin directly.

Evidence in `Perf/results/round78/` includes the individual samples, host
identities, full memory readings, timing controls, compatibility results and
matched profiles. Accepted into the rc2 development branch. Activation
requires the separate packaging verification workflow.
