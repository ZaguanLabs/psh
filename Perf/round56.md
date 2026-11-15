# Round 56: PTY readiness beyond FD_SETSIZE

Following zselect's readiness work, review found an unchecked `FD_SET` in
`zpty -rt`. With many files open, a valid PTY master exceeds the fixed select
set and accesses memory outside the stack object. Instrumented pristine Zsh
5.9.2 reproduces this independently of psh. See [the finding and reproducer](bugs/zpty-select-descriptor-boundary.md).

The candidate uses poll where available, following the existing socket/TCP
module approach. It requests readable data with zero timeout; subsequent
character reads, pattern matching, buffering, return statuses and the existing
fallback on polling errors are unchanged. EOF/hangup readiness is exercised
with a child that writes and exits. No native ABI or module name changes.

Select-only builds check the descriptor before FD_SET and before touching
buffered output or processing the pattern. An oversized descriptor gets status
1 and a range diagnostic, with the destination parameter untouched. This is a
safety correction to undefined behavior, not a performance tradeoff. Use a
poll-capable build, fewer open descriptors, or a blocking read if appropriate.
The select-only early error takes precedence over later pattern diagnostics.
Reads without `-t` retain high-descriptor support. COMPATIBILITY.md records it.

## Validation

The Linux harness creates real PTYs with inherited descriptors and verifies
which module was loaded. The matrix covers descriptors 11, 1023, 1024, 1025 and
2048; blocking/nonblocking PTY creation; C/C.UTF-8; empty input, plain text,
newline termination, binary NUL/Meta bytes, Unicode, matched/unmatched patterns,
required matches, blocking reads, and output from an exiting child. Independent
expected bytes/statuses are checked, and `/proc` confirms that readiness reads
do not change descriptor flags. Every process has a bounded timeout.

| Build | Cases | Failed checks | Below-boundary control differences |
| --- | ---: | ---: | ---: |
| Pristine release module | 80 | 0 | 0 |
| Pristine instrumented module | 200 | 108 | 0 |
| Preceding psh instrumented module | 200 | 108 | reference |
| Candidate release module | 200 | 0 | 0 |
| Candidate instrumented poll module | 200 | 0 | 0 |
| Candidate instrumented select fallback | 200 | 0 | 0 |

All 108 reference failures are sanitizer stops on the oversized nonblocking
reads. The 12 high-descriptor blocking-read cases pass even before the change.
The ordinary reference matrix covers all 80 cases below FD_SETSIZE; whole
stdout/stderr/status values match, including binary results. Separate module
builds instrument only zpty with UBSan, not the whole shell. Forcing the select
fallback tests that implementation on Linux, not a different operating system.

The initial uninstrumented wide-descriptor matrix was interrupted after some
cases hung; its partial setup/log and the initial low-descriptor run are
retained as exploratory evidence. The final sanitizer matrix makes the fault
observable at the first access, avoiding dependence on the corrupted process's
later behavior.

The lasting V08 regression checks an empty live PTY, input, then drained input.
The full upstream suite passes 62 scripts, zero failures, three skips. All 24
unchanged OMZ terminal sessions pass with the user's framework/theme/plugins.
All 80 Memcheck cases pass, covering ordinary and high descriptors with zero
reported errors. Leak checking was disabled; this is not a leak-freedom claim. There is no measured
performance claim for this correction. Installed rc2 remains active; complete
isolated packaging/native-loader verification is required before activation.
Other operating systems and signal-injection stress are not certified here.

## Reproduction

```sh
python3 Perf/build.py --which candidate --profile release
python3 Perf/check-zpty-readiness.py --shell .work/release-candidate/Src/zsh \
  --modules .work/release-runtime/lib/zsh/5.9.2 --backend poll \
  --output .work/round56/candidate.json --require-pass
make -C .work/release-candidate check
python3 Packaging/check-ohmyzsh.py --candidate .work/release-candidate/Src/zsh \
  --output .work/round56/ohmyzsh.json
```

The harness needs Linux `/proc`, PTYs, and a descriptor limit of at least 2100.
It does not raise the limit. Use `--counts 0 1020 --memcheck` for a smaller memory
check covering ordinary and high descriptors. `--reference FILE` compares
below-boundary controls; independent result checks still cover the high cases.
Source/binary identities, sanitizer build commands and logs are retained under
`Perf/results/round56`.
