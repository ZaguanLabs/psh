# Round 93 — function calls and pattern state

Round 92 remains the accepted interpreter. The best pattern-state trial
removed 40,035 allocations from zchat paste and ran that workload about
1% faster. In the longer zcoder wide-layout comparison it retained 76 KiB
more anonymous memory and 84 KiB more private resident memory. We kept the
three trials as experimental controls.

Disabling a pattern operator with `disable -p` can change how arguments
match inside a shell function. Zsh snapshots the disabled operators on
entry because a function can set `LOCAL_PATTERNS` immediately before
returning. With that option set, return restores the entry state.
Otherwise changes propagate to the caller.

Round 92 kept a linked record for each call. On this release build the
record was 16 bytes. The pattern trial represents a sequence of enclosing
scopes that all entered with every operator enabled by an empty list.
Returning to such a scope with `LOCAL_PATTERNS` set clears the disables.
The first nonempty mask creates an explicit record. Every deeper scope,
including one entering with an empty mask, then pushes and pops a record
until the list is empty again. This preserves the boundary at which a
previously disabled operator must become disabled again. The decision
reads the live flag array, which native modules can modify directly.

## Two command-stack trials

The biggest common allocation in the direct and sourced zchat profiles
came from the 256-byte stack used by the `%_` prompt escape. The shell
allocates one for each function call, even when the function never prints a
prompt. Both trials gave each active call independent storage and kept up
to one idle buffer after return.

The first recycled the buffer when its address matched the one originally
supplied. On direct zcoder paste this reduced stack allocations from 20,021
to three. On zchat, overlapping function calls left 20,015 allocations
out of the original 40,035. Direct paste was around 1% faster. After 20
cycles, median anonymous memory on both paste workloads was 8 KiB higher
than round 92 in both run orders. Address equality also gives no capacity
guarantee after an in-place resize by a native caller.

The second trial asked the allocator to resize the returned buffer before
saving it. DHAT counted 40,036 stack allocations or resizes on direct zchat
paste, with 10,249,216 bytes requested against round 92's 10,248,960.
Both command-stack trials increased median virtual size by 4–8 KiB across
the four workloads. Both experimental patches are archived under `Perf/results/round93/`.

## Measurement

Each trial used the release compiler's profile training and link-time
optimization. Each of the 14 customer workloads ran nine alternating
samples per shell, pinned to CPU 13, followed by a second set in reverse
starting order. The harness checked complete application output. Four
workloads also ran against pristine Zsh and the installed psh. The sourced
paste timings used 12 samples per shell. DHAT and Callgrind ran separately
from the timing comparisons.

| Direct workload, median ms per batch | Round 92 | Pattern trial | Round 92 repeat | Pattern trial repeat |
| --- | ---: | ---: | ---: | ---: |
| zcoder paste | 66.219 | 66.139 | 66.086 | 66.119 |
| zchat paste | 112.749 | 111.056 | 114.490 | 113.408 |
| zfetch encode | 11.345 | 11.090 | 11.232 | 11.055 |
| Endgame | 35.803 | 35.934 | 35.937 | 35.931 |

Zcoder paste and Endgame moved in opposite directions across run orders.
Direct zchat paste used 0.9–1.5% less time and zfetch used 1.6–2.2% less.
Against pristine release Zsh the pattern trial took 66.11 vs 134.13 ms
on zcoder paste and 110.96 vs 233.57 ms on zchat paste, including gains
from prior rounds. With the worker sourced, median zchat paste fell from
114.73 to 113.75 ms and zcoder paste from 67.52 to 67.13 ms.

With a disabled operator saved by an enclosing function, sourced zchat
paste took 116.52 vs 115.67 ms and zcoder took 68.80 vs 68.41 ms. The
worker resets the current operators with `emulate -R zsh`. Its enclosing
record keeps the trial on the explicit-stack path during the worker;
each pair still returned identical paste contents.

DHAT attributed 40,035 allocations (640,560 bytes) on zchat paste and
20,021 (320,336 bytes) on zcoder paste to saving pattern state on round 92.
The trial eliminated all of them in direct and sourced runs. Across the
direct zchat process, peak live heap fell by 45 bytes, from 163,786 to
163,741. Direct zcoder peak fell by 13 bytes. These figures include
startup, warmup and result verification.

## Resident and virtual memory

The Linux checkpoint driver sampled five fresh processes per shell and
repeated the comparison with the shell order reversed. The following
deltas compare the pattern trial with round 92 after 20 cycles. Values
are median KiB in the first and second run.

| Workload | Anonymous RSS | Private resident | Peak RSS | Virtual size |
| --- | ---: | ---: | ---: | ---: |
| zcoder paste | +8 / +8 | +8 / +12 | −20 / −4 | +4 / +4 |
| zchat paste | +8 / +8 | +12 / +12 | −40 / +16 | +4 / +4 |
| Endgame | 0 / −4 | +16 / 0 | 0 / −16 | +4 / +4 |
| zcoder wide layout | +80 / +76 | +88 / +92 | +88 / +124 | +88 / +88 |

Private resident memory includes private clean file-backed pages.
Anonymous RSS isolates the resident anonymous pages. Virtual size includes
reservations. The pattern trial added 64 bytes of executable text on this
build, with identical data and BSS sizes.

A separate wide-layout run extended the checkpoint to 120 cycles with
five fresh processes per build. At cycle 20 median anonymous memory was
1,384 KiB on round 92 and 1,460 KiB on the trial. Both stayed at those
values through cycle 120. Final private memory was 2,164 vs 2,248 KiB,
peak RSS 5,564 vs 5,636 KiB and virtual size 92,516 vs 92,604 KiB.
The initial workload checkpoint differed by only 4 KiB of anonymous
memory. The gap opened during repeated layout work and then plateaued.

At depth 256, with every operator enabled, the separate recursion control
reduced DHAT peak live heap by 4,109 bytes. On Linux the resident part
of the process's main `[heap]` mapping fell from 196 to 188 KiB at the
deepest call and stayed there after unwinding. The mapping's reserved
virtual size rose from 264 to 272 KiB. Disabling one operator before the
outermost call sent all 257 calls through the explicit stack. Both builds
then used 196 KiB resident and 264 KiB virtual in this mapping. Each
checkpoint value is the median of six fresh shells.

## Compatibility and reproduction

A matching-SDK module checks four levels of nested pattern scopes against
independent snapshots of the exported flag array. It covers zero, mixed
and full masks, writes noncanonical nonzero bytes and changes
`LOCAL_PATTERNS` before each return. With the option set, the shell
restores canonical boolean bytes. With the option unset, it preserves the
current bytes. The shell fixture also exercises late localization, anonymous
functions, sticky emulation, eval, subshells and a signal trap. Each invocation checked 4,680 scope restores.

The command-stack fixture checks distinct storage across active functions,
the live prefix after return, pushes through the final valid slot, prompt
rendering and replacement with a full-size heap allocation by a native
builtin. It compares results with pristine Zsh and round 92.

All three trials passed 24 interactive Oh My Zsh sessions with the
configured theme, plugins and controls, seven paired native-loader cases
and 2,640 substitution comparisons with pristine Zsh. Each upstream run
passed 64 scripts with two skips (privileged mode and GDBM). Bundled zjson
passed 14,237 checks each in C and C.UTF-8. The pattern trial also matched
pristine Zsh on 14,364 pattern checks. All targeted native probe runs
completed with zero Memcheck errors.

The timing and process-memory drivers are `Perf/customer-benchmark.py` and
`Perf/memory-checkpoints.py`. Both native fixtures are in
`Perf/results/round93/`. The accompanying compressed command files specify
the SDK headers, compiler options and Memcheck invocations. The archive
also contains per-build timings, allocation profiles, memory samples,
compatibility results and binary hashes.
