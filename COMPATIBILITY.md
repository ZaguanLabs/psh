# Compatibility policy for psh 1.0.0-rc0

psh targets the language and public module interfaces of **upstream Zsh 5.9.2**.
It is an experimental performance fork. **We have not established 100% drop-in
compatibility for arbitrary scripts, configurations, modules or platforms.**
Passing tests establish coverage of those cases; they do not establish that an
unknown script will work. An undocumented language, status, diagnostic, option,
expansion or evaluation difference is a compatibility bug, including one found
outside the author's own projects.

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

## What has and has not been checked

The [source-review map](Perf/audit.md) describes focused coverage. Nineteen
accepted optimizations change a limited set of core paths: arrays/subscripts,
metafied strings, character scanning, terminal-star matching, substitution and
arithmetic. This is not a completed audit of the complete interpreter.

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
