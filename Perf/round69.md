# Round 69: compiler comparison and selection

This explores compiler-generated code after the rejected separator-parser trials.
It introduces no interpreter source change, new native interface, or change to
customer/framework code. Compilation happens in isolated private package work
trees, and both candidates remain inactive.

## Pair

Both private development builds use release assertions disabled, multibyte and
PCRE support, `-O2 -g -flto`, and separate matching runtimes. The initial builds
pass the direct upstream suite as configured here, with 64 scripts, zero failures
and two skips. Source paths and binaries remain distinct throughout.

Full package builds use the isolated `Packaging/build.py --optimization lto`
workflow, including SDKs, native project objects, bundled function trees and
split debugger symbols. No old work directory or completed build is overwritten.
The two selected releases are:

| Compiler | Release | Role |
| --- | --- | --- |
| GCC 15.2.0 | `1.0.0-rc2-3117bd5765ac` | matching-compiler LTO control |
| Clang 20.1.8 | `1.0.0-rc2-d3bb6b460711` | alternative-compiler probe |

The earlier direct `make install.modules` checks omitted the stock function
tree. Their candidate-side OMZ failure listed missing `add-zsh-hook`,
`is-at-least`, `compdef` and related functions. This is an uninstalled-build
path failure, not evidence of a Clang-specific OMZ defect. It was not hidden or
used to justify a compiler switch. All genuine interactive results below use
the complete package.

## Serialized project tests

An initial attempt ran both package test drivers concurrently. Their project
build areas interleaved. GCC's LTO project log showed duplicate core symbols;
Clang also failed two malformed-UTF-8 JSON checks. GCC failed zdraw and zmdown
during those overlapping builds. These results are incomplete compiler evidence
because their build areas were not independent.

The reruns use `--jobs 1` and complete serially. GCC then passes all seven project
suites. The earlier native build/output evidence is retained separately as a
shared-build-area failure, not blamed on its compiler. The serial scheduling does
not remove a test or change an expected result.

Clang still fails two zjson C.UTF-8 checks in this serialized run:

```text
FAIL: malformed UTF-8 still produces a JSON string; expected $'0', got $'1'
FAIL: JSON replaces malformed prefixes and retains following text; expected replacement,A,e-acute, got empty
```

The project reports 14,237 checks and two failures. The raw log retains the
actual expected-byte representation. Other Clang suites, including core, zdraw,
zmdown, zcurl, zhtml2md and zoup, pass. This specific failure reproduces after
the build scheduling is corrected and blocks a compatible Clang candidate.
It is not labeled a compiler bug without a source-level reproducer, and no
customer code or assertion was patched to suppress it.

Because of this blocker, Clang received no supported performance adoption claim
and no terminal compatibility certificate. The initial missing-function error
is separately explained above and is not conflated with a genuine Clang/OMZ
regression.

## GCC verification

Both private candidates were staged as inactive versioned packages after local
protection snapshots. The public `psh` link remained the original
`1.0.0-rc2-b80aa8a9db05`. The GCC package used the tested zdraw/zcurl/zmdown
modules through the provided staged-module workflow, then passed
`Packaging/verify.py verify` before any activation decision:

- seven core/bundled suites passed;
- 24 unchanged OMZ interactive sessions passed, including editor/completion,
  history, prompt, syntax highlighting and async behavior;
- all ordinary startup modes and interactive login PTY behavior passed;
- 14 native codec/preload observations passed;
- 11,830 protected entries, including stable Zsh and personal/global startup
  inputs, remained unchanged.

This validates GCC's private control, not a new source optimization. Clang's
known project-suite failure prevents comparing or choosing it as a compatible
performance option. No a posteriori exclusion of that test is allowed.

## Decision and next routes

There is no compiler replacement, source change, elapsed-time speedup claim or
active-installation change from this investigation. Compatible GCC evidence
cannot override Clang's known incompatibility. PGO is not presented as portable:
the current packager explicitly requires GCC for its supported instrumentation
path. No instrumentation workaround was introduced for Clang.

The failed zjson case remains the first item to isolate if a Clang route is
revisited. Otherwise, the previously surveyed arithmetic execution-plan work
and measured integration of additional real application kernels are the next
higher-potential areas. No such architectural change is made by this report.

Raw build/test logs, package provenance and validation records remain in each
versioned private work directory and under `Perf/results/round69`.
