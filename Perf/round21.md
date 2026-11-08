# Round twenty-one: Oh My Zsh is the hard compatibility boundary

The user has changed the development contract: prioritize performance, permit
justified and documented Zsh breaking changes, and keep **Oh My Zsh working
unchanged**. “90% compatibility” is a direction, not a numerical score or a
quota of failures. The [compatibility policy](../COMPATIBILITY.md) and
[repository instructions](../AGENTS.md) now record that contract.

This round adds a required integration gate and fresh profiles. It introduces
no new Zsh C optimization, representation or deliberate language break. The
nineteen accepted optimizations remain in the unchanged installed release build
`1.0.0-rc0-1d099d21957d`; the project version remains rc0 during private testing.

## What the new gate checks

The [driver](../Packaging/check-ohmyzsh.py) runs real interactive terminals with
an isolated HOME, ZDOTDIR, history and completion cache. It loads the installed
framework/theme/plugins/highlighter from their real files, without patching
those files or sourcing personal startup programs or credential files. Literal
theme/plugin choices and numeric history limits are read as data from `.zshrc`;
no personal startup content is copied to reports. Update checks are disabled
only for these test sessions. Completion security auditing remains enabled.

The current baseline is:

- Oh My Zsh `b509b1c6ed0c1ba37de12cbd37f30b2b2f61193a`: 1,198 source files
  fingerprinted before/after.
- Theme `re5et`, plugin `git`, history limits 100,000/100,000, and unchanged
  zsh-syntax-highlighting `e0165eaa730dd0fa321a6a6de74f092fe87630b0`:
  349 source files fingerprinted before/after.
- Reference `/usr/bin/zsh` 5.9.2 and the exact installed psh release executable.
- Four profiles: configured non-login; configured login; configured with the
  parent's inherited FPATH; and additional `gitfast`, `z`, `extract`, `sudo`,
  and `history-substring-search` plugins.
- Six sessions per profile: reference cold/warm; psh using the reference cache;
  psh warm/cold; and reference using psh's cache. All **24 sessions match**.

The operations check actual `git checkout`, filename, quoted-space, Unicode,
and git-alias completion buffers and cursor positions; rendered syntax
highlight spans; history navigation; prompt configuration and percent expansion;
live git prompt output after its async callback; and Ctrl-C recovery without
executing the aborted command. Every session also holds a real OMZ async handler
behind a FIFO, completes input while it is blocked, releases it and checks the
callback. The fixture uses native redraw hooks and a generation marker to wait
for a completed frame; it does not manually paint highlights or substitute a
sleep for async completion. These observation widgets are test instrumentation,
so the sessions are functional evidence, not input-latency measurements.

The literal completion words are checked, then the complete raw buffers and
highlight arrays must match across interpreters and cache phases. The word
assertions permit a trailing blank; Git completion can stop at the `checkout`
common prefix shared with `checkout-index`. The raw differential comparison
remains exact. Initial harness attempts corrected an overly strict space
assertion and an earlier-frame observation race; the generation-marked
post-widget redraw removes that race.
No product or framework change was made to accommodate either fixture issue.

The gate establishes coverage of these exact revisions and scenarios. It does
not certify every third-party plugin, future OMZ update, terminal, platform or
personal startup integration. A new known OMZ failure still blocks adoption and
must become a regression case, even when the existing matrix passes.

## Activation now requires matching evidence

`Packaging/verify.py verify` runs the gate as the normal user. The privileged
installer consumes a passing `ohmyzsh.json` tied to the exact executable and
current driver/fixture hashes. Framework code is never executed as root.

The negative activation tests reject missing, failed, different-executable and
stale-driver evidence before changing the active shell, `/etc/shells` or active
installation record. A failed rerun deletes the earlier passing certificate,
so it cannot be reused to bypass the failure. The valid final report permits
activation of the unchanged current build.

Existing or rollback releases can refresh only this integration evidence with:

```sh
python3 Packaging/verify.py ohmyzsh --build /path/to/build.json
```

Final verification retains passing receipts for all seven package suites,
installed components, startup filenames and SDK/profile checks, and confirms
that all **11,828 protected Zsh/startup entries** remain unchanged. This round
reuses the unchanged executable and native module hashes; it does not claim a
fresh rebuild or rerun of every old native suite.

## Fresh profiles of the real release build

Five complete Callgrind instruction profiles were collected with the existing
customer/library workers and original source fingerprints. The executable is
the actual release-profile daily driver, rather than a debug-profile surrogate.
Every run exits successfully with a nonempty final state and unchanged project
sources. Commands, worker/binary/source hashes, compressed profiles and flat
annotations are [retained](results/round21/).

These are whole-process instruction counts, including startup, loading,
construction, warm-up and work. They are not warm timer measurements, and a
self-instruction percentage is not a predicted wall-time speedup. This round
makes no new comparative performance claim.

| Workload | Process instructions | Arithmetic self | Bounded array scans | Subscript parsing | Hash-table scans |
| --- | ---: | ---: | ---: | ---: | ---: |
| endgame | 1,201,814,169 | 47.07% | 0.00% | 0.66% | 0.06% |
| mario | 443,487,368 | 23.92% | 0.24% | 1.01% | 1.77% |
| drawing | 505,593,470 | 21.69% | 14.53% | 1.67% | 0.65% |
| json-encode | 3,062,554,665 | 1.84% | 6.33% | 0.08% | 8.89% |
| json-validate | 4,350,823,625 | 1.88% | 8.30% | 12.71% | 6.89% |

The next investigations are concrete:

1. **Array-existence metadata.** `arrlen_ge()` consumes 14.53% of drawing and
   8.30% of JSON validation instructions. Its bounded null-pointer scan is still
   linear. Evaluate a length/generation representation or cache for ordinary
   arrays, with a complete mutation/invalidation audit and explicit native SDK
   consequences. Special/tied/custom arrays and OMZ parameter behavior need
   their own evidence. No cache or quadratic whole-application claim is adopted.
2. **Repeated arithmetic parsing and operand work.** Arithmetic accounts for
   47.07% of Endgame instructions, 23.92% of Mario and 21.69% of drawing. Lexing,
   parser dispatch, operands and allocations remain targets. A parsed form would
   need runtime variable/function lookup and defined option, callback and error
   behavior; no arithmetic cache or VM is adopted here.
3. **Scope bookkeeping.** Table scanning accounts for 8.89% of JSON encoding and
   6.89% of validation. More direct scope tracking merits investigation, while
   preserving OMZ's dynamic locals, hooks and signal callbacks. The mixed/slower
   round-eighteen variants remain rejected; new permission to break compatibility
   does not turn their existing measurements into gains.

Structural changes and intentional differences can now be considered, with
measured customer benefits, explicit migration and passing unchanged-OMZ
validation. Memory safety and accidental wrong results remain bugs. Existing
pristine, native/API and application tests still identify unexpected changes;
they will not be reduced to a “90% pass” threshold.
