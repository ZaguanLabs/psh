# psh — Performance SHell

A Zsh 5.9.2 performance fork for people who do substantial work inside the shell.

psh grew out of Zsh applications: editors, chat clients, terminal interfaces and
graphics experiments. It targets repeated interpreter work in those programs
while preserving existing Zsh behavior by default. The current public candidate
is **1.0.0-rc1**, with 30 accepted core optimizations and six bundled companion projects.

[Release notes](../Releases/1.0.0-rc1.md) ·
[Compatibility](../COMPATIBILITY.md) ·
[Installation](../Packaging/README.md) ·
[Performance evidence](../Perf/README.md)

## Try the source release

Download the attached `psh-1.0.0-rc1.tar.xz` from
[Releases](https://github.com/ZaguanLabs/psh/releases). It includes the verified
upstream sources needed by the build tools, so no Git checkout is required.

```sh
tar -xf psh-1.0.0-rc1.tar.xz
cd psh-1.0.0-rc1
python3 Perf/build.py --which candidate --profile release
./psh --version
./psh -f
```

This core trial builds and runs in the extracted directory. It does not install
a system shell, change your login shell or edit your startup files. Core builds
retain debugger symbols; the full packaging workflow splits them into a separate
file. The six bundled projects are installed through that full workflow.

The complete [installation guide](../Packaging/README.md) covers dependencies,
native modules, verification, isolated paths and rollback. The packaged release
is currently validated on Mageia Linux x86-64. Other platforms are experimental.

## New in rc1

Optional GCC PGO/LTO builds, lower glob memory use, faster bounded array copies
and reduced lexer allocation join the core. Bundled zdraw 0.1.4 improves widget
workloads and guards unsafe screen coexistence on affected ncurses libraries.
Memory-safety fixes and stronger native-library and unchanged-Oh-My-Zsh checks
accompany the performance work. [Release notes](../Releases/1.0.0-rc1.md) separate
measured gains from controls and explain the tested limits.

## What changes

The accepted changes cover array access and append, metafied strings, ASCII and
multibyte traversal, pattern matching, substitutions, arithmetic conversion,
option emulation and local-parameter cleanup. Eligible paths avoid repeated
work; uncertain cases retain the original implementation.

The package also includes:

| Project | Purpose |
| --- | --- |
| **zdraw** | Terminal drawing, Unicode measurement, input and UI companions |
| **zjson** | Pure Zsh JSON parsing and encoding |
| **zcurl** | Native HTTP/HTTPS and WebSocket operations through libcurl |
| **zmdown** | Native Markdown rendering for terminals |
| **zhtml2md** | Pure Zsh HTML-to-Markdown conversion |
| **zoup** | Pure Zsh HTML cleaning |

Pinned sources, provenance, tests and component licences are included. These
projects retain their own APIs and development status.

## Compatibility matters

`$ZSH_VERSION` remains `5.9.2`; stock modules keep their `zsh/*` names. Personal
Zsh startup filenames retain their meaning, while the installer uses separate
psh directories and global configuration. It leaves stable Zsh installed.

Oh My Zsh working unchanged is a release requirement. The validated setup passes
real completion, history, prompt, highlighting, async and Ctrl-C checks without
framework edits. That is coverage of tested configurations, not a guarantee for
every plugin or every Zsh script.

Read [the compatibility policy](../COMPATIBILITY.md) before adopting psh,
especially for native modules. **Universal drop-in compatibility is not claimed.**
Unexpected script failures and memory-safety problems are bugs.

## Help test rc1

Try your real scripts and interactive setup. Report differences from Zsh at the
[issue tracker](https://github.com/ZaguanLabs/psh/issues), with a minimal example,
both versions, relevant options/locale and expected versus actual results.
Please keep credentials and private startup files out of reports.

The [development history](../README.psh.md) retains accepted and rejected trials,
including slower controls. Upstream Zsh's README and `LICENCE`, psh's `LICENSE`,
and bundled third-party notices remain in the source distribution.
