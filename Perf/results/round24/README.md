# Round twenty-four evidence

[The report](../../round24.md) explains forward-search prefix reuse, ownership
and callback guards, measured gains, slower controls and the installed build.
The immutable reference is commit `9d710a9d617d4458afd166577fe40d98b11140d7`.
The only production C change is in `Src/params.c`; the existing array ownership
contract, public layouts and exported symbol set remain unchanged.

- `library-benchmarks.json` / `library-repeat.json` and
  `customer-benchmarks.json` / `customer-repeat.json` retain all nine alternating
  samples per run, including slower Endgame, drawing and URL-encoding controls.
  `parser-benchmarks.json` and `search-benchmarks.json` retain their controls.
  `timing-commands.json` and `idle-check.json` record scheduling and build/test
  separation. Warm timers exclude preparation and initial discovery.
- Actual daily-driver profiles and matched comparison profiles are compressed
  as `*.callgrind.gz`. `instruction-summary.json` records exclusive counts and
  original raw hashes. Source/state hashes match within the matched pairs.
  Profile instruction totals include preparation and initial discoveries.
  `hardware.json` measures fully scheduled user-space events from exec to exit.
- `large-search.json`, `clang-search.json`, `development-search.json` and
  `installed-search.json` each retain 362,580 byte/status/capture comparisons.
  `search-memcheck.json` retains the additional 169,344 boundary comparisons
  under 168 Memcheck processes; individual logs remain beside it.
- Native loan/mutation receipts cover GCC, Clang, debug and installed pairs,
  including Memcheck. Their default mode compares hosts that already share the
  round-twenty-two ownership rule. The historical `--raw-contract` mode is for a
  pre-cache reference and is not used for these pairs.
  `*search-signals*` records three GDB probes of unqueued searches per candidate.
- `validation.json` records the broad differential groups.
  `package-validation.json`, the seven `test-*.json` receipts, `ohmyzsh.json`,
  installed identity receipts and `activation.json` bind the actual daily driver
  and its protection checks. Framework tests run as the normal user.
- `source-checks.json` verifies 1,847 pristine files, all 1,853 installed core
  inputs, unchanged default/scalar search generators and fixture syntax.
  `patch-check.json` records seven-file reconstruction from the preceding commit.
- `build-setup-missing.log` preserves the early generated-driver launch failure.
  `cache-fixture-flag-setup.log.gz` preserves the initial test flag syntax error;
  subsequent receipts bind the corrected fixture. Neither failure is removed.

Binaries, native fixture objects and complete personal/stable-install protection
snapshots remain local. Activation receipts retain protection counts without
those private snapshot contents. `sha256.json` covers all files in this evidence
directory except itself. No source archive or public release is created here;
the original rc0 tag, draft and seven assets are retained.
