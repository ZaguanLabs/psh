# Publishing the first public rc0

Source preparation does not publish a release or silently move an existing tag.
The repository is public; the initial `v1.0.0-rc0` release remains an unpublished
historical checkpoint until an explicit transition is approved.

## Prepared inputs

`Packaging/source-release.py` takes a clean committed tree and produces the
source archive, `release.json`, `SOURCE-INFO.json` inside the archive, and initial
checksums. `Packaging/check-source-release.py` validates the exact archive outside
Git with Git disabled during builds. It exercises debug/release core builds,
separate native runtimes, both core suites, and staging both complete package
profiles without installing those temporary packages.

The local `public-rc0` release directory additionally contains the finished
GitHub body, complete checksums, source-validation report and compressed logs.
The body uses commit-pinned repository links. The attached source archive,
rather than GitHub's automatic snapshot, carries the original baseline archive.

## Existing checkpoint and the tag decision

At preparation time the original annotated tag object is
`1e5ff955da1e686c74a7b44e47156ec0fc89e673`, peeling to
`f6e94e435a7f657725a66dea69ad3038e2655525`. Its draft has seven historical assets.
It is older than the final 27-optimization source tree.

Before publishing under `v1.0.0-rc0`:

1. Verify that the current remote tag and historical draft/assets still match
   the saved receipt. Keep the original bytes, identities and release metadata.
2. Preserve the original tag object under an archival tag such as
   `archive/private-v1.0.0-rc0`, and associate the old draft with that checkpoint.
   Keep its seven assets. This tag/release transition needs explicit approval
   under the repository's checkpoint policy.
3. Create the public annotated tag at **the commit in the prepared `release.json`**,
   using a guarded update if the old version-name ref is moved. The latest branch
   tip is not a substitute for checking the archive's exact source identity.
4. Create a new draft prerelease for the public tag, upload the prepared files,
   verify every uploaded digest, and review the finished notes and download links.
5. Publish as a prerelease after approval. Keep the public tag and archive
   immutable; subsequent corrections use another candidate/version.

The [earlier private notes](1.0.0-rc0-private-checkpoint.md), original tag/asset
receipt and local historical source archive provide independent recovery points.
The release-preparation work itself leaves the original remote checkpoint intact.
