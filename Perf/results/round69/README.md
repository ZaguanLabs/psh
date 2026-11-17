# Round 69 evidence

See [the compiler experiment](../../round69.md).

- `development-*.log.gz`: initial matching direct-build configure/compile and
  64-script upstream checks.
- `initial-omz-*.log.gz`: direct uninstalled-build failures when function trees
  had not been installed. These do not identify a Clang-specific OMZ regression.
- `package-*.log.gz`, `install-*.log.gz`, `test-*.log.gz`, `refresh-gcc.log.gz` and
  `verify-gcc.log.gz`: actual isolated package.build/install/test/verification
  commands and outcomes.
- `serial-clang-zjson.log.gz`: the reproducible serialized Clang C.UTF-8 failure.
- `parallel-failures/gcc.json` and `parallel-failures/clang.json`: preserved
  test reports from interleaved native builds, excluding the claim that they
  were isolated compiler regressions.
- `gcc-validation.json` and `gcc-build.json`: full, matching GCC package and
  verification identity. Selected Clang reporter and build records remain under
  their private package work directory too.
- `source-identity.json`: protected active executable, compiler identities,
  release names, source digest and completed validation counts.

Both new candidate package prefixes are retained, inactive. No public tag,
source archive, repository visibility, stable Zsh or startup file is changed.
