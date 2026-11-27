# Round 108 — bounded two-tier compiled integer arithmetic bytecode cache

Callgrind on `round106b` showed `Src/math.c` still taking 53.2% of all Endgame instructions (`op` 16.9%, `zzlex` 14.4%, `mathparse` + `mathparse.cold` 18.5%, `lexconstant` 3.3%) due to re-lexing and re-parsing identical `(( ... ))` and `$(( ... ))` expressions thousands of times per frame.

## Changes (`Src/math.c`, `Src/params.c`)

- **Standard parameter-table predicate (`Src/params.c:psh_paramtab_is_standard()`)**: Internal helper checking `paramtab == realparamtab && paramtab->getnode == getparamnode && paramtab->hash == hasher && paramtab->cmpnodes == strcmp`, automatically falling back if `zsh/param/private` or a custom parameter table is active.
- **Two-tier static-BSS bytecode cache (`Src/math.c`)**:
  - Compact tier: 128 direct-mapped slots (`src[80]`, `ops[48]`, `consts[12]`, `vars[12]`, ~56 KiB BSS) for typical loop/condition expressions.
  - Large tier: 8 direct-mapped slots (`src[384]`, `ops[192]`, `consts[32]`, `vars[16]`, ~9.6 KiB BSS) for large compound conditions (such as Endgame's road-mask expression).
  - Keyed on `(src, len, isset(CPRECEDENCES))` using a 256-byte `mbc_bad_char` filter table so float literals, subscripts, radix syntax, and non-ASCII text reject before touching cache slots.
  - Compiles plain-ASCII integer expressions using Zsh's own `c_prec`/`z_prec` and `type[]` tables (`checkunary` parity), precomputing variable `hasher()` values and deduplicating variable slots so repeated variables in one expression are looked up once via per-execution `Param pms[]`.
  - Supports constants, variables (`PM_INTEGER` + plain-decimal `PM_SCALAR`), arithmetic/bitwise/shift/comparison/logical ops, `**` for `0 <= exp <= 62`, short-circuit `&&`/`||`/`?:`, comma, unary/pre/post inc/dec, and `=` / compound assignments (evaluating RHS before LHS to match `op()`).
  - Side-effect safety: read-only and single-write-at-end expressions bail out cleanly to `mathevall()` before any mutation; multi-write expressions without division/branch pre-verify all variables before op 0; expressions with type bailouts auto-demote (`valid = 2`) to avoid repeated double work on float variables.
- **Direct constant/variable fast path in `mathevalarg()`**: Resolves single decimal integers and single plain ASCII integer/scalar identifiers directly without touching the bytecode cache, avoiding cache overhead on simple array subscripts (`arr[i]`, `arr[1]`).

## Earlier iterations (retained for comparison)

- `round108` (single 128-slot 80-byte/48-op cache without `**` or large tier): +10–11% on wide layouts and +5–6% on `zfetch`/`drawing-binning`, but missed Endgame's 310-byte road check (only −3.1% on `endgame-world`) and regressed `mario-race` (+13%) due to repeated runtime bailouts on float variables.
- `round108b` (unified 64-slot 384-byte/192-op cache with `**` and bailout demotion): cut `endgame-world` 30.42 → 17.83 ms (**1.71×**), but oversized slots and 6-branch hashing slightly dulled wide layouts/drawing-binning and left `mario-race` at +7.0%.
- `round108c` (two-tier split + `mbc_bad_char` table + direct `mathevalarg` fast path) recovered all compact-tier wins while extending `endgame-world` to **1.72×** and eliminating the `shooter-step` regressions.

## Measurements (`round108c` vs `round107b`, 9 alternating samples on CPU 13, both starting orders)

| Workload | Forward (`107b` → `108c`) | Forward Δ | Reverse (`107b` → `108c`) | Reverse Δ |
| --- | ---: | ---: | ---: | ---: |
| `endgame/endgame-world` | 30.49 → 17.68 ms | **−42.01% (1.72×)** | 30.33 → 17.67 ms | **−41.76% (1.72×)** |
| `zcoder.zsh/coder-wide-layout` | 41.71 → 37.79 ms | **−9.40% (1.10×)** | 41.50 → 37.72 ms | **−9.10% (1.10×)** |
| `zchat.zsh/chat-wide-layout` | 41.67 → 37.85 ms | **−9.16% (1.10×)** | 41.79 → 38.00 ms | **−9.09% (1.10×)** |
| `z3dfx.drawing/drawing-binning` | 7.32 → 6.92 ms | **−5.54% (1.06×)** | 7.31 → 6.89 ms | **−5.72% (1.06×)** |
| `zfetch/fetch-encode` | 10.74 → 10.27 ms | **−4.39% (1.05×)** | 10.82 → 10.29 ms | **−4.84% (1.05×)** |
| `zchat.zsh/chat-paste` | 99.67 → 97.14 ms | −2.54% | 99.79 → 97.43 ms | −2.36% |
| `zcoder.zsh/coder-paste` | 60.36 → 59.12 ms | −2.05% | 60.25 → 59.30 ms | −1.57% |
| `zchat.zsh/chat-layout` | 4.40 → 4.32 ms | −1.82% | 4.42 → 4.32 ms | −2.37% |
| `zcoder.zsh/coder-layout` | 4.49 → 4.41 ms | −1.72% | 4.49 → 4.41 ms | −1.69% |
| `zjson` | 46.31 → 45.54 ms | −1.67% | 46.39 → 45.64 ms | −1.63% |
| `z3dfx/shooter-step` | 7.28 → 7.25 ms | −0.41% | 7.29 → 7.25 ms | −0.51% |
| `z3dfx.agy/shooter-step` | 7.30 → 7.26 ms | −0.48% | 7.23 → 7.23 ms | +0.04% |
| `z3dfx.grok/shooter-step` | 7.26 → 7.24 ms | −0.29% | 7.25 → 7.22 ms | −0.39% |
| `zcoder.zsh/coder-skill-fold` | 7.93 → 7.97 ms | +0.54% | 7.90 → 7.96 ms | +0.71% |
| `z3dfx.mario/mario-race` | 13.48 → 13.93 ms | +3.37% | 13.38 → 13.93 ms | +4.15% |

All customer workloads produced identical application state hashes.

## Compatibility

- `Perf/math-compare.py` vs pristine Zsh: **15,300** cases across 5 locales (`C`, `C.UTF-8`, `fr_FR.UTF-8`, `nb_NO.UTF-8`, `tr_TR.UTF-8`) — 0 mismatches.
- `Perf/math-storage-compare.py`: 144 stack-storage cases passed.
- Targeted 79-case bytecode edge-case suite (compound evaluation order, short-circuiting, `CPRECEDENCES`, `**`, `INT64_MIN/-1`, division-by-zero bailout, `readonly`, `NO_UNSET`, `FORCEFLOAT`, `OCTALZEROES`, `WARNNESTEDVAR`, `zsh/param/private`, dynamic type transitions, array slices): 79/79 matched pristine Zsh.
- `Perf/check-math-counter-module.py --memcheck`: passed, 0 Memcheck errors.
- Bundled `zjson`: 14,237 checks, 0 failures in `C` and `C.UTF-8`.
- Upstream `make check`: 63 passed, 0 failed, 2 skipped.
