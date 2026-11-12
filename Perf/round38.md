# Round 38: rc1 compiler profiles and release hardening

This iteration adds an explicitly selected compiler optimization workflow,
fresh full-scene benchmark coverage, stateful differential checks and two
packaging/verification fixes. The interpreter retains its 27 accepted core
optimizations. No new shell syntax, arithmetic execution-plan cache, public
structure layout or native ownership rule is introduced.

The candidate is `1.0.0-rc1-b0850020f4a1`, built with GCC 15.2.0 on the Mageia
x86-64 host. It uses `-O2 -g`, GCC profile feedback and LTO; assertions remain
disabled, with separate debugger symbols. Its stripped executable is 883,312
bytes versus 854,680 for the ordinary build. Ordinary and PGO-only builds remain
available; `--optimization standard` is still the default.

## Compiler workflow

Four profiles are compared: ordinary, LTO, PGO and PGO+LTO. PGO trains only on
checked bundled core and JSON workloads. All customer scenes and simulation
projects are held out. Training executables, modules and gcov data stay in each
candidate's private directory. Core profiles are required; absent optional-module
profiles are recorded and use ordinary heuristics. Profile mismatches are errors.
Configure probes use ordinary flags so unrelated conftest programs cannot
contaminate feedback. The final executable has no generation instrumentation.

The build digest includes the compiler identity, optimization recipe and training
source hashes. Existing build/profile directories cannot be silently reused.
The three bundled native projects build in private locations; zcurl no longer
replaces another candidate's shared Vendor build cache during packaging.

The first ordinary, LTO, PGO and combined trials all passed 63 upstream scripts,
zero failures, two skips. Pilot results retain mixed/slower LTO cases. PGO and
the combined profile show broader gains; the combined candidate is taken through
the complete package and interactive gates before final measurements.

## Completion directory permissions

The initial PGO package was built under `umask 0002`. Its `functions/` directory
was 0755, but Python-created `share/psh/5.9.2` was 0775. The zcurl completion PTY
correctly stopped at compinit's insecure-directory prompt. This candidate is not
adopted; the failing receipt and output are retained.

Packaging now removes group/other write bits from distribution directories,
including the payload root. It does not alter permissions on source directories,
personal files or stable Zsh. Corrected ordinary and optimized inactive installs
pass compaudit under the same 0002 umask. Source-archive validation stages both
package profiles under 0002 and checks their directory modes. Completion security
checks remain enabled.

## Inherited function-path gate

The old OMZ driver added its inherited-FPATH profile only if the launcher exported
FPATH. Running from Bash therefore exercised 18 rather than 24 sessions, despite
testing the configured highlighter. The driver now obtains the reference shell's
default fpath when FPATH is absent and always includes that profile. An explicit
inherited value retains its meaning. The configured framework, theme, plugins,
highlighter and personal startup files are not edited.

## Compatibility evidence

The final combined candidate passes all seven package suites, including the
190-test zdraw terminal/component suite, exact installed-core tests and installed
change-gutter rendering. The mandatory OMZ gate passes 24 sessions with the user's
re5et/git/syntax-highlighting configuration, completion, history, prompt, async,
Ctrl-C and cross-runtime completion-cache checks.

Twelve additional comparison groups pass against pristine release Zsh: arrays,
scalar operations, search, patterns, substitution, emulation, arithmetic, stateful
sequences and focused native memory checks. These include 195,600 arithmetic
comparisons across five locales, 281,834 scalar comparisons, 5,192 array cases
and 63,840 pattern checks. Stateful coverage compares eight 1,000-step sequences
in C/C.UTF-8 (16,000 step-level comparisons); two additional 150-step seeds in
both locales run under Memcheck. Generated scripts and exact diagnostics are
retained for reproduction. Native array loans, scope callbacks and floating
state/locale checks run under Memcheck with leak checking disabled.

This is coverage, not universal compatibility proof. The tested packaging host
is Mageia x86-64 with GCC 15.2.0. Other platforms/toolchains, arbitrary native code
and all asynchronous trap schedules are not certified by this record.

## Scene profile and measurement scope

The full Moonlit run constructs 73,110 triangles. A separate zprof run attributes
much of its function time to paint-tri, paint-flush, geometry construction and
pixel readback. The complete Callgrind run records 59,764,589,887 instructions;
paramsubst has 11.10% self instructions. Arithmetic, allocation, string conversion
and libc locale/formatting work also remain visible. These are separate profiles,
not timer samples; Callgrind includes sourcing and output serialization too.
Its full rendered output hash matches the uninstrumented profiling run.

Final comparisons use the actual active rc0 and the verified combined rc1, CPU
13 and C.UTF-8. Scene samples are alternating fresh processes, with one excluded
warmup per host, no scene cache, a construction timer excluding source loading
and serialization, and complete palette/material/depth output comparisons.
Existing customer kernels retain nine alternating samples and result-state
checks. Own builds, tests and profilers finish before timing; external activity
is not continuously audited. These results do not measure cached launches,
interactive frame rates or network performance.


## Measured against rc0

These are **additional gains over the accepted rc0 build**, using the optional
**PGO+LTO** configuration. Five measured fresh constructions per shell/scene,
plus an excluded warmup, on CPU 13 in C.UTF-8:

| Scene | rc0 → rc1 construction | Less time |
| --- | ---: | ---: |
| Alpine Vigil | 26.86 → 23.97 s | 10.7% |
| Moonlit Vigil | 6.16 → 5.50 s | 10.8% |
| Faerie Pool | 19.63 → 17.66 s | 10.0% |
| Profile Study | 5.57 → 4.91 s | 11.9% |
| Per Arne | 14.10 → 12.49 s | 11.4% |
| Emerald Rings | 16.97 → 15.14 s | 10.7% |

Complete palette and material/depth output matches in every run. An independent
five-sample Moonlit repeat takes 6.20 → 5.58 seconds (10.0% less time).
Existing customer kernels use nine alternating samples and a complete repeat:

| Offline kernel | Less time, first / repeat |
| --- | ---: |
| zcoder.zsh/coder-paste | 16.2% / 15.6% |
| zcoder.zsh/coder-layout | 11.7% / 11.7% |
| zcoder.zsh/coder-wide-layout | 13.2% / 12.9% |
| zchat.zsh/chat-paste | 16.5% / 16.2% |
| zchat.zsh/chat-layout | 11.6% / 11.6% |
| zchat.zsh/chat-wide-layout | 13.3% / 13.0% |
| endgame/endgame-world | 15.0% / 15.0% |
| z3dfx.mario/mario-race | 11.5% / 11.2% |
| z3dfx/shooter-step | 13.2% / 13.8% |
| z3dfx.agy/shooter-step | 12.6% / 13.6% |
| z3dfx.grok/shooter-step | 13.4% / 13.5% |
| zfetch/fetch-encode | 18.2% / 18.3% |
| z3dfx.drawing/drawing-binning | 12.6% / 12.6% |

Bundled JSON kernels are also measured, but are **training workloads**, so their
results are not held-out evidence. The scenes and simulation projects above are
held out. These are host/workload-specific medians, not a universal shell-speed
or cached-launch claim. See [all samples and receipts](results/round38/README.md).
