# Initial scanner measurements

Measured locally on Linux with Zsh 5.9.2 during development on 2026-10-04.
Command: `zsh -df scripts/benchmark.zsh`. These are single wall-clock samples
of synthetic, repeated HTML sections; no network or terminal rendering is timed.

| Input bytes | Sections | Initial scanner | Segmented scanner |
| ---: | ---: | ---: | ---: |
| 19,328 | 128 | 0.606 s | 0.111 s |
| 77,312 | 512 | 7.056 s | 0.469 s |
| 154,624 | 1,024 | 25.303 s | 1.044 s |

The initial scanner repeatedly sliced the unconsumed document. The revised
scanner splits once on `<` and only reassembles segments where parser state
requires it, such as a `<` inside a quoted attribute. An initial boundary-count
implementation also performed costly per-character global replacement; counting
the split array removed that work.

These measurements establish a useful local improvement, not a general speed
guarantee. This remains synchronous processing. A browser must measure its own
page corpus and responsiveness needs before choosing scheduling or input limits.

## Script-state handling, 2026-10-11

After adding escaped/double-escaped script handling and comment `--!>` endings,
the same synthetic benchmark on Zsh 5.9.2 measured:

| Input bytes | Sections | Wall-clock time |
| ---: | ---: | ---: |
| 19,328 | 128 | 0.124 s |
| 77,312 | 512 | 0.491 s |
| 154,624 | 1,024 | 1.024 s |

These single samples include ordinary script removal, not just tag filtering.
Regression tests exercise the escaped-state transitions separately. Historical
samples are context, not a controlled comparison across machines or sessions.
