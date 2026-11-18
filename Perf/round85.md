# Round 85 — reuse a second temporary arena for nested calls

The zchat 10,000-byte paste took 120 ms with two spare arenas, down from
175–178 ms with one. Both builds used the same release compiler settings.
At cycle 20, zchat retained 16 KiB more private memory. The change also
reduced zcoder skill-folding time by 19%. The largest consistent slowdown
in these comparisons was 1.5–1.9% on zcoder paste.

## The round 84 comparison

Round 84 reported a 15.3% zchat paste gap against the installed rc2. The
two executables had different compiler settings. Equal-length paths with
the same executable name reproduced the difference at 170.51 ms for the
installed binary and 198.35 ms for round 84. An independent in-tree LTO
rebuild of round 84 agreed with the previous development binary to within
1% on both paste fixtures.

Enabling profile-guided optimization on round 84 took zchat from 199.27
to 173.89 ms, and from 203.48 to 174.93 ms in reverse order. Paired
directly with the installed rc2 at matching optimization levels, round 84
took 172.25 ms versus 172.77 ms installed. Its zcoder paste took 70.28 ms
versus 98.83 ms installed. The earlier zchat comparison therefore provides
no evidence of a 15% source regression.

The builds used GCC 15.2, release assertions disabled, multibyte support,
PCRE and LTO. Both trained builds used the packaging compiler pipeline.
All four training cases passed and the hashed training inputs matched the
installed release manifest. Customer kernels were held out. The archived
training reports record 33 profile data files per build and 49 warnings
per build for untrained units.

## Nested paste decoding

Zchat calls a byte-length helper from its terminal-event decoder for each
input byte. With one idle mapping, this workload still made 20,072 private
anonymous mappings. With two, it made 59. Cumulative mapping requests
dropped from 328,879,696 to 986,704 bytes and successful whole-process
unmaps fell from 20,068 to 54. The installed rc2 made 40,094 mappings.
In contrast, zcoder's decoder was already down to 30 mappings with one
spare and made 27 with two.

The mmap allocator can now hold two cleared standard-size mappings, up
to 32 KiB of spare arena space per process. The signal queue covers the
push and pop. Each reclaimed arena is cleared in full before reuse, and
a live allocation still has a single owner. Additional and oversized
mappings follow the existing release path. Preprocessed allocator code
matched round 84 for both non-mmap and Valgrind-instrumented builds.

Two independent comparisons used nine alternating samples on CPU 13 in
C.UTF-8. The second run started with the opposite binary. All fourteen
customer kernels returned identical project states. Values below are
median milliseconds per batch, with one spare followed by two.

| Kernel | First | Repeat |
| --- | ---: | ---: |
| zchat paste | 174.74 → 119.66 | 177.66 → 119.78 |
| zcoder paste | 70.49 → 71.86 | 70.84 → 71.91 |
| zcoder skill folding | 11.18 → 8.99 | 11.05 → 8.98 |
| z3dfx shooter step | 9.73 → 9.13 | 9.75 → 9.20 |
| zcoder wide layout | 57.87 → 58.59 | 58.05 → 58.83 |

Without profile guidance, the same source change took zchat from 206.01
to 137.69 ms and from 204.20 to 137.47 ms. Direct comparisons with the
trained two-spare candidate measured 173.09 → 119.34 ms from the installed
rc2 and 233.55 → 119.59 ms from pristine release Zsh. These last two
comparisons include earlier development.

Separate Callgrind runs measured 1.986 billion user instructions on the
installed release, 2.311 billion with one spare and 2.639 billion with
two. The libc clearing routine accounted for 328 million more counted
instructions in the two-spare build. The trace and elapsed measurements
show the tradeoff between clearing a mapping in userspace and returning
to the kernel for a new one.

## Resident footprint

Linux smaps and process status were sampled in separate runs with the
result live. Each cell gives median KiB for one spare followed by two.
The four customer kernels used three samples per binary at cycle 20.
The 64 KiB transcript used five samples at cycle 100. All executable
aliases had the same length and basename.

| Workload | Anonymous | Private | RSS | Peak RSS | Virtual size |
| --- | ---: | ---: | ---: | ---: | ---: |
| zchat paste | 492 → 508 | 1,432 → 1,448 | 4,012 → 3,952 | 4,216 → 4,072 | 91,648 → 91,664 |
| zcoder paste | 484 → 504 | 1,424 → 1,444 | 3,936 → 4,028 | 3,936 → 4,028 | 91,648 → 91,664 |
| zcoder skill folding | 416 → 428 | 1,364 → 1,400 | 3,964 → 4,012 | 3,964 → 4,012 | 91,648 → 91,664 |
| Endgame world | 1,344 → 1,360 | 2,284 → 2,304 | 4,868 → 4,892 | 4,868 → 4,892 | 92,456 → 92,472 |
| zcoder transcript | 1,104 → 1,120 | 2,044 → 2,064 | 4,656 → 4,676 | 6,228 → 6,344 | 92,280 → 92,296 |

Both transcript builds had the same median anonymous and private readings
at cycle 20 as at 100. At recursion depth 200, both grew by 2,020 KiB RSS
from startup. After return, the two-spare build retained 16 KiB more.
The compiler choice also affected footprint. On zchat paste with one
spare, private memory fell from 1,504 KiB under LTO alone to 1,432 KiB
with profile guidance, while anonymous memory held at 492 KiB.

## Compatibility and reproduction

Both profile-guided binaries passed 64 upstream scripts with two skips,
24 interactive Oh My Zsh sessions and seven paired native-loader cases.
The final candidate also passed all 14,237 bundled zjson checks in each
of C and C.UTF-8. The native heap probe now keeps three standard arenas
live during a scope, checks each payload, releases the scope and repeats.
It passed directly and under Memcheck on pristine Zsh and both trained
builds. The last-argument and scalar-append fixtures matched pristine
output in both locales.

The build identities, raw timing samples, memory checkpoints, mapping
distributions, Callgrind profiles and compatibility results are in
`Perf/results/round85/`. Use `Perf/customer-benchmark.py` for operation
timing and `Perf/memory-checkpoints.py` for resident measurements.
`Perf/heap-map-profile.py --shell BASE --shell CANDIDATE --zcoder ZCODER_PATH
--zchat ZCHAT_PATH --output maps.json` reproduces the mapping comparison.
The accepted source is on the rc2 development branch. The measurements
used isolated private runtimes.
