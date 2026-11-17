# Round 72: corrected compiler comparison; retain GCC

Round 71 fixes the conversion-status bug that blocked the Clang experiment.
This round resumes the performance comparison using those exact corrected
GCC 15.2.0 and Clang 20.1.8 development binaries, both built with `-O2 -g -flto`.
Clang is not adopted: every customer-kernel median is slower in both runs.
No production interpreter or compiler-default change is introduced.

Before this work, the remaining generated-manual edits and native getter
reentry report were committed and pushed as requested. The report's checksums
pass and every archived file matches its corresponding source file. The archive
has a different top-level directory name; the first comparison used the wrong
root mapping, then the corrected comparison passed. No report was emailed.

## Comparable evidence

The exact executables retain round 71's passing full upstream suite (64 scripts,
zero failures, two skips each), all 14,237 zjson checks in both C and C.UTF-8,
and 24 unchanged OMZ terminal sessions per compiler. Their hashes are recorded
again in this round. Historical compiler builds are retained separately.

Both timing runs use all thirteen existing actual customer kernels, nine
alternating samples per binary, CPU 13 and C.UTF-8. Builds, test drivers,
debuggers and profilers had finished before timing. The two timing runs are
serial, not concurrent. Every sample's complete resulting state agrees.
These are internal operation-batch elapsed times from fresh shell processes,
not whole-process startup or interactive frame-rate measurements.

| Customer kernel | First GCC -> Clang ms | Repeat GCC -> Clang ms |
| --- | ---: | ---: |
| zcoder.zsh/coder-paste | 112.172 -> 115.491 | 112.819 -> 116.089 |
| zcoder.zsh/coder-layout | 5.450 -> 5.684 | 5.426 -> 5.695 |
| zcoder.zsh/coder-wide-layout | 65.962 -> 68.892 | 65.547 -> 68.758 |
| zchat.zsh/chat-paste | 206.168 -> 211.843 | 207.296 -> 210.464 |
| zchat.zsh/chat-layout | 5.457 -> 5.672 | 5.427 -> 5.683 |
| zchat.zsh/chat-wide-layout | 65.505 -> 68.366 | 65.732 -> 69.012 |
| endgame/endgame-world | 45.533 -> 46.431 | 45.811 -> 46.387 |
| z3dfx.mario/mario-race | 20.214 -> 20.400 | 20.597 -> 20.623 |
| z3dfx/shooter-step | 11.716 -> 11.883 | 11.781 -> 11.837 |
| z3dfx.agy/shooter-step | 11.754 -> 11.902 | 11.847 -> 11.991 |
| z3dfx.grok/shooter-step | 11.824 -> 11.939 | 11.794 -> 11.913 |
| zfetch/fetch-encode | 13.723 -> 14.015 | 13.999 -> 14.145 |
| z3dfx.drawing/drawing-binning | 12.900 -> 13.345 | 13.085 -> 13.446 |

Clang's coder-paste median is about 3% slower in both runs, while layout medians
are roughly 4–5% slower. Other workloads range from nearly flat to slower. No
aggregate score hides the controls. These results support retaining GCC for
this host/configuration; they do not rank all compiler versions, flag choices
or architectures. No comparison against the installed PGO+LTO build is inferred
from this matched LTO pair.

Full packaged native-project/loader verification was not repeated for a compiler
candidate rejected on these measurements. Round 71's interpreter and OMZ
validation does not substitute for that gate. No Clang compatibility certificate,
activation, new package, published release or tag is produced.

## Fresh profiles of the actual installed release

After both timers completed, `Perf/profile-customer-release.py` profiled the
unchanged installed `1.0.0-rc2-b80aa8a9db05` executable. Its SHA-256 remains
`3a4b0785c95b0b9753b3bca97006380d3e821af48d7cb687ea66f749002ad63f`.
The driver records customer sources and bytecode inputs before/after, resulting
state, raw Callgrind output and caller summaries.

| Kernel | Whole profiling-process instructions | Result-state SHA-256 |
| --- | ---: | --- |
| Endgame world, two iterations | 1,068,345,587 | `6299c35a068a34015a5c807070152d168e7d3604771a24d83d9bed2a4da3fead` |
| Coder paste, one iteration | 1,183,594,157 | `f29df9212fefb9dda43261da27d6e3f2c44dcfdbb19c8821a793a63227553caf` |

Endgame remains dominated by arithmetic: `mathparse` self cost 13.32%, `op`
12.61%, and `zzlex` 10.84%; identifier scanning is 5.23% and integer conversion
4.13%. These self-cost percentages refer to the named profiled symbols; recursive
caller totals must not be added to them. The Endgame state matches round 67.

Coder paste has distributed costs: parameter substitution 6.07%, identifier
scanning 4.52%, command execution 4.42%, multibyte length scanning 4.26%, and
string substitution 3.57%. Its profile does not justify reviving the rejected
splitter prototypes. Identifier scanning already contains rounds 14 and 25's
ASCII optimizations, so a new trial must compare against those existing paths.

The next source-level target remains repeated arithmetic parsing, subject to the
[state/ownership contract](arithmetic-internals.md): lazy reads, callbacks,
option/locale changes, diagnostics, signal boundaries and recursion must stay
observable in the same order. This round does not implement an execution-plan
cache or claim its prospective benefit. Raw debug annotations retain the
installed build's historical source paths; no current-source identity is implied.

## Reproduction and disposition

```sh
python3 Perf/customer-benchmark.py \
  .work/round71/gcc/Src/zsh .work/round71/clang/Src/zsh \
  --labs /home/stig/dev/ai/zaguan/labs --challenge /home/stig/dev/challenge \
  --samples 9 --cpu 13 --output /path/to/new-comparison.json
```

Repeat serially for the second comparison. The profile records contain exact
commands for reproducing the installed-release observations after timing ends.
Raw samples, state hashes, compiler identities and compressed profile/log files
are retained under `Perf/results/round72`. The packaging overview now correctly
identifies development as rc2 and distinguishes development validation from an
activation certificate. The active shell, personal configuration, stable Zsh and
historical release artifacts remain unchanged.
