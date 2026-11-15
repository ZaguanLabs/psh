# Round 48: filesystem boundaries beyond the application kernels

The first post-rc2 investigation follows shell strings into operating-system
interfaces in `zsh/system` and `zsh/mapfile`. This is focused coverage, not a
complete module audit. Research is on `research/post-rc2-filesystem`; installed
rc2 remains the reference daily-driver release.

## Candidate: sysopen pathname decoding

`bin_sysopen()` calls `open()` on a metafied argument. This can cause failed
lookups, wrong-name creation, or successful access to a different existing
file. A two-line fix applies the existing `unmeta()` helper immediately at both
system-call boundaries. Original diagnostics, flags, FD movement and ABI stay
in place. See [the finding](bugs/sysopen-metafied-path.md).

The filesystem oracle uses Python's byte paths to create and inspect fixtures
independently of shell filename handling. Pristine Zsh and rc2 fail 146/1,038
cases; the trial passes all 1,038. Ordinary names, arbitrary bytes and valid
UTF-8 are included. This deliberately checks desired file identity rather than
requiring the candidate to reproduce the reference's wrong-file operations.

The real OMZ gate passes 24 sessions with unchanged framework sources. Its
initial attempt failed because the standalone development build only staged
modules, not autoload functions. `make install.fns` in the private build stages
those under `.work/release-runtime`; the original failure is retained in the
work directory. No user/framework configuration was patched. The complete upstream suite passes 62 scripts with zero failures and three
skips (privileged and optional-module coverage). Two locale-specific
collision fixtures pass Valgrind with no reported errors. This is an uninstalled
candidate, not a completed packaged-release validation or a performance gain.

## Additional findings retained for separate investigation

- `mapfile[f]=''` leaves an existing nonempty file intact. In the mmap writer,
  a zero-length mmap fails before the truncation inside its success branch.
  Related empty-file getter/unset behavior was already discussed upstream:
  https://www.zsh.org/mla/workers/2024/msg00083.html . Do not count this family
  as an established new discovery. Reproducer in an isolated directory:
  `zmodload zsh/mapfile; print -rn payload > f; mapfile[f]=''; wc -c < f`
  reports 7 on the tested builds.
- `getposint()` narrows `zlong` to `int` before validation. On this 64-bit host,
  `sysread -i 4294967296 -s 1` successfully reads FD 0. Feeding a single X byte
  through subprocess stdin reproduces it without blocking. This occurs in
  pristine, rc2 and the pathname candidate; JSON evidence is retained. No FD
  conversion change is included in this trial.

These findings motivate a systematic review of pathname decoding, checked
integer conversions, zero-length I/O and error cleanup before more aggressive
I/O optimizations. Performance follow-up should profile actual file-heavy
workloads and count syscalls; no timing claim follows from this correctness fix.

## Reproduction

```
python3 Perf/build.py --which candidate --profile release
make -C .work/release-candidate install.fns
python3 Perf/check-sysopen-paths.py --shell .work/release-candidate/Src/zsh --output .work/round48/candidate.json --require-pass
make -C .work/release-candidate check
python3 Packaging/check-ohmyzsh.py --candidate .work/release-candidate/Src/zsh --output .work/round48/ohmyzsh.json
```

Keep large rebuildable outputs confined to one private build following the
recent disk cleanup; compressed evidence is stored under `Perf/results/round48`.
