# ASCII classification guided by customer projects — 2026-11-07

This revision compares the **thirteenth psh** (`.work/round13/psh`, preceding
commit `131c5b5`) with the fourteenth candidate. Both include the separately
backported maintainer fix for scalar-search terminator reads. Measurements
isolate this revision, rather than cumulative gains over pristine Zsh.

## Customer workloads and selected cost

The benchmark coverage now includes kernels from **twelve of the twenty supplied
projects**. The new driver adds eleven cases across nine projects; zjson,
zhtml2md and zoup retain their existing drivers. The
[coverage map](customer-projects.md) records every project, measured work and
pending integration. Actual project functions are sourced directly. These are
offline library/simulation measurements; visible frame rate, network latency,
GPU rendering and terminal painting remain separate work.

Profiles identified `itype_end()` as 8–11% of instructions in zcoder paste,
Endgame world generation, Mario simulation and drawing binning. This public
helper scans identifiers and other character classes. Its multibyte path sent
ordinary ASCII through `mb_metacharlenconv()` before checking classification.

## Change and compatibility boundary

A six-line case handles ASCII immediately after the existing token check.
The converter already returns width one for these bytes without touching its
shift state. The scanner now uses that width directly and performs the same
live `zistype()` test. The initial `mb_charinit()`, token precedence, `once`
behavior and original conversion/classification body remain in place.

Metafied bytes (including literal NUL), invalid encodings, non-ASCII text,
Unicode word/separator membership, `POSIX_IDENTIFIERS` selection and the entire
byte-mode path retain their original handling. No cache, length gate, additional
allocation, public signature, structure or exported symbol is introduced.
Signal queue/dispatch boundaries are unchanged. This is focused compatibility
evidence, not a complete source or asynchronous-signal audit.

The [incremental patch](0014-ascii-classification.patch) applies after round
thirteen; native fixtures and project benchmarks are included separately.

## Measurements

AMD Ryzen 9 5950X, Mageia Linux x86-64, GCC 15.2.0, `-O2 -g`, multibyte support
and Zsh debug assertions. Nine alternating fresh-process samples per build,
pinned to CPU 2 in C.UTF-8. Loading, construction, warm-up and simulation reset
precede timing. Paste reset and per-batch binning preparation are measured.
Expected results are checked for every sample; resulting state matches exactly.
Each timing driver ran with this work's builds, tests and profilers idle.

Additional customer kernels, milliseconds per complete batch:

| Project / operation | Batch | Previous psh | New psh | Ratio |
| --- | --- | ---: | ---: | ---: |
| zcoder: bracketed paste | 10,000 characters | 127.334 | 118.348 | 1.08x |
| zcoder: forced layout | 2 × 10,000 characters | 6.198 | 5.798 | 1.07x |
| zchat: bracketed paste | 10,000 characters | 236.645 | 217.985 | 1.09x |
| zchat: forced layout | 2 × 10,000 characters | 6.195 | 5.783 | 1.07x |
| Endgame: complete world generation | 2 × 72×38 maps | 51.197 | 47.894 | 1.07x |
| Mario: active race simulation | 120 steps | 31.667 | 29.027 | 1.09x |
| z3dfx: active simulation | 60 steps | 15.851 | 14.931 | 1.06x |
| z3dfx.agy: active simulation | 60 steps | 15.835 | 14.894 | 1.06x |
| z3dfx.grok: active simulation | 60 steps | 15.918 | 14.825 | 1.07x |
| zfetch: URL encoding | 3 × 2 KiB prefix + UTF-8 | 16.708 | 16.680 | 1.00x |
| drawing: geometry binning | 3 × 122 triangles | 16.059 | 14.725 | 1.09x |

Most of these project kernels improve by **1.06–1.09x**. URL encoding remains
essentially unchanged; its byte-mode string-length/index traversal dominates
its profile. Similar shooter variants are retained as distinct project checks,
without treating them as independent workload families. The drawing case
measures actual binning and checks every tile against the project's brute-force
oracle; it performs no raster submission or presentation.

Existing warm application/library calls, milliseconds per call:

| Workload | Previous psh | New psh | Ratio |
| --- | ---: | ---: | ---: |
| zjson: parse 2,000 numbers | 104.297 | 101.521 | 1.03x |
| zjson: encode 4,000 strings | 222.705 | 216.721 | 1.03x |
| zjson: validate 2,000 numbers | 98.492 | 96.398 | 1.02x |
| z3dfx: navigation rebuild | 2.365 | 2.193 | 1.08x |
| zhtml2md: 1 MiB comment and retained paragraph | 166.702 | 167.289 | 1.00x |
| zhtml2md: 100 KiB complete prose | 131.820 | 130.548 | 1.01x |
| zjson: repair 100,000 bytes | 21.747 | 21.281 | 1.02x |
| zoup: clean 128 HTML sections | 106.945 | 101.272 | 1.06x |

The JSON operations measure roughly 2–3% lower medians; navigation improves by
1.08x and cleaning by 1.06x. Comment conversion measures **0.4% slower**, and
prose is about 1% faster. Small shifts do not establish gains or regressions.
Output bytes/state hashes agree; explicit expectations also check comment
conversion, JSON repair and encoding. See the
[customer](results/round14/customer-benchmarks.json),
[application](results/round14/application-benchmarks.json) and
[parser](results/round14/parser-benchmarks.json) records for all samples.

Callgrind, including startup, construction and warm-up, with both builds using
the final worker and the same minimal environment:

| Kernel | Previous instructions | New instructions | Reduction |
| --- | ---: | ---: | ---: |
| zcoder paste | 1,692,213,054 | 1,562,705,259 | 7.7% |
| zfetch URL encoding | 515,351,693 | 514,795,195 | 0.1% |
| Endgame world generation | 1,387,328,181 | 1,277,340,261 | 7.9% |
| Mario simulation | 771,976,831 | 697,313,687 | 9.7% |
| Drawing binning | 582,929,092 | 526,165,653 | 9.7% |

The input, world, race and binning profiles execute roughly **8–10% fewer
instructions**. URL encoding executes about 0.1% fewer. Instructions are not
CPU cycles, and these counts include work outside the timed batch. All paired
profiles produce identical state. Commands, source and binary hashes are in
[matched-profile-commands.json](results/round14/matched-profile-commands.json).


## Benchmark corrections and application issue

An initial shooter pilot omitted the input library, leaving focus unset and
exercising an early return. The final fixture sources that library and asserts
that simulation time advanced, the player remains alive, and navigation covers
the map. The no-op pilot is excluded from accepted results.

Review also exposed a pre-existing Mario reset issue: a second `race-reset`
doubles `track_length` from 448.36574769 to 896.73149539, including in pristine
Zsh. The benchmark now restores the global's fresh-launch value before each
untimed reset and asserts valid track bounds. The
[reproducer and diagnosis](bugs/mario-track-reset.md) are saved; the application
repository is unchanged.

All eleven customer cases were repeated after that correction. The original
nine-sample dataset and exact worker remain under `pre-reset-*`. They are
excluded from the final table. That earlier URL-encoding median was 1.6%
slower (16.986 vs 17.258 ms); the corrected complete rerun measures 16.708 vs
16.680 ms. Both are retained, and no URL-encoding speedup is claimed. The psh
binary was unchanged between these runs. The JSON/parser drivers use separate
unchanged workers and did not require repetition.

## Validation

- **62 upstream scripts pass, zero failures, three skipped** (privileged,
  PCRE and GDBM), with capability-dependent individual skips retained in the
  complete log. Upstream PTY completion and ZLE scripts pass.
- A pristine-header native fixture performs **378,752 checks per run**, on both
  pristine Zsh and the candidate in **five encodings**, all ten runs under
  Memcheck with zero errors: **3,787,520 checks** in total. Leak checking is
  disabled; this is focused corpus evidence.
- The fixture compares the public helper with the original release scanner
  body, renamed but otherwise unchanged. Its private wide membership tables
  are reconstructed using the release's own routine and public IFS/WORDCHARS
  values. It checks exact allocation ends, two byte offsets, every byte in raw
  and metafied inputs, token handling, ASCII prefixes through 1,024 bytes,
  full and single-character scans, clean/seeded conversion state and the next
  conversion.
  Complete allocations remain unchanged. Six character classes, multibyte
  on/off, POSIX identifiers on/off, default/changed separator and word sets,
  and changed exported ASCII classification flags are covered. Cases where
  the byte-mode terminator itself belongs to the requested class are excluded.
  The non-ASCII set member is encoded for each supporting locale before
  entering the shell; C uses ASCII sets.
- **5,192 array**, **28,394 scalar read/write**, **193,236 search**,
  **2,640 substitution** and **159,600 five-encoding pattern comparisons**
  match pristine Zsh in output bytes, diagnostics and status. Twenty native
  accessor/API/search cases and **36 actual PTY completion buffers** match too.
- A no-multibyte build passes eight substitution scripts (one UTF-8 skip)
  followed by the conditional script, sequentially; **2,640 substitution
  comparisons** match its pristine counterpart. The new branch is inside the
  existing multibyte compile-time condition.
- All **eleven new kernels** match pristine Zsh in **C and C.UTF-8**, using
  the corrected final worker. Each checks expected results and full recorded
  state. Original Endgame engine/adventure/Horizon suites pass **76/96/128**
  checks, and AGY/Grok engine suites each pass **86**, with matching status,
  stdout and stderr against round thirteen.
- Existing application status/output matches round thirteen in C and C.UTF-8:
  **14,237 zjson checks, 101 zoup cleaner checks, nine stream checks and 86
  z3dfx engine checks**. All **307 zhtml2md checks** pass with its explicit
  child-shell override set to the candidate.

- Public exports, dynamic exported names/types and generated public declarations
  remain identical to pristine Zsh. Its **1,847-file source manifest** and the
  preceding snapshot verify unchanged. The incremental source patch reproduces
  the current helper. The published `psh` matches the tested and timed binary.

Evidence, commands and hashes: [results/round14/](results/round14/).
The coverage map identifies the remaining customer workloads; these results
are local Linux/compiler measurements rather than portability or complete-app
latency guarantees.
