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

## Unreleased post-rc2 system-module corrections

The research branch includes corrections which are **not present in installed
or published rc2**. Ordinary valid descriptors keep their existing behavior,
but scripts depending on the following accidents will behave differently:

- `sysopen` now decodes Zsh's internal filename representation before calling
  the OS. Affected byte/UTF-8 names select the requested file instead of an
  encoded spelling. Scripts which compensated for the bug must remove that
  compensation; files created with the wrong spelling may need an explicit,
  reviewed rename. No automatic file migration is performed. See [round 48](Perf/round48.md).
- `sysread` descriptor and size options, `syswrite -o`, and `sysseek -u` now
  reject parsed integers outside `[0, INT_MAX]` before narrowing them. On the
  tested platform, values such as `4294967296` previously aliased descriptor
  zero. Pass the actual descriptor or a supported buffer size instead. See
  [round 49](Perf/round49.md).
- `systell()` checks the original integer or floating-point argument before
  converting to a descriptor. Oversized integers, infinities, and NaN are
  rejected. Representable fractions still truncate toward zero, including
  `systell(-0.9)` selecting descriptor zero. See [round 50](Perf/round50.md).
- On builds using the `select` fallback, `sysread -t` now rejects input
  descriptors at or above `FD_SETSIZE` with parameter error status 1. Previously
  constructing the descriptor set accessed memory out of bounds. Use a lower
  descriptor or a build with `poll`; untimed reads retain high-descriptor
  support. Rejection precedes evaluation of the timeout expression. The normal
  Linux `poll` build is unaffected. See [round 51](Perf/round51.md).
- `sysread -t` now rejects NaN, infinities, and numbers outside the backend's
  representable conversion range with status 1 and `timeout out of range`.
  The expression still executes once before this check, while I/O and
  result/count assignments are skipped. On typical 32-bit-int platforms,
  poll accepts nonnegative integer seconds through 2147483 (about 24.9 days);
  fractional seconds can reach the millisecond
  conversion boundary. Select retains its int-second boundary. This fixes
  silent wraparound and undefined conversion; it does not introduce a cap
  or chunk long waits. Use representable waits in an application-controlled
  loop for longer durations. Supported negative waits remain backend-specific,
  including poll's indefinite-wait convention. Newly rejected inputs can
  trigger the same error-control effects described below. See [round 52](Perf/round52.md).
  [Round 53](Perf/round53.md) removes the unnecessary lower range restriction
  for poll: all finite negative integer seconds and floating values at or
  below -1 second select its indefinite-wait sentinel without narrowing or
  multiplying their magnitude. Fractions between -1 and zero retain their
  existing millisecond truncation (so -0.0001 still polls immediately).
  This deliberately gives very large finite negative inputs the same meaning
  as -1 instead of reproducing accidental wraparound or round 52's rejection.
  NaN and infinities remain parameter errors; select keeps its existing policy.

`zselect` now validates the full parsed descriptor against its existing
`FD_SETSIZE` bound before converting to int. An oversized number can no longer
alias a valid descriptor and report readiness for it. Range errors return
status 1 and leave the default/named arrays and associative results untouched;
the diagnostic prints the full parsed value instead of a wrapped int. Ordinary
lexical checks and their order remain in place. Pass actual descriptors instead
of relying on wraparound, and handle status 1 before reading readiness results.
See [round 54](Perf/round54.md). This can change success/error branches and stop
later option processing for previously accepted oversized arguments.

`zpty -rt` now uses `poll` when available, allowing valid PTY descriptors at
or above `FD_SETSIZE` without writing beyond a fixed-size descriptor set.
On select-only builds, these reads instead return status 1 with a range
diagnostic before pattern processing, consuming buffered output or assigning
the destination parameter. Use a poll-capable build, keep fewer descriptors
open, or use a blocking read when appropriate. Reads without `-t` retain
support for high descriptors. Ordinary readiness, data and pattern behavior
are unchanged in the tested controls; see [round 56](Perf/round56.md).

`zsystem flock -i` now rejects NaN retry intervals with the existing invalid
interval diagnostic and status 1, before opening the lock file or assigning
the `-f` variable. Previously NaN bypassed both range comparisons and reached
an undefined integer conversion; a release build could silently acquire a lock.
Use a positive finite interval. Existing rounding of sub-microsecond positive
values to one microsecond and the upper bound are retained. The expression's
side effects still occur once; later options are skipped after rejection.
Timeout (`-t`) behavior is unchanged. See [round 57](Perf/round57.md).

The exported `zcloselockfd(int)` now rejects negative descriptors before
indexing the descriptor table. `zsystem flock -u -- -1` retains status 1 and
its existing not-in-use diagnostic, without reading outside the table.
Native callers retain the same signature, -1 error return and unchanged errno.
Ordinary fractional truncation is preserved. This does not fix the separate
narrowing of wide arithmetic results in the system-module caller; see
[round 58](Perf/round58.md) for the tested scope.

The round-59 follow-up validates `zsystem flock -u` arithmetic before narrowing
to int. Wide integers, out-of-range floats, NaN and infinities now return status
1 with a range diagnostic, leaving locks intact. For example, `fd + 4294967296`
previously unlocked `fd` on the tested platform; it is now rejected. Pass the
actual descriptor instead. Fractional truncation remains supported, including
`fd + 0.9` and `-0.9`. Arithmetic is evaluated once and its existing side effects
remain; evaluation errors stop before descriptor access. Native interfaces and
valid negative-descriptor diagnostics are unchanged. See [round 59](Perf/round59.md).

`read -u` now checks the parsed integer before narrowing it to a descriptor.
On the tested platform, `4294967296 + fd` previously read `fd`. Values outside
`[0, INT_MAX]` now return status 1 with `file descriptor out of range` and do
not read. `read -t` on a descriptor at or above `FD_SETSIZE` uses `poll` where
available, so a valid high descriptor still times out or returns data. A
select-only build reports an invalid descriptor instead of indexing past the
fixed descriptor set. `read -t 0 -k 1 -u 2147483647` previously crashed; it now
returns status 1. `print -u` has the same narrowing and is not part of this
correction. See [round 60](Perf/round60.md).

The round-61 follow-up applies the same pre-narrowing range check to `print -u`.
For example, `4294967296 + fd` previously wrote to `fd`; it now returns status 1
with `file descriptor out of range` before duplicating a descriptor or writing.
Pass the actual nonnegative descriptor instead. Existing lexical diagnostics,
ordinary descriptors, closed but representable descriptors, coprocess output,
and the undocumented `-up` spelling remain unchanged. No native interface is
changed. See [round 61](Perf/round61.md).

`zle -F` now validates its descriptor before narrowing to int. On the tested
platform, `4294967296 + fd` previously added, replaced, listed or removed the
handler belonging to `fd`. Values outside `[0, INT_MAX]` now return status 1
with the existing `Bad file descriptor number for -F` diagnostic without
changing watcher state. Install or remove the watcher using its actual
nonnegative descriptor. Ordinary parsing, `-w`, listing, replacement, callback
dispatch and removal are unchanged. No native interface is modified. See
[round 62](Perf/round62.md).

On select-only builds, `zle -F` now rejects descriptors at or above
`FD_SETSIZE` with `file descriptor out of range for select`, status 1 and no
watcher-state change. Previously it indexed outside select's fixed-size sets;
the tested high-descriptor callback was not delivered. Use a build with `poll`
for such descriptors, keep fewer descriptors open, or perform the I/O through
another supported mechanism. Descriptors below the bound retain select's
ordinary callback behavior. Poll-enabled builds continue to support them.
Native layouts and callback interfaces are unchanged. See
[round 63](Perf/round63.md).

`zsocket` now validates accept and `-d` descriptors before narrowing.
`4294967296 + fd` no longer accepts a connection from, or moves a listener onto,
the different descriptor `fd`. Negative values no longer index before the shell's
descriptor table. The existing invalid-argument diagnostics and status 1 are
used without creating a socket. Historical numeric-prefix parsing is retained:
an argument such as `3x` still selects descriptor 3, with no promise that this
is a recommended spelling. Ordinary zero/nonnumeric errors and closed-fd errors
are unchanged. In select-only builds, `zsocket -a -t` also rejects descriptors
at or above `FD_SETSIZE` with a select-range diagnostic before consuming a
connection; use `poll`, fewer descriptors, or blocking acceptance instead.
Ordinary high-descriptor acceptance remains supported. No native interface is
modified. See [round 64](Perf/round64.md).

`ztcp -c`, `-a` and `-d` now validate descriptors before narrowing to int.
Previously `4294967296 + fd` could close or accept on session `fd`, or redirect
a new listener onto descriptor `fd`. Wider and negative values now return the
existing invalid-argument diagnostics and status 1 before operating on these
descriptors. Use the real descriptor. Numeric prefixes such as `3x` retain their
legacy behavior; ordinary zero/nonnumeric errors and closed/unknown descriptor
errors are unchanged. Select-only `ztcp -a -t` also rejects descriptors at or
above `FD_SETSIZE` before consuming a connection. Use poll, fewer descriptors,
or ordinary blocking acceptance instead. Ordinary high-descriptor acceptance,
session ownership and native interfaces are unchanged. Port-number parsing is
separate, legacy behavior and is not altered. See [round 65](Perf/round65.md).

The round-66 follow-up validates numeric TCP ports before `htons()`. A value
such as `65536 + port` previously listened on or connected to the truncated
`port`; a negative argument was likewise used as an unsigned port. Numeric
ports outside `1..65535` now return status 1 with `bad service name or port
number`, before socket creation. Use the actual port. Standard service-name
lookup and legacy numeric prefixes such as `2323x` remain supported. Existing
zero/nonnumeric outbound error behavior is unchanged; listener zero was already
rejected. Native interfaces and descriptor handling are unaffected. See
[round 66](Perf/round66.md).

Earlier rejection has observable consequences. For example:

```zsh
x=0
sysseek -u 4294967296 '++x'
```

On tested pristine Zsh, the descriptor aliases zero and `x` becomes 1 before
the seek. The candidate reports parameter error status 1 without evaluating
`++x`. A wrapped but closed descriptor can likewise change an OS error status
2 into parameter error status 1. Result/count variables can remain untouched
where a legacy I/O attempt modified them. Ordinary command expansions still
occur before builtin validation; this does not promise that invalid commands
have no side effects whatsoever.

New failures also affect conditionals, ZERR traps, ERR_EXIT, ERR_RETURN, and
subsequent arithmetic execution. A `systell()` range error uses the existing
arithmetic-error path, which can abort the containing expansion or execution
context. Argument side effects evaluated before reaching `systell()` remain.
Use real descriptors and handle the command's status; do not depend on numeric
wraparound, on an invalid arithmetic call returning a usable value, or on
`ERRNO` after parameter errors. Diagnostics can themselves affect `ERRNO`;
the module documents it for OS-error statuses, not parameter error status 1.

The error-context matrix in [round 51](Perf/round51.md) compares new rejections
with established negative-descriptor failures, and retains valid/ordinary-error
controls against pristine Zsh and rc2. This is focused Linux x86-64 coverage,
not a guarantee for every trap combination or architecture. These corrections
do not change the native ABI, and no performance gain is claimed.

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
