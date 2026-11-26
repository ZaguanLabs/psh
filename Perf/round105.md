# Round 105 — confirmed-prefix in-place array updates and plain-ASCII subscript fast path

Callgrind on `round100` showed `setarrvalue_len()` consuming 7.76% of `z3dfx` shooter (22.6M Ir) because its in-place replacement path was capped at `v->end <= 32`, falling back to a full `arrlen(old)` scan on every `arr[i]=val` for `i > 32` even when round 22's confirmed-prefix cache already applied. Meanwhile `parse_subscript()` and `parsestrnoerr()` ran full lexer context save/restore and `dquote_parse()` even for plain ASCII literals like `arr[i]` or `arr[1]`.

## Changes

- **`Src/params.c`**: Extended `setarrvalue_len()`'s in-place size-preserving replacement path to reuse `array_length_ge(v->pm, old, (unsigned)v->end)` for owned non-unique arrays of any length (under existing signal-queue and ownership guards), and used `array_length_full(v->pm, old)` when full length is needed.
- **`Src/lex.c`**: Added a lookup table `dquote_plain_ascii[256]` of printable ASCII + TAB bytes that `dquote_parse()` copies verbatim without escaping or tokenization. When `!zleactive`, `parse_subscript()` and `parsestrnoerr()` scan directly and return immediately when all bytes up to `endchar`/`'\0'` are plain ASCII.

## Measurements (`round105` vs `round104`, 9 alternating samples, CPU 13)

- `z3dfx.drawing/drawing-binning`: 10.89 → 8.93 ms (−18.0%, 1.22×), reversed 10.89 → 8.90 ms (−18.2%)
- `z3dfx/shooter-step` (+ `agy`, `grok`): 8.62 → 7.81–7.83 ms (−9.1–9.6%, 1.10×)
- `z3dfx.mario/mario-race`: 16.05 → 14.73 ms (−8.2%, 1.09×), reversed 15.99 → 14.79 ms (−7.5%)
- `zcoder.zsh/coder-wide-layout`: 46.73 → 44.34 ms (−5.1%, 1.05×), reversed 46.82 → 44.48 ms (−5.0%)
- `zchat.zsh/chat-wide-layout`: 46.66 → 44.68 ms (−4.2%, 1.04×), reversed 46.53 → 44.37 ms (−4.6%)
- `zcoder.zsh/coder-paste`, `zchat.zsh/chat-paste`, `zjson`: −1.2% to −1.7%.

## Verification

- Subscript & array replacement differential oracle vs pristine Zsh (indices `<= 32` and `> 32`, negative indices, slices, growth, unique arrays, associative arrays with quotes/escapes/UTF-8/`$`, nested subscripts): 100% identical in `C` and `C.UTF-8`.
- Upstream `make check`: 63 passed, 0 failed, 2 skipped.
- Bundled `zjson`: 14,237 checks, 0 failures in `C` and `C.UTF-8`.
