#!/usr/bin/env zsh
emulate -R zsh
zmodload zmdown || exit 1

show_help() {
  emulate -L zsh
  local document=$'# Example tool\n\nUsage: `example [options]`\n\n- **--help**: show this help\n- **--version**: show the version'
  zmdown --text "$document"
}

show_help
