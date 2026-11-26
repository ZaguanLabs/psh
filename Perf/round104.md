# Round 104 — precompute option-emulation masks and skip redundant `inittyptab()` calls

Callgrind on `round100` showed `emulate` → `scanmatchtable` consuming 5.19% of `zjson` (146.3M Ir) and 4.23% of `zchat` paste (81.4M Ir), while `bin_setopt()` called `inittyptab()` unconditionally (60,043 times in `zjson`, 38.1M Ir = 1.35%), rebuilding `typtab[]` and reallocating `ifs_wide` / `wordchars_wide` on every `setopt localoptions`.

## Changes

- **`Src/options.c`**: Precomputed flat `emul_keep[2][OPT_SIZE]` and `emul_set[2][4][OPT_SIZE]` byte tables in `createoptiontable()` for all 8 `(mode, fully)` combinations. `installemulation()` applies `new_opts[i] = (new_opts[i] & keep[i]) | set[i]` directly whenever `optiontab` is untouched (`!scantab`, original `nodes`/`ct`), falling back to `scanhashtable()` otherwise.
- **`Src/options.c`, `Src/builtin.c`**: In `bin_setopt()` and `bin_set()`, only invoke `inittyptab()` when `opts[MULTIBYTE]` or `opts[BANGHIST]` actually changed (the only options selectable by `setopt`/`set` that affect `typtab[]`).

## Measurements (`round104` vs `round103b`, 9 alternating samples, CPU 13)

- `zjson`: 50.83 → 48.07 ms (−5.4%), reversed 50.79 → 47.79 ms (−5.9%)
- `endgame/endgame-world`: 37.14 → 35.79 ms (−3.6%), reversed 36.96 → 35.37 ms (−4.3%)
- `zchat.zsh/chat-paste`: 107.03 → 103.62 ms (−3.2%), reversed 107.65 → 104.12 ms (−3.3%)
- `zfetch/fetch-encode`: 11.58 → 11.27 ms (−2.6%), reversed 11.37 → 11.06 ms (−2.8%)
- `zcoder.zsh/coder-skill-fold`: 8.19 → 8.07 ms (−1.5%), reversed 8.19 → 8.04 ms (−1.9%)
- `z3dfx.mario/mario-race`: 16.51 → 16.26 ms (−1.5%), reversed 16.43 → 16.17 ms (−1.6%)

## Verification

- `emulate`/`setopt` differential oracle vs pristine Zsh (all 4 modes × normal/`-R`, `localoptions`, `nomultibyte`, `emulate -L sh` default IFS): 100% identical.
- Upstream `make check`: 63 passed, 0 failed, 2 skipped.
- Bundled `zjson`: 14,237 checks, 0 failures in `C` and `C.UTF-8`.
