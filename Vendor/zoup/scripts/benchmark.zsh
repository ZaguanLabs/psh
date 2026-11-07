#!/usr/bin/env zsh
# SPDX-License-Identifier: Apache-2.0
emulate -R zsh
zmodload zsh/datetime || exit 1
fpath=( "${0:A:h:h}/functions" "${fpath[@]}" )
autoload -Uz zoup
typeset html='' REPLY
typeset -F started elapsed
typeset -i count
for count in 128 512 1024; do
  html=''
  repeat $count; do
    html+='<section class="card"><h2>Heading</h2><p>Hello <a href="/next">world</a>.</p><img src="photo.jpg" alt="A landscape"><script>ignore()</script></section>'
  done
  started=$EPOCHREALTIME
  zoup clean -- "$html" || exit 1
  elapsed=$(( EPOCHREALTIME - started ))
  printf '%d bytes, %d sections: %.3f seconds (%d output bytes)\n' ${#html} $count $elapsed ${#REPLY}
done
