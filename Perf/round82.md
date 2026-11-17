# Round 82 — last-argument storage across shell function calls

When zcoder serializes transcript metadata, it passes each field to
`zjson_quote` as a function argument. Zsh exposes the last argument as
`$_`. The function runner saves that value so the caller can see it again
when the function returns. Round 81 made a heap copy on entry, even for an
empty value. When the callee changed the buffer size, restoring a large
caller value could allocate and copy it a second time.

Round 82 saves up to 31 bytes of shell-internal string data plus the
terminator in the function's stack frame. Longer values use a private
buffer with the previous capacity. On ordinary return the shell installs
that buffer directly. A native wrapper that handles the call keeps the
value it left in the shell and releases the unused backup. The change
uses the function runner's existing signal queue.

## Heap use on zcoder transcript writes

Separate DHAT runs used the installed rc2 and matched private GCC 15.2 LTO
development builds. Each process loaded zcoder's actual transcript and
zjson sources, ran one warmup and ten measured serializations, and verified
the complete JSON. The table gives cumulative requested bytes across the
whole process. The instrument includes allocations visible to Valgrind.

| Tool-result payload | Installed rc2 | Round 81 | First trial | Round 82 |
| --- | ---: | ---: | ---: | ---: |
| 16 bytes | 678,285 | 691,844 | 707,736 | 689,392 |
| 4 KiB | 2,095,719 | 1,929,758 | 1,805,730 | 1,792,666 |
| 64 KiB | 23,354,148 | 20,484,827 | 18,333,279 | 18,320,215 |

The first trial kept the caller's allocation and gave the callee a new
buffer of the same capacity. Spare capacity raised the small workload's
allocation traffic by 2.3%. The final build removed 287 heap allocations
relative to round 81 at each size. At 64 KiB this cut cumulative allocation
by 10.6% and peak live heap from 1,001,766 to 936,379 bytes. Peak live heap
at 4 KiB fell from 203,029 to 199,082 bytes. At 16 bytes it rose by 18 bytes.

## Elapsed time

Medians below are milliseconds per batch, in round 81 → round 82 order.
Each run used nine alternating samples on CPU 13. The repeat reversed the
starting order. Timing ran separately from profiling, tests and compilation.

| Tool-result payload | Calls per timed batch | First comparison | Repeat |
| --- | ---: | ---: | ---: |
| 16 bytes | 50 | 17.575 → 17.683 | 17.753 → 17.567 |
| 4 KiB | 20 | 14.326 → 14.133 | 14.267 → 14.190 |
| 64 KiB | 3 | 16.791 → 16.676 | 16.839 → 16.774 |

Pristine Zsh and round 82 took 20.395 and 16.719 ms respectively on the
64 KiB batch in a separate five-sample run. That difference includes earlier
rounds. Across the fourteen customer controls, both comparisons returned
identical states. Coder paste took 1.8% and 0.9% less time, chat paste took
1.3% less in both runs, and the Mario race took 2.9% and 2.3% less time.
Coder wide layout took 1.2% and 0.9% more time.

## Resident pages and stack cost

Five alternating samples per binary serialized and checked the same payload
100 times. Linux process checkpoints kept both the input and verified output
live. All entries below are medians in KiB at the last checkpoint.

| Tool-result payload | Anonymous | Private | RSS | Peak RSS | Virtual size |
| --- | ---: | ---: | ---: | ---: | ---: |
| 4 KiB | 508 → 504 | 1,416 → 1,408 | 4,008 → 3,948 | 4,008 → 3,948 | 91,708 → 91,708 |
| 64 KiB | 1,164 → 1,160 | 2,048 → 2,040 | 4,680 → 4,608 | 6,140 → 6,100 | 92,408 → 92,408 |

The large serializer's retained private memory fell by 8 KiB. Most of the
heap saving occurred during the call. The first trial retained 64 KiB less
anonymous memory than its paired round 81 control for this payload, but
requested more heap on small calls. Three other customer workloads showed
0–4 KiB lower anonymous memory after 20 cycles in the final build. Their
median peak RSS rose by 12–152 KiB. These page counts depend on allocator
history and include effects outside the function runner.

Disassembly of these x86-64 GCC/LTO builds shows 48 extra bytes of stack
per active function-runner frame, including saved registers. A separate
200-level recursion test paused the process at the deepest call. Median
growth from the initial checkpoint in resident stack pages was 1,064 →
1,072 KiB across five runs per host. The pages were still resident just
after return. Total anonymous growth at the deepest point was 1,996 →
2,000 KiB. The short-value path therefore has a measurable cost at depth.

## Compatibility and reproduction

The final build passed 64 upstream scripts with two skips, including a
regression for empty, 31-byte, 32-byte and long last arguments across a
nonzero function return. Both trials passed 24 interactive Oh My Zsh sessions
and seven native-loader comparisons. In C and C.UTF-8 the focused fixture
matched pristine Zsh and round 81 byte for byte, including status and
diagnostics. It covers empty and multibyte values, shell-encoded NUL and
invalid bytes, 100 nested calls of alternating sizes, and signal-trap
restoration. The matching-SDK wrapper probe exercises passing through,
delegating and skipping a body with both short and long caller arguments.
Both trial binaries matched the reference under Memcheck.

From the repository root, use `Perf/shift-benchmark.py BASE CANDIDATE
--named-project ZCODER --cpu CPU --output result.json` for timing.
The round 81 transcript-memory driver accepts `BASE CANDIDATE ZCODER
OUTPUT PAYLOAD_BYTES`. Run `SHELL -df Perf/underscore-scope-check.zsh`
for the differential fixture, adding the directory containing a matching
`underscore_probe.so` to exercise native wrappers. Compile the probe with
`cc -shared -fPIC -DMODULE -IBUILD/Src -ISOURCE/Src -IBUILD
Perf/underscore-wrapper-probe.c -o underscore_probe.so` for each host.

Raw timing samples, memory checkpoints, heap profiles, binary identities
and gate reports are in `Perf/results/round82/`. The `all-heap` directory
retains the first trial and its patch. The `short` directory records the
accepted implementation.
