# psh — Performance SHell

Performance work on the Zsh 5.9.2 release source, with **observable Zsh behavior
as the compatibility contract**. Changes are measured against a pristine build
and checked for expansion, quoting, option, emulation, capture, native API and
signal behavior. Measurements include gains and regressions.

The author's Zsh projects are the primary customer workloads. Their profiles
guide optimization priorities; project kernels and controls accompany focused
shell benchmarks.

```sh
git clone git@github.com:ZaguanLabs/psh.git
cd psh
python3 Perf/build.py
./psh -dfc 'print -r -- "$ZSH_VERSION"'
```

The build uses Python 3.12+, Git, a C compiler and Make. It restores the original
release sources from the `upstream/zsh-5.9.2` tag and verifies all 1,847 file
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

- [Project details and the fifteen experiments](README.psh.md)
- [Build, comparison and benchmark workflow](Perf/README.md)
- [Customer project workloads and remaining coverage](Perf/customer-projects.md)
- [Source-review coverage](Perf/audit.md)
- [Latest measurements and compatibility evidence](Perf/round15.md)
- [Daily installation and bundled packages](Packaging/README.md)
- [Upstream bug report, backported fix and reproducer](Perf/upstream-terminator-read.md)

The review is ongoing. Test results are evidence of compatibility, not proof of
complete equivalence. Internal Zsh identities and public module interfaces are
retained; invocation uses the requested `psh` name.

The original [Zsh README](README), [Zsh licence](LICENCE), and per-file notices
are retained. The repository's existing [ZaguanLabs license](LICENSE) is also
preserved.
