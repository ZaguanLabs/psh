# psh — Performance SHell

**psh 1.0.0-rc0**, based on Zsh 5.9.2, is an experimental performance fork.
Performance takes priority, with broad Zsh compatibility and documented breaking
changes allowed where their benefits justify them. **Oh My Zsh must work
unchanged.** Universal drop-in compatibility is not promised; undocumented or
accidental language/evaluation differences remain bugs. See the
[compatibility policy and intentional differences](COMPATIBILITY.md).

Changes are measured against a pristine build and checked for expansion,
quoting, options, emulation, captures, native APIs and signal behavior.
Measurements include gains and regressions.

The author's Zsh projects are the primary customer workloads. Their profiles
guide optimization priorities; project kernels and controls accompany focused
shell benchmarks.

```sh
git clone git@github.com:ZaguanLabs/psh.git
cd psh
python3 Perf/build.py
./psh --version
# psh 1.0.0-rc0 (zsh 5.9.2)
./psh -dfc 'print -r -- "$ZSH_VERSION"'
# 5.9.2
```

The build uses Python 3.12+, a C compiler and Make. A clone also needs Git
and the upstream tag. The attached source release contains a verified baseline
archive and builds without Git history. It restores the original
release sources from that tag or bundled archive and verifies all 1,847 file
hashes before building the baseline. The supplied release's generated configure
script and documentation are included. Builds and private native modules live
under `.work/`; `./psh` is the local executable. This development build does not
install a system shell.

For daily use, the separate [installation workflow](Packaging/README.md) builds
an isolated `/usr/local/psh` distribution, bundles zdraw, zjson, zcurl, zmdown,
zhtml2md, and zoup, and registers `/usr/local/bin/psh` in `/etc/shells` after
validation. The stable Zsh installation remains in place.

For a shallow clone, fetch the baseline tag first:

```sh
git fetch origin tag upstream/zsh-5.9.2
```

- [Latest investigation: grouped string hashing, not adopted](Perf/round29.md)
- [Current private rc0 optimization, measurements and installed build](Perf/round28.md)
- [Release profile and binary-size details](Releases/rc0-release-profile.md)
- [Oh My Zsh compatibility gate and fresh release-build profiles](Perf/round21.md)
- [Original RC notes, binary-size explanation and validation](Releases/1.0.0-rc0.md)
- [Compatibility policy and reporting regressions](COMPATIBILITY.md)
- [Project details and accepted optimizations](README.psh.md)
- [Build, comparison and benchmark workflow](Perf/README.md)
- [Customer project workloads and remaining coverage](Perf/customer-projects.md)
- [Source-review coverage](Perf/audit.md)
- [Deeper review: arithmetic, locale costs, arrays and allocation](Perf/round19.md)
- [Daily installation and bundled packages](Packaging/README.md)
- [Upstream bug report, backported fix and reproducer](Perf/upstream-terminator-read.md)

The review is ongoing. Test results are evidence of compatibility, not proof of
complete equivalence. `$ZSH_VERSION` remains 5.9.2 and modules retain their Zsh names.
Project version reporting and private integration paths are documented exceptions.

The original [Zsh README](README), [Zsh licence](LICENCE), and per-file notices
are retained. The repository's existing [ZaguanLabs license](LICENSE) is also
preserved.
