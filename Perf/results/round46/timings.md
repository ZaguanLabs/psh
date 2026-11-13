# Round 46 complete timing results

Two complete runs each use nine alternating samples per release on CPU 13,
C.UTF-8. Positive changes mean more elapsed time (slower); negative means less.
All complete output states match. See the raw JSON for samples, source/cache
metadata, binary hashes and measurement scopes. Setup of files/private source
copies and reference-result validation are outside the process timers.

## glob

ms/process.

| Case | First previous → candidate | Time change | Repeat previous → candidate | Time change | First RSS, KiB | Repeat RSS, KiB |
| --- | ---: | ---: | ---: | ---: | ---: | ---: |
| plain-control (100 files) | 2.091 → 2.067 | -1.14% | 2.079 → 2.086 | +0.34% | 3,668 → 3,624 | 3,668 → 3,668 |
| short (100 files) | 2.269 → 2.215 | -2.38% | 2.192 → 2.188 | -0.16% | 3,828 → 3,820 | 3,824 → 3,812 |
| long (100 files) | 3.097 → 3.063 | -1.10% | 3.053 → 3.037 | -0.55% | 4,140 → 4,048 | 4,144 → 4,076 |
| function (100 files) | 2.529 → 2.556 | +1.06% | 2.515 → 2.505 | -0.40% | 3,780 → 3,792 | 3,808 → 3,796 |
| sort (100 files) | 2.087 → 2.095 | +0.36% | 2.096 → 2.085 | -0.52% | 3,780 → 3,820 | 3,820 → 3,780 |
| retained-function (100 files) | 3.074 → 3.013 | -1.98% | 3.077 → 3.062 | -0.49% | 3,940 → 3,684 | 4,076 → 3,760 |
| plain-control (1000 files) | 2.397 → 2.391 | -0.26% | 2.465 → 2.387 | -3.19% | 3,972 → 3,940 | 3,944 → 3,924 |
| short (1000 files) | 3.733 → 3.719 | -0.37% | 3.806 → 3.775 | -0.82% | 3,944 → 4,036 | 4,016 → 4,036 |
| long (1000 files) | 13.869 → 13.518 | -2.53% | 13.942 → 13.481 | -3.31% | 8,208 → 7,508 | 8,276 → 7,520 |
| function (1000 files) | 7.005 → 6.961 | -0.62% | 6.927 → 6.935 | +0.10% | 4,104 → 4,180 | 4,132 → 4,132 |
| sort (1000 files) | 3.009 → 2.864 | -4.83% | 3.003 → 3.034 | +1.03% | 4,084 → 4,084 | 4,064 → 4,048 |
| retained-function (1000 files) | 13.469 → 12.866 | -4.48% | 13.647 → 12.720 | -6.79% | 6,472 → 5,424 | 6,416 → 5,412 |
| plain-control (10000 files) | 5.997 → 5.923 | -1.24% | 6.116 → 6.035 | -1.32% | 5,316 → 5,316 | 5,348 → 5,220 |
| short (10000 files) | 19.800 → 19.848 | +0.25% | 20.887 → 20.646 | -1.15% | 6,900 → 6,920 | 6,916 → 6,892 |
| long (10000 files) | 377.817 → 323.072 | -14.49% | 387.573 → 326.057 | -15.87% | 48,912 → 41,032 | 48,996 → 41,000 |
| function (10000 files) | 72.833 → 70.216 | -3.59% | 73.328 → 69.810 | -4.80% | 7,524 → 7,204 | 7,496 → 7,204 |
| sort (10000 files) | 11.902 → 12.057 | +1.30% | 10.539 → 10.663 | +1.18% | 5,924 → 6,032 | 5,924 → 5,924 |
| retained-function (10000 files) | 277.761 → 203.192 | -26.85% | 275.069 → 208.439 | -24.22% | 30,756 → 20,036 | 30,792 → 20,008 |

## customer

ms/batch, warm operation.

| Case | First previous → candidate | Time change | Repeat previous → candidate | Time change |
| --- | ---: | ---: | ---: | ---: |
| zcoder.zsh/coder-paste | 98.521 → 96.833 | -1.71% | 97.944 → 97.280 | -0.68% |
| zcoder.zsh/coder-layout | 4.935 → 4.933 | -0.04% | 4.915 → 4.930 | +0.31% |
| zcoder.zsh/coder-wide-layout | 58.802 → 58.871 | +0.12% | 58.988 → 58.199 | -1.34% |
| zchat.zsh/chat-paste | 173.291 → 176.620 | +1.92% | 174.578 → 175.729 | +0.66% |
| zchat.zsh/chat-layout | 5.024 → 4.979 | -0.90% | 4.909 → 4.934 | +0.51% |
| zchat.zsh/chat-wide-layout | 58.243 → 58.881 | +1.10% | 58.378 → 58.404 | +0.04% |
| endgame/endgame-world | 37.919 → 38.462 | +1.43% | 38.056 → 38.552 | +1.30% |
| z3dfx.mario/mario-race | 18.047 → 18.063 | +0.09% | 18.025 → 18.037 | +0.07% |
| z3dfx/shooter-step | 10.550 → 10.430 | -1.14% | 10.490 → 10.405 | -0.81% |
| z3dfx.agy/shooter-step | 10.499 → 10.341 | -1.50% | 10.547 → 10.476 | -0.67% |
| z3dfx.grok/shooter-step | 10.517 → 10.403 | -1.08% | 10.622 → 10.506 | -1.09% |
| zfetch/fetch-encode | 11.580 → 11.399 | -1.56% | 11.618 → 11.454 | -1.41% |
| z3dfx.drawing/drawing-binning | 11.630 → 11.594 | -0.31% | 11.636 → 11.617 | -0.16% |

## applications

ms/call, warm operation.

| Case | First previous → candidate | Time change | Repeat previous → candidate | Time change |
| --- | ---: | ---: | ---: | ---: |
| zjson-object | 164.351 → 162.118 | -1.36% | 165.818 → 163.208 | -1.57% |
| zjson-encode-object | 205.570 → 202.256 | -1.61% | 206.020 → 202.028 | -1.94% |
| zjson-array | 73.586 → 72.248 | -1.82% | 73.303 → 71.822 | -2.02% |
| zjson-encode-array | 168.818 → 166.328 | -1.47% | 167.948 → 164.999 | -1.76% |
| zjson | 71.409 → 70.563 | -1.19% | 71.215 → 69.965 | -1.75% |

## fresh-customer

ms/current project kernel process. Neither fresh kernel mode represents a complete app launch.

| Case | First previous → candidate | Time change | Repeat previous → candidate | Time change | First RSS, KiB | Repeat RSS, KiB |
| --- | ---: | ---: | ---: | ---: | ---: | ---: |
| zcoder.zsh/coder-paste | 203.258 → 197.829 | -2.67% | 199.992 → 197.396 | -1.30% | 3,860 → 3,880 | 3,912 → 3,924 |
| zcoder.zsh/coder-layout | 12.996 → 13.004 | +0.06% | 12.806 → 12.887 | +0.63% | 4,588 → 4,648 | 4,588 → 4,588 |
| zcoder.zsh/coder-wide-layout | 124.640 → 123.643 | -0.80% | 121.039 → 120.515 | -0.43% | 5,612 → 5,584 | 5,672 → 5,632 |
| zchat.zsh/chat-paste | 367.639 → 367.424 | -0.06% | 351.131 → 355.082 | +1.13% | 3,940 → 3,912 | 3,980 → 3,912 |
| zchat.zsh/chat-layout | 13.404 → 13.293 | -0.83% | 13.274 → 13.414 | +1.06% | 4,640 → 4,588 | 4,576 → 4,624 |
| zchat.zsh/chat-wide-layout | 124.522 → 125.355 | +0.67% | 123.385 → 124.685 | +1.05% | 5,604 → 5,604 | 5,624 → 5,536 |
| endgame/endgame-world | 82.075 → 83.520 | +1.76% | 81.238 → 82.385 | +1.41% | 4,792 → 4,804 | 4,820 → 4,804 |
| z3dfx.mario/mario-race | 44.336 → 44.916 | +1.31% | 43.369 → 43.270 | -0.23% | 3,944 → 4,036 | 3,960 → 4,036 |
| z3dfx/shooter-step | 35.267 → 35.299 | +0.09% | 34.551 → 34.350 | -0.58% | 4,320 → 4,416 | 4,396 → 4,408 |
| z3dfx.agy/shooter-step | 35.214 → 35.191 | -0.06% | 34.620 → 34.479 | -0.41% | 4,408 → 4,408 | 4,412 → 4,412 |
| z3dfx.grok/shooter-step | 35.327 → 35.201 | -0.36% | 34.656 → 34.348 | -0.89% | 4,448 → 4,412 | 4,408 → 4,412 |
| zfetch/fetch-encode | 26.116 → 25.773 | -1.31% | 26.165 → 25.835 | -1.26% | 3,668 → 3,728 | 3,668 → 3,760 |
| z3dfx.drawing/drawing-binning | 37.362 → 37.334 | -0.08% | 37.650 → 37.544 | -0.28% | 3,880 → 3,940 | 3,876 → 3,912 |

## text-customer

ms/private text-only project kernel process. Neither fresh kernel mode represents a complete app launch.

| Case | First previous → candidate | Time change | Repeat previous → candidate | Time change | First RSS, KiB | Repeat RSS, KiB |
| --- | ---: | ---: | ---: | ---: | ---: | ---: |
| zcoder.zsh/coder-paste | 204.165 → 199.810 | -2.13% | 201.025 → 199.665 | -0.68% | 3,876 → 3,912 | 3,940 → 3,924 |
| zcoder.zsh/coder-layout | 13.515 → 13.532 | +0.13% | 14.283 → 14.076 | -1.45% | 4,584 → 4,548 | 4,588 → 4,624 |
| zcoder.zsh/coder-wide-layout | 121.524 → 121.411 | -0.09% | 127.717 → 128.814 | +0.86% | 5,568 → 5,580 | 5,544 → 5,584 |
| zchat.zsh/chat-paste | 352.628 → 357.393 | +1.35% | 361.820 → 366.120 | +1.19% | 4,036 → 3,876 | 3,940 → 4,028 |
| zchat.zsh/chat-layout | 13.430 → 13.335 | -0.71% | 13.450 → 13.463 | +0.10% | 4,548 → 4,644 | 4,620 → 4,624 |
| zchat.zsh/chat-wide-layout | 121.628 → 120.776 | -0.70% | 122.303 → 121.725 | -0.47% | 5,604 → 5,628 | 5,540 → 5,580 |
| endgame/endgame-world | 81.065 → 82.129 | +1.31% | 80.772 → 81.894 | +1.39% | 4,784 → 4,804 | 4,816 → 4,816 |
| z3dfx.mario/mario-race | 42.918 → 42.863 | -0.13% | 43.247 → 43.069 | -0.41% | 4,044 → 3,912 | 3,900 → 4,068 |
| z3dfx/shooter-step | 34.400 → 34.171 | -0.67% | 34.817 → 34.474 | -0.99% | 4,448 → 4,408 | 4,464 → 4,408 |
| z3dfx.agy/shooter-step | 34.007 → 33.803 | -0.60% | 33.959 → 33.956 | -0.01% | 4,376 → 4,448 | 4,396 → 4,408 |
| z3dfx.grok/shooter-step | 33.926 → 34.085 | +0.47% | 34.644 → 34.545 | -0.29% | 4,408 → 4,560 | 4,408 → 4,376 |
| zfetch/fetch-encode | 25.923 → 25.503 | -1.62% | 26.296 → 26.116 | -0.68% | 3,780 → 3,624 | 3,768 → 3,656 |
| z3dfx.drawing/drawing-binning | 36.894 → 36.974 | +0.22% | 37.500 → 37.630 | +0.34% | 3,876 → 3,984 | 3,876 → 3,880 |
