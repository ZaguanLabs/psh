emulate -R zsh
s=a
print -r -- "${s[(in:2:)*]}"
