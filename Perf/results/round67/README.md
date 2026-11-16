# Round 67 evidence

[The report](../../round67.md) explains the profile and rejected trial.

- `actual/profile.json` selects the exact installed rc2, its customer inputs and
  source/cache metadata, raw stdout/state hashes and complete instruction totals.
- `actual/*.callgrind.gz`, `*.callers.gz`, `*.stdout.gz` and `*.stderr.gz` retain
  the installed Endgame and coder profiles.
- `endgame-core.callgrind.gz` and `endgame-core.txt.gz` retain a derived source
  annotation. `normalization.json` gives its source-prefix mapping, raw/normalized
  summary, and matching historical/current `Src/math.c` digest. No semantic values
  are changed by this path normalization.
- `separator-{before,pristine,candidate,memcheck}.json.gz` retain all results.
  `duplicate-analysis.json` records the 12 identical repeated invocations.
- `profile-{before,after}/` are ordinary matching-development profiles of the
  rejected one-byte raw-comparison trial. Their resulting states are equal.
- `candidate.patch.gz` is the prototype. `focused-timing.json.gz` contains all
  alternating samples, including slower ordinary and fallback controls.
- `build.log.gz`, `restoration-build.log.gz`, `source-identity.json` and the
  `restored` source/binary hashes preserve exact correction of the rejected trial.

The first corpus attempt used positional comparison for an instrumented subset;
subsequent strict-key construction found the expected identical duplicates.
The final keyed comparison is the retained result. Early filename-extension
collision and failed scope-launcher probes are not presented as passing or semantic
results. Complete final profiles were regenerated with unique case filenames.
`initial-naming/` retains the older four coder outputs separately.
