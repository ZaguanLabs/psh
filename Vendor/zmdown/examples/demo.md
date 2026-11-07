# Markdown, directly in your shell

Use **bold**, *emphasis*, ~~strikethrough~~, and `inline code` in ordinary shell
scripts. Paragraphs wrap to the terminal width.

## Structured output

- Read a file, stdin, or a string.
- Capture the rendered result in a Zsh variable.
  - Keep local variables local.
  - Preserve the final newline.
- [x] Format output for people.
- [ ] Build the next script.

> Markdown is data. Shell expressions such as $(whoami) remain text.

| Input | Example |
| :--- | :--- |
| File | `zmdown README.md` |
| String | `zmdown --text "$message"` |
| Variable | `zmdown -v rendered --text "$message"` |

```zsh
zmodload zmdown
zmdown --text '# Hello from Zsh'
```

Links retain their destinations: [CommonMark](https://commonmark.org).

Unicode: 界, café, é.
