set pagination off
set confirm off
break installemulation
commands
silent
printf "emulation-entry queue=%d mode=%d\n", queueing_enabled, new_emulation
continue
end
run
