# Round 109 — fast simple parameter expansion (`try_simple_paramsubst`) and ASCII `stringsubst` skip

Callgrind on `round106b` showed `paramsubst()` (4.0%–6.3%) and `stringsubst()` (2.4%–3.2%) as the top remaining hotspots across `coder-wide`, `chat-paste`, and `zjson`. Even plain `$var`, `"$var"`, `${var}`, `"${var}"`, and `$1`..`$9` expansions set up `paramsubst()`'s full 45-variable stack frame, ran `fetchvalue()`/`getstrvalue()`, scanned for flags/modifiers/subscripts, and called `strcatsub()`/`strcspn()`.

## Changes (`Src/subst.c`)

- **`try_simple_paramsubst()`**: Handles plain scalar (`PM_SCALAR`, `stdscalar_gsu`), base-10 integer (`PM_INTEGER`, `stdinteger_gsu`, base `0`/`10`/`-10`), and single-digit positional (`$1`..`$9`, `${1}`..`${9}`) expansions directly from `stringsubst()` before entering `paramsubst()`.
  - Uses inline `hasher` + power-of-2 bucket indexing and NUL-safe byte comparison against `paramtab` (guarded by `psh_paramtab_is_standard()`), with a single-pass stack base-10 formatter for integers.
  - Falls back untouched to `paramsubst()` whenever `SHWORDSPLIT` splitting or unquoted `GLOBSUBST` applies, or on flags/subscripts/colon modifiers/padding/case flags/unset/autoload/non-standard GSU/arrays/floats.
  - Clears `l->list.flags &= ~LF_ARRAY`, preserves `nulstring` for quoted empty expansions, and advances `*str` past the copied value (and trailing solitary `Dnull`), eliminating redundant rescans of untokenized parameter values and extra `strcspn()` calls on `"$var"`.
- **Fast ASCII scan in `stringsubst()`**: When `!asssub`, scans past leading ASCII bytes `0x01..0x7f` first — returning immediately on pure-ASCII literals without calling `strchr(..., Inpar)` or `strcspn(..., subst_tokens)`, and skipping `strcspn()` when advancing past `Dnull` lands directly on `String`/`Qstring`/`Tick`/`Qtick`.

## Measurements (`round109` vs `round108c`, 9 alternating samples on CPU 13, both starting orders)

| Workload | Forward (`108c` → `109`) | Forward Δ | Reverse (`108c` → `109`) | Reverse Δ |
| --- | ---: | ---: | ---: | ---: |
| `zcoder.zsh/coder-skill-fold` | 7.98 → 7.62 ms | **−4.43% (1.05×)** | 8.00 → 7.60 ms | **−5.05% (1.05×)** |
| `zjson` | 46.00 → 44.00 ms | **−4.35% (1.05×)** | 45.89 → 43.97 ms | **−4.19% (1.04×)** |
| `zcoder.zsh/coder-wide-layout` | 37.75 → 36.33 ms | **−3.75% (1.04×)** | 37.81 → 36.41 ms | **−3.71% (1.04×)** |
| `zchat.zsh/chat-layout` | 4.32 → 4.16 ms | **−3.64% (1.04×)** | 4.34 → 4.20 ms | **−3.23% (1.03×)** |
| `zchat.zsh/chat-wide-layout` | 37.75 → 36.56 ms | **−3.15% (1.03×)** | 37.84 → 36.67 ms | **−3.10% (1.03×)** |
| `zcoder.zsh/coder-layout` | 4.40 → 4.26 ms | **−3.12% (1.03×)** | 4.42 → 4.24 ms | **−4.03% (1.04×)** |
| `zcoder.zsh/coder-paste` | 59.20 → 57.43 ms | **−3.00% (1.03×)** | 59.55 → 57.40 ms | **−3.61% (1.04×)** |
| `zchat.zsh/chat-paste` | 97.67 → 95.02 ms | **−2.71% (1.03×)** | 97.71 → 94.60 ms | **−3.18% (1.03×)** |
| `endgame/endgame-world` | 17.62 → 17.42 ms | −1.14% | 17.69 → 17.46 ms | −1.31% |
| `zfetch/fetch-encode` | 10.26 → 10.27 ms | +0.06% | 10.29 → 10.13 ms | −1.50% |
| `z3dfx.drawing/drawing-binning` | 6.96 → 7.03 ms | +1.01% | 7.04 → 7.05 ms | +0.16% |
| `z3dfx/shooter-step` | 7.29 → 7.39 ms | +1.46% | 7.28 → 7.40 ms | +1.65% |
| `z3dfx.mario/mario-race` | 14.07 → 14.37 ms | +2.15% | 14.10 → 14.44 ms | +2.40% |

All customer workloads produced identical application state hashes.

## Compatibility

- `Perf/substitution-compare.py` vs pristine Zsh: **2,640** checks across `C` & `C.UTF-8` — 0 differences.
- `Perf/pattern-compare.py` vs pristine Zsh: **14,364** checks across `C` & `C.UTF-8` — 0 differences.
- Targeted 22-case `try_simple_paramsubst` edge-case suite (`$1`..`$9`/`$10`, quoted/unquoted empty, `INT64_MIN`, non-base-10 ints, `SHWORDSPLIT`, `GLOBSUBST`, `NO_UNSET`, `KSHARRAYS`, colon modifiers, subscripts, `typeset -L/-R/-Z/-u/-l`, `zsh/param/private`, UTF-8 idents/values, process substitution, `KSHTYPESET`): 22/22 matched pristine Zsh.
- Bundled `zjson`: 14,237 checks, 0 failures in `C` and `C.UTF-8`.
- Upstream `make check`: 63 passed, 0 failed, 2 skipped.
