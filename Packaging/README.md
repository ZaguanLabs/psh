# Installing psh alongside Zsh

This distribution installs psh and all six pinned customer packages together.
It retains `ZSH_VERSION=5.9.2`, `zsh/*` module identities, native package names,
and the usual personal startup filenames. It does not replace the system Zsh,
alter personal startup files, or change the account's login shell.

The [first installed release's validation record](validation-2026-11-07.json)
contains executable and native-module hashes, pinned revisions, suite results,
and the protection-check summary. Full local logs remain under `.work/package/`.

## Layout

| Entry | Purpose |
| --- | --- |
| `/usr/local/bin/psh` | Public executable, through `current` |
| `/usr/local/bin/psh-config` | Discover this release's package and SDK paths |
| `/usr/local/psh/current` | Active release symlink |
| `/usr/local/psh/releases/5.9.2-<digest>/bin/psh` | Versioned executable |
| `<release>/lib/psh/5.9.2/` | `zdraw.so`, `zcurl.so`, `zmdown.so`, and stock `zsh/*.so` |
| `<release>/share/psh/5.9.2/functions/` | Stock functions, completions, and package autoloads |
| `<release>/share/psh/5.9.2/scripts/` | Package libraries, data, documentation, and licences |
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

## Build, test, and activate

Use Python 3.12+, Git, Make, a C compiler, Autoconf/Autoheader, Yodl, wide-character
ncurses and PCRE2 development files (`pcre2-config`), and libcurl development
files >= 8.16.0 with `pkg-config`. Project tests also use Python, OpenSSL, `tic`, and standard Unix
utilities. No downloaded dependency or system package change is performed by
these scripts. Builds target the current machine and its installed libraries.

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

Build inputs determine the release digest. An existing build directory is
retained rather than overwritten. Each command accepts `--build PATH` to select
a previous `build.json`; the default is `.work/package/latest.json`. Logs,
local protection snapshots, test reports, and the validation receipt remain in
`.work/package/<release>/`. Protection snapshots contain file metadata and hashes;
keep them local.

`Packaging/test.py` runs the full upstream shell suite and all six project
suites, with a private `zsh` executable shim for tests that hardcode that name.
The shim selects the installed candidate; it is never installed globally.
Native project builds use disposable clones of the configured psh source tree.
The module refresh publishes the exact `.so` files exercised by those suites.
Final verification checks native loading paths, installed libraries and entity
data, interactive login startup in a PTY with temporary dotfiles, source hashes,
and the unchanged stable Zsh installation. An active release's modules cannot
be refreshed in place.

Verification also compares the installed stock module inventory with
`/usr/bin/zsh`, refusing activation if an existing module is absent from psh.
PCRE2 support is explicitly enabled; it is optional and off by default in the
upstream source configuration.

## Use the bundled packages

Start a trial shell with `psh`, or run an application explicitly:

```sh
psh /path/to/zcoder.zsh
```

The current local zcoder checkout can automatically re-execute its own private
Zsh and prefer its own native modules. To test this psh and its bundled modules
specifically, use this launch form (no zcoder files need changing):

```zsh
ZCODER_RUNTIME=system psh -dfc '
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

Use `psh-config --module-dir`, `--function-dir`, `--headers-root`, `--mandir`,
`--prefix`, or `--version` for the other paths. A new native module must use this
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
