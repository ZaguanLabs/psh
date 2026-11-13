# Paired release measurements

All comparisons use nine alternating samples per shell, CPU 13 and C.UTF-8.
Builds, tests and profilers finished before timing. Complete outputs/states match.
Glob timing includes fresh-process launch and output. Peak RSS is measured by GNU time.

## Glob scans

Negative changes mean less time or RSS; every control is retained.

| Run | Case | Files | Previous ms | Candidate ms | Time change | Previous KiB | Candidate KiB | RSS change |
| --- | --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| glob | plain-control | 100 | 2.045 | 2.056 | +0.51% | 3668 | 3772 | +2.84% |
| glob | short | 100 | 2.211 | 2.208 | -0.12% | 3824 | 3848 | +0.63% |
| glob | long | 100 | 3.100 | 3.052 | -1.54% | 4180 | 4196 | +0.38% |
| glob | function | 100 | 2.506 | 2.489 | -0.66% | 3760 | 3872 | +2.98% |
| glob | sort | 100 | 2.100 | 2.091 | -0.42% | 3684 | 3712 | +0.76% |
| glob | retained-function | 100 | 3.165 | 3.105 | -1.89% | 3972 | 4132 | +4.03% |
| glob | plain-control | 1000 | 2.457 | 2.396 | -2.49% | 3876 | 3932 | +1.44% |
| glob | short | 1000 | 3.948 | 3.895 | -1.33% | 4168 | 4092 | -1.82% |
| glob | long | 1000 | 15.150 | 14.187 | -6.36% | 9268 | 8284 | -10.62% |
| glob | function | 1000 | 7.072 | 6.969 | -1.46% | 4180 | 4176 | -0.10% |
| glob | sort | 1000 | 3.013 | 3.025 | +0.41% | 3940 | 4092 | +3.86% |
| glob | retained-function | 1000 | 14.310 | 13.727 | -4.07% | 7460 | 6476 | -13.19% |
| glob | plain-control | 10000 | 6.017 | 5.991 | -0.43% | 5412 | 5424 | +0.22% |
| glob | short | 10000 | 19.642 | 19.393 | -1.27% | 7668 | 6948 | -9.39% |
| glob | long | 10000 | 456.751 | 380.754 | -16.64% | 60712 | 48988 | -19.31% |
| glob | function | 10000 | 87.912 | 70.872 | -19.38% | 8376 | 7520 | -10.22% |
| glob | sort | 10000 | 10.183 | 10.089 | -0.93% | 5824 | 5976 | +2.61% |
| glob | retained-function | 10000 | 371.791 | 280.898 | -24.45% | 42280 | 30812 | -27.12% |
| glob-repeat | plain-control | 100 | 2.043 | 2.050 | +0.38% | 3688 | 3824 | +3.69% |
| glob-repeat | short | 100 | 2.204 | 2.190 | -0.64% | 3820 | 3748 | -1.88% |
| glob-repeat | long | 100 | 3.111 | 3.069 | -1.33% | 4132 | 4188 | +1.36% |
| glob-repeat | function | 100 | 2.536 | 2.525 | -0.47% | 3792 | 3880 | +2.32% |
| glob-repeat | sort | 100 | 2.105 | 2.096 | -0.45% | 3768 | 3816 | +1.27% |
| glob-repeat | retained-function | 100 | 3.141 | 3.082 | -1.87% | 4016 | 4132 | +2.89% |
| glob-repeat | plain-control | 1000 | 2.407 | 2.412 | +0.19% | 3972 | 3936 | -0.91% |
| glob-repeat | short | 1000 | 3.991 | 3.960 | -0.79% | 4168 | 4104 | -1.54% |
| glob-repeat | long | 1000 | 14.957 | 13.972 | -6.59% | 9256 | 8284 | -10.50% |
| glob-repeat | function | 1000 | 7.117 | 6.951 | -2.33% | 4148 | 4348 | +4.82% |
| glob-repeat | sort | 1000 | 3.004 | 3.023 | +0.66% | 3944 | 4072 | +3.25% |
| glob-repeat | retained-function | 1000 | 14.600 | 13.620 | -6.71% | 7508 | 6588 | -12.25% |
| glob-repeat | plain-control | 10000 | 6.024 | 5.850 | -2.89% | 5240 | 5352 | +2.14% |
| glob-repeat | short | 10000 | 22.516 | 22.212 | -1.35% | 7660 | 6944 | -9.35% |
| glob-repeat | long | 10000 | 473.259 | 385.729 | -18.50% | 60712 | 49084 | -19.15% |
| glob-repeat | function | 10000 | 90.240 | 73.982 | -18.02% | 8280 | 7520 | -9.18% |
| glob-repeat | sort | 10000 | 10.435 | 10.450 | +0.15% | 5904 | 5980 | +1.29% |
| glob-repeat | retained-function | 10000 | 379.241 | 290.002 | -23.53% | 42260 | 30788 | -27.15% |

## Customer controls

Customer kernels use ms/batch; JSON operations use ms/call. Small changes here
do not establish an application speedup.

| Workload | Previous ms | Candidate ms | Time change |
| --- | ---: | ---: | ---: |
| zcoder.zsh/coder-paste | 96.784 | 96.069 | -0.74% |
| zcoder.zsh/coder-layout | 5.133 | 5.154 | +0.41% |
| zcoder.zsh/coder-wide-layout | 58.087 | 57.357 | -1.26% |
| zchat.zsh/chat-paste | 171.733 | 170.278 | -0.85% |
| zchat.zsh/chat-layout | 5.143 | 5.128 | -0.29% |
| zchat.zsh/chat-wide-layout | 57.820 | 57.173 | -1.12% |
| endgame/endgame-world | 37.477 | 37.548 | +0.19% |
| z3dfx.mario/mario-race | 18.007 | 17.939 | -0.38% |
| z3dfx/shooter-step | 10.344 | 10.301 | -0.42% |
| z3dfx.agy/shooter-step | 10.300 | 10.300 | +0.00% |
| z3dfx.grok/shooter-step | 10.322 | 10.304 | -0.17% |
| zfetch/fetch-encode | 11.413 | 11.271 | -1.24% |
| z3dfx.drawing/drawing-binning | 11.321 | 11.379 | +0.51% |
| zjson-object | 172.686 | 172.363 | -0.19% |
| zjson-encode-object | 203.048 | 200.666 | -1.17% |
| zjson-array | 73.693 | 72.822 | -1.18% |
| zjson-encode-array | 166.648 | 164.471 | -1.31% |
| zjson | 70.648 | 70.058 | -0.84% |
