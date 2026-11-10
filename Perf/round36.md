# Round 36: option-default loop fusion, not adopted

Both prototypes are shelved. The accepted scope-index build from
[round 35](round35.md), `1.0.0-rc0-bde30291d0ec`, remains active with **27 accepted
optimizations**. Production source is restored exactly and the DEBUG development
executable was never replaced. This round retains new regression coverage and
the complete unsuccessful experiments.

## Cost and proposals

The preceding JSON encoding profile spends about 5.5% of instructions resetting
option defaults: generic table traversal plus roughly 2.6 million `setemulate()`
calls. `installemulation()` already prefilters irrelevant entries, but the
generic scanner still checks masks/pattern state and calls a function per match.

The first proposal fuses the walk and writes only when signals are already
queued. Native oracles and upstream tests pass, but customer profiles show no
meaningful use of that path: normal resets run unqueued. Its nearly unchanged
instruction counts are retained under `queued-only/`; it is not a successful
optimization hidden behind a benchmark.

The second proposal fuses ordinary walks regardless of queue level. It keeps
the private scan-status/successor protocol, ascending bucket order, live node
flags, aliases, full/partial selection and destination indices. Generated
providers retain the original scanner/callback API. There are no cached
defaults, allocations, public structure changes or added signal boundaries.
One internal helper symbol is added only to the trial executable.

The helper receives pointers to the original shared setter mode and destination,
while retaining the original call's `fully` argument. This matters on reentry:
a generated provider can recursively install defaults into a different buffer.
The released implementation then directs later outer callbacks into the inner
buffer using the inner mode but the outer `fully` value. The new native tests
preserve this unusual behavior rather than silently replacing it with independent
per-call state. They test deterministic provider reentry, not asynchronous signal
delivery.

Both complete two-file production proposals remain as unapplied patches in the
[evidence archive](results/round36/README.md), replayed against parent
`22bc13984a8b1d7fa791732737678e100e59e73b`.

## Profiles and customer timings

GCC release configuration, `-O2 -g`, DEBUG off, dynamic modules and multibyte
support. These are separately configured private builds of the accepted source
and trial; no installed candidate is produced. The matched whole-process
Callgrind runs have identical resulting states and pinned worker/project/ELF
hashes:

| Kernel | Accepted-source instructions | Fused trial | Reduction |
| --- | ---: | ---: | ---: |
| coder paste | 1,298,890,596 | 1,299,236,179 | -0.027% |
| chat paste | 2,193,418,898 | 2,172,855,339 | 0.938% |
| Endgame | 1,144,584,323 | 1,144,557,675 | 0.002% |
| JSON encoding | 2,549,157,252 | 2,515,913,007 | 1.304% |

The second loop actually runs, unlike the guarded prototype. Its smaller
instruction count does not translate into a useful customer elapsed-time gain.
Nine alternating samples per case, CPU 13, C.UTF-8; own builds, tests and
profilers finish before each timing phase. The new native reentry checks run
between the first and repeat phases. External activity is not continuously
audited. Positive time change is slower; customer units are milliseconds per
batch, library units milliseconds per call.

| Kernel | First accepted → trial | Time change | Repeat accepted → trial | Time change |
| --- | ---: | ---: | ---: | ---: |
| coder paste | 114.000 → 114.611 | +0.54% | 116.187 → 125.855 | +8.32% |
| coder layout | 5.780 → 5.745 | -0.61% | 5.769 → 5.739 | -0.52% |
| coder wide layout | 65.799 → 66.318 | +0.79% | 65.932 → 66.165 | +0.35% |
| chat paste | 204.296 → 206.774 | +1.21% | 209.961 → 219.965 | +4.76% |
| chat layout | 5.768 → 5.758 | -0.17% | 5.814 → 5.801 | -0.22% |
| chat wide layout | 65.652 → 65.928 | +0.42% | 65.786 → 66.176 | +0.59% |
| Endgame | 44.331 → 44.589 | +0.58% | 44.519 → 44.798 | +0.63% |
| Mario | 20.264 → 20.504 | +1.18% | 20.493 → 20.651 | +0.77% |
| z3dfx | 11.846 → 11.990 | +1.22% | 12.043 → 12.127 | +0.70% |
| z3dfx.agy | 11.883 → 12.008 | +1.05% | 12.020 → 12.132 | +0.93% |
| z3dfx.grok | 11.873 → 11.990 | +0.99% | 12.001 → 12.129 | +1.07% |
| URL encoding | 14.060 → 14.014 | -0.33% | 14.085 → 14.026 | -0.42% |
| drawing binning | 13.104 → 12.976 | -0.98% | 13.083 → 12.991 | -0.70% |
| JSON array | 90.747 → 93.732 | +3.29% | 95.205 → 96.012 | +0.85% |
| JSON encoding | 202.925 → 204.129 | +0.59% | 207.574 → 208.437 | +0.42% |
| JSON validation | 92.984 → 94.426 | +1.55% | 92.298 → 94.279 | +2.15% |
| navigation | 1.933 → 2.004 | +3.69% | 1.957 → 2.004 | +2.39% |

The coder/chat repeat differs substantially from the first pass. Both passes
and every sample are retained; those larger repeat deficits are not presented
as stable causal estimates. No cause such as alignment, scheduling or thermal
state is established. Even the first pass lacks a compelling benefit in the
primary workloads. There is no aggregate score or full-application startup claim.
The proposal is rejected at this private pilot stage.

## Verification and useful retained coverage

Both proposals pass the existing 13-group differential/native/frontend/customer
checks. The accepted-source GCC build, guarded trial and fused trial each pass
63 upstream scripts with zero failures and two skips. Checks include arithmetic,
scalar/array operations, search, patterns, substitutions, floating conversion,
generic hash mutation, custom accessors, PTY completion, complete option states,
customer kernels and five original project suites. These results do not certify
every platform or every script.

The extended [native option fixture](emulation-module.c) adds **1,536 scenarios**
per host/locale, making **58,258** total. Outer modes 0–127, three inner mode
choices, ordinary/generated inner tables and both queue contexts compare both
destination buffers, callback state/traces and the original queue level against
the released predicate. The existing cases retain live output/flag aliasing,
negative aliases, duplicate destinations, all flag combinations and generated
provider behavior.

The extended fixture passes **699,096 observations in 12 zero-error Memcheck
processes**, leak checks disabled: accepted-source versus fused, pristine release
versus exact installed daily driver, and pristine DEBUG versus unchanged DEBUG
developer executable, each in C and C.UTF-8. Repetitions across hosts/locales are
observations, not that many unique scenarios. The earlier unextended oracle
results remain separately identifiable.

Two test-setup mistakes remain in the archive. The first pristine comparison
compiled a DEBUG-header module for a release host and was correctly rejected
for its missing `queue_in` export; the final comparison uses the matching release
SDK. The initial new reentry fixture omitted the table's add callback, causing
its own resize to call NULL. The corrected fixture installs that callback and
all final runs pass. Neither failure is attributed to Zsh or hidden as a passing
run. No verifier was weakened.

Because the pilot is rejected, there is no new package build, installation,
activation, Clang certification or candidate OMZ gate. The unchanged daily
driver retains its existing seven package-suite and 24-session unchanged OMZ
certification; those receipts are reused only for those unchanged artifacts.
All 1,853 canonical package inputs, the 1,603-entry installed manifest and 11,828
protected stable-Zsh/startup entries are checked again, along with the developer
ELF, `/etc/shells` and account login shell. The exact manifest count is recorded
in the restoration receipt. The project remains private rc0, with its original
tag, draft and seven assets intact.

The generic walk remains a cost, but this experiment only changes its constant
factors. A larger option-default improvement would need to reduce repeated
selection work while respecting mutable native flags, table ownership and
output aliases. Repeated arithmetic still offers a larger structural target:
guarded syntax plans must preserve dynamic reads, lazy lvalues, diagnostics and
option/locale state. Neither direction is implemented here.
