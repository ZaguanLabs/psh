#!/usr/bin/env zsh
# SPDX-License-Identifier: Apache-2.0
emulate -R zsh
setopt pipe_fail
typeset test_root=${0:A:h:h}
fpath=( "$test_root/functions" "${fpath[@]}" )
autoload -Uz zoup
typeset actual expected REPLY=original
expected=$'<p>hello</p>\n\n'
print -rn -- $'<p>hello</p><script>bad</script>\n\n' | zoup clean --stdin || exit 1
[[ $REPLY == "$expected" ]] || { print -ru2 -- 'FAIL stdin/trailing newlines'; exit 1; }
# Append a marker so command substitution cannot hide lost trailing newlines.
actual=$(zsh -df "$test_root/bin/zoup" clean -- $'<p>x</p>\n\n'; print -rn -- END)
[[ $actual == $'<p>x</p>\n\nEND' ]] || { print -ru2 -- 'FAIL CLI stdout'; exit 1; }
actual=$(print -rn -- '<p>x</p><img alt=y>' | zsh -df "$test_root/bin/zoup" clean --stdin)
[[ $actual == '<p>x</p>y' ]] || { print -ru2 -- 'FAIL CLI stdin'; exit 1; }
actual=$(zoup clean --stdout -- '<p' 2>/dev/null)
[[ $? == 1 && -z $actual ]] || { print -ru2 -- 'FAIL atomic stdout'; exit 1; }
print -rn -- "${(pl:1048577::x:)}" | zoup clean --stdin 2>/dev/null
[[ $? != 0 ]] || { print -ru2 -- 'FAIL bounded stdin'; exit 1; }
REPLY=original
zoup clean --stdin 0<&- 2>/dev/null
[[ $? == 1 && $REPLY == original ]] || { print -ru2 -- 'FAIL stdin descriptor error'; exit 1; }
expected="<p>${(pl:9000::x:)}</p>"$'\n\n'
print -rn -- "$expected" | zoup clean --stdin || exit 1
[[ $REPLY == "$expected" ]] || { print -ru2 -- 'FAIL input spanning read buffers'; exit 1; }
typeset fixture
for fixture in page script-comments; do
  actual=$(zsh -df "$test_root/bin/zoup" clean --stdin < "$test_root/tests/fixtures/$fixture.html") || exit 1
  expected=$(<"$test_root/tests/fixtures/$fixture.clean.html")
  [[ $actual == "$expected" ]] || { print -ru2 -- "FAIL whole-page fixture: $fixture"; exit 1; }
done
print -r -- '9 stream checks passed'
