# Stock curses querychar supplies an undersized wide-character buffer

Found while integrating zdraw 0.1.4 in [round 47](../round47.md).
This is inherited source code in Zsh 5.9.2, with an observable attribute-loss
failure in the preceding accepted psh build. It is not caused by zdraw 0.1.4.

## Reproducer

Run in a terminal with a wide-character-enabled `zsh/curses` module:

```zsh
zmodload zsh/curses
zcurses init
zcurses addwin sample 2 8 0 0
zcurses attr sample underline
zcurses string sample X
zcurses move sample 0 0
zcurses querychar sample cell
zcurses delwin sample
zcurses end
print -rl -- "${cell[@]}"
```

Expected: `X`, `default/default`, `underline`, on separate lines. The preceding
psh release `1.0.0-rc1-126770ba80d2` loses `underline`. The initial zdraw-update
candidate does too. A pristine Zsh build produces the expected visible result;
that does not make its one-character buffer safe. The manifestation depends on
compiler and stack layout. zdraw's own querychar already uses a full buffer.

## Cause and evidence

`Src/Modules/curses.c:zccmd_querychar()` declares `wchar_t c` and passes `&c`
to `getcchar()`. The library writes a terminated wide-character string, including
any combining characters. Even an ASCII cell needs two `wchar_t` slots.
The [ncurses contract](https://invisible-island.net/ncurses/man/curs_getcchar.3x.html)
provides a count query with a null destination; the count includes the terminator.

The archived diagnostic relocates the pristine routine's single-character
destination into an exact `malloc(sizeof(wchar_t))` allocation. It does not
increase its capacity. Under pristine Zsh and matching headers, Memcheck reports
an invalid four-byte write in `getcchar`, immediately after that allocation.
This deliberately instrumented run exposes the object boundary; it is **not**
a claim that Memcheck detected the unchanged stack allocation's overflow.
An attempted ASan build could not link because libasan was unavailable; no
ASan result is claimed.

## Correction and scope

Query the required count, allocate that many wide characters using the existing
shell arena, and pass the full buffer to `getcchar`. Continue returning only the
first character, preserving the established interface, colors and attributes.
There is no native ABI change. Memory corruption is a bug, not an intentional
compatibility difference.

`Perf/check-curses-querychar.py` checks ASCII, spaces, Unicode, wide cells and
combining marks with plain/bold/underline/reverse attributes and two color
pairs in private PTYs. It can run each backend under Memcheck. The original
seeded 600-operation stock/zdraw comparison is retained without weakening its
cell, status or terminal-output checks. See round 47 for final results and
build identities; this focused fix does not certify the entire curses module.
