# Round 42 paired timing pilots

Percentages are candidate elapsed time relative to the baseline; negative means less time. Nine alternating samples except the three-sample Moonlit pilots. Every resulting state matches. These compare the interim correctness-only package and the separately rejected count-bound trial; the final unsigned-count package has its own confirmation reports.

## Initial correctness fix versus preceding accepted psh

| Workload | Baseline ms | Candidate ms | Change |
| --- | ---: | ---: | ---: |
| zcoder.zsh/coder-paste | 99.062 | 99.424 | +0.37% |
| zcoder.zsh/coder-layout | 5.138 | 5.114 | -0.47% |
| zcoder.zsh/coder-wide-layout | 58.310 | 57.827 | -0.83% |
| zchat.zsh/chat-paste | 173.742 | 172.599 | -0.66% |
| zchat.zsh/chat-layout | 5.140 | 5.132 | -0.16% |
| zchat.zsh/chat-wide-layout | 57.826 | 57.451 | -0.65% |
| endgame/endgame-world | 37.795 | 37.644 | -0.40% |
| z3dfx.mario/mario-race | 18.061 | 17.949 | -0.62% |
| z3dfx/shooter-step | 10.474 | 10.332 | -1.36% |
| z3dfx.agy/shooter-step | 10.527 | 10.344 | -1.74% |
| z3dfx.grok/shooter-step | 10.557 | 10.327 | -2.18% |
| zfetch/fetch-encode | 11.509 | 11.359 | -1.30% |
| z3dfx.drawing/drawing-binning | 11.527 | 11.408 | -1.03% |
| zjson-object | 175.247 | 173.225 | -1.15% |
| zjson-encode-object | 203.036 | 201.100 | -0.95% |
| zjson-array | 74.011 | 73.738 | -0.37% |
| zjson-encode-array | 169.137 | 168.090 | -0.62% |
| zjson | 70.938 | 71.294 | +0.50% |
| Moonlit fresh construction | 5592.719 | 5528.544 | -1.15% |

| Hash size | Operation | Baseline ms | Candidate ms | Change |
| ---: | --- | ---: | ---: | ---: |
| 0 | keys | 167.063 | 167.795 | +0.44% |
| 0 | values | 172.638 | 174.663 | +1.17% |
| 0 | pairs | 180.361 | 179.991 | -0.20% |
| 0 | match | 248.384 | 249.516 | +0.46% |
| 0 | array-control | 234.616 | 235.248 | +0.27% |
| 16 | keys | 20.204 | 20.427 | +1.10% |
| 16 | values | 21.330 | 21.663 | +1.56% |
| 16 | pairs | 30.605 | 30.972 | +1.20% |
| 16 | match | 29.907 | 30.096 | +0.63% |
| 16 | array-control | 22.659 | 22.849 | +0.84% |
| 256 | keys | 12.197 | 12.113 | -0.69% |
| 256 | values | 12.847 | 12.793 | -0.43% |
| 256 | pairs | 25.916 | 25.851 | -0.25% |
| 256 | match | 16.874 | 16.977 | +0.61% |
| 256 | array-control | 10.323 | 10.353 | +0.30% |
| 4096 | keys | 13.437 | 13.773 | +2.50% |
| 4096 | values | 14.095 | 14.313 | +1.55% |
| 4096 | pairs | 26.401 | 26.552 | +0.57% |
| 4096 | match | 17.794 | 18.016 | +1.25% |
| 4096 | array-control | 10.606 | 10.625 | +0.18% |
| 4097 | keys | 13.422 | 13.708 | +2.13% |
| 4097 | values | 14.021 | 14.306 | +2.03% |
| 4097 | pairs | 26.230 | 26.458 | +0.87% |
| 4097 | match | 17.727 | 17.964 | +1.33% |
| 4097 | array-control | 10.607 | 10.624 | +0.16% |

## Count-bound trial versus initial correctness fix

| Workload | Baseline ms | Candidate ms | Change |
| --- | ---: | ---: | ---: |
| zcoder.zsh/coder-paste | 102.005 | 100.652 | -1.33% |
| zcoder.zsh/coder-layout | 5.159 | 5.176 | +0.33% |
| zcoder.zsh/coder-wide-layout | 58.908 | 58.815 | -0.16% |
| zchat.zsh/chat-paste | 177.528 | 174.005 | -1.98% |
| zchat.zsh/chat-layout | 5.135 | 5.170 | +0.68% |
| zchat.zsh/chat-wide-layout | 57.584 | 57.460 | -0.22% |
| endgame/endgame-world | 37.607 | 37.884 | +0.74% |
| z3dfx.mario/mario-race | 17.842 | 17.867 | +0.14% |
| z3dfx/shooter-step | 10.380 | 10.334 | -0.44% |
| z3dfx.agy/shooter-step | 10.422 | 10.365 | -0.55% |
| z3dfx.grok/shooter-step | 10.374 | 10.375 | +0.01% |
| zfetch/fetch-encode | 11.429 | 11.456 | +0.24% |
| z3dfx.drawing/drawing-binning | 11.413 | 11.493 | +0.70% |
| zjson-object | 174.116 | 176.437 | +1.33% |
| zjson-encode-object | 202.639 | 203.618 | +0.48% |
| zjson-array | 73.813 | 73.473 | -0.46% |
| zjson-encode-array | 168.511 | 169.357 | +0.50% |
| zjson | 73.345 | 72.922 | -0.58% |
| Moonlit fresh construction | 5520.759 | 5576.169 | +1.00% |

| Hash size | Operation | Baseline ms | Candidate ms | Change |
| ---: | --- | ---: | ---: | ---: |
| 0 | keys | 168.497 | 169.583 | +0.64% |
| 0 | values | 174.610 | 176.272 | +0.95% |
| 0 | pairs | 178.358 | 181.091 | +1.53% |
| 0 | match | 248.477 | 249.835 | +0.55% |
| 0 | array-control | 233.318 | 238.376 | +2.17% |
| 16 | keys | 20.632 | 19.967 | -3.23% |
| 16 | values | 21.801 | 21.278 | -2.40% |
| 16 | pairs | 32.001 | 31.307 | -2.17% |
| 16 | match | 30.958 | 30.542 | -1.35% |
| 16 | array-control | 23.809 | 23.392 | -1.75% |
| 256 | keys | 12.187 | 11.739 | -3.67% |
| 256 | values | 12.893 | 12.509 | -2.98% |
| 256 | pairs | 26.731 | 26.158 | -2.14% |
| 256 | match | 17.030 | 16.546 | -2.85% |
| 256 | array-control | 10.416 | 10.431 | +0.15% |
| 4096 | keys | 14.451 | 13.408 | -7.22% |
| 4096 | values | 15.068 | 14.021 | -6.95% |
| 4096 | pairs | 27.244 | 26.554 | -2.54% |
| 4096 | match | 18.102 | 17.555 | -3.02% |
| 4096 | array-control | 10.622 | 10.601 | -0.20% |
| 4097 | keys | 13.663 | 13.696 | +0.25% |
| 4097 | values | 14.293 | 14.310 | +0.12% |
| 4097 | pairs | 26.556 | 26.415 | -0.53% |
| 4097 | match | 18.040 | 17.964 | -0.42% |
| 4097 | array-control | 10.702 | 10.769 | +0.62% |

