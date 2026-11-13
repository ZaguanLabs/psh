# Round 45 complete timing results

Both complete runs use nine alternating samples per release, CPU 13, C.UTF-8.
Positive time changes are slower; negative changes are faster. Setup and validation
are outside warm timing. Complete output states match. Raw samples and identities
are in the corresponding JSON files (gzip where indicated).

## applications

ms/call.

| Case | First previous → candidate | Time change | Repeat previous → candidate | Time change |
| --- | ---: | ---: | ---: | ---: |
| zjson-object | 177.091 → 162.405 | -8.29% | 175.665 → 163.227 | -7.08% |
| zjson-encode-object | 203.226 → 204.924 | +0.84% | 202.335 → 202.595 | +0.13% |
| zjson-array | 73.361 → 71.756 | -2.19% | 74.187 → 72.696 | -2.01% |
| zjson-encode-array | 167.289 → 165.834 | -0.87% | 165.403 → 166.411 | +0.61% |
| zjson | 70.948 → 69.931 | -1.43% | 72.387 → 71.067 | -1.82% |

## customer

ms/batch.

| Case | First previous → candidate | Time change | Repeat previous → candidate | Time change |
| --- | ---: | ---: | ---: | ---: |
| zcoder.zsh/coder-paste | 98.115 → 97.687 | -0.44% | 97.857 → 97.437 | -0.43% |
| zcoder.zsh/coder-layout | 5.151 → 4.899 | -4.89% | 5.216 → 4.995 | -4.24% |
| zcoder.zsh/coder-wide-layout | 57.843 → 58.350 | +0.88% | 58.191 → 58.394 | +0.35% |
| zchat.zsh/chat-paste | 172.669 → 172.425 | -0.14% | 172.238 → 171.468 | -0.45% |
| zchat.zsh/chat-layout | 5.211 → 4.995 | -4.15% | 5.217 → 4.954 | -5.04% |
| zchat.zsh/chat-wide-layout | 57.607 → 57.644 | +0.06% | 57.801 → 58.215 | +0.72% |
| endgame/endgame-world | 38.063 → 38.109 | +0.12% | 38.248 → 38.649 | +1.05% |
| z3dfx.mario/mario-race | 18.471 → 17.910 | -3.04% | 18.514 → 18.443 | -0.38% |
| z3dfx/shooter-step | 10.553 → 10.414 | -1.32% | 10.723 → 10.471 | -2.35% |
| z3dfx.agy/shooter-step | 10.624 → 10.477 | -1.38% | 10.622 → 10.614 | -0.08% |
| z3dfx.grok/shooter-step | 10.587 → 10.395 | -1.81% | 10.565 → 10.622 | +0.54% |
| zfetch/fetch-encode | 11.313 → 11.679 | +3.24% | 11.598 → 11.478 | -1.03% |
| z3dfx.drawing/drawing-binning | 11.662 → 11.645 | -0.15% | 11.460 → 11.827 | +3.20% |

## copies

ms/batch; 1,000 copies except full: 50.

| Case | First previous → candidate | Time change | Repeat previous → candidate | Time change |
| --- | ---: | ---: | ---: | ---: |
| prefix (32 elements) | 0.964 → 0.979 | +1.56% | 1.028 → 1.042 | +1.36% |
| middle (32 elements) | 0.971 → 0.989 | +1.85% | 1.013 → 1.032 | +1.88% |
| full (32 elements) | 0.143 → 0.143 | +0.00% | 0.142 → 0.144 | +1.41% |
| negative (32 elements) | 1.033 → 1.046 | +1.26% | 0.996 → 1.003 | +0.70% |
| beyond (32 elements) | 0.917 → 0.952 | +3.82% | 0.910 → 0.928 | +1.98% |
| prefix (4096 elements) | 1.698 → 0.987 | -41.87% | 1.700 → 1.003 | -41.00% |
| middle (4096 elements) | 1.340 → 1.028 | -23.28% | 1.332 → 1.023 | -23.20% |
| full (4096 elements) | 16.378 → 16.460 | +0.50% | 16.437 → 16.542 | +0.64% |
| negative (4096 elements) | 2.380 → 2.360 | -0.84% | 2.382 → 2.357 | -1.05% |
| beyond (4096 elements) | 1.627 → 1.641 | +0.86% | 1.628 → 1.643 | +0.92% |
| prefix (32768 elements) | 6.621 → 0.996 | -84.96% | 6.649 → 0.998 | -84.99% |
| middle (32768 elements) | 3.803 → 0.998 | -73.76% | 3.817 → 0.993 | -73.98% |
| full (32768 elements) | 126.189 → 127.963 | +1.41% | 127.234 → 127.274 | +0.03% |
| negative (32768 elements) | 11.961 → 11.759 | -1.69% | 11.947 → 11.792 | -1.30% |
| beyond (32768 elements) | 6.705 → 6.652 | -0.79% | 6.631 → 6.641 | +0.15% |

## Focused slower controls

The inconsistent first/repeat URL and drawing results prompted 21 alternating
samples per release. These medians are retained as measured costs of the candidate.

| Case | Previous → candidate, ms/batch | Time change |
| --- | ---: | ---: |
| zfetch/fetch-encode | 11.317 → 11.534 | +1.92% |
| z3dfx.drawing/drawing-binning | 11.358 → 11.596 | +2.10% |
