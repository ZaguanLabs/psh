set pagination off
set confirm off
set inferior-tty /dev/null
set $eligible = 0
set $inplace = 0
break *0x48a612 if $rdx >= 4096
commands
silent
set $pm = ((struct value *)$rbx)->pm
printf "name=%s flags=%#x assignment=%#x prefix=%ld start=%d end=%d queue=%d ordinary=%d\n", $pm->node.nam, $pm->node.flags, *(int*)($rsp+28), $rdx, $r9d, $esi, queueing_enabled, $pm->gsu.s == &stdscalar_gsu
continue
end
break *0x48a895
commands
silent
set $eligible = $eligible + 1
continue
end
break *0x48a89a
commands
silent
if $rax == $r15
set $inplace = $inplace + 1
end
continue
end
run
printf "growth calls=%d in-place=%d\n", $eligible, $inplace
