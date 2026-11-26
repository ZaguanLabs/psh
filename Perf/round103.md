# Round 103 — direct RFC 3629 UTF-8 decoding and SWAR ASCII scanning

Callgrind on `round100` showed `mbrtowc` + `__gconv_transform_utf8_internal` + `mb_metacharlenconv_r` taking 18.23% of all instructions in `zcoder` wide layout (231.5M Ir) because Zsh fed metafied UTF-8 bytes one byte at a time into glibc's gconv state machine. Meanwhile `mb_metastrlenend()` took 4.50% of `coder-paste` (50.4M Ir) scanning long ASCII buffers one byte at a time.

## Changes

- **`Src/utils.c`, `Src/pattern.c`**:
  - Added `psh_ctype_is_utf8()` using `nl_langinfo(CODESET)` with pointer caching, honoring both global `setlocale()` and thread-local `uselocale()` with zero stale-locale risk.
  - Added inline RFC 3629 UTF-8 decoding (`U+0000..U+D7FF`, `U+E000..U+10FFFF`, including metafied NUL `Meta 0x20` and Meta-escaped continuation bytes) in `mb_metacharlenconv_r()`, `mb_metastrlenend()`, and `pattern.c` (`charref`/`charnext`/`charrefinc`) when shift state is initial and `LC_CTYPE` is UTF-8. Any invalid, incomplete, or libc-specific extended sequence (such as glibc's `> U+10FFFF` or 5/6-byte UTF-8 sequences) falls straight through to the original `mbrtowc()` loop for exact libc parity.
  - Added bounded 32-byte/8-byte SWAR ASCII scanning in `mb_metastrlenend()` (using `strlen()` once after 16 leading ASCII bytes when `eptr == NULL` so reads never cross allocation boundaries under Memcheck).

## Measurements (`round103` vs `round102`, 9 alternating samples, CPU 13)

- `zcoder.zsh/coder-wide-layout`: 52.63 → 46.41 ms (−11.8%, 1.13×), reversed 52.63 → 46.76 ms (−11.2%)
- `zchat.zsh/chat-wide-layout`: 52.52 → 46.44 ms (−11.6%, 1.13×), reversed 52.63 → 46.39 ms (−11.9%)
- `endgame/endgame-world`: 37.79 → 36.77 ms (−2.7%), reversed 37.89 → 36.74 ms (−3.1%)
- `z3dfx.drawing/drawing-binning`: 11.08 → 10.82 ms (−2.4%), reversed 11.11 → 10.83 ms (−2.5%)
- `zcoder.zsh/coder-paste`: 63.97 → 62.85 ms (−1.8%), reversed 63.78 → 62.68 ms (−1.7%)
- `zchat.zsh/chat-paste`: 108.35 → 107.03 ms (−1.2%), reversed 108.48 → 107.29 ms (−1.1%)

## Verification

- Exhaustive UTF-8 differential oracle vs pristine Zsh (1–6 byte UTF-8, overlongs, surrogates, `> U+10FFFF`, truncated sequences, embedded NUL, Meta-boundary bytes, `nomultibyte` toggle): 100% identical in `C` and `C.UTF-8`, zero Memcheck errors.
- Upstream `make check`: 63 passed, 0 failed, 2 skipped.
- Bundled `zjson`: 14,237 checks, 0 failures in `C` and `C.UTF-8`.
- Native loaders gate: 7/7 matched.
