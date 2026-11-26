# Round 106 — accelerate math lexing, plain-identifier access, and iterative operator parsing

Callgrind on `round100` showed `Src/math.c` accounting for 68.7% of all Endgame instructions (`op` 13.8%, `mathparse` + `mathparse.cold` 19.6%, `zzlex` 12.8%, `lexconstant` + `zstrtol_underscore` 7.7%) and 15–30% across `mario`, `shooter`, and `coder-wide`.

## Changes (`Src/math.c`)

- **Single-pass decimal integer lexing in `lexconstant()`**: Directly accumulates `0` and 1–18 digit decimal integers without scanning twice or calling `zstrtol_underscore()`, falling back to the original path for radix/float/underscore/octal/overflow cases.
- **Borrowed plain-ASCII identifiers + direct parameter access**: `zzlex()` scans pure ASCII identifiers `< 64` bytes inline and borrows `(ptr, len)` instead of heap-allocating `dupstrpfx()`. `getmathparam()` and `setmathvar()` read/write standard `PM_INTEGER`/`PM_FFLOAT`/`PM_EFLOAT` directly and parse plain decimal `PM_SCALAR` strings (`math_parse_plain_decimal()`, excluding `-0` so `FORCEFLOAT` preserves `-0.0`) without spawning recursive `matheval()` calls. `struct mathvalue` tracks `cached_pm` to preserve exact Zsh compound-assignment vs plain-assignment return-type coercion semantics (including callback redeclaration).
- **Outer-only signal queueing + iterative operator stack**: Moved `queue_signals()`/`unqueue_signals()` out of recursive `mathparse()` to wrap the single top-level `mathparse()` call in `mathevall()`, eliminating `mathparse.cold` splits and millions of redundant signal-queue updates. Added a 64-entry iterative operator-precedence stack in `mathparse()` for non-`BOOL`, non-`QUEST`, non-`M_INPAR` operators (falling back to recursion beyond depth 64).

## Measurements (`round106b`, 9 alternating samples on CPU 13; pristine: 5 samples)

| Workload | Pristine Zsh 5.9.2 | `v1.0.0-rc3` (`round100`) | Round 106b | vs `rc3` | vs Pristine |
| --- | ---: | ---: | ---: | ---: | ---: |
| `z3dfx.drawing/drawing-binning` | 17.75 ms | 11.04 ms | 7.55 ms | 1.46× | 2.36× |
| `zchat.zsh/chat-wide-layout` | 122.85 ms | 55.98 ms | 41.85 ms | 1.34× | 2.93× |
| `zcoder.zsh/coder-wide-layout` | 122.34 ms | 55.88 ms | 42.02 ms | 1.33× | 2.90× |
| `z3dfx.mario/mario-race` | 34.06 ms | 16.64 ms | 13.64 ms | 1.22× | 2.53× |
| `z3dfx/shooter-step` | 16.78 ms | 8.78 ms | 7.36 ms | 1.19× | 2.28× |
| `endgame/endgame-world` | 53.86 ms | 37.43 ms | 32.00 ms | 1.17× | 1.68× |
| `zchat.zsh/chat-paste` | 235.21 ms | 110.13 ms | 100.47 ms | 1.09× | 2.34× |
| `zjson` | 107.89 ms | 50.71 ms | 46.54 ms | 1.09× | 2.31× |
| `zcoder.zsh/coder-paste` | 133.45 ms | 63.93 ms | 60.18 ms | 1.06× | 2.22× |
| `zfetch/fetch-encode` | 46.62 ms | 11.23 ms | 10.82 ms | 1.04× | 4.33× |

All 15 workloads improved in both starting orders.

## Profile and memory summary (`round100` → `round106b`)

- Callgrind `Ir`: `coder-wide` 1,270M → 899M (−29.2%), `endgame` 1,039M → 904M (−12.9%), `chat-paste` 1,926M → 1,705M (−11.5%), `zjson` 2,820M → 2,500M (−11.4%).
- DHAT total malloc bytes: `endgame` 16.78 → 2.71 MiB (−83.9%), `zjson` 49.61 → 12.73 MiB (−74.3%), `chat-paste` 26.52 → 11.10 MiB (−58.1%), `coder-wide` 24.88 → 13.79 MiB (−44.5%).
- Linux `/proc` 20-cycle medians (5 processes): resident main heap down 4 KiB on `coder-wide` (1,020 → 1,016 KiB) and `chat-paste` (216 → 212 KiB), equal on `endgame` (1,072 KiB) and `mario` (152 KiB); `VmSize` +12 KiB from fixed static pools/tables.

## Compatibility

- `Perf/math-compare.py` vs pristine Zsh: **78,240** comparisons across `C` & `C.UTF-8` (`zsh`/`ksh`/`sh`) — 0 mismatches.
- `Perf/math-storage-compare.py`: 144 stack-storage cases passed.
- Memcheck: 2,292 arithmetic descriptor cases + `Perf/check-math-counter-module.py` — 0 errors.
- Substitution & pattern differential suites vs pristine Zsh: 2,640 + 14,364 checks — 0 differences.
- Upstream `make check`: 63 passed, 0 failed, 2 skipped.
- Bundled `zjson`: 14,237 checks, 0 failures in `C` and `C.UTF-8`.
- Native loaders gate: 7/7 matched.
- Required Oh My Zsh gate (`Packaging/check-ohmyzsh.py`): **24/24** interactive PTY sessions matched with source files unchanged.
