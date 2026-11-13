# Run in a private PTY with the native benchmark driver's report channel.
emulate -R zsh
setopt nounset
module_path=("$1")
typeset command_name=$2 report_fd=$4 value attribute color expected_first
typeset -a values cell
integer failures=0 cases=0 valid
if [[ $command_name == zcurses ]]; then
  zmodload zsh/curses || exit 90
else
  zmodload zdraw || exit 90
fi
"$command_name" init || exit 91
"$command_name" addwin sample 2 12 0 0 || exit 92
values=(X ' ')
[[ $LC_ALL == C.UTF-8 ]] && values+=(é 界 $'e\u0301' $'a\u0301\u0308\u0302\u0304')
print -r -u "$report_fd" -- 0
for value in "${values[@]}"; do
  expected_first=$value[1]
  for attribute in plain bold underline reverse; do
    for color in default/default red/black; do
      "$command_name" attr sample -bold -underline -reverse default/default || exit 93
      "$command_name" clear sample || exit 94
      "$command_name" move sample 0 0 || exit 95
      "$command_name" attr sample "$color" || exit 96
      [[ $attribute == plain ]] || "$command_name" attr sample "$attribute" || exit 97
      "$command_name" string sample "$value" || exit 98
      "$command_name" move sample 0 0 || exit 99
      "$command_name" querychar sample cell || exit 100
      valid=1
      [[ $cell[1] == "$expected_first" && $cell[2] == "$color" ]] || valid=0
      if [[ $attribute == plain ]]; then
        (( ${#cell} == 2 )) || valid=0
      else
        (( ${#cell} == 3 && ${cell[(Ie)$attribute]} )) || valid=0
      fi
      (( ++cases ))
      (( valid )) || (( ++failures ))
      print -r -u "$report_fd" -- "$cases:$valid:${(qqqq)value}:$attribute:$color"
      print -rl -u "$report_fd" -- "${(@qqqq)cell}"
    done
  done
done
"$command_name" delwin sample || exit 101
"$command_name" end || exit 102
print -r -u "$report_fd" -- "cases=$cases failures=$failures"
