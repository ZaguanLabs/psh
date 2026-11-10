# Round 37 evidence

The [report](../../round37.md) adopts arithmetic state-contract maintenance and
development-module isolation. Active iteration: `1.0.0-rc0-7e8f4c48abf5`, ELF
SHA-256 `8f4b852f5e26aac6942b956f064ee1629177c0c5ffc3702b57b2513be8db837d`.
There are still 27 accepted optimizations. This is not a speedup claim.

## Final selected implementation

- [Source checks](source-checks.json) bind the five-file
  [incremental patch](../../0037-arithmetic-state-contract.patch), exact original
  `math.c` reconstruction, all 1,853 canonical inputs, 1,847 pristine files,
  frozen source/driver/builder hashes and 124 unchanged generated native headers
  per compiler. Only `Src/math.c` changes among canonical package inputs.
- [Compiler identity](code-identity.json) and its [helper](code-identity.py)
  establish equal complete preprocessed token streams, allocated arithmetic-object
  sections, text relocations and exports with both GCC and Clang release builds.
  `paired-*` and `clang-paired-*` build/upstream/state records refer to the final
  field-list implementation; `previous-*` and `clang-previous-*` are reference builds.
- [Installed identity](installed-code-identity.json) records equal whole-core
  `.text`, `.data`, `.bss`, executable size and exports. The only changed allocated
  sections are build ID and readonly data; readonly differences normalize exactly
  by replacing the old release name with the new one in compiled paths.
  [Native identity](native-code-identity.json) retains the list of all 40 matching
  native-module text sections.

## Tests and exact installed measurements

- [Broad validation](validation.json) has 13 passing groups and detailed
  commands/logs. `math.json` records 195,600 differential comparisons, including
  the new state cases. Customer correctness and five original project suites
  are retained alongside the frontend/native comparisons.
- `paired-state-memcheck.json`, `clang-paired-state.json`,
  `installed-state-memcheck.json` and `development-state-memcheck.json` cover
  four pairs in C/C.UTF-8. There are 5,184 paired comparisons across 16
  instrumented host/locale invocations, including forked subshells; every final
  quiet error log is empty, leak checks disabled. The corpus has 54 expressions
  across three emulations and four option contexts, 648 comparisons per locale.
- GCC and Clang final upstream logs show 63 passed, zero failed, two skipped;
  pristine DEBUG and published developer DEBUG logs show 62/0/3. The rebuilt
  DEBUG oracle's module isolation is verified separately.
- [Installed profiles](installed-profiles.json) bind eight exact old/new release
  runs to matching project, worker and resulting-state fingerprints. Their
  `installed-*.callgrind.gz` data are raw profiles with deterministic compression;
  flat views and output/log receipts are retained. These are final profiles,
  distinct from the earlier typed-record profiles.
- [Timing preconditions](timing-preconditions.json), brief CPU observation,
  [commands](timing-commands.json) and four customer/library result groups retain
  all nine alternating samples, both passes and every slower control. Own builds,
  tests and profiling finish first; external activity is not continuously audited.
  Timings do not establish a causal change for byte-identical machine code.

## Rejected experiments and baseline setup failure

`typed-record/` retains the first save-record source, patch, commands,
GCC/Clang builds/upstream/focused checks, broad validation and eight raw
private-build profiles. Its GCC frame reserves 64 more bytes, so it is not selected.
It was never packaged or activated. Profile counts from this directory are not
substituted for the final installed profiles.

`object-probes/` holds complete C sources for the separate-error-result,
readonly-metadata, paired-field and declaration-generating probes. Their
command/source/code fingerprints and assembly remain in the root receipts.
Object-only variants have no claimed runtime certification. The successful
paired-field probe became the final implementation with explanatory comments;
its actual final builds have independent compiler identity proof.

`test-setup-failure/` preserves the initial DEBUG failure, old builder source,
module-load diagnostic and old baseline ELF identity. A pristine shell was
loading psh's `mathfunc.so` from the shared development prefix and failed on
`psh_scope_module_ack` before completing any cases. That failed run is excluded.
[Runtime isolation](development-runtime-isolation.json) records both corrected
default paths and successful real module loading; `pristine-debug-rebuild.log`
records the fixed builder. The entire old baseline build tree stays local.

## Packaging, activation and private checkpoint

Seven `test-*.json` suites and raw logs bind the installed native modules and
scripts. [Package verification](package-verification.json) and [OMZ](ohmyzsh.json)
record 24 genuine terminal sessions with the unchanged re5et/git/highlighter
setup and completion/history/prompt/async/Ctrl-C checks.
[Activation](activation.json) records the active ELF and unchanged previous
release (1,603 manifest entries), stable Zsh/startup files (11,828), `/etc/shells`
and login shell. The filtered installed-package receipt includes native hashes.

Precommit GitHub receipts compare the private draft/seven assets with the
historical receipt. [Final checkpoint helper](final-checkpoint.py) verifies remote
HEAD, original tag, draft, visibility and active binary before updating ignored
local status. Post-push receipts remain under `.work/logs/round37/`. No tag or
release is published and rc0 is unchanged.

[SHA-256 index](sha256.json) covers every archived file except itself. Raw
logs/patch whitespace is preserved. ELF/object binaries, build trees and private
machine snapshots stay local. No fresh other-OS/32-bit/non-multibyte certification
or universal compatibility proof is claimed.
