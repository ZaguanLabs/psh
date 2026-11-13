# Compatibility policy for psh 1.0.0-rc1 development

psh aims for meaningful performance gains on **Zsh 5.9.2** while preserving
existing behavior by default. Existing scripts working unchanged is the normal
target. Limited, deliberate differences remain possible when their benefit is
substantial, their affected behavior is understood and documented, and a migration
or fallback exists. Commonly used semantics should not be sacrificed for marginal
speedups. The user's “90% compatibility” direction expresses tolerance for limited
differences; it is not an established percentage or a quota of tests that may fail.
**100% drop-in compatibility with arbitrary Zsh scripts,
native modules, configurations or platforms is not promised.**

**Oh My Zsh working unchanged is a hard requirement.** A known framework,
theme, plugin, completion, history, prompt, hook or async regression blocks
adoption. A workaround requiring edits to Oh My Zsh or the user's OMZ setup
does not satisfy the requirement. The user's configured stack is the primary
integration target; representative additional plugins extend its coverage.

Passing tests establishes coverage, not universal proof for every plugin,
future update or platform. Undocumented or accidental behavioral differences
remain bugs, including those found outside the author's projects. Memory
corruption and unsafe ownership are never accepted as compatibility tradeoffs.

## rc1 build and test changes

rc1 retains rc0's core-language and native ownership contracts. Its optional
compiler profiles change code generation, not those contracts. PGO trains on
checked bundled offline workloads; LTO is a separate experiment. The ordinary
compiler profile remains available, and all profiles require the existing
native-module and unchanged-OMZ gates. New stateful differential sequences
exercise mutation, scope and post-error recovery across long-lived processes.

Package staging now removes group/other write permissions from distribution
directories even under a `0002` umask. This prevents insecure completion parents;
the security checks, personal startup files and system Zsh permissions remain
unchanged. Published rc0 source and release assets are retained intact.

## Bundled zdraw 0.1.4 screen safety

The bundled module probes whether the linked curses library can delete one
screen without freeing another screen's windows. Fixed or backported libraries
retain screen coexistence. If that probe fails, `zdraw init` returns failure
while another curses screen is retained, before allocating a new screen; it
preserves the other owner's state and emits a diagnostic. For example, a
`zcurses init; zcurses end; zdraw init` sequence can reach this guard because
ending curses mode does not delete the retained stock screen.

Use a separate process or a library with the fix when coexistence is required
on an affected host. This is the upstream module's safety fix, not a core Zsh
language change or a version-number-based ban. This host passes the probe;
the package suite also tests a forced guard variant. An older ncurses runtime
has not been substituted locally. See [round 47](Perf/round47.md) and the
[zdraw build guide](Vendor/zdraw/docs/building.md).

## Parameter-scope index and native opt-in

Round 35 adds a private bitmap for buckets that may contain local parameters.
The indexed walk retains ordinary bucket order, callback successor tracking,
history/locale restoration and the existing cleanup callback. Generated tables,
nonstandard real-table methods and nested scans retain the legacy path.
Uncertain index state is rebuilt or falls back. Rehashing invalidates the bitmap;
allocation failure falls back
without adding an interpreter error. No public structure layout changes.

**Existing native modules need no scope-related changes.** Before native module
initialization or constructors execute, tracking is suspended. A module which
does not explicitly acknowledge the protocol leaves the process using legacy
scope scans, including after that module unloads. Previously built compatible
modules can still load. Autoload declarations and already-loaded module queries
do not alone disable indexing. Failed native-loading attempts may conservatively
select the legacy path. This is a performance fallback, not a script migration.

Audited modules may opt in during setup using the matching psh SDK:

```c
#ifdef PSH_SCOPE_INDEX_VERSION
    psh_scope_module_ack(m);
#endif
```

Opt in only when real-parameter-table changes use the standard core hash
operations, its methods/representation/bucket links remain under core control,
and every in-place promotion of a visible parameter's level is notified.
`psh_scope_setlevel(pm, level)` publishes the field and bitmap atomically using
the existing signal queue. Alternatively, a caller already holding that queue
may update the level and call `psh_scope_mark(pm)` before releasing it. Detached
snapshots and associative elements are not indexed. Merely rebuilding a module
against the SDK does not opt it in. Omit acknowledgment when these guarantees
cannot be made; the legacy scanner preserves support for direct native writes.

`psh_scope_tracking()` reports whether the native policy currently permits the
index; individual ineligible walks can still fall back. This API is conditional
on the psh SDK feature macro. Modules using it must run against a matching psh
core. The conditional setup acknowledgment preserves source builds against
ordinary Zsh headers. The three bundled native projects carry recorded local
patches for this acknowledgment; their imported revisions and original hashes
remain in `Vendor/sources.json`.

This change introduces no intended Zsh language divergence. Coverage, limits
and the unchanged-framework evidence are recorded in [round 35](Perf/round35.md).

## Withdrawn thread-locale float formatting

Round 40 withdraws the round-39 output optimization. The complete original
`convfloat()` sequence is restored, including the temporary global LC_NUMERIC
change and restoration. Native printf handlers keep their original thread and
global locale observations, including handlers introduced by libc plugins.
The module-only acknowledgment policy could not establish process-wide safety.

The five optional `psh_float_*` exports introduced during private development
remain available so already-built SDK clients still load. `PSH_FLOAT_LOCALE_VERSION`
remains defined as API availability; `psh_float_locale_tracking()` always returns
zero. Acknowledgment, disable and loader begin/end functions are inert. No
thread-locale fast path can be enabled through them. Scope indexing retains its
separate active protocol and original behavior. Public Module layouts are unchanged.
The three bundled native modules no longer acknowledge formatting safety; their
recorded patch history retains both the experiment and its withdrawal.

[Round 40](Perf/round40.md) records the native gconv and explicit ELF-preload
reproducers, the withdrawal and new mandatory native-library compatibility gate.
[Round 39](Perf/round39.md) remains a historical experiment with its measured gains
and earlier tests; those gains are withdrawn from the current development build.

## Required Oh My Zsh gate

`Packaging/check-ohmyzsh.py` sources the installed framework, theme, plugins
and configured syntax highlighter unchanged in real interactive terminals.
It compares psh with system Zsh using isolated homes, histories and caches.
The personal startup file supplies literal theme/plugin choices; the test does
not source that file, private keys or unrelated startup integrations. Update
checks are disabled only in the test environment; completion security auditing
remains enabled.

Coverage includes configured and extra plugins, login and non-login startup,
inherited `FPATH`, cold/warm and cross-interpreter compiled completion caches,
actual completion buffers, rendered syntax highlights, history navigation,
prompt configuration, blocked async handlers and callbacks, and Ctrl-C recovery.
[The recorded baseline](Perf/round21.md) identifies exact revisions and coverage.
New failing OMZ cases must be investigated and added to the gate; existing
passing cases are not permission to accept a known untested regression.

The normal package verifier requires this gate. Activation requires a passing
report bound to the exact installed executable and current test driver. No
framework code runs as root. An existing release or rollback candidate can be
rechecked with `Packaging/verify.py ohmyzsh --build PATH`.

## Accepting a deliberate Zsh difference

Try behavior-preserving approaches first. Architectural changes start by
characterizing the existing behavior and proceed one change at a time, compared
with pristine Zsh and the preceding accepted build. Evaluation order, side
effects, options, diagnostics, scope restoration and supported native interfaces
remain part of that behavior. Uncertain fast-path eligibility or ownership uses
the legacy path. A faster benchmark alone does not justify a semantic regression.

Record its trigger and standard-Zsh versus psh output/status, the performance
evidence and slower controls, affected scripts or native interfaces, migration
or fallback, and the unchanged-OMZ validation. Upstream/differential tests remain
useful for finding differences; intentional changes get explicit expectations
instead of silently disabling checks. Native interface changes require matching
SDKs and rebuilt modules. Round twenty-two introduces no intended shell-language
change; its native array-ownership rules are described below.
Round twenty-three adds only an arithmetic inline hint, with no new intended
language or native-interface difference.
Round twenty-four extends confirmed-prefix reuse to forward array search starts,
under the same ownership and signal guards; it adds no new intended difference.

Round twenty-five merges identical ASCII/token classification branches. It adds
no intended language or native-interface difference.

Round twenty-six accelerates bounded decimal prefixes, then resumes the original
conversion loop for continuations. It adds no intended language or native-interface
difference; original truncation and diagnostic behavior remain in place.

Round twenty-seven prefilters option-emulation scans using the existing scanner
masks. The original setter checks remain for generated tables; no new intended
language, native-interface or ownership difference is introduced.

Round twenty-eight reuses confirmed prefixes when counting an owned array before
append, and records constructed prefixes after eligible assignments. It retains
the existing queued-signal and mutable native getter-loan contract, cache layout
and invalidation. No new intended language or native-interface difference is
introduced; raw field mutation remains subject to the existing migration below.

Round twenty-nine's grouped string-hash prototypes were not adopted. The
original `hasher()` remains unchanged; the added native oracle and performance
controls introduce no installed language, module or ownership difference.

## Deliberate differences

| Surface | Difference and practical consequence |
| --- | --- |
| Program identity | Version/help text identifies psh; this branch's `psh --version` reports `psh 1.0.0-rc1 (zsh 5.9.2)`. Invocation names naturally affect `$0`, `$ZSH_NAME` and some diagnostic prefixes. Tools parsing the old `zsh --version` format need to use `$ZSH_VERSION` or `psh-config --zsh-version`. |
| Language identity | `$ZSH_VERSION` remains `5.9.2`. There is no new reserved `PSH_VERSION` shell parameter. Project versioning does not replace the upstream version used by scripts and module paths. |
| Global startup | Global startup files live under `/usr/local/psh/etc`, separately from the system Zsh configuration. Personal `.zshenv`, `.zshrc`, `.zprofile`, `.zlogin` and `.zlogout` names retain their meaning. A setup depending on system global startup content may need equivalent psh configuration. |
| Functions and modules | Default paths are private, versioned psh paths. Bundled stock modules keep their `zsh/*` names and base version. The six added packages provide additional autoload names. Inherited `FPATH`, and user assignments to `fpath` or `module_path`, retain their usual effects. |
| Build profile | Packaging defaults to `--profile release`, with Zsh debug assertions disabled. `--profile debug` and the separate `Perf/build.py` development build retain assertions. The original rc0 debug build could print an extra diagnostic when loading terminal modules with `TERM` unset or invalid. The release-profile iteration removes this difference through configure settings; symbols remain available separately. |
| Third-party native code | An identical `$ZSH_VERSION` alone does not certify an independently compiled binary module. Build and test it against the matching psh SDK. In particular, moving from the original debug profile to the release profile removes the debug-only `dputs` and `queue_in` exports, just as in pristine Zsh; modules using those exports must be rebuilt. Existing modules are not replaced in the stable Zsh installation. |
| Interpreter selection | A `#!/bin/zsh` shebang, explicit `exec zsh`, or an application's private Zsh runtime continues to select that interpreter. Installing psh does not rewrite scripts, aliases or child commands. |
| Correctness backport | The upstream-maintainer scalar-search terminator-read fix is included separately from performance changes. It corrects an existing out-of-bounds read; identical manifestations of that invalid read are not a compatibility promise. |

Different distribution patches, compiler flags, optional dependencies and locale
implementations can also affect behavior. The pristine comparison baseline is
the imported release, not an arbitrary distribution's configured Zsh package.

## Native array ownership

Round twenty-two caches confirmed array prefixes, using private parameter flag
bit 30, `PM_ARRAY_EXPOSED`, to track mutable vector loans. The parameter/value
structures retain their layout. Calling `getaparam()`, the ordinary array getter,
or whole-array `getarrvalue()` marks the allocation exposed. Such vectors retain
ordinary scanning, including when a module keeps the loan across interpreter
calls, cache eviction, a same-vector setter, or an in-place append reallocation.
Replacing the allocation through its setter permits caching again.
Round twenty-four uses the same confirmed prefixes to locate forward pattern
search starts. It preserves matching/capture behavior and the same native loan
opt-out; a terminator still supplies the original missing index.

Native modules must obtain mutable vectors through those accessors and change
owned parameter allocations through their setters. Do not silently replace,
free, resize or change the terminator of `pm->u.arr` through a raw field alias
while bypassing both the getters and setter. That bypass is outside psh's
supported native contract: it can leave confirmed bounds stale. Migrate it to
`getaparam(name)` or `pm->gsu.a->getfn(pm)` before retaining a mutable vector,
and use `pm->gsu.a->setfn(pm, replacement)` for ownership transfer. Preserve
private flag bits when changing unrelated attributes. The new read-only helpers
are internal to the interpreter and must not provide mutable native loans.

This is an explicit native integration constraint, not a claim that arbitrary
Zsh binary modules remain interchangeable. Rebuild and test third-party modules
against the matching SDK. The bundled native modules are rebuilt and tested;
the retained-loan fixture additionally uses the preceding SDK with both shells.
The [round-twenty-two report](Perf/round22.md) records the ownership tests and
performance controls. Unsafe ownership remains a bug, not an accepted tradeoff.

The explicit negative control is `Perf/array-cache-raw-alias.zsh`, using
`Perf/array-cache-module.c`: warm element 1000, take a raw `pm->u.arr` alias,
temporarily put the terminator at element 4, then query element 1000. The
preceding psh/Zsh scan path prints `raw:present=0:value=`; cached psh prints
`raw:present=1:value=item`. Both exit zero. Replacing the raw loan with the
normal getter prints `getter:present=0:value=` in both interpreters. The fixture
keeps the allocation and tail alive and restores them. This demonstrates the
unsupported bypass and its migration; it is not a supported mutation pattern.
Cache metadata is used only inside already queued signal regions; unqueued
queries retain scanning and the caller's signal-delivery boundaries.

## Nested associative getters

Pristine Zsh 5.9.2 and earlier psh builds can return an inner hash's values
when an outer hash element's native getter calls `gethparam()` for that inner
hash. psh now preserves the outer expansion's working state and pattern across
nested getters. This is a corrected wrong-result bug, not a deliberate loss of
Zsh functionality. Public native layouts and the existing function interface
remain unchanged. The [reproducer and scope](Perf/bugs/hash-getter-reentry.md)
include the observed before/after results and limitations; arbitrary table
destruction or growth during callbacks is not certified by this fix.

## Stock curses character readback

The wide-character `zcurses querychar` implementation inherited from Zsh 5.9.2
passed a single `wchar_t` to an API that writes a terminated string. psh now
allocates the complete cell buffer while continuing to return its first
character. This corrects memory corruption and observed attribute loss in an
earlier psh build; it is not a deliberate incompatibility or native ABI change.
See the [reproducer and evidence limits](Perf/bugs/curses-querychar.md).

## What has and has not been checked

The [source-review map](Perf/audit.md) describes focused coverage. Twenty-seven
accepted optimizations change a limited set of core paths: arrays/subscripts,
metafied strings, character scanning, terminal-star matching, substitution and
arithmetic, option emulation and local-parameter cleanup. This is not a completed
audit of the complete interpreter.

Evidence includes upstream scripts, byte-for-byte differential results, native
fixtures built with pristine headers, allocation-boundary and floating-state
checks, several encodings and emulations, PTY completion/startup checks, and the
author's real project workloads. [RC notes](Releases/1.0.0-rc0.md) identify the
current tested build; the [release-profile history](Releases/rc0-release-profile.md)
records the subsequent configuration change. General asynchronous trap
schedules, all external modules, all locale implementations, other operating
systems and all downstream patch
sets remain outside that evidence. A French Belgian locale test does not
certify every script run in Belgium.

The Linux packaging workflow is validated on this Mageia x86-64 host. Other
platforms can try the core source build, but are not certified by this RC.
Compiler/configuration details belong with every reported result.

## Reporting a compatibility bug

Report a minimal reproducer at the [psh issue tracker](https://github.com/ZaguanLabs/psh/issues).
Include:

- The script or expression and the expected versus actual stdout, stderr and
  exit status.
- `psh --version`, `psh-config --build-id` when installed, and the reference
  Zsh version.
- Operating system, relevant locale and options, emulation, and any required
  plugin/native-module or startup setup.

Try the reproducer with both interpreters using `-df` to narrow startup effects.
If that removes the problem, include the minimal necessary setup. Do not post
credentials or an entire private startup configuration. A working Zsh script
that fails under psh deserves investigation even when every existing test passes.

## RC and promotion policy

Public rc0 is released; this branch prepares `1.0.0-rc1`. Source commit, build
digest and binary hashes distinguish development iterations. The initial private
tag/draft is retained at `archive/private-v1.0.0-rc0`, and the public rc0 tag and
assets remain immutable. Earlier source artifacts and installed builds are
historical checkpoints. Each public tag, `SOURCE-INFO.json` and attached archive must identify
the same source commit. Public release tags and source archives are immutable;
fixes after public release get a new candidate/version. Wider
testing and reported regressions inform promotion to 1.0.0. The RC label is not
a claim that compatibility review is complete. Existing private releases remain
available for rollback without changing the account login shell or stable Zsh.
