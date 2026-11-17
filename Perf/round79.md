# Round 79 — right-size the positional argument vector

The list passed to `doshfunc()` has one node for the function name and one for
each positional argument. Only the arguments go into `pparams`. With N
arguments, the old code allocated and cleared N+2 pointers, copied the N
strings, and relied on the cleared tail for its terminator.
Both trials allocate N+1 pointers and keep each string independently owned.
The first fills the vector and writes its terminating NULL explicitly. The
second keeps the existing zero-initialization and changes only the size.
The function name supplies `$0` under FUNCTIONARGZERO. Signals are queued throughout setup. Native
callers passing a NULL list continue to use the separate empty-vector path.

## Allocation measurements

Valgrind DHAT profiled the installed rc2, round 78 and both trials
running the same coder paste worker. The worker warms up and runs the batch
again, repeatedly calling the two-argument terminal decoder. All four
complete state hashes agree. The numbers below sum the DHAT program points
for the positional-vector allocation in `doshfunc()`. They cover the lifetime
of those allocations, including later reads and writes.

| Host | Vector allocations | Bytes requested | Bytes written | Bytes read |
| --- | ---: | ---: | ---: | ---: |
| Installed rc2 | 20,021 | 640,528 | 960,720 | 1,761,128 |
| Round 78 | 20,021 | 640,528 | 960,720 | 1,761,128 |
| Explicit terminator | 20,021 | 480,360 | 480,360 | 1,761,128 |
| Existing zero-initialization | 20,021 | 480,360 | 800,552 | 1,761,128 |

Both trials requested 160,168 fewer bytes cumulatively (eight per call
on this host). The explicit terminator saved 480,360 bytes of writes over
the run. Keeping zero-initialization saved 160,168 bytes of writes. The shell
can reuse that memory between calls.

A small native builtin samples glibc's `malloc_usable_size(pparams)` inside
the real function on each build. Both trials and the control return the expected
argument counts from zero through sixteen. With two arguments the reported usable size falls
from 40 to 24 bytes. With four it falls from 56 to 40. Each tested even count
from two through sixteen saves 16 bytes, while the other tested counts occupy
the same allocator size classes. These measurements apply to this x86-64
glibc host. The diagnostic was built against the matching SDK for each shell.

## Customer tradeoff and decision

Adopt the smaller, zero-initialized vector. It saves one requested pointer
and one cleared pointer per call. The allocation also matches the size
used by the positional-argument branch of `shift` when freeing it. The
explicit-terminator variant saved more writes in the profile, but its
paste, racing and shooter batches were consistently slower than round 78.

Each variant was compared with round 78 twice, with nine alternating samples
per workload on CPU 13 and the starting order reversed for the second run.
All thirteen workloads produced identical complete results. Selected median
time changes are relative to each run's own baseline. Positive values indicate
slower execution.

| Workload | Explicit NULL, first / repeat | Adopted, first / repeat |
| --- | ---: | ---: |
| Coder paste | +1.41% / +1.57% | +0.75% / flat |
| Chat paste | +2.38% / +2.66% | +0.82% / +1.59% |
| Chat ASCII layout | −0.98% / −1.56% | +1.28% / +1.52% |
| Coder wide layout | −1.14% / −0.74% | −0.97% / −0.67% |
| Mario race | +1.33% / +2.04% | flat / −0.23% |
| Grok shooter | +2.60% / +1.74% | −1.60% / −1.10% |

Three alternating memory samples per host followed each timing pair. After
twenty cycles, the adopted variant matched round 78's median anonymous
resident memory on coder paste (460 KiB), coder wide layout (1,396 KiB),
chat paste (480 KiB) and endgame (1,324 KiB). Peak RSS differences ranged
from −96 to +72 KiB, private resident differences from −16 to +36 KiB and
virtual size differences from −4 to 0 KiB across these workloads. The
measured benefit is lower allocation traffic with mixed timing effects.

## Compatibility and reproduction

`Perf/function-argv-check.zsh` exercises empty, spaced, multibyte and raw-byte
arguments, calls with 0, 1, 4 and 1,024 arguments, both FUNCTIONARGZERO
settings, nested calls, front and back shifts, append, replacement and caller
restoration. Exact NUL-delimited output, stderr and status match pristine Zsh,
round 78 and the candidate in C and C.UTF-8. Both trials also matched the reference
output under Memcheck in both locales. With a directory argument the same
script loads the diagnostic
and prints the size-class measurements.

The private GCC build uses `-O2 -g -flto`, multibyte support and PCRE.
The upstream suite passed 64 scripts with two skips. All 24 interactive OMZ
sessions and all seven native-loader comparisons passed. The candidate was
tested through its private build and runtime.

Compile `Perf/function-argv-probe.c` to `argv_probe.so` separately for each
host using `cc -O2 -g -Wall -Werror -shared -fPIC -DMODULE -DHAVE_CONFIG_H`
and the matching build and source `Src` include directories. Run the host as
`zsh -df Perf/function-argv-check.zsh /absolute/module/directory`. For the
shell-only differential fixture omit the directory argument. DHAT used
`--tool=dhat --num-callers=32` with `zsh -df Perf/customer-workload.zsh
coder-paste /home/stig/dev/ai/zaguan/labs/zcoder.zsh 1`. Binary and source
identities, raw profiles, timing samples and memory checkpoints accompany
this report in `Perf/results/round79/`.
