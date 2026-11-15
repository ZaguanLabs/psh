# sysopen uses the internal encoded filename as an OS pathname

Reproduced on the retained pristine Zsh 5.9.2 build, system Zsh and psh rc2,
on Linux x86-64. This is inherited behavior, not a psh-only incompatibility.
The current upstream source inspected on 2026-11-15 also passes `*args` directly
into both `open()` calls in `bin_sysopen()`:
https://raw.githubusercontent.com/zsh-users/zsh/master/Src/Modules/system.c
That source inspection is not a runtime test of current upstream Git. A search
of the mailing archive did not establish whether this has already been reported.

Zsh internally escapes selected bytes with Meta (0x83) followed by the byte
XOR 32. File APIs need the decoded filename. `sysopen` omits that conversion,
although `zsystem flock` in the same module uses `unmeta()`.

For a directory containing both `name-83` and `name-83-a3` (suffixes here denote
literal hexadecimal bytes), opening the former silently opens the latter.
Reading returns the latter's data; append and truncation modify it instead of
the requested file. The command reports success. Creating a missing path can
also create the encoded spelling instead. Valid UTF-8 filenames such as `界`,
`文档` and `🙂` contain affected bytes; this is not restricted to invalid UTF-8.

The safe reproducer creates only temporary files:

```
python3 Perf/check-sysopen-paths.py --shell /usr/bin/zsh --output /tmp/sysopen.json
```

The independent filesystem oracle covers every single-byte filename suffix
except NUL and slash, four UTF-8 names, read/create, and deliberate read/append/
truncate collisions in C and C.UTF-8. Pristine and rc2 fail 146 of 1,038 cases;
the candidate passes all cases. Both locales also pass the collision/create
fixture under Valgrind. Full results are in `Perf/results/round48/`.

Candidate fix: call `open(unmeta(*args), ...)` in both branches, retaining the
original internal string for diagnostics. No descriptor handling, flags, mode,
module layout or error code is changed. The formerly incorrect file selection
is an intentional bug correction, covered by `Test/V14system.ztst`.

No report has been sent, and no deployed binary has been replaced by this trial.
