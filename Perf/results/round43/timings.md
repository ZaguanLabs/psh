# Exact-package performance controls

Nine alternating samples per shell, CPU 13, C.UTF-8. All complete result states match.
Builds, correctness tests and profilers finished first; a separate zdraw build/test run also finished before timing.
These small shifts do not establish that the lifetime repairs accelerate applications.

| Workload | Previous (ms) | Candidate (ms) | Candidate time change |
| --- | ---: | ---: | ---: |
| zcoder.zsh/coder-paste | 99.760 | 97.685 | -2.08% |
| zcoder.zsh/coder-layout | 5.172 | 5.164 | -0.15% |
| zcoder.zsh/coder-wide-layout | 58.109 | 57.888 | -0.38% |
| zchat.zsh/chat-paste | 172.319 | 170.325 | -1.16% |
| zchat.zsh/chat-layout | 5.167 | 5.153 | -0.27% |
| zchat.zsh/chat-wide-layout | 57.550 | 57.439 | -0.19% |
| endgame/endgame-world | 37.801 | 37.697 | -0.28% |
| z3dfx.mario/mario-race | 18.243 | 17.901 | -1.87% |
| z3dfx/shooter-step | 10.435 | 10.280 | -1.49% |
| z3dfx.agy/shooter-step | 10.410 | 10.288 | -1.17% |
| z3dfx.grok/shooter-step | 10.408 | 10.270 | -1.33% |
| zfetch/fetch-encode | 11.457 | 11.357 | -0.87% |
| z3dfx.drawing/drawing-binning | 11.502 | 11.449 | -0.46% |
| zjson-object | 174.693 | 172.812 | -1.08% |
| zjson-encode-object | 202.529 | 200.461 | -1.02% |
| zjson-array | 73.589 | 72.795 | -1.08% |
| zjson-encode-array | 166.303 | 165.964 | -0.20% |
| zjson | 71.625 | 70.794 | -1.16% |

Customer kernels use ms/batch; JSON operations use ms/call. All cases and samples are retained.
