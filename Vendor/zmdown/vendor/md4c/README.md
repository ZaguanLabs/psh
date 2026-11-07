# MD4C provenance

Unmodified files from https://github.com/mity/md4c at commit
`00788b157b2b6ef3efd8659b66f6521229f382d7` (retrieved 2026-09-11).
This is a pinned development revision following release 0.5.3, not a claim
that these files are the release tarball.

The current revision fixes code-span newline whitespace differences found when
testing release 0.5.3 against CommonMark 0.31.2. The pinned parser passes all 652
examples through its HTML renderer after normalizing inter-element whitespace.
Code-span and preformatted whitespace remain significant in that comparison.

`md4c.c`, `md4c.h`, `entity.c`, and `entity.h` are compiled into the module.
`md4c-html.c` and `md4c-html.h` are used only by the parser conformance tests.
The terminal renderer is implemented separately in `src/render.c`.

The upstream MIT licence is in `LICENSE.md`; copyright notices remain in each
source file. `SHA256SUMS` records the vendored file digests. Run
`sha256sum -c SHA256SUMS` from this directory to verify them.
