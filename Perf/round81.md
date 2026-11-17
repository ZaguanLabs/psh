# Round 81 — shifting named arrays

Zcoder's `transcript_metadata_json` builds a local array of eight fields.
It removes the first field after each read. Round 80 duplicated every
surviving string, including any large tool result waiting for its turn to
be quoted. Round 81 moves the surviving pointers into a right-sized
vector and uses the ordinary setter to release the discarded string and
invalidate the cached array length.

This applies to `shift name` and `shift -p name` on a nonempty, ordinary,
mutable whole array with no outstanding native exposure. The eligible
parameter table, lookup functions and array accessors must be the shell
defaults. Explicit counts, multiple names, special or tied parameters,
custom accessors, native getter loans and nested-variable warnings use the
existing implementation. The copy still takes time proportional to the
number of surviving pointers.

## Time and allocation traffic

The two comparisons below used nine samples per host, alternating fresh
processes pinned to CPU 13, with the starting order reversed for the repeat.
Times are median milliseconds per batch, with round 80 first in each pair.
The drain cases remove one element at a time until one survives. The
serializer uses the project's actual transcript and zjson sources with fixture
payloads. Every run checks the complete JSON, including quoted text, a
newline and a Unicode field.

| Workload | Repetitions per timed batch | First run | Repeat |
| --- | ---: | ---: | ---: |
| Drain 8 elements from the front | 200 | 2.641 → 2.389 | 2.638 → 2.399 |
| Drain 8 elements from the back | 200 | 2.858 → 2.585 | 2.833 → 2.611 |
| Drain 256 elements from the front | 2 | 1.956 → 0.381 | 1.994 → 0.384 |
| Drain 256 elements from the back | 2 | 2.060 → 0.468 | 2.075 → 0.470 |
| Drain 4,096 elements from the front | 1 | 216.731 → 5.092 | 217.785 → 5.109 |
| Drain 4,096 elements from the back | 1 | 215.433 → 5.855 | 218.492 → 5.826 |
| Serialize a 16-byte result | 50 | 17.684 → 17.734 | 17.804 → 17.813 |
| Serialize a 4 KiB result | 20 | 14.380 → 14.350 | 14.485 → 14.395 |
| Serialize a 64 KiB result | 3 | 16.933 → 16.883 | 16.998 → 17.002 |

In a separate five-sample comparison, pristine Zsh and round 81 took
225.294 and 5.117 ms for the 4,096-element front drain, and 16.504 and
14.404 ms for the 4 KiB serializer batch. This comparison includes earlier
development rounds. Across fourteen broader customer workloads, both timing
runs produced identical states. Coder wide layout took 1.4% and 1.2% less
time than round 80. The agy shooter took 1.6% and 0.6% more time.

Separate DHAT profiles measured eleven calls to the 4 KiB serializer
(including warmup) and two 256-element front drains. The installed rc2
release and round 80 made identical allocations inside the shift builtin.

| Work inside shift | Installed rc2 and round 80 | Round 81 |
| --- | ---: | ---: |
| Serializer, 88 shifts | 185,867 bytes in 396 blocks | 3,168 bytes in 88 blocks |
| Front drain, 510 shifts | 777,666 bytes in 65,790 blocks | 526,320 bytes in 510 blocks |

Across the entire serializer process, cumulative allocated bytes fell from
2,112,441 to 1,929,758 (8.6%). Live heap bytes at the peak were 203,050 and
203,029. These counts cover allocations visible to DHAT. Measured serializer
time differed by less than 1% in every comparison with round 80.

## Process memory

The parent sampled Linux smaps and process status while the shell waited
with the input and verified JSON still live. Five alternating samples per
binary ran 100 serializer cycles. Values below are medians in KiB.
Private memory sums private clean and dirty pages, including file-backed
pages. VmSize measures virtual address space.

| Payload at cycle 100 | Anonymous | Private | RSS | Peak RSS | VmSize |
| --- | ---: | ---: | ---: | ---: | ---: |
| 4 KiB, round 80 → 81 | 508 → 504 | 1,392 → 1,424 | 4,040 → 4,036 | 4,040 → 4,036 | 91,708 → 91,708 |
| 64 KiB, round 80 → 81 | 1,160 → 1,160 | 2,088 → 2,048 | 4,696 → 4,676 | 6,044 → 6,112 | 92,408 → 92,408 |

Each host's median anonymous RSS at cycle 20 matched its cycle 100 reading.
A first 20-cycle run used a shorter wrapper with three samples per host. Its
64 KiB case ended with 960 → 1,088 KiB anonymous and 1,844 → 1,988 KiB
private. Even at equal iteration counts the wrapper affected page retention.
The measurements establish lower cumulative allocation traffic. They give
mixed results for retained and peak process memory.

Four other customer workloads ran for 20 cycles each in separate processes.
Median anonymous RSS changed by at most 4 KiB in each direction. Peak RSS
ranged from 100 KiB lower for coder wide layout to 76 KiB higher for coder
paste. All four final virtual sizes matched round 80.

## Compatibility and reproduction

A rejected trial entered the new path before the builtin queued signals.
The interactive suite passed on that binary. A matching-SDK probe calling
the builtin handler directly found a queue-depth delta of −1. The accepted
build enters the existing signal queue before looking up the parameter.
Round 80 and the corrected build both give a zero delta. Both preserve a
native mutable getter's copy behavior and the two reads and one write seen
by a custom accessor. Results from the rejected binary are archived separately.

The accepted build passed the upstream suite (64 scripts, two skips), 24
interactive Oh My Zsh sessions using the configured stack and controls, and
seven native-loader comparisons. The differential fixture compares stdout,
stderr and status against pristine Zsh and round 80 under C and C.UTF-8,
including overshifts, readonly arrays, tied and unique arrays, KSHARRAYS,
and nested-scope warnings. The native fixture compares matching round 80
and 81 SDKs. All candidate fixtures also matched under Memcheck.

Run `python3 Perf/shift-benchmark.py BASE CANDIDATE --named-project ZCODER
--cpu CPU --samples 9 --output result.json` for the focused workloads. The
100-cycle memory driver takes `BASE CANDIDATE ZCODER OUTPUT PAYLOAD_BYTES`
from the repository root. Binary and input hashes, raw samples, DHAT
profiles, differential observations, build logs and compatibility evidence
are under `Perf/results/round81/`.
