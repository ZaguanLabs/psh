# Installing psh alongside Zsh

This distribution installs psh and all six pinned customer packages together.
It retains `ZSH_VERSION=5.9.2`, `zsh/*` module identities, native package names,
and the usual personal startup filenames. It does not replace the system Zsh,
alter personal startup files, or change the account's login shell.

The current project version is **1.0.0-rc0**. `psh --version` reports
`psh 1.0.0-rc0 (zsh 5.9.2)`; `$ZSH_VERSION` and module/function directories
remain based on Zsh 5.9.2. [Compatibility limits](../COMPATIBILITY.md) and
[original RC validation](../Releases/1.0.0-rc0.md) describe the tested scope.
The [decimal-conversion iteration](../Perf/round26.md) records the current private
build; [release-profile notes](../Releases/rc0-release-profile.md) describe its
configuration and debugger symbols. The project version stays rc0 until public release.

The [first installed release's validation record](validation-2026-11-07.json)
contains executable and native-module hashes, pinned revisions, suite results,
and the protection-check summary. Full local logs remain under `.work/package/`.
The [component packaging fix](validation-2026-11-07-components.json) records the
subsequent repair and its installed-package regression tests.

## Layout

| Entry | Purpose |
| --- | --- |
| `/usr/local/bin/psh` | Public executable, through `current` |
| `/usr/local/bin/psh-config` | Discover this release's package and SDK paths |
| `/usr/local/psh/current` | Active release symlink |
| `/usr/local/psh/releases/1.0.0-rc0-<digest>/bin/psh` | Versioned executable |
| `<release>/lib/psh/5.9.2/` | `zdraw.so`, `zcurl.so`, `zmdown.so`, and stock `zsh/*.so` |
| `<release>/share/psh/5.9.2/functions/` | Stock functions, completions, and package autoloads |
| `<release>/share/psh/5.9.2/scripts/` | Package libraries, data, documentation, and licences |
| `<release>/bin/.debug/psh.debug` | Separate debugger symbols for the stripped executable |
| `<release>/include/psh/` | Matching native module SDK (`config.h` and `Src/` headers) |
| `<release>/share/man/` | Private manual pages, including `psh(1)` |
| `/usr/local/psh/site-functions/` | Optional local psh functions |
| `/usr/local/psh/etc/` | Optional global `zshenv`, `zshrc`, `zprofile`, `zlogin`, `zlogout` |
| `/usr/local/psh/state/` | Active-release record and `/etc/shells` backup |

The release's compiled default `module_path` and `fpath` point to its own
directories. Configure's otherwise implicit system Zsh site-function fallback
is disabled. Global startup files also use the private psh directory. Existing
personal `~/.zsh*` files, or `$ZDOTDIR/.zsh*`, retain their normal meaning;
assignments in those files can override lookup paths as in Zsh.

Each binary pins the paths of its release. Switching `current` therefore leaves
already running shells using their original matching modules. Keep old release
directories while any process still uses them. The development `./psh` produced
by `Perf/build.py` remains a separate executable with development paths.
After upgrading, start a new psh process. Recreate any application trial that
cached a versioned package path, using the current `psh-config --script-dir`.

## Build, test, and activate

Use Python 3.12+, Git, Make, a C compiler, Autoconf/Autoheader, Yodl, wide-character
ncurses and PCRE2 development files (`pcre2-config`), and libcurl development
files >= 8.16.0 with `pkg-config`. Project tests also use Python, OpenSSL, `tic`, and standard Unix
utilities. No downloaded dependency or system package change is performed by
these scripts. Builds target the current machine and its installed libraries.
The split-symbol default additionally uses GNU `objcopy` and `strip` and checks
ELF64 little-endian runtime sections and dynamic exports before/after. Use
`--symbols embedded` to retain symbols in the executable. The default
`--profile release` disables Zsh debug assertions; `--profile debug` enables
them for development and gives the build a distinct digest. Symbol storage is
independent of assertions: both profiles use `-O2 -g`, with explicit `LDFLAGS=-g`
to prevent configure from stripping symbols before the separate debugger file
is created. Native modules retain the exact bytes exercised by their suites.
The separate debug file is installed too, so this reduces executable size rather
than promising an equivalent reduction in total installation space.

Use the private installer below for installation. The retained upstream
`make install` target follows configure's Zsh defaults and can target a Zsh
installation; it is not the psh installation workflow.

Run the build and tests as your normal user. Use `sudo` only for installation:

```sh
python3 Packaging/build.py
python3 Packaging/verify.py snapshot
sudo python3 Packaging/install.py candidate
python3 Packaging/test.py
python3 Packaging/verify.py stage-modules
sudo python3 Packaging/install.py refresh-modules
python3 Packaging/verify.py verify
# Preview /etc/shells: activation appends /usr/local/bin/psh if absent.
sudo python3 Packaging/install.py activate
```

The candidate is installed into an inactive versioned directory so test children
can use its real compiled paths. The public executable and shell registration
are published only after successful validation. Activation appends exactly
`/usr/local/bin/psh` to `/etc/shells`, preserving the existing entries and saving
a backup. It refuses unrelated existing public entries.

Oh My Zsh is now a required compatibility gate for private development and
activation. The normal-user verifier tests the checkout at `~/.oh-my-zsh`, with
the literal theme/plugin choices and numeric history limits from `.zshrc`, plus its configured syntax
highlighter, in isolated interactive homes. Personal startup files, secrets and
unrelated startup programs are not sourced. All framework/theme/plugin files
remain unchanged; update checks are disabled only in those test sessions and
completion security auditing stays enabled. Use `--ohmyzsh-root PATH` with the
verifier to select another checkout.

Activation refuses missing, failed, stale or different-executable OMZ evidence.
Only the unprivileged verifier executes framework code. Refresh the gate for an
existing release, including a rollback candidate, without rerunning its build:

```sh
python3 Packaging/verify.py ohmyzsh --build /path/to/build.json
```

The standalone test supports explicit `--theme`, repeated `--plugin` and
`--syntax-highlighting` inputs when configuration cannot be read as literal
values. The [coverage report](../Perf/round21.md) records the tested revisions,
interactive operations and limitations.

Build inputs determine the release digest. An existing build directory is
retained rather than overwritten. Each command accepts `--build PATH` to select
a previous `build.json`; the default is `.work/package/latest.json`. Logs,
local protection snapshots, test reports, and the validation receipt remain in
`.work/package/<release>/`. Protection snapshots contain file metadata and hashes;
keep them local.

`Packaging/test.py` runs the full upstream shell suite through
`Packaging/core-test.py`, using the exact installed ELF through a private
symlink named `zsh`. Hardcoded upstream child paths and configured module-file
paths are routed to the installed executable/modules in a disposable harness.
This preserves upstream diagnostic-name expectations; direct `psh` identity,
option listings, startup and package loading are tested separately.
All six project suites also use the installed shell, with a private `zsh`
executable shim for tests that hardcode that name.
The shim selects the installed candidate; it is never installed globally.
Native project builds use disposable clones of the configured psh source tree.
The module refresh publishes the exact `.so` files exercised by those suites.
Final verification checks native loading paths, installed libraries and entity
data, interactive login startup in a PTY with temporary dotfiles, source hashes,
and the unchanged stable Zsh installation. Release-profile verification also
checks the DEBUG setting in the matching SDK and compares terminal loading against system Zsh for unset, empty, invalid and
valid TERM values. An active release's modules cannot be refreshed in place.

It also checks the installed zdraw component files and their relative library
dependencies, then runs the upstream change-gutter rendering assertions against
the installed component and native module in a PTY. Run that regression alone
with `python3 Packaging/test-installed-components.py`.

Verification also compares the installed stock module inventory with
`/usr/bin/zsh`, refusing activation if an existing module is absent from psh.
PCRE2 support is explicitly enabled; it is optional and off by default in the
upstream source configuration.

## Use the bundled packages

Start a trial shell using the private default function path:

```sh
env -u FPATH /usr/local/bin/psh
```

Zsh honors an inherited `FPATH`. This machine's current interactive Zsh exports
a path containing its own system functions and personal plugins; psh preserves
that environment-variable behavior. Clearing `FPATH` for this child process
lets psh initialize its private defaults before reading your normal startup
files. It does not change the parent shell, your dotfiles, or core semantics.
If `FPATH` is unset already, plain `psh` selects the private defaults too.

The current local zcoder checkout can automatically re-execute its own private
Zsh and prefer its own native modules. To test this psh and its bundled modules
specifically, use this launch form (no zcoder files need changing):

```zsh
env -u FPATH ZCODER_RUNTIME=system /usr/local/bin/psh -dfc '
  zmodload zdraw zmdown zcurl || exit
  _psh_entry=$1
  shift
  source "$_psh_entry" "$@"
' psh "$HOME/dev/ai/zaguan/labs/zcoder.zsh/zcoder.zsh"
```

Here zcoder's `system` setting means to keep the invoking shell. Preloading the
native modules makes its existing loaders retain these tested copies. Put any
zcoder arguments after the filename. This is a launch recipe, not a claim that
the complete application session has been tested.

Loading remains explicit, so shell startup does not acquire package side effects:

```zsh
zmodload zdraw zcurl zmdown
autoload -Uz zjson zjson_quote zhtml2md zoup zdraw-ui
zjson                         # source the complete JSON library
zjson_quote 'hello'           # public zjson_* APIs can also load lazily
print -r -- "$REPLY"
zhtml2md <<< '<p>Hello &amp; welcome</p>'
zoup clean --stdout -- '<p>Hello<script>discard()</script></p>'
zmdown --plain --text '**Hello**'
zdraw-ui                      # load the existing drawing helpers
```

The original source entry points remain available when applications need them:

```zsh
source "$(psh-config --script-dir)/zjson/zjson.zsh"
source "$(psh-config --script-dir)/zcurl/zcurl.zsh"
```

Reusable zdraw components keep their upstream relative paths, including
`zdraw/examples/components/change-gutter.zsh`, `linked-detail.zsh`, and
`status-strip.zsh` below `psh-config --script-dir`. These are runtime helpers used
by applications, despite living under `examples/` upstream. For example:

```zsh
source "$(psh-config --script-dir)/zdraw/examples/components/change-gutter.zsh"
```

Use `psh-config --module-dir`, `--function-dir`, `--headers-root`, `--mandir`,
`--prefix`, or `--version` for the other paths and project identity.
`psh-config --version` now returns `1.0.0-rc0`; use `--zsh-version` for `5.9.2`
and `--build-id` for the source/settings digest. A new native module must use this
release's SDK and be tested with this executable. Do not copy a system Zsh `.so`
into psh just because the version string matches. Applications that hardcode
their own module directories or an external `zsh` command still select those
explicit paths; edit or override those application settings when testing psh.

Read the private manual with `man -M "$(psh-config --mandir)" psh`.

The source imports and full file hashes are recorded in
[`Vendor/sources.json`](../Vendor/sources.json). Imports use committed project
snapshots, preserving their licences and tests; local uncommitted changes in the
original repositories are not included or modified. Native rendering and network
code still link the system ncurses/libcurl libraries normally.

## Returning to Zsh

Exit the trial psh session to return to the launching shell. Installation does
not run `chsh`. If you later choose psh as your account login shell, make that
separate choice after testing your normal startup and applications.

For a later psh upgrade, retain the previous release and its validation record;
the active symlink can be returned to that directory. Do not delete a release
still used by running shells. For complete removal, first ensure no account uses
`/usr/local/bin/psh` as its login shell, remove that exact line from `/etc/shells`
while preserving subsequent edits, and remove only the psh public links and
private installation tree. The installer records release file manifests in
`<release>/psh-install.json`; the system Zsh paths are outside that tree.


## Source RC artifacts

Use the attached `psh-1.0.0-rc0.tar.xz` release asset for an archive build. It
includes the verified upstream baseline needed by `Perf/build.py`; GitHub's
automatic source snapshots do not include that extra baseline archive. A Git
clone can obtain the baseline through the upstream tag instead.

Maintainers create the source artifact from a clean committed tree:

```sh
python3 Packaging/source-release.py --ref HEAD --output .work/releases/rc0-release-profile
```

An existing source archive is never overwritten with different bytes. During
private rc0 iteration, select a fresh `--output .work/releases/<checkpoint>`
directory and retain the earlier source artifact. `--ref` must identify the
committed inputs being packaged. The original rc0 tag remains a checkpoint.

The result under the selected directory includes a source tarball,
`SHA256SUMS` and commit/tree/baseline metadata. It excludes local caches and
protected-file snapshots. Tar metadata and compression are deterministic for
the same source commit. The source archive carries the vendored sources and
licences; it does not claim a prebuilt binary will run on another distribution.
