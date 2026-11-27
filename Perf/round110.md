# Round 110 — wordcode-site bytecode pointer cache (`psh_eprog_gen`) and rounding-mode-exact float literal cache

Callgrind on `round109` showed two remaining high-leverage hotspots:
1. `mbc_eval()` spent 13% of all `endgame` instructions (and 4% of `coder-wide`) hashing the exact same literal `(( ... ))` and `for (( ... ))` expression strings and running `memcmp()` on every loop iteration, plus `ecgetstr(EC_DUPTOK)` heap-copying 3-byte expressions and non-inlined `mbc_read_var()` calls.
2. `math_strtod()` / `strtod_l()` took 9.5% of all `mario-race` instructions parsing short decimal float literals (`17.0`, `0.016`, `1.2`, `1.3`) and `PM_SCALAR` float parameters (`dt="0.016"`).

## Changes

- **`psh_eprog_gen` generation counter (`Src/parse.c`)**: Incremented whenever a permanent `Eprog` is actually freed in `freeeprog()` (`!--p->nref`), guaranteeing zero ABA/pointer-reuse risk for wordcode-site caching.
- **128-entry wordcode-site pointer cache (`Src/math.c`, `Src/exec.c`, `Src/loop.c`)**:
  - `mbc_site_cache[128]` (~3 KiB BSS) maps permanent wordcode site `(Wordcode site, psh_eprog_gen, cprec)` directly to `(tier, slot)` (or `MBC_TIER_NEG` for non-compilable/demoted sites).
  - `execarith()` (`Src/exec.c`) checks `matheval_site(site, &val)` before calling `ecgetstr()` whenever `!(state->prog->flags & EF_HEAP) && !isset(XTRACE) && !(*site & 1)`, skipping `ecgetstr()`, heap allocation, hashing, and `memcmp()` completely on warm hits; misses populate `mbc_site_cache` via `matheval_cached()`.
  - `execfor()` (`Src/loop.c`) passes `cond_site` and `adv_site` to `mathevali_cached()` / `matheval_cached()` for literal `for ((...))` conditions and steps.
  - Non-compilable/float sites cache `MBC_TIER_NEG`, skipping `mbc_eval()`'s hash scan entirely on subsequent iterations.
  - Inlined the warm `pms[arg]` register load directly inside `case MBC_LOAD_VAR:` in `mbc_exec_vm()`.
- **Rounding-mode-exact decimal float fast path & cache (`Src/math.c:math_lex_plain_float()`)**:
  - Integer-valued decimal floats with `<= 15` significant digits and zero fractional part (e.g. `0.0`, `17.0`, `29.0`, `32.0`) convert directly via `(double)nz_acc` with zero rounding-mode dependence and zero FP exceptions.
  - Non-integer plain decimal floats (`<= 23` bytes, e.g. `0.016`, `1.2`, `0.70`) use a bounded 64-entry static-BSS cache (2 KiB) keyed by `(text, len, fegetround())`, populated via `math_strtod()` only when no FP exception or `errno` change occurs.
  - Guarded by `uselocale((locale_t)0) == LC_GLOBAL_LOCALE` so custom thread locales fall back to `math_strtod()`.
  - Wired into both `lexconstant()` and `getmathparam()` (`PM_SCALAR`).

## Rejected experiment (`round110` v1)

- An initial `round110` trial used hardware division `(double)acc / psh_pow10[frac_digits]` for non-integer decimal floats. `Perf/check-math-locale-module.py --memcheck` caught that hardware division diverges from `strtod()` under non-default `fesetround()` rounding modes (and sets `FE_INEXACT` on native x86-64). Replaced in `round110b` with the exact integer-valued fast path + 64-entry rounding-mode-keyed cache above.

## Measurements (`round110b` vs `round109`, 9 alternating samples on CPU 13, both starting orders)

| Workload | Forward (`109` → `110b`) | Forward Δ | Reverse (`109` → `110b`) | Reverse Δ |
| --- | ---: | ---: | ---: | ---: |
| `endgame/endgame-world` | 17.47 → 13.78 ms | **−21.12% (1.27×)** | 17.40 → 13.65 ms | **−21.55% (1.27×)** |
| `zchat.zsh/chat-wide-layout` | 37.02 → 34.94 ms | **−5.63% (1.06×)** | 36.85 → 35.02 ms | **−4.98% (1.05×)** |
| `zcoder.zsh/coder-wide-layout` | 37.03 → 35.12 ms | **−5.15% (1.05×)** | 36.74 → 34.79 ms | **−5.31% (1.06×)** |
| `z3dfx/shooter-step` | 7.36 → 7.05 ms | **−4.20% (1.04×)** | 7.34 → 7.04 ms | **−4.07% (1.04×)** |
| `z3dfx.grok/shooter-step` | 7.35 → 7.05 ms | **−4.06% (1.04×)** | 7.32 → 7.01 ms | **−4.22% (1.04×)** |
| `z3dfx.agy/shooter-step` | 7.35 → 7.07 ms | **−3.79% (1.04×)** | 7.30 → 7.03 ms | **−3.67% (1.04×)** |
| `zfetch/fetch-encode` | 10.23 → 9.89 ms | **−3.36% (1.03×)** | 10.33 → 9.91 ms | **−4.04% (1.04×)** |
| `z3dfx.mario/mario-race` | 14.20 → 13.77 ms | **−3.03% (1.03×)** | 14.13 → 13.80 ms | **−2.38% (1.02×)** |
| `zjson` | 44.73 → 44.07 ms | −1.47% | 44.21 → 44.20 ms | −0.01% |
| `zcoder.zsh/coder-paste` | 57.52 → 57.09 ms | −0.75% | 57.28 → 56.95 ms | −0.59% |
| `zchat.zsh/chat-paste` | 94.72 → 94.12 ms | −0.64% | 94.61 → 93.70 ms | −0.96% |
| `zchat.zsh/chat-layout` | 4.15 → 4.15 ms | −0.19% | 4.20 → 4.16 ms | −0.95% |
| `zcoder.zsh/coder-skill-fold` | 7.59 → 7.57 ms | −0.29% | 7.62 → 7.61 ms | −0.17% |
| `zcoder.zsh/coder-layout` | 4.26 → 4.26 ms | −0.12% | 4.24 → 4.23 ms | −0.28% |
| `z3dfx.drawing/drawing-binning` | 6.98 → 7.01 ms | +0.40% | 6.96 → 7.02 ms | +0.88% |

All customer workloads produced identical application state hashes.

## Compatibility

- `Perf/check-math-locale-module.py` vs pristine Zsh: **33,472** checks × 8 locales (`C`, `C.UTF-8`, `fr_FR.UTF-8`, `nb_NO.UTF-8`, `tr_TR.UTF-8`, `ja_JP.eucjp`, `zh_CN.GB18030`, `zh_TW.EUC-TW` = **267,776** checks) matched bit-for-bit across all 4 IEEE-754 rounding modes, FP exception flags, `errno`, and global/thread locales — passed both natively and under Memcheck.
- `Perf/check-math-counter-module.py --memcheck`: passed, 0 Memcheck errors.
- `Perf/math-compare.py` vs pristine Zsh: 15,300 cases across 5 locales — 0 mismatches.
- `Perf/math-storage-compare.py`: 144 stack-storage cases passed.
- Bundled `zjson`: 14,237 checks, 0 failures in `C` and `C.UTF-8`.
- Upstream `make check`: 63 passed, 0 failed, 2 skipped.
