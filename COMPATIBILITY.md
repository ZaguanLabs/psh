# Compatibility policy for psh 1.0.0-rc0

psh is a performance-first fork based on **Zsh 5.9.2**. Broad compatibility is
valuable, but deliberate breaking changes are allowed when they deliver a
measured benefit and their behavior and migration are documented. The user's
“90% compatibility” direction is not an established percentage or a quota of
tests that may fail. **100% drop-in compatibility with arbitrary Zsh scripts,
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
| Program identity | Version/help text identifies psh; `psh --version` reports `psh 1.0.0-rc0 (zsh 5.9.2)`. Invocation names naturally affect `$0`, `$ZSH_NAME` and some diagnostic prefixes. Tools parsing the old `zsh --version` format need to use `$ZSH_VERSION` or `psh-config --zsh-version`. |
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

## What has and has not been checked

The [source-review map](Perf/audit.md) describes focused coverage. Twenty-six
accepted optimizations change a limited set of core paths: arrays/subscripts,
metafied strings, character scanning, terminal-star matching, substitution and
arithmetic and option emulation. This is not a completed audit of the complete interpreter.

Evidence includes upstream scripts, byte-for-byte differential results, native
fixtures built with pristine headers, allocation-boundary and floating-state
checks, several encodings and emulations, PTY completion/startup checks, and the
author's real project workloads. [RC results](Releases/1.0.0-rc0.md) identify the
actual tested builds; the [private release-profile iteration](Releases/rc0-release-profile.md)
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

The project version remains `1.0.0-rc0` throughout private testing until public
release. Source commit, build digest and binary hashes distinguish those
iterations. The existing `v1.0.0-rc0` tag and its draft identify the initial
checkpoint while work continues on `main`; earlier source artifacts and
installed builds are retained. Public release tags and source archives are
immutable; fixes after public release get a new candidate/version. Wider
testing and reported regressions inform promotion to 1.0.0. The RC label is not
a claim that compatibility review is complete. Existing private releases remain
available for rollback without changing the account login shell or stable Zsh.
