# psh development contract

The user prioritizes performance and permits deliberate, documented departures
from standard Zsh. Broad compatibility remains valuable, but full Zsh semantic
equivalence is no longer the acceptance criterion. “90% compatibility” describes
direction; it is not a test-pass quota or an established measurement.

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
- Keep the project version `1.0.0-rc0` until public release. Distinguish private
  iterations using commits, build digests and binary hashes. Retain historical
  artifacts and the existing tag/draft checkpoint. Do not publish or change
  repository visibility without an explicit instruction.

## Performance and compatibility work

Profile the actual release build and the user's projects. Keep timing separate
from builds, tests and profilers, alternate samples, compare resulting states,
and retain slower controls and unsuccessful experiments.

A deliberate incompatibility needs a measured benefit, an exact before/after
reproducer, a documented migration or fallback, and passing OMZ evidence.
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
