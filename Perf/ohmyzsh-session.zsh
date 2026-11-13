# Sourced only by the isolated interactive compatibility harness.
export ZSH=$PSH_OMZ_ROOT
ZSH_CUSTOM=$ZSH/custom
ZSH_CACHE_DIR=$HOME/cache
ZSH_COMPDUMP=$HOME/.zcompdump
ZSH_THEME=$PSH_OMZ_THEME
plugins=(${=PSH_OMZ_PLUGINS})
HISTFILE=$HOME/.history
HISTSIZE=$PSH_OMZ_HISTSIZE
SAVEHIST=$PSH_OMZ_SAVEHIST
zstyle ':omz:update' mode disabled
source "$ZSH/oh-my-zsh.sh" || exit 81
if [[ -n $PSH_OMZ_HIGHLIGHT ]]; then
  source "$PSH_OMZ_HIGHLIGHT" || exit 82
fi

# A blocked handler establishes that ZLE can accept and complete input before
# an async result is ready. Recent OMZ runs its own register/request/callback
# code; older checkouts use the explicitly recorded ZLE descriptor fixture.
_psh_omz_probe() {
  local reply
  IFS= read -r reply < "$PSH_OMZ_GATE" || return
  print -r -- "$reply"
}
typeset -g PSH_OMZ_ASYNC_DRIVER=omz
if (( ${+functions[_omz_register_handler]} )); then
  _omz_register_handler _psh_omz_probe
else
  # Older OMZ has no async prompt API. Exercise ZLE's real descriptor callback
  # without injecting newer framework code or claiming OMZ async coverage.
  PSH_OMZ_ASYNC_DRIVER=zle-fd
  typeset -g _PSH_OMZ_ASYNC_OUTPUT=''
  typeset -gi _PSH_OMZ_ASYNC_FD=-1
  _psh_omz_fd_ready() {
    local reply
    IFS= read -r reply <&$1 && _PSH_OMZ_ASYNC_OUTPUT=$reply
    zle -F "$1"
    exec {_PSH_OMZ_ASYNC_FD}<&-
    _PSH_OMZ_ASYNC_FD=-1
    zle -R
  }
  exec {_PSH_OMZ_ASYNC_FD}< <(_psh_omz_probe)
  zle -F "$_PSH_OMZ_ASYNC_FD" _psh_omz_fd_ready
fi
# Old checkouts do not compile compinit's dump themselves. Compile only the
# disposable fixture's cache so cold/warm/handoff bytecode coverage still runs.
typeset -g PSH_OMZ_DUMP_DRIVER=framework
if ! command grep -Eq 'zrecompile|zcompile' "$ZSH/oh-my-zsh.sh"; then
  PSH_OMZ_DUMP_DRIVER=fixture
  zcompile -M "$ZSH_COMPDUMP" || exit 85
fi
zmodload -F zsh/files b:zf_mv
typeset -gi PSH_OMZ_GENERATION=0

_psh_omz_rendered() {
  {
    builtin printf '%s\0' "$PSH_OMZ_GENERATION" "$BUFFER" "$CURSOR" "${region_highlight[@]}"
  } > "$PSH_OMZ_RENDER.new"
  zf_mv -f -- "$PSH_OMZ_RENDER.new" "$PSH_OMZ_RENDER"
}
autoload -Uz add-zle-hook-widget
# Registered after syntax highlighting, so this observes its actual redraw
# output rather than calling a highlighter by hand from the inspection widget.
add-zle-hook-widget line-pre-redraw _psh_omz_rendered

_psh_omz_capture() {
  zle -f keepsuffix
  (( ++PSH_OMZ_GENERATION ))
  {
    builtin printf '%s\0' "$PSH_OMZ_GENERATION" "$BUFFER" "$CURSOR" \
      "${_OMZ_ASYNC_OUTPUT[_psh_omz_probe]-${_PSH_OMZ_ASYNC_OUTPUT-}}" "$(git_prompt_info)" "${region_highlight[@]}"
  } > "$PSH_OMZ_CAPTURE.new"
  zf_mv -f -- "$PSH_OMZ_CAPTURE.new" "$PSH_OMZ_CAPTURE"
  # This test handler runs once. Normal git async handlers remain registered.
  if [[ -n ${_OMZ_ASYNC_OUTPUT[_psh_omz_probe]-} ]]; then
    _omz_async_functions=("${(@)_omz_async_functions:#_psh_omz_probe}")
  fi
}
zle -N _psh_omz_capture
bindkey -M emacs '^X^P' _psh_omz_capture
bindkey -M viins '^X^P' _psh_omz_capture

_psh_omz_exit() {
  local handler fd pid
  if [[ $PSH_OMZ_ASYNC_DRIVER == zle-fd ]]; then
    if (( _PSH_OMZ_ASYNC_FD >= 0 )); then
      zle -F "$_PSH_OMZ_ASYNC_FD"
      exec {_PSH_OMZ_ASYNC_FD}<&-
    fi
    builtin exit 0
  fi
  for handler in "${(@k)_OMZ_ASYNC_FDS}"; do
    fd=${_OMZ_ASYNC_FDS[$handler]:--1}
    pid=${_OMZ_ASYNC_PIDS[$handler]:--1}
    if (( fd >= 0 )); then
      exec {fd}<&-
      zle -F "$fd"
      if (( pid > 0 )); then
        if [[ -o monitor ]]; then
          kill -TERM -- -$pid 2>/dev/null
        else
          kill -TERM -- $pid 2>/dev/null
        fi
      fi
    fi
  done
  builtin exit 0
}

# Record only framework state. Personal startup files, keys and environment
# values are never sourced or dumped by this fixture.
{
  builtin print -rl -- "theme=$ZSH_THEME" "plugins=${(j:,:)plugins}"
  builtin print -rl -- "history-size=$HISTSIZE" "history-save=$SAVEHIST"
  builtin print -rl -- "async-driver=$PSH_OMZ_ASYNC_DRIVER" "compiled-dump-driver=$PSH_OMZ_DUMP_DRIVER"
  builtin print -rl -- "git-alias=${aliases[gco]-}" "git-completion=${_comps[git]-}"
  builtin print -r -- "branch=$(git_current_branch)"
  if (( ${+functions[_omz_git_prompt_info]} )); then
    builtin print -r -- "git-prompt=$(_omz_git_prompt_info)"
  else
    builtin print -r -- "git-prompt=$(git_prompt_info)"
  fi
  if [[ "$PROMPT $RPROMPT $RPS1" == *git_prompt_info* ]]; then
    builtin print -r -- theme-uses-git-prompt=1
  else
    builtin print -r -- theme-uses-git-prompt=0
  fi
  builtin print -rl -- "prompt=${(qqq)PROMPT}" "rprompt=${(qqq)RPROMPT}" "rps1=${(qqq)RPS1}"
  builtin print -r -- "prompt-expansion=$(builtin print -P -- '%F{green}%n@%m %~%f %(!.#.>)')"
  builtin print -r -- "omz-version=$(omz version)"
  bindkey -M emacs '^R'
  bindkey -M emacs '^[[A'
  builtin set -o
} > "$PSH_OMZ_STATE"
[[ -n ${_comps[git]-} && $ZSH_THEME == $PSH_OMZ_THEME ]] || exit 83
if (( ${plugins[(Ie)git]} )); then
  [[ -n ${aliases[gco]-} ]] || exit 83
fi
[[ -z $PSH_OMZ_HIGHLIGHT || ${+functions[_zsh_highlight]} == 1 ]] || exit 84
print -r -- ready > "$PSH_OMZ_READY"
