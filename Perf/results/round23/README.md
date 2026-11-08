# Round twenty-three evidence

[The report](../../round23.md) explains the selected inline hint, measured gains,
slower controls, compatibility scope and installed build.

The immutable reference is commit `0414178359bc40c627127cc2bf4b0595d6f155ab`.
The accepted core change is a single `inline` token in `Src/math.c`; its function
body is unchanged. The comparison tool additionally gains an operator corpus.

- `*-benchmarks.json` retains the initial run with severe timing variation and
  external compiler activity observed in the same measurement window. It is
  not used as clean latency evidence.
- `*-repeat.json` and `*-confirm.json` retain both subsequent nine-sample idle
  runs, including all slower controls and the first idle wide-editor outlier.
- `hardware*.json` contains fully scheduled user-space counters, measured from
  exec through exit; this scope includes setup unlike the warm timers.
- Actual-release baseline and matched comparison profiles are compressed as
  `*.callgrind.gz`, beside flat reports, commands, hashes and disassemblies.
- Differential, operator-expanded, native Memcheck, compiler/configuration,
  package, Oh My Zsh and activation receipts identify their exact hosts.

All samples and unsuccessful/noisy timing evidence are retained. Binaries,
native fixture objects, unrelated process working directories and complete
personal/stable-install protection snapshots remain local. Activation records
contain protection counts without those private snapshot contents.

The version remains rc0. The original tag, draft and assets are retained.
