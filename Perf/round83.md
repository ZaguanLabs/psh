# Round 83 — grow large scalar appends in place when possible

After 100 zcoder transcript writes with a 64 KiB tool result, round 83
retained 64 KiB less private memory than round 82 in two comparisons.
At 256 KiB the saving was 260 KiB. Wall time for the 64 KiB serializer
batch stayed within 0.01% of round 82.

Round 41 tried reallocating ordinary scalar appends and set the change
aside on application timing. Round 82's profile gave us a reason to
revisit it for memory. After `transcript_metadata_json` adds the large tool
result, it appends four smaller pieces to the same output string. Each
append previously allocated the complete result and copied the prefix.

The accepted change asks `zrealloc` to grow the existing allocation to
the exact required size for a nonempty append to an owned scalar prefix
of at least 4,096 internal bytes. This cutoff limits the change to large
copies. The getter and existing subscript normalization run first. The
guard requires augmented assignment at the end of the value, the ordinary
scalar accessor table, a matching owned pointer, eligible parameter
attributes and a held signal queue. The assignment installs the result
through the ordinary setter, which maintains named directories. The common
export path still updates the environment. Plain replacement, direct native
`setstrvalue` calls, custom accessors, tied values and interior insertions
follow their previous paths.

## Resident memory

The round 81 memory driver loaded the project's real transcript and zjson
sources, serialized fixture data, and checked the complete JSON. It sampled
Linux smaps and process status with the input and verified result still live.
Five fresh processes per binary alternated for each payload. The repeat
reversed host order and used equal-length executable paths via hard links.
Here are the repeat medians at cycle 100, in KiB, with round 82 first.

| Tool-result payload | Anonymous | Private | RSS | Peak RSS | Virtual size |
| --- | ---: | ---: | ---: | ---: | ---: |
| 4 KiB | 500 → 504 | 1,348 → 1,336 | 3,956 → 4,052 | 3,956 → 4,052 | 91,708 → 91,708 |
| 64 KiB | 1,164 → 1,100 | 1,996 → 1,932 | 4,636 → 4,620 | 6,108 → 5,992 | 92,408 → 92,340 |
| 256 KiB | 2,900 → 2,636 | 3,732 → 3,472 | 6,452 → 6,188 | 13,056 → 13,044 | 94,336 → 94,076 |

The first run at 64 KiB had the same anonymous and private medians as the
repeat. Across all three payloads the median anonymous reading at cycle 20
also held at cycle 100. At 256 KiB the retained private saving was 260 KiB
while peak RSS fell only 12 KiB. The 4 KiB case had overlapping anonymous
readings and higher total RSS in the repeat. Across coder paste, coder wide
layout and endgame, the 20-cycle anonymous medians moved by at most 4 KiB.
These page counts are specific to this Linux host and allocator.

Separate debugger runs followed the actual native allocator return address
for each eligible growth. All 44 appends stayed at the same address for
each of the 4 KiB and 64 KiB cases, across eleven serializations each.
Other allocation layouts can require a move. Separate DHAT profiles of
the 64 KiB case recorded 23,354,148 cumulative bytes for the installed rc2,
18,320,215 for round 82 and 18,320,191 for round 83. Both development builds
recorded 10,419 blocks, and their measured live-heap peaks were within 18
bytes. The footprint improvement appears in the resident-page measurements.

## Time and compatibility

Each comparison used nine alternating samples on CPU 13 and the repeat
started with round 83. Timed processes ran separately from builds, tests,
debuggers and profilers. Median milliseconds per batch include resetting
the scalar in the direct append fixtures.

| Workload | First comparison | Repeat |
| --- | ---: | ---: |
| 5,000 appends of 32 bytes to 32 bytes | 2.337 → 2.450 | 2.327 → 2.450 |
| 1,000 appends of 32 bytes to 4,096 bytes | 1.809 → 1.801 | 1.801 → 1.825 |
| 250 appends of 32 bytes to 65,536 bytes | 4.660 → 4.399 | 4.659 → 4.393 |
| 100 appends of 32 bytes to 1,000,000 bytes | 30.402 → 28.489 | 30.398 → 28.414 |
| 20 transcript serializations at 4 KiB | 14.268 → 14.215 | 14.307 → 14.290 |
| 3 transcript serializations at 64 KiB | 16.711 → 16.710 | 16.779 → 16.780 |

The short append control took 4.8% and 5.3% more time. Among fourteen
customer controls, coder paste took 1.0% and 1.4% more time, chat paste
1.3% and 2.1% more, and coder wide layout 1.3% and 0.7% less. All final
states matched. The retained memory savings on the larger transcripts
and the roughly 6% time saving on large scalar appends justify these
tradeoffs. A separate five-sample comparison put pristine Zsh at 20.588 ms
and round 83 at 16.766 ms for the 64 KiB transcript batch. That comparison
includes earlier rounds.

The upstream suite passed 64 scripts with two skips. All 24 interactive
Oh My Zsh sessions and seven native-loader comparisons passed. The 484-case
append matrix matched pristine Zsh and round 82. Focused script and
interactive checks in C and C.UTF-8 covered the cutoff, self-reference,
indexed appends, encoded NUL and invalid bytes, scoped exports, and removal
of a named-directory entry. The candidate matched under Memcheck. The
native probe checked borrowed-string edits before append, custom getter and
setter counts, and queued and unqueued public calls. An initial probe used
debug headers for the release hosts and assigned the diagnostic queue depth
directly. The corrected runs paired compatible headers with each host and
used the shell's queue macros.

Run `python3 Perf/scalar-write-benchmark.py BASE CANDIDATE --append-boundaries
--cpu CPU --output result.json` for the cutoff and large-prefix timings.
The transcript timing and memory drivers use the round 82 commands. For the
focused differential fixture, run `SHELL -df Perf/large-scalar-append-check.zsh`
and `SHELL -dfic 'source "$1"' check /absolute/path/to/large-scalar-append-check.zsh`
with an isolated startup directory. Raw samples, profiles, binary hashes and
gate evidence are in `Perf/results/round83/`. In equal-path results,
`a/zsh` is round 82 and `b/zsh` is round 83.
