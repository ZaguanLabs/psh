# Final unsigned-count package versus preceding accepted psh

Final package: `1.0.0-rc1-6db51a2527d4`. Nine alternating samples on CPU 13, C.UTF-8; three samples plus excluded warmups for Moonlit. Negative change means less elapsed time. Every resulting state/rendered output matches.

| Workload | Baseline ms | Final ms | Change |
| --- | ---: | ---: | ---: |
| zcoder.zsh/coder-paste | 98.138 | 97.596 | -0.55% |
| zcoder.zsh/coder-layout | 5.139 | 5.127 | -0.23% |
| zcoder.zsh/coder-wide-layout | 58.026 | 58.010 | -0.03% |
| zchat.zsh/chat-paste | 171.840 | 170.873 | -0.56% |
| zchat.zsh/chat-layout | 5.144 | 5.133 | -0.21% |
| zchat.zsh/chat-wide-layout | 57.862 | 57.585 | -0.48% |
| endgame/endgame-world | 37.790 | 37.762 | -0.07% |
| z3dfx.mario/mario-race | 18.119 | 17.988 | -0.72% |
| z3dfx/shooter-step | 10.482 | 10.334 | -1.41% |
| z3dfx.agy/shooter-step | 10.540 | 10.336 | -1.94% |
| z3dfx.grok/shooter-step | 10.487 | 10.331 | -1.49% |
| zfetch/fetch-encode | 11.478 | 11.380 | -0.85% |
| z3dfx.drawing/drawing-binning | 11.470 | 11.496 | +0.23% |
| zjson-object | 172.827 | 172.861 | +0.02% |
| zjson-encode-object | 201.839 | 198.951 | -1.43% |
| zjson-array | 73.764 | 73.400 | -0.49% |
| zjson-encode-array | 166.834 | 165.608 | -0.73% |
| zjson | 71.209 | 70.343 | -1.22% |
| Moonlit fresh construction | 5598.223 | 5505.137 | -1.66% |

| Hash size | Operation | Baseline ms | Final ms | Change |
| ---: | --- | ---: | ---: | ---: |
| 0 | keys | 166.966 | 164.304 | -1.59% |
| 0 | values | 173.556 | 173.123 | -0.25% |
| 0 | pairs | 181.996 | 181.172 | -0.45% |
| 0 | match | 249.780 | 248.533 | -0.50% |
| 0 | array-control | 236.563 | 234.609 | -0.83% |
| 16 | keys | 20.309 | 20.528 | +1.08% |
| 16 | values | 21.787 | 21.857 | +0.32% |
| 16 | pairs | 31.055 | 31.009 | -0.15% |
| 16 | match | 29.997 | 29.915 | -0.27% |
| 16 | array-control | 22.955 | 22.943 | -0.06% |
| 256 | keys | 12.074 | 11.992 | -0.68% |
| 256 | values | 12.775 | 12.772 | -0.02% |
| 256 | pairs | 26.147 | 26.400 | +0.97% |
| 256 | match | 16.809 | 16.727 | -0.48% |
| 256 | array-control | 10.254 | 10.308 | +0.53% |
| 4096 | keys | 13.365 | 13.563 | +1.48% |
| 4096 | values | 14.020 | 14.233 | +1.52% |
| 4096 | pairs | 26.033 | 26.171 | +0.53% |
| 4096 | match | 17.628 | 17.798 | +0.97% |
| 4096 | array-control | 10.516 | 10.560 | +0.41% |
| 4097 | keys | 13.338 | 13.463 | +0.93% |
| 4097 | values | 13.980 | 14.161 | +1.29% |
| 4097 | pairs | 26.116 | 26.334 | +0.83% |
| 4097 | match | 17.641 | 17.756 | +0.65% |
| 4097 | array-control | 10.576 | 10.613 | +0.34% |
