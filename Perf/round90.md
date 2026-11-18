# Round 90 — scan for process substitution during word expansion

On round 89, zchat paste took about 1.4% longer than round 88 even though
Callgrind counted slightly fewer instructions across the whole process.
The profile attributed 1,241,582 calls to the C library's byte-set scan
to the two passes of `stringsubst`. The experiments below target that
recurring work. The timing difference on round 89 does not by itself
identify the scanner as its cause.

## Experiments

The first build (`tails`) tested for the terminator before each
`strcspn` call. During zchat paste the number of calls from
`stringsubst` fell to 961,235. Both zcoder paste comparisons were
1.7–1.9% faster than round 89, but Endgame took 3.3–3.6% longer.

The second build (`short`) bypassed both passes for empty words and
one-byte ASCII literals. Neither can contain a substitution token or
a noninitial assignment marker. Endgame again took about 3% longer.
In the direct round 88 comparisons both experiments still took longer
on both paste workloads. Their patches, timings and profiles are archived.

The third build (`paren`) uses the token sequence common to
`<(...)`, `>(...)` and `=(...)`. It searches for the tokenized opening
parenthesis with `strchr`, starting one byte past the cursor so the
preceding byte is available. At a match it checks that byte for a process
marker. The `=` form still needs to begin the word. A successful
substitution resumes at the original suffix in the new buffer. A
nonmatching parenthesis advances the search by one byte. The second pass
retains its existing parameter, arithmetic, command and assignment logic.

## Customer workloads

The third build had lower median times on all 14 customer kernels in both
comparisons, and each produced identical application state. Each run used
nine alternating samples per shell on CPU 13. The second run reversed the
starting order. The projects were held out of the release build's
profile-guided training.

| Milliseconds per batch | Round 89 | Round 90 | Round 89 repeat | Round 90 repeat |
| --- | ---: | ---: | ---: | ---: |
| zcoder paste | 69.068 | 68.420 | 69.337 | 68.643 |
| zchat paste | 115.617 | 114.927 | 115.672 | 115.179 |
| zchat layout | 4.848 | 4.790 | 4.877 | 4.803 |
| Endgame world | 37.057 | 36.843 | 37.356 | 36.875 |

A separate five-sample comparison measured zchat paste at 233.59 ms on
pristine release Zsh and 115.06 ms on this build. Against the installed
rc2, it took 171.02 ms and 115.06 ms respectively. Those comparisons
include the earlier rounds.

In a direct 15-sample comparison with round 88, zcoder paste still took
68.534 ms against 67.124 ms, and zchat paste took 115.779 ms against
113.784 ms. Round 90 recovered some of the time lost in round 89.
Callgrind counted 20.55 million fewer instructions on zchat paste and
2.46 million fewer on Endgame compared with round 89. Hardware counters
also showed fewer retired instructions on both workloads and zcoder paste.

The isolated 20,000-iteration word controls followed the same direction
as the customer results for the accepted build. Single-byte literals
took 15.50 ms against 15.73 ms on round 89, and the 1,024-byte literal
took 48.23 ms against 48.63 ms. The first two trials were both slower on
the long literal. Each control verified the resulting argument bytes.

## Memory and compiler controls

In separate nine-sample comparisons with round 89, compiling zcoder's
48 libraries took 23.99 ms against 23.97 ms. Compiling zchat's 19 took
6.62 ms against 6.65 ms. Both pairs produced byte-identical compiled
files. Peak RSS for the compilers matched at 7,740 KiB on zcoder and
4,720 KiB on zchat. Retained private memory differed by at most 8 KiB.

A direct nine-sample comparison with round 88 measured zcoder at
5,840 → 5,140 KiB of retained private memory and zchat at 2,344 → 2,112
KiB. Anonymous memory fell by 652 KiB and 176 KiB respectively. The
compiler therefore kept the earlier footprint improvement on this host.

For running applications, two five-sample comparisons reversed host
order. After 20 workload cycles, retained private memory ranged from
equal to 32 KiB higher than round 89 across the three applications.
Anonymous memory was within 4 KiB and virtual size matched in every
pair. Peak RSS on zchat paste rose from 4,028 to 4,368 KiB in the
first comparison and from 4,040 to 4,180 KiB in the repeat. Endgame
and wide layout had mixed peak results. The process scanner adds no
allocation of its own.

## Compatibility and reproduction

All three builds matched pristine Zsh on 2,640 substitution comparisons
across C and C.UTF-8. These check output, diagnostics and status while
exercising quoting, expansion order, assignment markers, all byte values
and command and process substitution. The additional process fixture
reads adjacent substitutions within one word, nested substitutions,
a prefixed descriptor and an equals-form temporary file. Its output
matched across pristine, round 89 and all three trials in both locales.
Memcheck reported zero errors on those runs.

Each trial passed all 24 interactive Oh My Zsh sessions, seven paired
native-loader cases, and 64 upstream test scripts with two skips. The
bundled zjson suite passed 14,237 checks per locale on each build.

Use `Perf/customer-benchmark.py` for application timing,
`Perf/substitution-compare.py` for the differential matrix, and
`Perf/results/round89/compile.py` for compiler time and memory. The
patches, profiles, raw samples, and compiled and input hashes are in
`Perf/results/round90/`.
