emulate -R zsh
setopt extendedglob
for (( i=0; i<100; i++ )); do
  [[ $'\xe2\x82A' == *[[:INVALID:][:INCOMPLETE:]]* ]] || print bad-malformed
  [[ '"' != *[[:INVALID:][:INCOMPLETE:]]* ]] || print bad-ascii
  [[ $'\xef\xbf\xbdA\xc3\xa9' != *[[:INVALID:][:INCOMPLETE:]]* ]] || print bad-valid
  [[ $'\xe2\x82A' == [[:INVALID:][:INCOMPLETE:]]##A ]] || print bad-repeat
  [[ 'ABC' == [^[:INVALID:][:INCOMPLETE:]]## ]] || print bad-ascii-repeat
 done
