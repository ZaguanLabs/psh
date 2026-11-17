emulate -R zsh
source Vendor/zjson/zjson.zsh || exit 90
zjson_quote $'\xe2\x82A\xc3\xa9'
print -r -- "quoted:${(qqqq)REPLY}"
zjson_begin "$REPLY"
print -r -- "parsed:$?:$ZJSON_ERROR_CODE:${(qqqq)ZJSON_TOKEN_VALUE}"
