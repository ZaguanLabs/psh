# Round 80 — positional shifts

The previous `shift` allocated a fresh positional argument vector on every
successful call, including a shift of zero. It copied the surviving pointers,
freed the removed argument strings, and freed the old vector. Removing a
single trailing argument therefore copied the entire surviving prefix.

The accepted development build evaluates the count and checks errors as before. A positional
shift of zero can then return immediately. When at least half the arguments
survive, a front shift moves the remaining pointers and their terminator with
`memmove`. A back shift writes the terminator after the last survivor. Both
request the smaller size from `zrealloc`. When a shift discards more entries
than it keeps, it copies the small result to a fresh allocation and releases
the old vector. The two directions retain their previous string-free order.
Signal queuing covers the operation, and named arrays use the existing getter
and setter path, including for a count of zero. The shell still scans the
vector to get its length for a positive shift.

## Why keep two shrink paths?

The first trial requested a realloc for every positive positional shift.
A glibc diagnostic followed a vector of 32,768 arguments down to 16,384,
1,024, one and then zero. On the front-shift run, the first trial still had
4,080 usable bytes at one and zero arguments. Round 79 used 24 bytes at both
points. The final variant gave the same 24-byte readings as round 79. At
1,024 arguments it also returned to 8,200 usable bytes. At exactly half
the initial count it held 135,152 bytes versus 131,080 in round 79. These are
glibc usable allocation sizes. Page residency is measured separately below.
The back-shift sequence had identical usable sizes on all three builds.
Allocator placement and history affect these readings.

## Timings and retained memory

Both focused comparisons used nine alternating samples per binary on CPU 13.
The repeat started with the candidate. The table reports median milliseconds
per batch, in round 79 → final candidate order for both comparisons.

| Workload | First run | Repeat |
| --- | ---: | ---: |
| Remove 32 from the front | 0.030 → 0.030 | 0.030 → 0.030 |
| Remove 4,096 from the front | 4.652 → 4.027 | 4.667 → 4.052 |
| Remove 4,096 from the back | 5.236 → 4.104 | 5.199 → 4.062 |
| Remove 16,384 from the front | 48.009 → 41.728 | 48.118 → 41.828 |
| Remove 16,384 from the back | 51.559 → 33.559 | 50.980 → 33.684 |
| Shift by zero 1,024 times with 4,096 arguments | 1.840 → 0.554 | 1.849 → 0.557 |

Fourteen customer kernels returned identical complete results across both
timing runs for each trial. For the final build, zcoder skill folding was
1.1% and 1.5% faster while coder wide layout was 0.8% and 0.5% slower.
Chat paste was 2.5% faster in the first run and 0.2% slower in the repeat.
The large gains above apply to repeated shifts on long vectors.

Separate customer memory runs used three alternating processes per host
and verified live state through twenty cycles. Median anonymous resident
memory was 392 → 392 KiB for skill folding, 468 → 464 KiB for coder paste,
1,392 → 1,396 KiB for coder wide layout and 1,324 → 1,324 KiB for endgame.
Peak RSS was mixed, ranging from a 120 KiB decrease to a 32 KiB increase,
and virtual size matched at these boundaries.

## Application profile and compatibility

The customer suite now exercises the zcoder project's
`_skills_fold_lines` function for folded and literal multiline descriptions,
including whitespace, a blank line and Unicode. The fixture checks both
complete output strings. Each call shifts away the mode and walks the
remaining four arguments. The other thirteen existing kernels provide
controls.

Callgrind collected instructions during `bin_shift` on the installed rc2
release and on matched private GCC/LTO development builds. All four hosts
produced identical final states on each workload.

| Build | zcoder skill folding | 4,096 single back shifts |
| --- | ---: | ---: |
| Installed release | 213,263 | 88,100,584 |
| Round 79 | 197,263 | 88,143,163 |
| Always shrink by realloc | 227,518 | 22,139,481 |
| Copy on majority discard | 232,318 | 22,147,673 |

The short call in skill folding takes more instructions in the candidate.
The larger back-shift batch removes about three quarters of the instructions
inside the builtin. These instrumented counts cover the builtin and its
callees. The timings use separate uninstrumented processes.

Both private variants passed the upstream suite (64 scripts, two skips),
24 interactive OMZ sessions and seven native-loader comparisons. The added
B08 regression subsequently passed in isolation on the final build. The
differential fixture compared exact stdout, stderr and status with pristine
Zsh and round 79 in C and C.UTF-8. It covers repeated and bulk shifts from
both ends, zero, negative and excessive counts, arithmetic side effects
and division by zero, empty and multibyte arguments, KSHARRAYS, regrowth,
nested scope restoration and named array controls. Both candidate fixtures
also matched under Memcheck.

## Reproduction

Run `python3 Perf/shift-benchmark.py BASE CANDIDATE --samples 9 --cpu 13 --output
result.json` for the focused cases. The worker verifies the surviving
arguments before emitting the full state. GNU time reports whole-process
peak RSS, while the internal timer covers the shift loop. The customer
timing and retained-memory drivers use the same interface as round 79.
`Perf/shift-check.zsh` accepts `normal` and `error` for differential tests.
Use `storage /path/to/module-directory` for glibc usable-size measurements
with round 79's `argv_probe.so` compiled against each host's matching SDK.
Raw samples, host identities, comparison patches and profiles are in
`Perf/results/round80/`.
