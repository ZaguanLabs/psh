# zmdown

Develop an independent compiled Zsh module for Markdown rendering in shell scripts.
The public API must remain simple. This project has no dependency on zdraw,
zcoder, curses, a TUI framework, or an application event loop.

- Use the Zsh expertise skill for shell scripts and module integration.
- Keep parsing/rendering in a separately testable C core; keep Zsh glue small.
- Treat Markdown as data. Never execute it or forward arbitrary terminal controls.
- Build and test in `.build/`, using a matching Zsh source/configuration ABI.
- Preserve vendor source licences and pin dependency revisions.
- Run `make test` after code changes. Document actual coverage and limitations.
