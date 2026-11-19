# Round 98 — borrow long literals for one conditional match

Zcoder compares its current input with the text it last wrapped. With 10,000
wide characters, round 97 copied a 50,000-byte literal into the pattern
compiler on each height change and kept its last copy. Round 98 reads the
expanded right operand directly. After 128 height changes, glibc reported
49,808 fewer bytes in use. The same updates took about 2% less time.

## Scope and ownership

The conditional evaluator already keeps both operands alive and queues signals
through compilation and matching. A one-shot pattern can borrow the normalized
bytes when the existing token scan reaches the terminator and the literal is
at least 4,096 metafied bytes long. The compiler uses its usual scratch buffer
for the header and passes the borrowed address separately to the immediate
matcher. The evaluator keeps that address local to the comparison.

Cached patterns in functions still own their literals. Short strings, wildcards
and tokenized patterns use their existing representation. The public pattern
compiler continues to return complete programs for every storage mode. The
Linux binary retained all 1,072 previous dynamic symbols and added the two
core helpers used by the conditional evaluator. Its text grew by 550 bytes.

## Memory

After 128 height changes, glibc's median in-use count fell from 445,328 to
395,520 bytes across six processes per build. After comparing a small literal,
both builds used 395,776 bytes. At both checkpoints each build still had
948 KiB resident in a 964 KiB main heap. At the height-change checkpoint,
private dirty memory was 1,288 KiB on both. Private clean memory rose from
768 to 816 KiB.

Increasing the input tenfold also increased the live allocation saving tenfold.
The values below are median glibc arena bytes in use after the height changes,
over six processes per build and input. On the larger input, glibc also held
1,007,616 bytes in separate mappings on each build.

| Wide characters | Pristine Zsh | Round 97 | Round 98 | Saved vs round 97 |
| ---: | ---: | ---: | ---: | ---: |
| 10,000 | 495,760 | 445,328 | 395,520 | 49,808 bytes |
| 100,000 | 2,638,656 | 2,138,016 | 1,638,192 | 499,824 bytes |

All three builds had 4,016 KiB resident in the main heap at the larger size.
The development builds had the same 96,992 KiB process virtual size. Private
resident memory was 6,548 vs 6,552 KiB, total RSS was 9,268 vs 9,198 KiB,
and peak RSS was 21,754 vs 21,498 KiB (round 97 then round 98).

Repeatedly forcing the project to rebuild its wide layout produced a resident
saving as well. These are medians across five processes per build at cycle 120.

| Linux measure | Round 97 | Round 98 |
| --- | ---: | ---: |
| Main heap, resident | 1,084 KiB | 1,016 KiB |
| Main heap, mapped | 1,132 KiB | 1,020 KiB |
| Anonymous RSS | 1,364 KiB | 1,296 KiB |
| Private resident memory | 2,152 KiB | 2,128 KiB |
| Whole-process RSS | 4,848 KiB | 4,896 KiB |
| Peak RSS | 5,488 KiB | 5,496 KiB |
| Virtual size | 92,520 KiB | 92,408 KiB |

On the separate 20-cycle run the wide-layout resident heap fell 64 KiB, total
RSS fell 32 KiB and peak RSS fell 156 KiB. Whole-process RSS and peak therefore
varied in direction across these runs. At 20 cycles, zcoder paste, zchat paste
and Endgame recorded 40–48 KiB more private resident memory on round 98.
Their resident main heaps changed by −8, 0 and 0 KiB respectively.

DHAT measured 49,808 fewer live bytes at exit and the same peak of 659,529
live bytes on the complete viewport worker. Heap writes fell from 12.80 to
6.30 million bytes. Callgrind counted 404.81 million instructions, down from
411.31 million, including the initial wrap and final layout validation.

## Application timings

| 128 zcoder height changes | Round 97 | Round 98 | Pristine Zsh |
| --- | ---: | ---: | ---: |
| 64 ASCII characters | 0.858 ms | 0.898 ms | 2.220 ms |
| 10,000 ASCII characters | 2.240 ms | 2.251 ms | 6.826 ms |
| 10,000 wide characters | 7.086 ms | 6.948 ms | 24.925 ms |

The comparison used 12 alternating samples per input on CPU 13. Reversing the
starting build gave 7.121 vs 6.973 ms for long wide text, and 2.238 vs
2.265 ms for long ASCII. The 64-character ASCII control reversed direction.
The second run covered 13 sizes and inputs, including both sides of the
borrowing threshold for ASCII and wide text. Layout state matched throughout.

Across 14 customer workloads, with nine samples in each starting order, zcoder
paste took 0.5–0.7% less time and drawing binning took 0.5–0.6% less. Forced
wide-layout rebuilds took 1.0–1.7% more time in zcoder and 1.8–2.2% more in
zchat. Zchat's ordinary layout took 1.8–3.4% more. Against pristine Zsh,
round 98 was 2.01× as fast on zcoder paste, 2.19× on zcoder wide layout,
2.10× on zchat paste and 1.47× on Endgame. Every run checked application state.

## Compatibility

A focused fixture interleaves long dynamic comparisons with calls to a function
containing a cached 5,000-byte literal. It compares equality, negation, length
mismatches, wildcard matching, captures, case folding, expansion side effects
and malformed-pattern diagnostics. Inputs include embedded NUL, invalid bytes,
quoted glob characters and UTF-8. A native builtin reads the last match length
immediately after each comparison. Pristine Zsh and both development builds
produced identical output and diagnostics in C and C.UTF-8, with multibyte
enabled and disabled in each process. Memcheck reported zero errors. All three
also passed the 120 public compiler storage and ownership checks.

All 24 Oh My Zsh terminal sessions passed with the configured re5et theme,
git plugin and syntax highlighter, including completion, history, async prompts,
Ctrl-C recovery and compiled-cache handoff. The first gate attempt timed out
waiting for the candidate's first prompt. A fresh run of the unmodified gate
passed every profile. The first log is retained with the passing evidence.
All seven paired native-loader controls passed.

The bounded native pattern probe passed 3,920 checks per shell under Memcheck.
The differential suite matched pristine Zsh on 63,840 patterns and 2,640
substitutions. Upstream passed 64 scripts and skipped privileged mode and
GDBM. Bundled zjson passed 14,237 checks in each locale.

## Reproduction

The packaging compiler trained each PGO/LTO release independently. Commands,
binary and workload hashes, raw samples, profiles and gate results are in
`Perf/results/round98/`. The viewport worker and glibc probe are in
`Perf/results/round94/`. Elapsed-time samples ran separately from builds,
profilers and compatibility tests.

For a repeat on this machine, unpack the command files into `.work/round98/`
and extract this revision's source to `.work/round98/trial/build/`. From the
repository root, run the commands below with the pristine and round 97 builds
at the paths recorded in the identity file.

```sh
mkdir -p .work/round98/trial/logs
python3 .work/round98/build.py trial
bash .work/round98/baseline.sh
bash .work/round98/suite.sh
bash .work/round98/focused.sh pristine base trial
bash .work/round98/size-memory.sh
```
