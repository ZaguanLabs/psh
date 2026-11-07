# Project guidance

- Implement zoup in Zsh only, including its test and benchmark scripts. Do not
  add an external parser or a compiled extension. Standard Zsh builtins/modules
  are permitted; keep scalar-input cleaning free of module dependencies.
- Load the library through `autoload -Uz zoup`. Use the Zsh expert skill for
  implementation and review.
- Preserve the pipeline boundary: zcurl fetches; zoup removes content unsuitable
  for a text browser and returns HTML; zhtml parses/prepares; zdraw displays.
  zbrowser remains a future application. Keep networking, terminal layout, and
  event-loop ownership outside zoup.
- Preserve useful information, document boundaries, links, and form/table
  relationships. Do not turn cleanup into automatic article extraction.
- Treat HTML as literal data. Never evaluate it as shell code. Keep errors
  atomic and parsing work bounded. Document incomplete HTML behavior clearly.
- Run `zsh -df scripts/test.zsh` after code changes. Run the synthetic benchmark
  for scanner changes, and report measurements with their input sizes.
- Keep the user's existing files and unrelated changes intact.
