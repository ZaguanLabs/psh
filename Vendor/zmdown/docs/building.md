# Matching Zsh builds

A module must match its shell's architecture, public source revision, and
configuration ABI. A matching version string alone is insufficient. Builds
stay under `.build/`; they do not install anything or change supplied sources.

The default source is `.build/sources/zsh-5.9.2`, private shell build is
`.build/zsh`, and staged module directory is `.build/modules`. See the main
README for the pinned 5.9.2 source download.

`ZSH_BUILD_ROOT` selects an extracted public release or a configured in-tree
source tree. `ZMDOWN_BUILD_NAME=5.8` selects `.build/5.8/zsh` and
`.build/5.8/modules`, with its own source stamp. The test runner selects the
matching private shell automatically. A build name may contain letters,
digits, dots, hyphens, and underscores, but cannot be `.` or `..`.

A cache retains its supplied configuration. Select a new build name when
changing source or configure options; changing `CFLAGS` on an existing cache
does not rerun configure. `make clean` removes the default shell/module cache
only, keeping downloads, supplied sources, and named caches.

## Zsh 5.8 on modern GCC

Zsh 5.8's old configure probes can fail with modern compiler defaults, disabling
dynamic module support or misdetecting terminal library symbols. Configure the
supplied source explicitly before building:

```sh
mkdir -p .build/downloads .build/sources
curl -fL https://www.zsh.org/pub/old/zsh-5.8.tar.xz \
  -o .build/downloads/zsh-5.8.tar.xz
printf '%s  %s\n' \
  dcc4b54cc5565670a65581760261c163d720991f0d06486da61f8d839b52de27 \
  .build/downloads/zsh-5.8.tar.xz | sha256sum -c -
tar -xJf .build/downloads/zsh-5.8.tar.xz -C .build/sources
(
  cd .build/sources/zsh-5.8
  ./configure --enable-dynamic --with-tcsetpgrp \
    CFLAGS='-O2 -Wno-error=incompatible-pointer-types -Wno-error=implicit-int -Wno-error=implicit-function-declaration'
)
ZMDOWN_BUILD_NAME=5.8 ZSH_BUILD_ROOT="$PWD/.build/sources/zsh-5.8" make test
```

The source checksum is from the publisher's
[archive SHA256SUM](https://www.zsh.org/pub/old/SHA256SUM). These compatibility
flags apply to the old shell's configure/build. Standalone renderer, grapheme,
and conformance builds retain `-std=c11 -Wall -Wextra -Wpedantic -Werror`.

Start that matching shell with `.build/5.8/zsh/Src/zsh -df` and prepend
`$PWD/.build/5.8/modules` to `module_path`. Do not load this module into a
5.9.2 shell. `ZSH_TEST_SHELL` can select another shell only when it matches the
staged module's ABI.

## Diagnostics

The builder checks `config.modules` for `name=zmdown link=dynamic` before
compilation. A disabled/missing entry reports the cache's `config.log` and
points to the 5.8 instructions above. If linking produces no shared object,
the builder identifies its expected directory and the configuration files to
inspect. Configure failures remain visible in the command's output.

For a failed 5.8 probe configuration, apply the documented flags in a fresh
source tree, then use a fresh named cache. Avoid overriding the module entry
to force a build after configure reported that dynamic linking is unsupported.

## Verification scope

The real builtin suite, including PTYs and structured native parameters, is
run on private matching Zsh 5.8 and 5.9.2 builds on Linux. The installed host's
5.9.2 shell is also checked against the compatible 5.9.2 module. This is not
cross-platform ABI validation. Other operating systems and shell build
configurations remain unverified.
