#!/usr/bin/env zsh
# SPDX-License-Identifier: Apache-2.0
emulate -R zsh
setopt no_aliases
typeset test_root=${0:A:h:h}
typeset test_file
for test_file in "$test_root"/functions/* "$test_root"/bin/zoup "$test_root"/scripts/*.zsh "$test_root"/tests/*.zsh; do
  zsh -df -n -- "$test_file" || exit 1
done
zsh -df -- "$test_root/tests/clean.zsh" || exit 1
zsh -df -- "$test_root/tests/streams.zsh" || exit 1
