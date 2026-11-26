# Round 101 — pool cmdstack buffers, preserve nested heap rewind extents, and skip full arenas in freeheap

DHAT on `v1.0.0-rc3` (`round100`) showed that allocating and freeing 256-byte `cmdstack` buffers in `hist_context_save()` and `execshfunc()` accounted for 83.6% of all malloc bytes in Endgame (14.03 MiB), 74.3% in `zjson` (36.88 MiB), 58.0% in `zchat` paste (15.37 MiB), and 44.5% in `zcoder` wide layout (11.07 MiB). Callgrind also showed `freeheap()` walking 31 pushed arenas per `while`-loop iteration in `zcoder` wide layout (45.9M instructions, 3.61%), and `old_heaps()` resetting `rewound_extent` to `HEAP_BLOCK_SIZE` after every nested function return.

## Changes

- **`Src/prompt.c`, `Src/hist.c`, `Src/exec.c`, `Src/init.c`**: Added a fixed 8-slot static pool (`2 KiB` BSS) via internal helpers `alloc_cmdstack()` / `free_cmdstack()`, falling back to `zalloc`/`zfree` beyond 8 concurrent levels and adding zero bytes to recursive C stack frames.
- **`Src/mem.c`**: Added a 32-deep stack saving `rewound_extent` across nested `new_heaps()`/`old_heaps()` pairs (conservatively invalidating all stacked extents on `switch_heaps()`). In `freeheap()`, moved pushed arenas with `< 4096` bytes free ahead of `fheap` (when `fheap` has `>= 4096` bytes free) so subsequent `freeheap()` and `zhalloc()` scans skip nearly full arenas until `popheap()`, leaving `zhalloc()`'s fast path completely untouched.

Note: An initial trial (`round101`) tracked dirty arenas inside `zhalloc()`; that sped up wide layouts by 4.3–5.8% but regressed Endgame (+2.3–3.3%) and `drawing-binning` (+4.5–4.7%), matching round 86's finding. Moving nearly full arenas inside `freeheap()` (`round101b`) kept `zhalloc()` untouched and eliminated the regressions.

## Measurements (`round101b` vs `round100`, 9 alternating samples, CPU 13)

- `zcoder.zsh/coder-wide-layout`: 55.78 → 52.35 ms (−6.1%), reversed 57.17 → 53.78 ms (−5.9%)
- `zchat.zsh/chat-wide-layout`: 56.00 → 52.31 ms (−6.6%), reversed 56.09 → 52.45 ms (−6.5%)
- `endgame/endgame-world`: 37.64 → 37.14 ms (−1.3%), reversed 37.33 → 37.06 ms (−0.7%)
- DHAT total malloc bytes: Endgame 16.78 → 2.71 MiB (−83.9%), `zjson` 49.61 → 12.73 MiB (−74.4%), `coder-wide` 24.88 → 13.79 MiB (−44.5%).

## Verification

- Upstream `make check`: 63 passed, 0 failed, 2 skipped.
- Bundled `zjson`: 14,237 checks, 0 failures in `C` and `C.UTF-8`.
- Native loaders gate: 7/7 matched.
