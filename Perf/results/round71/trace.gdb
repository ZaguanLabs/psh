set pagination off
set environment LC_ALL C.UTF-8
break mb_patmatchrange if ch < 128 && zmb_ind != 0
commands
silent
printf "ASCII ch=%u status=%d flags=%d\n", ch, zmb_ind, patglobflags
bt 3
continue
end
run -df .work/round71/repro.zsh
