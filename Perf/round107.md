# Round 107 — power-of-2 hash tables with inline hashing, bitmask indexing, and first-byte key precheck

Callgrind on `round106b` showed `gethashnode2()` taking 3.4%–4.9% of total instructions across `coder-wide`, `chat-paste`, `zjson`, and `endgame`, due to indirect `ht->hash(nam)` calls, integer division (`% ht->hsize`) against prime bucket counts, and indirect `ht->cmpnodes()` calls on every probe.

## Changes

- **Power-of-2 initial hash table sizes** (`Src/hashtable.c`, `Src/params.c`, `Src/builtin.c`, `Src/options.c`, `Src/hashnameddir.c`): Changed default initial bucket counts to powers of two (`paramtab` 151 → 256, `shfunctab` 7 → 32, `builtintab` 85 → 128, `cmdnamtab` 201 → 256, `optiontab` 101 → 128, `reswdtab`/`aliastab` 23 → 32, `sufaliastab` 11 → 16, `nameddirtab` 201 → 256, default `newparamtable()` and associative arrays 17 → 32). `expandhashtable()` multiplies `hsize` by 4, preserving powers of two.
- **Fast default-hash/strcmp paths in `Src/hashtable.c`**: Added inline `psh_hasher_inline()` and `psh_bucket()` (using bitmask `hashval & (hsize - 1)` when `hsize` is a power of two, falling back to `% hsize` otherwise) plus a first-byte key precheck before `strcmp(hp->nam + 1, nam + 1)` in `gethashnode()`, `gethashnode2()`, `addhashnode2()`, and `removehashnode()` whenever `ht->hash == hasher` and `ht->cmpnodes == strcmp`. Custom hash/compare callbacks continue using the generic path unchanged.

## Rejected experiment (`round107` v1)

- An initial `round107` trial also added an ASCII/range-check fast path in `Src/glob.c:remnulargs()`. `Perf/check-remnulargs-module.py --memcheck` caught that native callers can mutate `typtab[c]` `INULL` flags dynamically at runtime; the `Src/glob.c` edit was reverted in `round107b`.

## Measurements (`round107b` vs `round106b`, 9 alternating samples on CPU 13, both starting orders)

| Workload | Forward (`106b` → `107b`) | Forward Δ | Reverse (`106b` → `107b`) | Reverse Δ |
| --- | ---: | ---: | ---: | ---: |
| `endgame/endgame-world` | 31.95 → 30.38 ms | −4.92% | 31.96 → 30.43 ms | −4.80% |
| `z3dfx.drawing/drawing-binning` | 7.64 → 7.36 ms | −3.72% | 7.69 → 7.40 ms | −3.87% |
| `z3dfx.mario/mario-race` | 13.95 → 13.49 ms | −3.27% | 13.97 → 13.70 ms | −1.96% |
| `z3dfx.grok/shooter-step` | 7.45 → 7.30 ms | −2.04% | 7.53 → 7.33 ms | −2.63% |
| `z3dfx.agy/shooter-step` | 7.47 → 7.27 ms | −2.62% | 7.57 → 7.49 ms | −1.04% |
| `z3dfx/shooter-step` | 7.39 → 7.32 ms | −1.03% | 7.59 → 7.48 ms | −1.48% |
| `zcoder.zsh/coder-skill-fold` | 8.22 → 8.07 ms | −1.82% | 8.12 → 7.96 ms | −2.02% |
| `zcoder.zsh/coder-wide-layout` | 41.91 → 41.32 ms | −1.42% | 42.36 → 41.78 ms | −1.38% |
| `zchat.zsh/chat-wide-layout` | 41.95 → 41.56 ms | −0.93% | 42.27 → 42.21 ms | −0.14% |
| `zchat.zsh/chat-paste` | 100.04 → 99.45 ms | −0.59% | 102.51 → 102.05 ms | −0.45% |
| `zcoder.zsh/coder-paste` | 60.53 → 60.31 ms | −0.36% | 60.53 → 60.74 ms | +0.35% |
| `zfetch/fetch-encode` | 10.79 → 10.71 ms | −0.75% | 10.83 → 10.84 ms | +0.17% |
| `zjson` | 46.70 → 46.52 ms | −0.38% | 47.25 → 47.28 ms | +0.06% |

All customer workloads produced identical application state hashes.

## Compatibility

- `Perf/check-hash-module.py --memcheck` vs pristine Zsh: **538,428** hash checks × 2 locales (`C`, `C.UTF-8`) matched, 0 Memcheck errors.
- `Perf/check-hash-reentry-module.py --memcheck`: passed (`count=2 calls=1 ok=1`, `pattern-ok=1`, `matrix-checks=12 ok=1`, `boundary-checks=2 ok=1`).
- `Perf/check-hash-scan-module.py --memcheck` vs pristine Zsh: **120,312** hash scan checks × 2 locales matched, 0 Memcheck errors.
- `Perf/check-remnulargs-module.py --memcheck` vs pristine Zsh: **31,003** marker-removal checks × 2 locales matched, 0 Memcheck errors.
- Bundled `zjson`: 14,237 checks, 0 failures in `C` and `C.UTF-8`.
- Upstream `make check`: 63 passed, 0 failed, 2 skipped.
