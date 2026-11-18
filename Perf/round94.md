# Round 94 — size literal pattern programs before allocation

Round 94 adopts the second trial, which sizes and reuses the pattern
compiler's scratch buffer for literals. Zcoder's height-only updates on a
10,000-character wide buffer took 30.3% less time. The simpler exact-size
append saved the same buffer space but took about as long as round 92 on
those updates.

Zcoder compares its input buffer with the previously wrapped buffer when
only the viewport height changes. Zsh compiles the quoted right-hand side
of that comparison as a literal pattern. On this build, 10,000 copies of
`界` occupy 50,000 bytes in Zsh's internal string representation. The
compiled program needs 50,064 bytes, including the header, terminator and
alignment.

DHAT first found a 100,128-byte live compiler buffer in a wide-layout
process. A debugger trace on round 92 confirmed that the compiler was
appending 50,001 bytes to a 56-byte header, starting from a 256-byte
buffer. This happened twice, in the standard worker's result checks.
That worker invalidates the application's layout cache for each timed
layout. A separate benchmark calls the project's actual height-only
update path 128 times without invalidating the cache. It compares the
resulting rows, offsets, lengths, cursor and viewport across builds.

## Two release builds

The first trial changes the growth rule at the final literal append. It
requests exactly the aligned program size. Other appends keep their
geometric growth. Compiling another long literal still shrinks the buffer
to 256 bytes on entry and grows it again on append.

The second trial uses the existing literal scan to determine the required
capacity before initializing the buffer. It reserves at least 256 bytes
and reuses the allocation when the required capacity matches. The payload
stays in its metafied representation and gets a terminating NUL, including
when a filename component ends at a slash. The compiler still starts
nonliteral patterns with its normal 256-byte buffer. The two trials are
independent changes to round 92.

On glibc, the native probe measured 100,136 usable bytes on round 92 for
the 50,064-byte static program, and 50,072 usable bytes with either
trial. Alongside the capacity measurement, the
probe checks literal lengths around the first growth boundary,
terminators, matching, file-component end pointers and all four
combinations of static and permanent-copy flags. It keeps copied programs
live across a second compilation and checks their contents again.

## Viewport updates and allocator behavior

| 128 height changes, median ms | Round 92 | Exact-size append | Size before allocation and reuse |
| --- | ---: | ---: | ---: |
| 64 ASCII characters | 0.927 | 0.922 | 0.912 |
| 10,000 ASCII characters | 5.708 | 5.695 | 4.133 |
| 10,000 wide characters | 25.058 | 25.091 | 17.468 |

The three builds returned identical rows, cursor and viewport geometry.
DHAT recorded 19,667,231 bytes requested over the full wide viewport
process on round 92, 13,158,914 on the exact-size append, and 6,667,628 on
the reuse build. The reuse build also eliminated 258 allocation or resize
events. Peak live allocation was about 660,000 bytes on all three builds.

After the height changes, glibc reported 495,392 bytes in use on round 92
and 445,328 on the reuse build, a difference of 50,064 bytes. A subsequent
small literal brought both to 395,776 bytes. Across those checkpoints all
three builds kept a 964 KiB main heap with 948 KiB resident. The lower
allocator count made space available within the process. This viewport
run showed no reduction in median anonymous RSS (1,276 KiB on round 92
and 1,278 KiB with reuse).

## Application timings

| Workload | Round 92, first run (ms) | Reuse, first run (ms) | Round 92, repeat (ms) | Reuse, repeat (ms) |
| --- | ---: | ---: | ---: | ---: |
| zcoder wide layout | 56.422 | 55.523 | 56.271 | 55.805 |
| zchat paste | 112.398 | 111.100 | 112.328 | 111.299 |
| zfetch encode | 11.305 | 11.060 | 11.353 | 11.043 |
| Endgame | 36.090 | 36.714 | 36.057 | 36.852 |

The reuse build was 1.7–2.2% slower on Endgame. Mario and drawing binning
also had higher median times in both run orders. Against pristine release
Zsh, zcoder wide layout took 55.71 vs 123.36 ms on the reuse build.
This comparison includes gains from earlier rounds. Against the installed psh,
the corresponding times were 55.81 vs 58.23 ms. When the paste worker was
sourced, zchat went from 115.77 to 113.88 ms and zcoder from 67.57 to
66.85 ms.

## Repeated workloads and process memory

After 20 forced layout cycles, the reuse build retained 20 KiB less
anonymous memory in each of the two five-process comparisons. Total
private resident memory was also down 20 KiB in each. The peak RSS
reported by Linux was **higher** by 168 KiB and 312 KiB. Median virtual
size was 92,516 KiB on both builds. On zcoder paste, zchat paste and
Endgame, retained anonymous memory differed by at most 4 KiB across the
two comparisons.

A separate five-process comparison ran 120 cycles of two forced layouts each. Median
anonymous RSS for round 92 and reuse was 1,384 and 1,364 KiB at cycle
20, then 1,384 and 1,368 KiB at both cycles 60 and 120. At cycle 120 the
private resident totals were 2,280 and 2,264 KiB, and peak RSS was 5,560
and 5,600 KiB. The exact-size append also retained less anonymous memory
(1,364 KiB at cycle 120).

A four-build run sampled the Linux main heap directly after 20 cycles.
The figures below are medians over five fresh processes per build, in KiB.

| Build | Main heap size | Main heap resident | Process anonymous RSS | Peak process RSS |
| --- | ---: | ---: | ---: | ---: |
| Round 92 | 1,132 | 1,100 | 1,380 | 5,640 |
| Rejected round 93 pattern-state trial | 1,216 | 1,180 | 1,464 | 5,696 |
| Exact-size append | 1,132 | 1,080 | 1,364 | 5,484 |
| Round 94 reuse | 1,132 | 1,080 | 1,360 | 5,568 |

The round 93 trial's extra resident pages were predominantly in the main
heap. Both round 92 and round 93 used the original literal-growth rule.
Round 94 saved 20 KiB of resident main heap while reserving the same
amount of address space as round 92. Peak process RSS moved in opposite
directions across comparisons.

## Reproduction

The release builds use the packaging compiler's normal training workload
and link-time optimization. The 14 customer workloads run nine
alternating samples per build on CPU 13, followed by a second run with
the starting order reversed. Four workloads also run against pristine
release Zsh and the installed psh. The viewport timings rotate the order
of three builds over 12 samples. Profilers, builds and compatibility tests
run outside those timing intervals.

Run `Perf/results/round94/viewport.py` with each executable as a separate
`--shell`, the zcoder checkout as `--project`, and `--cpu` and `--output`.
The allocator checkpoint driver takes `--build SHELL MODULE_DIR` for
each matching build. Its probe uses glibc's `mallinfo2` and
`malloc_usable_size`. The module build commands, source and release binary
hashes, patches, raw samples and gate results are in
`Perf/results/round94/`.

Pass `--heap-mapping` to `Perf/memory-checkpoints.py` to record size,
resident pages and anonymous pages for Linux mappings named `[heap]`.
The ordinary anonymous RSS and private-memory readings cover the entire
process, including anonymous mappings outside that main heap.

## Compatibility

Each trial passed 24 interactive Oh My Zsh sessions comparing the release
build to the reference. The gate exercised the configured re5et theme,
git plugin and syntax highlighter, completion, history, async prompts and
Ctrl-C recovery. The first exact-size trial run timed out at Ctrl-C in the
extended plugin configuration. A full isolated rerun passed all 24
sessions. Its partial first log is included with the successful results.

Both builds passed seven paired native-loader cases. The upstream suite
passed 64 scripts per build and skipped the privileged-mode and GDBM
tests. Bundled zjson passed 14,237 checks per build in each of C and
C.UTF-8. The literal probe passed on pristine Zsh, round 92 and both
trials, including under Memcheck.

The bounded-pattern fixture originally drew generated headers from the
debug build. Its module referenced the debug-only `queue_in` symbol when
loaded into pristine release Zsh. The driver now accepts
`--baseline-build` to compile against that reference's actual configuration.
The same pristine-header module runs on the reference and candidate in
each comparison. The original debug-build invocation also passed.
The four development binaries in the heap comparison export the same
1,071 dynamic symbol names.

Each trial matched pristine Zsh on all 63,840 extended pattern comparisons
and 2,640 substitutions. The bounded native API fixture passed 3,376
checks per shell across two locales and both multibyte settings under
Memcheck. It exercises queued and unqueued signals and checks capture
offsets. All native probe runs under Memcheck reported zero errors.
