# rc1 / round 38 evidence

The selected candidate is `1.0.0-rc1-b0850020f4a1`, GCC 15.2.0 PGO+LTO.
See [the investigation](../../round38.md) for methods and limits.

- `selected-scenes.json`: six full fresh scenes, five measured samples per host,
  one excluded warmup, exact palette/material/depth output checks.
- `selected-scene-repeat.json`: an independent five-sample Moonlit repeat.
- `selected-customer*.json`: thirteen real offline customer kernels, nine
  alternating samples per host and an independent complete repeat.
- `selected-library*.json`: bundled JSON training cases; these are in-sample.
- `*-pilot.json`: the ordinary/LTO/PGO/combined exploration, with mixed/slower
  LTO controls retained. Some pilots precede the permission repair and are not
  activation candidates.
- `selected-correctness.json` and its twelve named reports: pristine-versus-
  selected differential/native checks, including Memcheck runs without leak
  checking. Native raw-alias differences are explicitly classified by the
  existing ownership contract rather than hidden as failures.
- `stateful-inputs.tar.xz`: exact generated inputs for the final normal and
  Memcheck stateful comparisons. Seed/locale/output hashes are in their reports.
- `selected-build.json`, `selected-training.json`, `selected-validation.json`,
  `selected-ohmyzsh.json`, package suites and installed-core receipt: the exact
  installed inactive candidate, SDK/modules, compiler feedback and 24-session
  unchanged-framework gate. The full payload manifest includes no personal
  startup contents. Training and suite wall times are not benchmark samples.
- `initial-umask-failure.*`: the rejected package's compinit security prompt.
  Corrected candidates preserve auditing and tighten only payload directories.
- `moonlit-zprof.txt`, `moonlit.callgrind`, `moonlit-flat.txt`: separate full-scene
  baseline profiles; instruction counts include setup and output serialization.
- `final-protection.json`: active rc0, stable Zsh, startup files, shell
  registration and account shell unchanged; matching public exports and debugger
  lookup for the selected candidate.
- `compiler-pilot.py`, `final-timing.py`, `validate-selected.py`: exact orchestration
  with commands and explicit roots. Edit paths for another machine. Source and
  driver fingerprints accompany results; original customer projects are not
  copied into this repository.

`sha256.json` indexes all evidence files. No general platform certification,
universal compatibility or aggregate shell speedup is claimed. The final source
archive is validated separately after committing the release inputs; its report
belongs alongside that exact archive, not to an earlier source commit.
