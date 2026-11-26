# Round 102 — fast-path ASCII identifier scanning and defer `mb_charinit()` in `itype_end()`

Callgrind on `round100` showed `itype_end()` consuming 3.5–6.3% of all instructions across every customer workload (`mario` 6.30%, `shooter` 5.34%, `coder-wide` 4.91%, `endgame` 4.34%, `chat-paste` 3.96%, `coder-paste` 3.94%, `zjson` 3.48%). Every call executed `mb_charinit()` (`memset(&mb_shiftstate, 0, sizeof(mbstate_t))`) before scanning ASCII and checked `*ptr`, `<= 0x7f`, `zistype()`, and `once` on every byte.

## Changes

- **`Src/utils.c`**: Under `MULTIBYTE_SUPPORT`, `IIDENT` in `typtab[]` is set exclusively for ASCII `[0-9A-Za-z_]`. Added a direct ASCII loop `while (typtab[(unsigned char)*ptr] & IIDENT) ptr++;` that returns immediately whenever the stopping byte is `<= 0x7f`, without checking `MULTIBYTE`/`POSIXIDENTIFIERS` or zeroing `mb_shiftstate`. Hoisted `once` out of the general ASCII loop and deferred `mb_charinit()` until a non-ASCII, non-token byte is actually encountered.

## Measurements (`round102` vs `round101b`, 9 alternating samples, CPU 13)

- `z3dfx/shooter-step`: 8.86 → 8.56 ms (−3.4%), reversed 8.76 → 8.58 ms (−2.1%)
- `z3dfx.mario/mario-race`: 16.67 → 16.16 ms (−3.0%), reversed 16.57 → 16.19 ms (−2.3%)
- `z3dfx.agy/shooter-step`: 8.70 → 8.55 ms (−1.8%), reversed 8.82 → 8.57 ms (−2.8%)
- `zjson`: 51.28 → 50.68 ms (−1.2%), reversed 51.11 → 50.21 ms (−1.8%)
- `zcoder.zsh/coder-skill-fold`: 8.37 → 8.28 ms (−1.0%), reversed 8.37 → 8.29 ms (−1.0%)

## Verification

- Upstream `make check`: 63 passed, 0 failed, 2 skipped.
- Bundled `zjson`: 14,237 checks, 0 failures in `C` and `C.UTF-8`.
