# psh development contract

The user wants meaningful performance gains while preserving existing Zsh
behavior by default. Existing scripts working unchanged is the normal target.
Limited, deliberate, documented departures remain permitted when their benefit
is substantial and the affected behavior is understood. Do not sacrifice commonly
used semantics for marginal speedups. “90% compatibility” expresses tolerance for
limited differences; it is not a test-pass quota or an established measurement.

## Hard requirements

- Oh My Zsh must work unchanged. Do not adopt a change with a known OMZ
  regression, or patch the user's framework, themes, plugins or startup files
  to make a candidate pass. Requiring an OMZ-specific configuration change is
  incompatible with this requirement.
- Preserve the user's active OMZ theme/plugin stack, including its syntax
  highlighter, and test genuine ZLE/completion/history/prompt/async behavior.
  Startup success alone does not establish this requirement.
- Run `Packaging/verify.py verify` before activation. It includes the required
  OMZ terminal gate. `Packaging/verify.py ohmyzsh --build PATH` can refresh that
  evidence for an existing release, including rollback candidates. The
  privileged installer consumes matching evidence; framework code runs only
  under the normal user.
- Keep the stable Zsh installation, personal startup files and account login
  shell untouched. Install psh only through its isolated packaging workflow.
- Prepare `1.0.0-rc1` on the development branch. Published rc0 tags and source
  archives are immutable. Distinguish development iterations using commits,
  build digests and binary hashes. Retain historical artifacts and the archived
  private tag/draft checkpoint. Do not publish or change repository visibility
  without an explicit instruction.

## Performance and compatibility work

Profile the actual release build and the user's projects. Keep timing separate
from builds, tests and profilers, alternate samples, compare resulting states,
and retain slower controls and unsuccessful experiments.

Try behavior-preserving approaches first. For architectural changes, characterize
the existing behavior before replacing it, make one change at a time, and compare
against both pristine Zsh and the preceding accepted build. Preserve evaluation
order, side effects, option handling, diagnostics, scope restoration and supported
native interfaces unless a specific departure satisfies the policy below. Use
the legacy path where fast-path eligibility or ownership cannot be established.

A deliberate incompatibility needs a substantial measured benefit, an exact
before/after reproducer, a documented migration or fallback, and passing OMZ evidence.
Native ABI changes also require rebuilding affected modules against the
matching SDK. The existing differences are listed in `COMPATIBILITY.md`;
permission to introduce differences does not mean unspecified differences are
automatically accepted.

Continue differential and upstream testing to discover changes. Classify any
intentional divergences explicitly rather than deleting checks or hiding
failures. Memory corruption, unsafe ownership and accidental wrong results are
bugs, not compatibility tradeoffs. The user's applications are primary customer
workloads; substantial measured benefits there take priority over isolated
microbenchmark scores.
