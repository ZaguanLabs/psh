integer failed_matrices=0
(
emulate -R zsh
setopt multibyte
v=''
i=0
r=prefix${v}suffix
printf '%s\0' "$r"
typeset -p v i
print -r -- comparison-complete
)
integer matrix_status=$?
print -r -- matrix-0-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R zsh
setopt multibyte
v=''
i=0
r="prefix${v}suffix"
printf '%s\0' "$r"
typeset -p v i
print -r -- comparison-complete
)
integer matrix_status=$?
print -r -- matrix-1-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R zsh
setopt multibyte
v=''
i=0
r=${(qqq)v}
printf '%s\0' "$r"
typeset -p v i
print -r -- comparison-complete
)
integer matrix_status=$?
print -r -- matrix-2-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R zsh
setopt multibyte
v=''
i=0
r=${(e)v}
printf '%s\0' "$r"
typeset -p v i
print -r -- comparison-complete
)
integer matrix_status=$?
print -r -- matrix-3-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R zsh
setopt multibyte
v=''
i=0
r=${(U)v}
printf '%s\0' "$r"
typeset -p v i
print -r -- comparison-complete
)
integer matrix_status=$?
print -r -- matrix-4-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R zsh
setopt multibyte
v=''
i=0
r=${v//x/REPLACED}
printf '%s\0' "$r"
typeset -p v i
print -r -- comparison-complete
)
integer matrix_status=$?
print -r -- matrix-5-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R zsh
setopt multibyte
v=''
i=0
r=$((++i))${v}$[i+=2]
printf '%s\0' "$r"
typeset -p v i
print -r -- comparison-complete
)
integer matrix_status=$?
print -r -- matrix-6-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R zsh
setopt multibyte
v=''
i=0
r=$(print -rn -- "before${v}after")
printf '%s\0' "$r"
typeset -p v i
print -r -- comparison-complete
)
integer matrix_status=$?
print -r -- matrix-7-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R zsh
setopt multibyte
v=''
i=0
r=`print -rn -- "before${v}after"`
printf '%s\0' "$r"
typeset -p v i
print -r -- comparison-complete
)
integer matrix_status=$?
print -r -- matrix-8-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R zsh
setopt multibyte
v=''
i=0
typeset r=key=${v}
printf '%s\0' "$r"
typeset -p v i
print -r -- comparison-complete
)
integer matrix_status=$?
print -r -- matrix-9-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R zsh
setopt multibyte
v=''
i=0
typeset r="key=${v}"
printf '%s\0' "$r"
typeset -p v i
print -r -- comparison-complete
)
integer matrix_status=$?
print -r -- matrix-10-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R zsh
setopt multibyte
v=''
i=0
export r=key=${v}
printf '%s\0' "$r"
typeset -p v i
print -r -- comparison-complete
)
integer matrix_status=$?
print -r -- matrix-11-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R zsh
setopt multibyte
v=''
i=0
typeset -a a; a=(before${v}after "key=${v}"); typeset -p a; r=$#a
printf '%s\0' "$r"
typeset -p v i
print -r -- comparison-complete
)
integer matrix_status=$?
print -r -- matrix-12-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R zsh
setopt multibyte
v=''
i=0
setopt shwordsplit; typeset -a a; a=(before${v}after); typeset -p a; r=$#a
printf '%s\0' "$r"
typeset -p v i
print -r -- comparison-complete
)
integer matrix_status=$?
print -r -- matrix-13-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R zsh
setopt multibyte
v=''
i=0
setopt magic_equal_subst; typeset r=key=${v}
printf '%s\0' "$r"
typeset -p v i
print -r -- comparison-complete
)
integer matrix_status=$?
print -r -- matrix-14-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R zsh
setopt multibyte
v=''
i=0
r="${v}$(print -rn -- mid)${v}"
printf '%s\0' "$r"
typeset -p v i
print -r -- comparison-complete
)
integer matrix_status=$?
print -r -- matrix-15-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R zsh
setopt multibyte
v=''
i=0
r="${v}${(j.:.)${(s: :)v}}${v}"
printf '%s\0' "$r"
typeset -p v i
print -r -- comparison-complete
)
integer matrix_status=$?
print -r -- matrix-16-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R zsh
setopt multibyte
v=''
i=0
r=$(< <(print -rn -- "$v"))
printf '%s\0' "$r"
typeset -p v i
print -r -- comparison-complete
)
integer matrix_status=$?
print -r -- matrix-17-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R zsh
setopt multibyte
v=''
i=0
readfile() { REPLY=$(< "$1"); }; readfile =(print -rn -- "$v"); r=$REPLY
printf '%s\0' "$r"
typeset -p v i
print -r -- comparison-complete
)
integer matrix_status=$?
print -r -- matrix-18-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R zsh
setopt multibyte
v=''
i=0
r=$(print -r -- "$v" > >(IFS= read -r line; print -rn -- "$line"))
printf '%s\0' "$r"
typeset -p v i
print -r -- comparison-complete
)
integer matrix_status=$?
print -r -- matrix-19-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R zsh
setopt multibyte
v=''
i=0
r="xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx${v}yyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyy$((++i))zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz"
printf '%s\0' "$r"
typeset -p v i
print -r -- comparison-complete
)
integer matrix_status=$?
print -r -- matrix-20-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R zsh
setopt multibyte
v=''
i=0
typeset r=xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx=${v}yyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyy
printf '%s\0' "$r"
typeset -p v i
print -r -- comparison-complete
)
integer matrix_status=$?
print -r -- matrix-21-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R zsh
setopt multibyte
v='x=y:a b'
i=0
r=prefix${v}suffix
printf '%s\0' "$r"
typeset -p v i
print -r -- comparison-complete
)
integer matrix_status=$?
print -r -- matrix-22-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R zsh
setopt multibyte
v='x=y:a b'
i=0
r="prefix${v}suffix"
printf '%s\0' "$r"
typeset -p v i
print -r -- comparison-complete
)
integer matrix_status=$?
print -r -- matrix-23-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R zsh
setopt multibyte
v='x=y:a b'
i=0
r=${(qqq)v}
printf '%s\0' "$r"
typeset -p v i
print -r -- comparison-complete
)
integer matrix_status=$?
print -r -- matrix-24-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R zsh
setopt multibyte
v='x=y:a b'
i=0
r=${(e)v}
printf '%s\0' "$r"
typeset -p v i
print -r -- comparison-complete
)
integer matrix_status=$?
print -r -- matrix-25-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R zsh
setopt multibyte
v='x=y:a b'
i=0
r=${(U)v}
printf '%s\0' "$r"
typeset -p v i
print -r -- comparison-complete
)
integer matrix_status=$?
print -r -- matrix-26-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R zsh
setopt multibyte
v='x=y:a b'
i=0
r=${v//x/REPLACED}
printf '%s\0' "$r"
typeset -p v i
print -r -- comparison-complete
)
integer matrix_status=$?
print -r -- matrix-27-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R zsh
setopt multibyte
v='x=y:a b'
i=0
r=$((++i))${v}$[i+=2]
printf '%s\0' "$r"
typeset -p v i
print -r -- comparison-complete
)
integer matrix_status=$?
print -r -- matrix-28-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R zsh
setopt multibyte
v='x=y:a b'
i=0
r=$(print -rn -- "before${v}after")
printf '%s\0' "$r"
typeset -p v i
print -r -- comparison-complete
)
integer matrix_status=$?
print -r -- matrix-29-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R zsh
setopt multibyte
v='x=y:a b'
i=0
r=`print -rn -- "before${v}after"`
printf '%s\0' "$r"
typeset -p v i
print -r -- comparison-complete
)
integer matrix_status=$?
print -r -- matrix-30-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R zsh
setopt multibyte
v='x=y:a b'
i=0
typeset r=key=${v}
printf '%s\0' "$r"
typeset -p v i
print -r -- comparison-complete
)
integer matrix_status=$?
print -r -- matrix-31-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R zsh
setopt multibyte
v='x=y:a b'
i=0
typeset r="key=${v}"
printf '%s\0' "$r"
typeset -p v i
print -r -- comparison-complete
)
integer matrix_status=$?
print -r -- matrix-32-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R zsh
setopt multibyte
v='x=y:a b'
i=0
export r=key=${v}
printf '%s\0' "$r"
typeset -p v i
print -r -- comparison-complete
)
integer matrix_status=$?
print -r -- matrix-33-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R zsh
setopt multibyte
v='x=y:a b'
i=0
typeset -a a; a=(before${v}after "key=${v}"); typeset -p a; r=$#a
printf '%s\0' "$r"
typeset -p v i
print -r -- comparison-complete
)
integer matrix_status=$?
print -r -- matrix-34-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R zsh
setopt multibyte
v='x=y:a b'
i=0
setopt shwordsplit; typeset -a a; a=(before${v}after); typeset -p a; r=$#a
printf '%s\0' "$r"
typeset -p v i
print -r -- comparison-complete
)
integer matrix_status=$?
print -r -- matrix-35-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R zsh
setopt multibyte
v='x=y:a b'
i=0
setopt magic_equal_subst; typeset r=key=${v}
printf '%s\0' "$r"
typeset -p v i
print -r -- comparison-complete
)
integer matrix_status=$?
print -r -- matrix-36-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R zsh
setopt multibyte
v='x=y:a b'
i=0
r="${v}$(print -rn -- mid)${v}"
printf '%s\0' "$r"
typeset -p v i
print -r -- comparison-complete
)
integer matrix_status=$?
print -r -- matrix-37-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R zsh
setopt multibyte
v='x=y:a b'
i=0
r="${v}${(j.:.)${(s: :)v}}${v}"
printf '%s\0' "$r"
typeset -p v i
print -r -- comparison-complete
)
integer matrix_status=$?
print -r -- matrix-38-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R zsh
setopt multibyte
v='x=y:a b'
i=0
r=$(< <(print -rn -- "$v"))
printf '%s\0' "$r"
typeset -p v i
print -r -- comparison-complete
)
integer matrix_status=$?
print -r -- matrix-39-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R zsh
setopt multibyte
v='x=y:a b'
i=0
readfile() { REPLY=$(< "$1"); }; readfile =(print -rn -- "$v"); r=$REPLY
printf '%s\0' "$r"
typeset -p v i
print -r -- comparison-complete
)
integer matrix_status=$?
print -r -- matrix-40-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R zsh
setopt multibyte
v='x=y:a b'
i=0
r=$(print -r -- "$v" > >(IFS= read -r line; print -rn -- "$line"))
printf '%s\0' "$r"
typeset -p v i
print -r -- comparison-complete
)
integer matrix_status=$?
print -r -- matrix-41-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R zsh
setopt multibyte
v='x=y:a b'
i=0
r="xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx${v}yyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyy$((++i))zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz"
printf '%s\0' "$r"
typeset -p v i
print -r -- comparison-complete
)
integer matrix_status=$?
print -r -- matrix-42-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R zsh
setopt multibyte
v='x=y:a b'
i=0
typeset r=xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx=${v}yyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyy
printf '%s\0' "$r"
typeset -p v i
print -r -- comparison-complete
)
integer matrix_status=$?
print -r -- matrix-43-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R zsh
setopt multibyte
v='é😀'
i=0
r=prefix${v}suffix
printf '%s\0' "$r"
typeset -p v i
print -r -- comparison-complete
)
integer matrix_status=$?
print -r -- matrix-44-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R zsh
setopt multibyte
v='é😀'
i=0
r="prefix${v}suffix"
printf '%s\0' "$r"
typeset -p v i
print -r -- comparison-complete
)
integer matrix_status=$?
print -r -- matrix-45-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R zsh
setopt multibyte
v='é😀'
i=0
r=${(qqq)v}
printf '%s\0' "$r"
typeset -p v i
print -r -- comparison-complete
)
integer matrix_status=$?
print -r -- matrix-46-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R zsh
setopt multibyte
v='é😀'
i=0
r=${(e)v}
printf '%s\0' "$r"
typeset -p v i
print -r -- comparison-complete
)
integer matrix_status=$?
print -r -- matrix-47-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R zsh
setopt multibyte
v='é😀'
i=0
r=${(U)v}
printf '%s\0' "$r"
typeset -p v i
print -r -- comparison-complete
)
integer matrix_status=$?
print -r -- matrix-48-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R zsh
setopt multibyte
v='é😀'
i=0
r=${v//x/REPLACED}
printf '%s\0' "$r"
typeset -p v i
print -r -- comparison-complete
)
integer matrix_status=$?
print -r -- matrix-49-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R zsh
setopt multibyte
v='é😀'
i=0
r=$((++i))${v}$[i+=2]
printf '%s\0' "$r"
typeset -p v i
print -r -- comparison-complete
)
integer matrix_status=$?
print -r -- matrix-50-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R zsh
setopt multibyte
v='é😀'
i=0
r=$(print -rn -- "before${v}after")
printf '%s\0' "$r"
typeset -p v i
print -r -- comparison-complete
)
integer matrix_status=$?
print -r -- matrix-51-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R zsh
setopt multibyte
v='é😀'
i=0
r=`print -rn -- "before${v}after"`
printf '%s\0' "$r"
typeset -p v i
print -r -- comparison-complete
)
integer matrix_status=$?
print -r -- matrix-52-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R zsh
setopt multibyte
v='é😀'
i=0
typeset r=key=${v}
printf '%s\0' "$r"
typeset -p v i
print -r -- comparison-complete
)
integer matrix_status=$?
print -r -- matrix-53-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R zsh
setopt multibyte
v='é😀'
i=0
typeset r="key=${v}"
printf '%s\0' "$r"
typeset -p v i
print -r -- comparison-complete
)
integer matrix_status=$?
print -r -- matrix-54-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R zsh
setopt multibyte
v='é😀'
i=0
export r=key=${v}
printf '%s\0' "$r"
typeset -p v i
print -r -- comparison-complete
)
integer matrix_status=$?
print -r -- matrix-55-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R zsh
setopt multibyte
v='é😀'
i=0
typeset -a a; a=(before${v}after "key=${v}"); typeset -p a; r=$#a
printf '%s\0' "$r"
typeset -p v i
print -r -- comparison-complete
)
integer matrix_status=$?
print -r -- matrix-56-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R zsh
setopt multibyte
v='é😀'
i=0
setopt shwordsplit; typeset -a a; a=(before${v}after); typeset -p a; r=$#a
printf '%s\0' "$r"
typeset -p v i
print -r -- comparison-complete
)
integer matrix_status=$?
print -r -- matrix-57-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R zsh
setopt multibyte
v='é😀'
i=0
setopt magic_equal_subst; typeset r=key=${v}
printf '%s\0' "$r"
typeset -p v i
print -r -- comparison-complete
)
integer matrix_status=$?
print -r -- matrix-58-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R zsh
setopt multibyte
v='é😀'
i=0
r="${v}$(print -rn -- mid)${v}"
printf '%s\0' "$r"
typeset -p v i
print -r -- comparison-complete
)
integer matrix_status=$?
print -r -- matrix-59-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R zsh
setopt multibyte
v='é😀'
i=0
r="${v}${(j.:.)${(s: :)v}}${v}"
printf '%s\0' "$r"
typeset -p v i
print -r -- comparison-complete
)
integer matrix_status=$?
print -r -- matrix-60-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R zsh
setopt multibyte
v='é😀'
i=0
r=$(< <(print -rn -- "$v"))
printf '%s\0' "$r"
typeset -p v i
print -r -- comparison-complete
)
integer matrix_status=$?
print -r -- matrix-61-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R zsh
setopt multibyte
v='é😀'
i=0
readfile() { REPLY=$(< "$1"); }; readfile =(print -rn -- "$v"); r=$REPLY
printf '%s\0' "$r"
typeset -p v i
print -r -- comparison-complete
)
integer matrix_status=$?
print -r -- matrix-62-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R zsh
setopt multibyte
v='é😀'
i=0
r=$(print -r -- "$v" > >(IFS= read -r line; print -rn -- "$line"))
printf '%s\0' "$r"
typeset -p v i
print -r -- comparison-complete
)
integer matrix_status=$?
print -r -- matrix-63-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R zsh
setopt multibyte
v='é😀'
i=0
r="xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx${v}yyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyy$((++i))zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz"
printf '%s\0' "$r"
typeset -p v i
print -r -- comparison-complete
)
integer matrix_status=$?
print -r -- matrix-64-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R zsh
setopt multibyte
v='é😀'
i=0
typeset r=xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx=${v}yyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyy
printf '%s\0' "$r"
typeset -p v i
print -r -- comparison-complete
)
integer matrix_status=$?
print -r -- matrix-65-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R zsh
setopt multibyte
v=$'x\0y\203\377z'
i=0
r=prefix${v}suffix
printf '%s\0' "$r"
typeset -p v i
print -r -- comparison-complete
)
integer matrix_status=$?
print -r -- matrix-66-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R zsh
setopt multibyte
v=$'x\0y\203\377z'
i=0
r="prefix${v}suffix"
printf '%s\0' "$r"
typeset -p v i
print -r -- comparison-complete
)
integer matrix_status=$?
print -r -- matrix-67-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R zsh
setopt multibyte
v=$'x\0y\203\377z'
i=0
r=${(qqq)v}
printf '%s\0' "$r"
typeset -p v i
print -r -- comparison-complete
)
integer matrix_status=$?
print -r -- matrix-68-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R zsh
setopt multibyte
v=$'x\0y\203\377z'
i=0
r=${(e)v}
printf '%s\0' "$r"
typeset -p v i
print -r -- comparison-complete
)
integer matrix_status=$?
print -r -- matrix-69-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R zsh
setopt multibyte
v=$'x\0y\203\377z'
i=0
r=${(U)v}
printf '%s\0' "$r"
typeset -p v i
print -r -- comparison-complete
)
integer matrix_status=$?
print -r -- matrix-70-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R zsh
setopt multibyte
v=$'x\0y\203\377z'
i=0
r=${v//x/REPLACED}
printf '%s\0' "$r"
typeset -p v i
print -r -- comparison-complete
)
integer matrix_status=$?
print -r -- matrix-71-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R zsh
setopt multibyte
v=$'x\0y\203\377z'
i=0
r=$((++i))${v}$[i+=2]
printf '%s\0' "$r"
typeset -p v i
print -r -- comparison-complete
)
integer matrix_status=$?
print -r -- matrix-72-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R zsh
setopt multibyte
v=$'x\0y\203\377z'
i=0
r=$(print -rn -- "before${v}after")
printf '%s\0' "$r"
typeset -p v i
print -r -- comparison-complete
)
integer matrix_status=$?
print -r -- matrix-73-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R zsh
setopt multibyte
v=$'x\0y\203\377z'
i=0
r=`print -rn -- "before${v}after"`
printf '%s\0' "$r"
typeset -p v i
print -r -- comparison-complete
)
integer matrix_status=$?
print -r -- matrix-74-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R zsh
setopt multibyte
v=$'x\0y\203\377z'
i=0
typeset r=key=${v}
printf '%s\0' "$r"
typeset -p v i
print -r -- comparison-complete
)
integer matrix_status=$?
print -r -- matrix-75-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R zsh
setopt multibyte
v=$'x\0y\203\377z'
i=0
typeset r="key=${v}"
printf '%s\0' "$r"
typeset -p v i
print -r -- comparison-complete
)
integer matrix_status=$?
print -r -- matrix-76-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R zsh
setopt multibyte
v=$'x\0y\203\377z'
i=0
export r=key=${v}
printf '%s\0' "$r"
typeset -p v i
print -r -- comparison-complete
)
integer matrix_status=$?
print -r -- matrix-77-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R zsh
setopt multibyte
v=$'x\0y\203\377z'
i=0
typeset -a a; a=(before${v}after "key=${v}"); typeset -p a; r=$#a
printf '%s\0' "$r"
typeset -p v i
print -r -- comparison-complete
)
integer matrix_status=$?
print -r -- matrix-78-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R zsh
setopt multibyte
v=$'x\0y\203\377z'
i=0
setopt shwordsplit; typeset -a a; a=(before${v}after); typeset -p a; r=$#a
printf '%s\0' "$r"
typeset -p v i
print -r -- comparison-complete
)
integer matrix_status=$?
print -r -- matrix-79-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R zsh
setopt multibyte
v=$'x\0y\203\377z'
i=0
setopt magic_equal_subst; typeset r=key=${v}
printf '%s\0' "$r"
typeset -p v i
print -r -- comparison-complete
)
integer matrix_status=$?
print -r -- matrix-80-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R zsh
setopt multibyte
v=$'x\0y\203\377z'
i=0
r="${v}$(print -rn -- mid)${v}"
printf '%s\0' "$r"
typeset -p v i
print -r -- comparison-complete
)
integer matrix_status=$?
print -r -- matrix-81-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R zsh
setopt multibyte
v=$'x\0y\203\377z'
i=0
r="${v}${(j.:.)${(s: :)v}}${v}"
printf '%s\0' "$r"
typeset -p v i
print -r -- comparison-complete
)
integer matrix_status=$?
print -r -- matrix-82-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R zsh
setopt multibyte
v=$'x\0y\203\377z'
i=0
r=$(< <(print -rn -- "$v"))
printf '%s\0' "$r"
typeset -p v i
print -r -- comparison-complete
)
integer matrix_status=$?
print -r -- matrix-83-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R zsh
setopt multibyte
v=$'x\0y\203\377z'
i=0
readfile() { REPLY=$(< "$1"); }; readfile =(print -rn -- "$v"); r=$REPLY
printf '%s\0' "$r"
typeset -p v i
print -r -- comparison-complete
)
integer matrix_status=$?
print -r -- matrix-84-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R zsh
setopt multibyte
v=$'x\0y\203\377z'
i=0
r=$(print -r -- "$v" > >(IFS= read -r line; print -rn -- "$line"))
printf '%s\0' "$r"
typeset -p v i
print -r -- comparison-complete
)
integer matrix_status=$?
print -r -- matrix-85-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R zsh
setopt multibyte
v=$'x\0y\203\377z'
i=0
r="xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx${v}yyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyy$((++i))zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz"
printf '%s\0' "$r"
typeset -p v i
print -r -- comparison-complete
)
integer matrix_status=$?
print -r -- matrix-86-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R zsh
setopt multibyte
v=$'x\0y\203\377z'
i=0
typeset r=xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx=${v}yyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyy
printf '%s\0' "$r"
typeset -p v i
print -r -- comparison-complete
)
integer matrix_status=$?
print -r -- matrix-87-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R zsh
setopt multibyte
v='$(print -r -- expanded)'
i=0
r=prefix${v}suffix
printf '%s\0' "$r"
typeset -p v i
print -r -- comparison-complete
)
integer matrix_status=$?
print -r -- matrix-88-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R zsh
setopt multibyte
v='$(print -r -- expanded)'
i=0
r="prefix${v}suffix"
printf '%s\0' "$r"
typeset -p v i
print -r -- comparison-complete
)
integer matrix_status=$?
print -r -- matrix-89-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R zsh
setopt multibyte
v='$(print -r -- expanded)'
i=0
r=${(qqq)v}
printf '%s\0' "$r"
typeset -p v i
print -r -- comparison-complete
)
integer matrix_status=$?
print -r -- matrix-90-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R zsh
setopt multibyte
v='$(print -r -- expanded)'
i=0
r=${(e)v}
printf '%s\0' "$r"
typeset -p v i
print -r -- comparison-complete
)
integer matrix_status=$?
print -r -- matrix-91-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R zsh
setopt multibyte
v='$(print -r -- expanded)'
i=0
r=${(U)v}
printf '%s\0' "$r"
typeset -p v i
print -r -- comparison-complete
)
integer matrix_status=$?
print -r -- matrix-92-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R zsh
setopt multibyte
v='$(print -r -- expanded)'
i=0
r=${v//x/REPLACED}
printf '%s\0' "$r"
typeset -p v i
print -r -- comparison-complete
)
integer matrix_status=$?
print -r -- matrix-93-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R zsh
setopt multibyte
v='$(print -r -- expanded)'
i=0
r=$((++i))${v}$[i+=2]
printf '%s\0' "$r"
typeset -p v i
print -r -- comparison-complete
)
integer matrix_status=$?
print -r -- matrix-94-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R zsh
setopt multibyte
v='$(print -r -- expanded)'
i=0
r=$(print -rn -- "before${v}after")
printf '%s\0' "$r"
typeset -p v i
print -r -- comparison-complete
)
integer matrix_status=$?
print -r -- matrix-95-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R zsh
setopt multibyte
v='$(print -r -- expanded)'
i=0
r=`print -rn -- "before${v}after"`
printf '%s\0' "$r"
typeset -p v i
print -r -- comparison-complete
)
integer matrix_status=$?
print -r -- matrix-96-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R zsh
setopt multibyte
v='$(print -r -- expanded)'
i=0
typeset r=key=${v}
printf '%s\0' "$r"
typeset -p v i
print -r -- comparison-complete
)
integer matrix_status=$?
print -r -- matrix-97-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R zsh
setopt multibyte
v='$(print -r -- expanded)'
i=0
typeset r="key=${v}"
printf '%s\0' "$r"
typeset -p v i
print -r -- comparison-complete
)
integer matrix_status=$?
print -r -- matrix-98-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R zsh
setopt multibyte
v='$(print -r -- expanded)'
i=0
export r=key=${v}
printf '%s\0' "$r"
typeset -p v i
print -r -- comparison-complete
)
integer matrix_status=$?
print -r -- matrix-99-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R zsh
setopt multibyte
v='$(print -r -- expanded)'
i=0
typeset -a a; a=(before${v}after "key=${v}"); typeset -p a; r=$#a
printf '%s\0' "$r"
typeset -p v i
print -r -- comparison-complete
)
integer matrix_status=$?
print -r -- matrix-100-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R zsh
setopt multibyte
v='$(print -r -- expanded)'
i=0
setopt shwordsplit; typeset -a a; a=(before${v}after); typeset -p a; r=$#a
printf '%s\0' "$r"
typeset -p v i
print -r -- comparison-complete
)
integer matrix_status=$?
print -r -- matrix-101-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R zsh
setopt multibyte
v='$(print -r -- expanded)'
i=0
setopt magic_equal_subst; typeset r=key=${v}
printf '%s\0' "$r"
typeset -p v i
print -r -- comparison-complete
)
integer matrix_status=$?
print -r -- matrix-102-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R zsh
setopt multibyte
v='$(print -r -- expanded)'
i=0
r="${v}$(print -rn -- mid)${v}"
printf '%s\0' "$r"
typeset -p v i
print -r -- comparison-complete
)
integer matrix_status=$?
print -r -- matrix-103-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R zsh
setopt multibyte
v='$(print -r -- expanded)'
i=0
r="${v}${(j.:.)${(s: :)v}}${v}"
printf '%s\0' "$r"
typeset -p v i
print -r -- comparison-complete
)
integer matrix_status=$?
print -r -- matrix-104-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R zsh
setopt multibyte
v='$(print -r -- expanded)'
i=0
r=$(< <(print -rn -- "$v"))
printf '%s\0' "$r"
typeset -p v i
print -r -- comparison-complete
)
integer matrix_status=$?
print -r -- matrix-105-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R zsh
setopt multibyte
v='$(print -r -- expanded)'
i=0
readfile() { REPLY=$(< "$1"); }; readfile =(print -rn -- "$v"); r=$REPLY
printf '%s\0' "$r"
typeset -p v i
print -r -- comparison-complete
)
integer matrix_status=$?
print -r -- matrix-106-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R zsh
setopt multibyte
v='$(print -r -- expanded)'
i=0
r=$(print -r -- "$v" > >(IFS= read -r line; print -rn -- "$line"))
printf '%s\0' "$r"
typeset -p v i
print -r -- comparison-complete
)
integer matrix_status=$?
print -r -- matrix-107-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R zsh
setopt multibyte
v='$(print -r -- expanded)'
i=0
r="xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx${v}yyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyy$((++i))zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz"
printf '%s\0' "$r"
typeset -p v i
print -r -- comparison-complete
)
integer matrix_status=$?
print -r -- matrix-108-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R zsh
setopt multibyte
v='$(print -r -- expanded)'
i=0
typeset r=xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx=${v}yyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyy
printf '%s\0' "$r"
typeset -p v i
print -r -- comparison-complete
)
integer matrix_status=$?
print -r -- matrix-109-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R zsh
setopt multibyte
v='${v} `print tick` = <(x)'
i=0
r=prefix${v}suffix
printf '%s\0' "$r"
typeset -p v i
print -r -- comparison-complete
)
integer matrix_status=$?
print -r -- matrix-110-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R zsh
setopt multibyte
v='${v} `print tick` = <(x)'
i=0
r="prefix${v}suffix"
printf '%s\0' "$r"
typeset -p v i
print -r -- comparison-complete
)
integer matrix_status=$?
print -r -- matrix-111-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R zsh
setopt multibyte
v='${v} `print tick` = <(x)'
i=0
r=${(qqq)v}
printf '%s\0' "$r"
typeset -p v i
print -r -- comparison-complete
)
integer matrix_status=$?
print -r -- matrix-112-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R zsh
setopt multibyte
v='${v} `print tick` = <(x)'
i=0
r=${(e)v}
printf '%s\0' "$r"
typeset -p v i
print -r -- comparison-complete
)
integer matrix_status=$?
print -r -- matrix-113-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R zsh
setopt multibyte
v='${v} `print tick` = <(x)'
i=0
r=${(U)v}
printf '%s\0' "$r"
typeset -p v i
print -r -- comparison-complete
)
integer matrix_status=$?
print -r -- matrix-114-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R zsh
setopt multibyte
v='${v} `print tick` = <(x)'
i=0
r=${v//x/REPLACED}
printf '%s\0' "$r"
typeset -p v i
print -r -- comparison-complete
)
integer matrix_status=$?
print -r -- matrix-115-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R zsh
setopt multibyte
v='${v} `print tick` = <(x)'
i=0
r=$((++i))${v}$[i+=2]
printf '%s\0' "$r"
typeset -p v i
print -r -- comparison-complete
)
integer matrix_status=$?
print -r -- matrix-116-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R zsh
setopt multibyte
v='${v} `print tick` = <(x)'
i=0
r=$(print -rn -- "before${v}after")
printf '%s\0' "$r"
typeset -p v i
print -r -- comparison-complete
)
integer matrix_status=$?
print -r -- matrix-117-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R zsh
setopt multibyte
v='${v} `print tick` = <(x)'
i=0
r=`print -rn -- "before${v}after"`
printf '%s\0' "$r"
typeset -p v i
print -r -- comparison-complete
)
integer matrix_status=$?
print -r -- matrix-118-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R zsh
setopt multibyte
v='${v} `print tick` = <(x)'
i=0
typeset r=key=${v}
printf '%s\0' "$r"
typeset -p v i
print -r -- comparison-complete
)
integer matrix_status=$?
print -r -- matrix-119-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R zsh
setopt multibyte
v='${v} `print tick` = <(x)'
i=0
typeset r="key=${v}"
printf '%s\0' "$r"
typeset -p v i
print -r -- comparison-complete
)
integer matrix_status=$?
print -r -- matrix-120-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R zsh
setopt multibyte
v='${v} `print tick` = <(x)'
i=0
export r=key=${v}
printf '%s\0' "$r"
typeset -p v i
print -r -- comparison-complete
)
integer matrix_status=$?
print -r -- matrix-121-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R zsh
setopt multibyte
v='${v} `print tick` = <(x)'
i=0
typeset -a a; a=(before${v}after "key=${v}"); typeset -p a; r=$#a
printf '%s\0' "$r"
typeset -p v i
print -r -- comparison-complete
)
integer matrix_status=$?
print -r -- matrix-122-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R zsh
setopt multibyte
v='${v} `print tick` = <(x)'
i=0
setopt shwordsplit; typeset -a a; a=(before${v}after); typeset -p a; r=$#a
printf '%s\0' "$r"
typeset -p v i
print -r -- comparison-complete
)
integer matrix_status=$?
print -r -- matrix-123-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R zsh
setopt multibyte
v='${v} `print tick` = <(x)'
i=0
setopt magic_equal_subst; typeset r=key=${v}
printf '%s\0' "$r"
typeset -p v i
print -r -- comparison-complete
)
integer matrix_status=$?
print -r -- matrix-124-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R zsh
setopt multibyte
v='${v} `print tick` = <(x)'
i=0
r="${v}$(print -rn -- mid)${v}"
printf '%s\0' "$r"
typeset -p v i
print -r -- comparison-complete
)
integer matrix_status=$?
print -r -- matrix-125-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R zsh
setopt multibyte
v='${v} `print tick` = <(x)'
i=0
r="${v}${(j.:.)${(s: :)v}}${v}"
printf '%s\0' "$r"
typeset -p v i
print -r -- comparison-complete
)
integer matrix_status=$?
print -r -- matrix-126-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R zsh
setopt multibyte
v='${v} `print tick` = <(x)'
i=0
r=$(< <(print -rn -- "$v"))
printf '%s\0' "$r"
typeset -p v i
print -r -- comparison-complete
)
integer matrix_status=$?
print -r -- matrix-127-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R zsh
setopt multibyte
v='${v} `print tick` = <(x)'
i=0
readfile() { REPLY=$(< "$1"); }; readfile =(print -rn -- "$v"); r=$REPLY
printf '%s\0' "$r"
typeset -p v i
print -r -- comparison-complete
)
integer matrix_status=$?
print -r -- matrix-128-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R zsh
setopt multibyte
v='${v} `print tick` = <(x)'
i=0
r=$(print -r -- "$v" > >(IFS= read -r line; print -rn -- "$line"))
printf '%s\0' "$r"
typeset -p v i
print -r -- comparison-complete
)
integer matrix_status=$?
print -r -- matrix-129-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R zsh
setopt multibyte
v='${v} `print tick` = <(x)'
i=0
r="xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx${v}yyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyy$((++i))zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz"
printf '%s\0' "$r"
typeset -p v i
print -r -- comparison-complete
)
integer matrix_status=$?
print -r -- matrix-130-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R zsh
setopt multibyte
v='${v} `print tick` = <(x)'
i=0
typeset r=xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx=${v}yyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyy
printf '%s\0' "$r"
typeset -p v i
print -r -- comparison-complete
)
integer matrix_status=$?
print -r -- matrix-131-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R zsh
setopt multibyte
v=$'\000\001\002\003\004\005\006\007\010\011\012\013\014\015\016\017\020\021\022\023\024\025\026\027\030\031\032\033\034\035\036\037\040\041\042\043\044\045\046\047\050\051\052\053\054\055\056\057\060\061\062\063\064\065\066\067\070\071\072\073\074\075\076\077\100\101\102\103\104\105\106\107\110\111\112\113\114\115\116\117\120\121\122\123\124\125\126\127\130\131\132\133\134\135\136\137\140\141\142\143\144\145\146\147\150\151\152\153\154\155\156\157\160\161\162\163\164\165\166\167\170\171\172\173\174\175\176\177\200\201\202\203\204\205\206\207\210\211\212\213\214\215\216\217\220\221\222\223\224\225\226\227\230\231\232\233\234\235\236\237\240\241\242\243\244\245\246\247\250\251\252\253\254\255\256\257\260\261\262\263\264\265\266\267\270\271\272\273\274\275\276\277\300\301\302\303\304\305\306\307\310\311\312\313\314\315\316\317\320\321\322\323\324\325\326\327\330\331\332\333\334\335\336\337\340\341\342\343\344\345\346\347\350\351\352\353\354\355\356\357\360\361\362\363\364\365\366\367\370\371\372\373\374\375\376\377'
i=0
r=prefix${v}suffix
printf '%s\0' "$r"
typeset -p v i
print -r -- comparison-complete
)
integer matrix_status=$?
print -r -- matrix-132-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R zsh
setopt multibyte
v=$'\000\001\002\003\004\005\006\007\010\011\012\013\014\015\016\017\020\021\022\023\024\025\026\027\030\031\032\033\034\035\036\037\040\041\042\043\044\045\046\047\050\051\052\053\054\055\056\057\060\061\062\063\064\065\066\067\070\071\072\073\074\075\076\077\100\101\102\103\104\105\106\107\110\111\112\113\114\115\116\117\120\121\122\123\124\125\126\127\130\131\132\133\134\135\136\137\140\141\142\143\144\145\146\147\150\151\152\153\154\155\156\157\160\161\162\163\164\165\166\167\170\171\172\173\174\175\176\177\200\201\202\203\204\205\206\207\210\211\212\213\214\215\216\217\220\221\222\223\224\225\226\227\230\231\232\233\234\235\236\237\240\241\242\243\244\245\246\247\250\251\252\253\254\255\256\257\260\261\262\263\264\265\266\267\270\271\272\273\274\275\276\277\300\301\302\303\304\305\306\307\310\311\312\313\314\315\316\317\320\321\322\323\324\325\326\327\330\331\332\333\334\335\336\337\340\341\342\343\344\345\346\347\350\351\352\353\354\355\356\357\360\361\362\363\364\365\366\367\370\371\372\373\374\375\376\377'
i=0
r="prefix${v}suffix"
printf '%s\0' "$r"
typeset -p v i
print -r -- comparison-complete
)
integer matrix_status=$?
print -r -- matrix-133-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R zsh
setopt multibyte
v=$'\000\001\002\003\004\005\006\007\010\011\012\013\014\015\016\017\020\021\022\023\024\025\026\027\030\031\032\033\034\035\036\037\040\041\042\043\044\045\046\047\050\051\052\053\054\055\056\057\060\061\062\063\064\065\066\067\070\071\072\073\074\075\076\077\100\101\102\103\104\105\106\107\110\111\112\113\114\115\116\117\120\121\122\123\124\125\126\127\130\131\132\133\134\135\136\137\140\141\142\143\144\145\146\147\150\151\152\153\154\155\156\157\160\161\162\163\164\165\166\167\170\171\172\173\174\175\176\177\200\201\202\203\204\205\206\207\210\211\212\213\214\215\216\217\220\221\222\223\224\225\226\227\230\231\232\233\234\235\236\237\240\241\242\243\244\245\246\247\250\251\252\253\254\255\256\257\260\261\262\263\264\265\266\267\270\271\272\273\274\275\276\277\300\301\302\303\304\305\306\307\310\311\312\313\314\315\316\317\320\321\322\323\324\325\326\327\330\331\332\333\334\335\336\337\340\341\342\343\344\345\346\347\350\351\352\353\354\355\356\357\360\361\362\363\364\365\366\367\370\371\372\373\374\375\376\377'
i=0
r=${(qqq)v}
printf '%s\0' "$r"
typeset -p v i
print -r -- comparison-complete
)
integer matrix_status=$?
print -r -- matrix-134-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R zsh
setopt multibyte
v=$'\000\001\002\003\004\005\006\007\010\011\012\013\014\015\016\017\020\021\022\023\024\025\026\027\030\031\032\033\034\035\036\037\040\041\042\043\044\045\046\047\050\051\052\053\054\055\056\057\060\061\062\063\064\065\066\067\070\071\072\073\074\075\076\077\100\101\102\103\104\105\106\107\110\111\112\113\114\115\116\117\120\121\122\123\124\125\126\127\130\131\132\133\134\135\136\137\140\141\142\143\144\145\146\147\150\151\152\153\154\155\156\157\160\161\162\163\164\165\166\167\170\171\172\173\174\175\176\177\200\201\202\203\204\205\206\207\210\211\212\213\214\215\216\217\220\221\222\223\224\225\226\227\230\231\232\233\234\235\236\237\240\241\242\243\244\245\246\247\250\251\252\253\254\255\256\257\260\261\262\263\264\265\266\267\270\271\272\273\274\275\276\277\300\301\302\303\304\305\306\307\310\311\312\313\314\315\316\317\320\321\322\323\324\325\326\327\330\331\332\333\334\335\336\337\340\341\342\343\344\345\346\347\350\351\352\353\354\355\356\357\360\361\362\363\364\365\366\367\370\371\372\373\374\375\376\377'
i=0
r=${(e)v}
printf '%s\0' "$r"
typeset -p v i
print -r -- comparison-complete
)
integer matrix_status=$?
print -r -- matrix-135-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R zsh
setopt multibyte
v=$'\000\001\002\003\004\005\006\007\010\011\012\013\014\015\016\017\020\021\022\023\024\025\026\027\030\031\032\033\034\035\036\037\040\041\042\043\044\045\046\047\050\051\052\053\054\055\056\057\060\061\062\063\064\065\066\067\070\071\072\073\074\075\076\077\100\101\102\103\104\105\106\107\110\111\112\113\114\115\116\117\120\121\122\123\124\125\126\127\130\131\132\133\134\135\136\137\140\141\142\143\144\145\146\147\150\151\152\153\154\155\156\157\160\161\162\163\164\165\166\167\170\171\172\173\174\175\176\177\200\201\202\203\204\205\206\207\210\211\212\213\214\215\216\217\220\221\222\223\224\225\226\227\230\231\232\233\234\235\236\237\240\241\242\243\244\245\246\247\250\251\252\253\254\255\256\257\260\261\262\263\264\265\266\267\270\271\272\273\274\275\276\277\300\301\302\303\304\305\306\307\310\311\312\313\314\315\316\317\320\321\322\323\324\325\326\327\330\331\332\333\334\335\336\337\340\341\342\343\344\345\346\347\350\351\352\353\354\355\356\357\360\361\362\363\364\365\366\367\370\371\372\373\374\375\376\377'
i=0
r=${(U)v}
printf '%s\0' "$r"
typeset -p v i
print -r -- comparison-complete
)
integer matrix_status=$?
print -r -- matrix-136-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R zsh
setopt multibyte
v=$'\000\001\002\003\004\005\006\007\010\011\012\013\014\015\016\017\020\021\022\023\024\025\026\027\030\031\032\033\034\035\036\037\040\041\042\043\044\045\046\047\050\051\052\053\054\055\056\057\060\061\062\063\064\065\066\067\070\071\072\073\074\075\076\077\100\101\102\103\104\105\106\107\110\111\112\113\114\115\116\117\120\121\122\123\124\125\126\127\130\131\132\133\134\135\136\137\140\141\142\143\144\145\146\147\150\151\152\153\154\155\156\157\160\161\162\163\164\165\166\167\170\171\172\173\174\175\176\177\200\201\202\203\204\205\206\207\210\211\212\213\214\215\216\217\220\221\222\223\224\225\226\227\230\231\232\233\234\235\236\237\240\241\242\243\244\245\246\247\250\251\252\253\254\255\256\257\260\261\262\263\264\265\266\267\270\271\272\273\274\275\276\277\300\301\302\303\304\305\306\307\310\311\312\313\314\315\316\317\320\321\322\323\324\325\326\327\330\331\332\333\334\335\336\337\340\341\342\343\344\345\346\347\350\351\352\353\354\355\356\357\360\361\362\363\364\365\366\367\370\371\372\373\374\375\376\377'
i=0
r=${v//x/REPLACED}
printf '%s\0' "$r"
typeset -p v i
print -r -- comparison-complete
)
integer matrix_status=$?
print -r -- matrix-137-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R zsh
setopt multibyte
v=$'\000\001\002\003\004\005\006\007\010\011\012\013\014\015\016\017\020\021\022\023\024\025\026\027\030\031\032\033\034\035\036\037\040\041\042\043\044\045\046\047\050\051\052\053\054\055\056\057\060\061\062\063\064\065\066\067\070\071\072\073\074\075\076\077\100\101\102\103\104\105\106\107\110\111\112\113\114\115\116\117\120\121\122\123\124\125\126\127\130\131\132\133\134\135\136\137\140\141\142\143\144\145\146\147\150\151\152\153\154\155\156\157\160\161\162\163\164\165\166\167\170\171\172\173\174\175\176\177\200\201\202\203\204\205\206\207\210\211\212\213\214\215\216\217\220\221\222\223\224\225\226\227\230\231\232\233\234\235\236\237\240\241\242\243\244\245\246\247\250\251\252\253\254\255\256\257\260\261\262\263\264\265\266\267\270\271\272\273\274\275\276\277\300\301\302\303\304\305\306\307\310\311\312\313\314\315\316\317\320\321\322\323\324\325\326\327\330\331\332\333\334\335\336\337\340\341\342\343\344\345\346\347\350\351\352\353\354\355\356\357\360\361\362\363\364\365\366\367\370\371\372\373\374\375\376\377'
i=0
r=$((++i))${v}$[i+=2]
printf '%s\0' "$r"
typeset -p v i
print -r -- comparison-complete
)
integer matrix_status=$?
print -r -- matrix-138-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R zsh
setopt multibyte
v=$'\000\001\002\003\004\005\006\007\010\011\012\013\014\015\016\017\020\021\022\023\024\025\026\027\030\031\032\033\034\035\036\037\040\041\042\043\044\045\046\047\050\051\052\053\054\055\056\057\060\061\062\063\064\065\066\067\070\071\072\073\074\075\076\077\100\101\102\103\104\105\106\107\110\111\112\113\114\115\116\117\120\121\122\123\124\125\126\127\130\131\132\133\134\135\136\137\140\141\142\143\144\145\146\147\150\151\152\153\154\155\156\157\160\161\162\163\164\165\166\167\170\171\172\173\174\175\176\177\200\201\202\203\204\205\206\207\210\211\212\213\214\215\216\217\220\221\222\223\224\225\226\227\230\231\232\233\234\235\236\237\240\241\242\243\244\245\246\247\250\251\252\253\254\255\256\257\260\261\262\263\264\265\266\267\270\271\272\273\274\275\276\277\300\301\302\303\304\305\306\307\310\311\312\313\314\315\316\317\320\321\322\323\324\325\326\327\330\331\332\333\334\335\336\337\340\341\342\343\344\345\346\347\350\351\352\353\354\355\356\357\360\361\362\363\364\365\366\367\370\371\372\373\374\375\376\377'
i=0
r=$(print -rn -- "before${v}after")
printf '%s\0' "$r"
typeset -p v i
print -r -- comparison-complete
)
integer matrix_status=$?
print -r -- matrix-139-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R zsh
setopt multibyte
v=$'\000\001\002\003\004\005\006\007\010\011\012\013\014\015\016\017\020\021\022\023\024\025\026\027\030\031\032\033\034\035\036\037\040\041\042\043\044\045\046\047\050\051\052\053\054\055\056\057\060\061\062\063\064\065\066\067\070\071\072\073\074\075\076\077\100\101\102\103\104\105\106\107\110\111\112\113\114\115\116\117\120\121\122\123\124\125\126\127\130\131\132\133\134\135\136\137\140\141\142\143\144\145\146\147\150\151\152\153\154\155\156\157\160\161\162\163\164\165\166\167\170\171\172\173\174\175\176\177\200\201\202\203\204\205\206\207\210\211\212\213\214\215\216\217\220\221\222\223\224\225\226\227\230\231\232\233\234\235\236\237\240\241\242\243\244\245\246\247\250\251\252\253\254\255\256\257\260\261\262\263\264\265\266\267\270\271\272\273\274\275\276\277\300\301\302\303\304\305\306\307\310\311\312\313\314\315\316\317\320\321\322\323\324\325\326\327\330\331\332\333\334\335\336\337\340\341\342\343\344\345\346\347\350\351\352\353\354\355\356\357\360\361\362\363\364\365\366\367\370\371\372\373\374\375\376\377'
i=0
r=`print -rn -- "before${v}after"`
printf '%s\0' "$r"
typeset -p v i
print -r -- comparison-complete
)
integer matrix_status=$?
print -r -- matrix-140-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R zsh
setopt multibyte
v=$'\000\001\002\003\004\005\006\007\010\011\012\013\014\015\016\017\020\021\022\023\024\025\026\027\030\031\032\033\034\035\036\037\040\041\042\043\044\045\046\047\050\051\052\053\054\055\056\057\060\061\062\063\064\065\066\067\070\071\072\073\074\075\076\077\100\101\102\103\104\105\106\107\110\111\112\113\114\115\116\117\120\121\122\123\124\125\126\127\130\131\132\133\134\135\136\137\140\141\142\143\144\145\146\147\150\151\152\153\154\155\156\157\160\161\162\163\164\165\166\167\170\171\172\173\174\175\176\177\200\201\202\203\204\205\206\207\210\211\212\213\214\215\216\217\220\221\222\223\224\225\226\227\230\231\232\233\234\235\236\237\240\241\242\243\244\245\246\247\250\251\252\253\254\255\256\257\260\261\262\263\264\265\266\267\270\271\272\273\274\275\276\277\300\301\302\303\304\305\306\307\310\311\312\313\314\315\316\317\320\321\322\323\324\325\326\327\330\331\332\333\334\335\336\337\340\341\342\343\344\345\346\347\350\351\352\353\354\355\356\357\360\361\362\363\364\365\366\367\370\371\372\373\374\375\376\377'
i=0
typeset r=key=${v}
printf '%s\0' "$r"
typeset -p v i
print -r -- comparison-complete
)
integer matrix_status=$?
print -r -- matrix-141-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R zsh
setopt multibyte
v=$'\000\001\002\003\004\005\006\007\010\011\012\013\014\015\016\017\020\021\022\023\024\025\026\027\030\031\032\033\034\035\036\037\040\041\042\043\044\045\046\047\050\051\052\053\054\055\056\057\060\061\062\063\064\065\066\067\070\071\072\073\074\075\076\077\100\101\102\103\104\105\106\107\110\111\112\113\114\115\116\117\120\121\122\123\124\125\126\127\130\131\132\133\134\135\136\137\140\141\142\143\144\145\146\147\150\151\152\153\154\155\156\157\160\161\162\163\164\165\166\167\170\171\172\173\174\175\176\177\200\201\202\203\204\205\206\207\210\211\212\213\214\215\216\217\220\221\222\223\224\225\226\227\230\231\232\233\234\235\236\237\240\241\242\243\244\245\246\247\250\251\252\253\254\255\256\257\260\261\262\263\264\265\266\267\270\271\272\273\274\275\276\277\300\301\302\303\304\305\306\307\310\311\312\313\314\315\316\317\320\321\322\323\324\325\326\327\330\331\332\333\334\335\336\337\340\341\342\343\344\345\346\347\350\351\352\353\354\355\356\357\360\361\362\363\364\365\366\367\370\371\372\373\374\375\376\377'
i=0
typeset r="key=${v}"
printf '%s\0' "$r"
typeset -p v i
print -r -- comparison-complete
)
integer matrix_status=$?
print -r -- matrix-142-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R zsh
setopt multibyte
v=$'\000\001\002\003\004\005\006\007\010\011\012\013\014\015\016\017\020\021\022\023\024\025\026\027\030\031\032\033\034\035\036\037\040\041\042\043\044\045\046\047\050\051\052\053\054\055\056\057\060\061\062\063\064\065\066\067\070\071\072\073\074\075\076\077\100\101\102\103\104\105\106\107\110\111\112\113\114\115\116\117\120\121\122\123\124\125\126\127\130\131\132\133\134\135\136\137\140\141\142\143\144\145\146\147\150\151\152\153\154\155\156\157\160\161\162\163\164\165\166\167\170\171\172\173\174\175\176\177\200\201\202\203\204\205\206\207\210\211\212\213\214\215\216\217\220\221\222\223\224\225\226\227\230\231\232\233\234\235\236\237\240\241\242\243\244\245\246\247\250\251\252\253\254\255\256\257\260\261\262\263\264\265\266\267\270\271\272\273\274\275\276\277\300\301\302\303\304\305\306\307\310\311\312\313\314\315\316\317\320\321\322\323\324\325\326\327\330\331\332\333\334\335\336\337\340\341\342\343\344\345\346\347\350\351\352\353\354\355\356\357\360\361\362\363\364\365\366\367\370\371\372\373\374\375\376\377'
i=0
export r=key=${v}
printf '%s\0' "$r"
typeset -p v i
print -r -- comparison-complete
)
integer matrix_status=$?
print -r -- matrix-143-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R zsh
setopt multibyte
v=$'\000\001\002\003\004\005\006\007\010\011\012\013\014\015\016\017\020\021\022\023\024\025\026\027\030\031\032\033\034\035\036\037\040\041\042\043\044\045\046\047\050\051\052\053\054\055\056\057\060\061\062\063\064\065\066\067\070\071\072\073\074\075\076\077\100\101\102\103\104\105\106\107\110\111\112\113\114\115\116\117\120\121\122\123\124\125\126\127\130\131\132\133\134\135\136\137\140\141\142\143\144\145\146\147\150\151\152\153\154\155\156\157\160\161\162\163\164\165\166\167\170\171\172\173\174\175\176\177\200\201\202\203\204\205\206\207\210\211\212\213\214\215\216\217\220\221\222\223\224\225\226\227\230\231\232\233\234\235\236\237\240\241\242\243\244\245\246\247\250\251\252\253\254\255\256\257\260\261\262\263\264\265\266\267\270\271\272\273\274\275\276\277\300\301\302\303\304\305\306\307\310\311\312\313\314\315\316\317\320\321\322\323\324\325\326\327\330\331\332\333\334\335\336\337\340\341\342\343\344\345\346\347\350\351\352\353\354\355\356\357\360\361\362\363\364\365\366\367\370\371\372\373\374\375\376\377'
i=0
typeset -a a; a=(before${v}after "key=${v}"); typeset -p a; r=$#a
printf '%s\0' "$r"
typeset -p v i
print -r -- comparison-complete
)
integer matrix_status=$?
print -r -- matrix-144-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R zsh
setopt multibyte
v=$'\000\001\002\003\004\005\006\007\010\011\012\013\014\015\016\017\020\021\022\023\024\025\026\027\030\031\032\033\034\035\036\037\040\041\042\043\044\045\046\047\050\051\052\053\054\055\056\057\060\061\062\063\064\065\066\067\070\071\072\073\074\075\076\077\100\101\102\103\104\105\106\107\110\111\112\113\114\115\116\117\120\121\122\123\124\125\126\127\130\131\132\133\134\135\136\137\140\141\142\143\144\145\146\147\150\151\152\153\154\155\156\157\160\161\162\163\164\165\166\167\170\171\172\173\174\175\176\177\200\201\202\203\204\205\206\207\210\211\212\213\214\215\216\217\220\221\222\223\224\225\226\227\230\231\232\233\234\235\236\237\240\241\242\243\244\245\246\247\250\251\252\253\254\255\256\257\260\261\262\263\264\265\266\267\270\271\272\273\274\275\276\277\300\301\302\303\304\305\306\307\310\311\312\313\314\315\316\317\320\321\322\323\324\325\326\327\330\331\332\333\334\335\336\337\340\341\342\343\344\345\346\347\350\351\352\353\354\355\356\357\360\361\362\363\364\365\366\367\370\371\372\373\374\375\376\377'
i=0
setopt shwordsplit; typeset -a a; a=(before${v}after); typeset -p a; r=$#a
printf '%s\0' "$r"
typeset -p v i
print -r -- comparison-complete
)
integer matrix_status=$?
print -r -- matrix-145-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R zsh
setopt multibyte
v=$'\000\001\002\003\004\005\006\007\010\011\012\013\014\015\016\017\020\021\022\023\024\025\026\027\030\031\032\033\034\035\036\037\040\041\042\043\044\045\046\047\050\051\052\053\054\055\056\057\060\061\062\063\064\065\066\067\070\071\072\073\074\075\076\077\100\101\102\103\104\105\106\107\110\111\112\113\114\115\116\117\120\121\122\123\124\125\126\127\130\131\132\133\134\135\136\137\140\141\142\143\144\145\146\147\150\151\152\153\154\155\156\157\160\161\162\163\164\165\166\167\170\171\172\173\174\175\176\177\200\201\202\203\204\205\206\207\210\211\212\213\214\215\216\217\220\221\222\223\224\225\226\227\230\231\232\233\234\235\236\237\240\241\242\243\244\245\246\247\250\251\252\253\254\255\256\257\260\261\262\263\264\265\266\267\270\271\272\273\274\275\276\277\300\301\302\303\304\305\306\307\310\311\312\313\314\315\316\317\320\321\322\323\324\325\326\327\330\331\332\333\334\335\336\337\340\341\342\343\344\345\346\347\350\351\352\353\354\355\356\357\360\361\362\363\364\365\366\367\370\371\372\373\374\375\376\377'
i=0
setopt magic_equal_subst; typeset r=key=${v}
printf '%s\0' "$r"
typeset -p v i
print -r -- comparison-complete
)
integer matrix_status=$?
print -r -- matrix-146-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R zsh
setopt multibyte
v=$'\000\001\002\003\004\005\006\007\010\011\012\013\014\015\016\017\020\021\022\023\024\025\026\027\030\031\032\033\034\035\036\037\040\041\042\043\044\045\046\047\050\051\052\053\054\055\056\057\060\061\062\063\064\065\066\067\070\071\072\073\074\075\076\077\100\101\102\103\104\105\106\107\110\111\112\113\114\115\116\117\120\121\122\123\124\125\126\127\130\131\132\133\134\135\136\137\140\141\142\143\144\145\146\147\150\151\152\153\154\155\156\157\160\161\162\163\164\165\166\167\170\171\172\173\174\175\176\177\200\201\202\203\204\205\206\207\210\211\212\213\214\215\216\217\220\221\222\223\224\225\226\227\230\231\232\233\234\235\236\237\240\241\242\243\244\245\246\247\250\251\252\253\254\255\256\257\260\261\262\263\264\265\266\267\270\271\272\273\274\275\276\277\300\301\302\303\304\305\306\307\310\311\312\313\314\315\316\317\320\321\322\323\324\325\326\327\330\331\332\333\334\335\336\337\340\341\342\343\344\345\346\347\350\351\352\353\354\355\356\357\360\361\362\363\364\365\366\367\370\371\372\373\374\375\376\377'
i=0
r="${v}$(print -rn -- mid)${v}"
printf '%s\0' "$r"
typeset -p v i
print -r -- comparison-complete
)
integer matrix_status=$?
print -r -- matrix-147-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R zsh
setopt multibyte
v=$'\000\001\002\003\004\005\006\007\010\011\012\013\014\015\016\017\020\021\022\023\024\025\026\027\030\031\032\033\034\035\036\037\040\041\042\043\044\045\046\047\050\051\052\053\054\055\056\057\060\061\062\063\064\065\066\067\070\071\072\073\074\075\076\077\100\101\102\103\104\105\106\107\110\111\112\113\114\115\116\117\120\121\122\123\124\125\126\127\130\131\132\133\134\135\136\137\140\141\142\143\144\145\146\147\150\151\152\153\154\155\156\157\160\161\162\163\164\165\166\167\170\171\172\173\174\175\176\177\200\201\202\203\204\205\206\207\210\211\212\213\214\215\216\217\220\221\222\223\224\225\226\227\230\231\232\233\234\235\236\237\240\241\242\243\244\245\246\247\250\251\252\253\254\255\256\257\260\261\262\263\264\265\266\267\270\271\272\273\274\275\276\277\300\301\302\303\304\305\306\307\310\311\312\313\314\315\316\317\320\321\322\323\324\325\326\327\330\331\332\333\334\335\336\337\340\341\342\343\344\345\346\347\350\351\352\353\354\355\356\357\360\361\362\363\364\365\366\367\370\371\372\373\374\375\376\377'
i=0
r="${v}${(j.:.)${(s: :)v}}${v}"
printf '%s\0' "$r"
typeset -p v i
print -r -- comparison-complete
)
integer matrix_status=$?
print -r -- matrix-148-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R zsh
setopt multibyte
v=$'\000\001\002\003\004\005\006\007\010\011\012\013\014\015\016\017\020\021\022\023\024\025\026\027\030\031\032\033\034\035\036\037\040\041\042\043\044\045\046\047\050\051\052\053\054\055\056\057\060\061\062\063\064\065\066\067\070\071\072\073\074\075\076\077\100\101\102\103\104\105\106\107\110\111\112\113\114\115\116\117\120\121\122\123\124\125\126\127\130\131\132\133\134\135\136\137\140\141\142\143\144\145\146\147\150\151\152\153\154\155\156\157\160\161\162\163\164\165\166\167\170\171\172\173\174\175\176\177\200\201\202\203\204\205\206\207\210\211\212\213\214\215\216\217\220\221\222\223\224\225\226\227\230\231\232\233\234\235\236\237\240\241\242\243\244\245\246\247\250\251\252\253\254\255\256\257\260\261\262\263\264\265\266\267\270\271\272\273\274\275\276\277\300\301\302\303\304\305\306\307\310\311\312\313\314\315\316\317\320\321\322\323\324\325\326\327\330\331\332\333\334\335\336\337\340\341\342\343\344\345\346\347\350\351\352\353\354\355\356\357\360\361\362\363\364\365\366\367\370\371\372\373\374\375\376\377'
i=0
r=$(< <(print -rn -- "$v"))
printf '%s\0' "$r"
typeset -p v i
print -r -- comparison-complete
)
integer matrix_status=$?
print -r -- matrix-149-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R zsh
setopt multibyte
v=$'\000\001\002\003\004\005\006\007\010\011\012\013\014\015\016\017\020\021\022\023\024\025\026\027\030\031\032\033\034\035\036\037\040\041\042\043\044\045\046\047\050\051\052\053\054\055\056\057\060\061\062\063\064\065\066\067\070\071\072\073\074\075\076\077\100\101\102\103\104\105\106\107\110\111\112\113\114\115\116\117\120\121\122\123\124\125\126\127\130\131\132\133\134\135\136\137\140\141\142\143\144\145\146\147\150\151\152\153\154\155\156\157\160\161\162\163\164\165\166\167\170\171\172\173\174\175\176\177\200\201\202\203\204\205\206\207\210\211\212\213\214\215\216\217\220\221\222\223\224\225\226\227\230\231\232\233\234\235\236\237\240\241\242\243\244\245\246\247\250\251\252\253\254\255\256\257\260\261\262\263\264\265\266\267\270\271\272\273\274\275\276\277\300\301\302\303\304\305\306\307\310\311\312\313\314\315\316\317\320\321\322\323\324\325\326\327\330\331\332\333\334\335\336\337\340\341\342\343\344\345\346\347\350\351\352\353\354\355\356\357\360\361\362\363\364\365\366\367\370\371\372\373\374\375\376\377'
i=0
readfile() { REPLY=$(< "$1"); }; readfile =(print -rn -- "$v"); r=$REPLY
printf '%s\0' "$r"
typeset -p v i
print -r -- comparison-complete
)
integer matrix_status=$?
print -r -- matrix-150-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R zsh
setopt multibyte
v=$'\000\001\002\003\004\005\006\007\010\011\012\013\014\015\016\017\020\021\022\023\024\025\026\027\030\031\032\033\034\035\036\037\040\041\042\043\044\045\046\047\050\051\052\053\054\055\056\057\060\061\062\063\064\065\066\067\070\071\072\073\074\075\076\077\100\101\102\103\104\105\106\107\110\111\112\113\114\115\116\117\120\121\122\123\124\125\126\127\130\131\132\133\134\135\136\137\140\141\142\143\144\145\146\147\150\151\152\153\154\155\156\157\160\161\162\163\164\165\166\167\170\171\172\173\174\175\176\177\200\201\202\203\204\205\206\207\210\211\212\213\214\215\216\217\220\221\222\223\224\225\226\227\230\231\232\233\234\235\236\237\240\241\242\243\244\245\246\247\250\251\252\253\254\255\256\257\260\261\262\263\264\265\266\267\270\271\272\273\274\275\276\277\300\301\302\303\304\305\306\307\310\311\312\313\314\315\316\317\320\321\322\323\324\325\326\327\330\331\332\333\334\335\336\337\340\341\342\343\344\345\346\347\350\351\352\353\354\355\356\357\360\361\362\363\364\365\366\367\370\371\372\373\374\375\376\377'
i=0
r=$(print -r -- "$v" > >(IFS= read -r line; print -rn -- "$line"))
printf '%s\0' "$r"
typeset -p v i
print -r -- comparison-complete
)
integer matrix_status=$?
print -r -- matrix-151-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R zsh
setopt multibyte
v=$'\000\001\002\003\004\005\006\007\010\011\012\013\014\015\016\017\020\021\022\023\024\025\026\027\030\031\032\033\034\035\036\037\040\041\042\043\044\045\046\047\050\051\052\053\054\055\056\057\060\061\062\063\064\065\066\067\070\071\072\073\074\075\076\077\100\101\102\103\104\105\106\107\110\111\112\113\114\115\116\117\120\121\122\123\124\125\126\127\130\131\132\133\134\135\136\137\140\141\142\143\144\145\146\147\150\151\152\153\154\155\156\157\160\161\162\163\164\165\166\167\170\171\172\173\174\175\176\177\200\201\202\203\204\205\206\207\210\211\212\213\214\215\216\217\220\221\222\223\224\225\226\227\230\231\232\233\234\235\236\237\240\241\242\243\244\245\246\247\250\251\252\253\254\255\256\257\260\261\262\263\264\265\266\267\270\271\272\273\274\275\276\277\300\301\302\303\304\305\306\307\310\311\312\313\314\315\316\317\320\321\322\323\324\325\326\327\330\331\332\333\334\335\336\337\340\341\342\343\344\345\346\347\350\351\352\353\354\355\356\357\360\361\362\363\364\365\366\367\370\371\372\373\374\375\376\377'
i=0
r="xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx${v}yyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyy$((++i))zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz"
printf '%s\0' "$r"
typeset -p v i
print -r -- comparison-complete
)
integer matrix_status=$?
print -r -- matrix-152-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R zsh
setopt multibyte
v=$'\000\001\002\003\004\005\006\007\010\011\012\013\014\015\016\017\020\021\022\023\024\025\026\027\030\031\032\033\034\035\036\037\040\041\042\043\044\045\046\047\050\051\052\053\054\055\056\057\060\061\062\063\064\065\066\067\070\071\072\073\074\075\076\077\100\101\102\103\104\105\106\107\110\111\112\113\114\115\116\117\120\121\122\123\124\125\126\127\130\131\132\133\134\135\136\137\140\141\142\143\144\145\146\147\150\151\152\153\154\155\156\157\160\161\162\163\164\165\166\167\170\171\172\173\174\175\176\177\200\201\202\203\204\205\206\207\210\211\212\213\214\215\216\217\220\221\222\223\224\225\226\227\230\231\232\233\234\235\236\237\240\241\242\243\244\245\246\247\250\251\252\253\254\255\256\257\260\261\262\263\264\265\266\267\270\271\272\273\274\275\276\277\300\301\302\303\304\305\306\307\310\311\312\313\314\315\316\317\320\321\322\323\324\325\326\327\330\331\332\333\334\335\336\337\340\341\342\343\344\345\346\347\350\351\352\353\354\355\356\357\360\361\362\363\364\365\366\367\370\371\372\373\374\375\376\377'
i=0
typeset r=xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx=${v}yyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyy
printf '%s\0' "$r"
typeset -p v i
print -r -- comparison-complete
)
integer matrix_status=$?
print -r -- matrix-153-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R zsh
setopt multibyte
v='xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx'
i=0
r=prefix${v}suffix
printf '%s\0' "$r"
typeset -p v i
print -r -- comparison-complete
)
integer matrix_status=$?
print -r -- matrix-154-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R zsh
setopt multibyte
v='xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx'
i=0
r="prefix${v}suffix"
printf '%s\0' "$r"
typeset -p v i
print -r -- comparison-complete
)
integer matrix_status=$?
print -r -- matrix-155-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R zsh
setopt multibyte
v='xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx'
i=0
r=${(qqq)v}
printf '%s\0' "$r"
typeset -p v i
print -r -- comparison-complete
)
integer matrix_status=$?
print -r -- matrix-156-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R zsh
setopt multibyte
v='xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx'
i=0
r=${(e)v}
printf '%s\0' "$r"
typeset -p v i
print -r -- comparison-complete
)
integer matrix_status=$?
print -r -- matrix-157-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R zsh
setopt multibyte
v='xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx'
i=0
r=${(U)v}
printf '%s\0' "$r"
typeset -p v i
print -r -- comparison-complete
)
integer matrix_status=$?
print -r -- matrix-158-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R zsh
setopt multibyte
v='xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx'
i=0
r=${v//x/REPLACED}
printf '%s\0' "$r"
typeset -p v i
print -r -- comparison-complete
)
integer matrix_status=$?
print -r -- matrix-159-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R zsh
setopt multibyte
v='xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx'
i=0
r=$((++i))${v}$[i+=2]
printf '%s\0' "$r"
typeset -p v i
print -r -- comparison-complete
)
integer matrix_status=$?
print -r -- matrix-160-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R zsh
setopt multibyte
v='xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx'
i=0
r=$(print -rn -- "before${v}after")
printf '%s\0' "$r"
typeset -p v i
print -r -- comparison-complete
)
integer matrix_status=$?
print -r -- matrix-161-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R zsh
setopt multibyte
v='xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx'
i=0
r=`print -rn -- "before${v}after"`
printf '%s\0' "$r"
typeset -p v i
print -r -- comparison-complete
)
integer matrix_status=$?
print -r -- matrix-162-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R zsh
setopt multibyte
v='xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx'
i=0
typeset r=key=${v}
printf '%s\0' "$r"
typeset -p v i
print -r -- comparison-complete
)
integer matrix_status=$?
print -r -- matrix-163-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R zsh
setopt multibyte
v='xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx'
i=0
typeset r="key=${v}"
printf '%s\0' "$r"
typeset -p v i
print -r -- comparison-complete
)
integer matrix_status=$?
print -r -- matrix-164-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R zsh
setopt multibyte
v='xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx'
i=0
export r=key=${v}
printf '%s\0' "$r"
typeset -p v i
print -r -- comparison-complete
)
integer matrix_status=$?
print -r -- matrix-165-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R zsh
setopt multibyte
v='xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx'
i=0
typeset -a a; a=(before${v}after "key=${v}"); typeset -p a; r=$#a
printf '%s\0' "$r"
typeset -p v i
print -r -- comparison-complete
)
integer matrix_status=$?
print -r -- matrix-166-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R zsh
setopt multibyte
v='xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx'
i=0
setopt shwordsplit; typeset -a a; a=(before${v}after); typeset -p a; r=$#a
printf '%s\0' "$r"
typeset -p v i
print -r -- comparison-complete
)
integer matrix_status=$?
print -r -- matrix-167-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R zsh
setopt multibyte
v='xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx'
i=0
setopt magic_equal_subst; typeset r=key=${v}
printf '%s\0' "$r"
typeset -p v i
print -r -- comparison-complete
)
integer matrix_status=$?
print -r -- matrix-168-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R zsh
setopt multibyte
v='xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx'
i=0
r="${v}$(print -rn -- mid)${v}"
printf '%s\0' "$r"
typeset -p v i
print -r -- comparison-complete
)
integer matrix_status=$?
print -r -- matrix-169-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R zsh
setopt multibyte
v='xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx'
i=0
r="${v}${(j.:.)${(s: :)v}}${v}"
printf '%s\0' "$r"
typeset -p v i
print -r -- comparison-complete
)
integer matrix_status=$?
print -r -- matrix-170-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R zsh
setopt multibyte
v='xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx'
i=0
r=$(< <(print -rn -- "$v"))
printf '%s\0' "$r"
typeset -p v i
print -r -- comparison-complete
)
integer matrix_status=$?
print -r -- matrix-171-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R zsh
setopt multibyte
v='xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx'
i=0
readfile() { REPLY=$(< "$1"); }; readfile =(print -rn -- "$v"); r=$REPLY
printf '%s\0' "$r"
typeset -p v i
print -r -- comparison-complete
)
integer matrix_status=$?
print -r -- matrix-172-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R zsh
setopt multibyte
v='xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx'
i=0
r=$(print -r -- "$v" > >(IFS= read -r line; print -rn -- "$line"))
printf '%s\0' "$r"
typeset -p v i
print -r -- comparison-complete
)
integer matrix_status=$?
print -r -- matrix-173-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R zsh
setopt multibyte
v='xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx'
i=0
r="xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx${v}yyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyy$((++i))zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz"
printf '%s\0' "$r"
typeset -p v i
print -r -- comparison-complete
)
integer matrix_status=$?
print -r -- matrix-174-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R zsh
setopt multibyte
v='xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx'
i=0
typeset r=xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx=${v}yyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyy
printf '%s\0' "$r"
typeset -p v i
print -r -- comparison-complete
)
integer matrix_status=$?
print -r -- matrix-175-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R zsh
setopt multibyte
v='xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx'
i=0
r=prefix${v}suffix
printf '%s\0' "$r"
typeset -p v i
print -r -- comparison-complete
)
integer matrix_status=$?
print -r -- matrix-176-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R zsh
setopt multibyte
v='xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx'
i=0
r="prefix${v}suffix"
printf '%s\0' "$r"
typeset -p v i
print -r -- comparison-complete
)
integer matrix_status=$?
print -r -- matrix-177-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R zsh
setopt multibyte
v='xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx'
i=0
r=${(qqq)v}
printf '%s\0' "$r"
typeset -p v i
print -r -- comparison-complete
)
integer matrix_status=$?
print -r -- matrix-178-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R zsh
setopt multibyte
v='xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx'
i=0
r=${(e)v}
printf '%s\0' "$r"
typeset -p v i
print -r -- comparison-complete
)
integer matrix_status=$?
print -r -- matrix-179-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R zsh
setopt multibyte
v='xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx'
i=0
r=${(U)v}
printf '%s\0' "$r"
typeset -p v i
print -r -- comparison-complete
)
integer matrix_status=$?
print -r -- matrix-180-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R zsh
setopt multibyte
v='xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx'
i=0
r=${v//x/REPLACED}
printf '%s\0' "$r"
typeset -p v i
print -r -- comparison-complete
)
integer matrix_status=$?
print -r -- matrix-181-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R zsh
setopt multibyte
v='xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx'
i=0
r=$((++i))${v}$[i+=2]
printf '%s\0' "$r"
typeset -p v i
print -r -- comparison-complete
)
integer matrix_status=$?
print -r -- matrix-182-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R zsh
setopt multibyte
v='xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx'
i=0
r=$(print -rn -- "before${v}after")
printf '%s\0' "$r"
typeset -p v i
print -r -- comparison-complete
)
integer matrix_status=$?
print -r -- matrix-183-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R zsh
setopt multibyte
v='xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx'
i=0
r=`print -rn -- "before${v}after"`
printf '%s\0' "$r"
typeset -p v i
print -r -- comparison-complete
)
integer matrix_status=$?
print -r -- matrix-184-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R zsh
setopt multibyte
v='xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx'
i=0
typeset r=key=${v}
printf '%s\0' "$r"
typeset -p v i
print -r -- comparison-complete
)
integer matrix_status=$?
print -r -- matrix-185-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R zsh
setopt multibyte
v='xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx'
i=0
typeset r="key=${v}"
printf '%s\0' "$r"
typeset -p v i
print -r -- comparison-complete
)
integer matrix_status=$?
print -r -- matrix-186-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R zsh
setopt multibyte
v='xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx'
i=0
export r=key=${v}
printf '%s\0' "$r"
typeset -p v i
print -r -- comparison-complete
)
integer matrix_status=$?
print -r -- matrix-187-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R zsh
setopt multibyte
v='xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx'
i=0
typeset -a a; a=(before${v}after "key=${v}"); typeset -p a; r=$#a
printf '%s\0' "$r"
typeset -p v i
print -r -- comparison-complete
)
integer matrix_status=$?
print -r -- matrix-188-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R zsh
setopt multibyte
v='xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx'
i=0
setopt shwordsplit; typeset -a a; a=(before${v}after); typeset -p a; r=$#a
printf '%s\0' "$r"
typeset -p v i
print -r -- comparison-complete
)
integer matrix_status=$?
print -r -- matrix-189-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R zsh
setopt multibyte
v='xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx'
i=0
setopt magic_equal_subst; typeset r=key=${v}
printf '%s\0' "$r"
typeset -p v i
print -r -- comparison-complete
)
integer matrix_status=$?
print -r -- matrix-190-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R zsh
setopt multibyte
v='xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx'
i=0
r="${v}$(print -rn -- mid)${v}"
printf '%s\0' "$r"
typeset -p v i
print -r -- comparison-complete
)
integer matrix_status=$?
print -r -- matrix-191-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R zsh
setopt multibyte
v='xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx'
i=0
r="${v}${(j.:.)${(s: :)v}}${v}"
printf '%s\0' "$r"
typeset -p v i
print -r -- comparison-complete
)
integer matrix_status=$?
print -r -- matrix-192-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R zsh
setopt multibyte
v='xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx'
i=0
r=$(< <(print -rn -- "$v"))
printf '%s\0' "$r"
typeset -p v i
print -r -- comparison-complete
)
integer matrix_status=$?
print -r -- matrix-193-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R zsh
setopt multibyte
v='xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx'
i=0
readfile() { REPLY=$(< "$1"); }; readfile =(print -rn -- "$v"); r=$REPLY
printf '%s\0' "$r"
typeset -p v i
print -r -- comparison-complete
)
integer matrix_status=$?
print -r -- matrix-194-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R zsh
setopt multibyte
v='xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx'
i=0
r=$(print -r -- "$v" > >(IFS= read -r line; print -rn -- "$line"))
printf '%s\0' "$r"
typeset -p v i
print -r -- comparison-complete
)
integer matrix_status=$?
print -r -- matrix-195-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R zsh
setopt multibyte
v='xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx'
i=0
r="xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx${v}yyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyy$((++i))zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz"
printf '%s\0' "$r"
typeset -p v i
print -r -- comparison-complete
)
integer matrix_status=$?
print -r -- matrix-196-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R zsh
setopt multibyte
v='xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx'
i=0
typeset r=xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx=${v}yyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyy
printf '%s\0' "$r"
typeset -p v i
print -r -- comparison-complete
)
integer matrix_status=$?
print -r -- matrix-197-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R zsh
setopt multibyte
v='ééééééééééééééééééééééééééééééé= xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx'
i=0
r=prefix${v}suffix
printf '%s\0' "$r"
typeset -p v i
print -r -- comparison-complete
)
integer matrix_status=$?
print -r -- matrix-198-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R zsh
setopt multibyte
v='ééééééééééééééééééééééééééééééé= xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx'
i=0
r="prefix${v}suffix"
printf '%s\0' "$r"
typeset -p v i
print -r -- comparison-complete
)
integer matrix_status=$?
print -r -- matrix-199-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R zsh
setopt multibyte
v='ééééééééééééééééééééééééééééééé= xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx'
i=0
r=${(qqq)v}
printf '%s\0' "$r"
typeset -p v i
print -r -- comparison-complete
)
integer matrix_status=$?
print -r -- matrix-200-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R zsh
setopt multibyte
v='ééééééééééééééééééééééééééééééé= xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx'
i=0
r=${(e)v}
printf '%s\0' "$r"
typeset -p v i
print -r -- comparison-complete
)
integer matrix_status=$?
print -r -- matrix-201-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R zsh
setopt multibyte
v='ééééééééééééééééééééééééééééééé= xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx'
i=0
r=${(U)v}
printf '%s\0' "$r"
typeset -p v i
print -r -- comparison-complete
)
integer matrix_status=$?
print -r -- matrix-202-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R zsh
setopt multibyte
v='ééééééééééééééééééééééééééééééé= xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx'
i=0
r=${v//x/REPLACED}
printf '%s\0' "$r"
typeset -p v i
print -r -- comparison-complete
)
integer matrix_status=$?
print -r -- matrix-203-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R zsh
setopt multibyte
v='ééééééééééééééééééééééééééééééé= xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx'
i=0
r=$((++i))${v}$[i+=2]
printf '%s\0' "$r"
typeset -p v i
print -r -- comparison-complete
)
integer matrix_status=$?
print -r -- matrix-204-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R zsh
setopt multibyte
v='ééééééééééééééééééééééééééééééé= xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx'
i=0
r=$(print -rn -- "before${v}after")
printf '%s\0' "$r"
typeset -p v i
print -r -- comparison-complete
)
integer matrix_status=$?
print -r -- matrix-205-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R zsh
setopt multibyte
v='ééééééééééééééééééééééééééééééé= xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx'
i=0
r=`print -rn -- "before${v}after"`
printf '%s\0' "$r"
typeset -p v i
print -r -- comparison-complete
)
integer matrix_status=$?
print -r -- matrix-206-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R zsh
setopt multibyte
v='ééééééééééééééééééééééééééééééé= xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx'
i=0
typeset r=key=${v}
printf '%s\0' "$r"
typeset -p v i
print -r -- comparison-complete
)
integer matrix_status=$?
print -r -- matrix-207-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R zsh
setopt multibyte
v='ééééééééééééééééééééééééééééééé= xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx'
i=0
typeset r="key=${v}"
printf '%s\0' "$r"
typeset -p v i
print -r -- comparison-complete
)
integer matrix_status=$?
print -r -- matrix-208-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R zsh
setopt multibyte
v='ééééééééééééééééééééééééééééééé= xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx'
i=0
export r=key=${v}
printf '%s\0' "$r"
typeset -p v i
print -r -- comparison-complete
)
integer matrix_status=$?
print -r -- matrix-209-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R zsh
setopt multibyte
v='ééééééééééééééééééééééééééééééé= xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx'
i=0
typeset -a a; a=(before${v}after "key=${v}"); typeset -p a; r=$#a
printf '%s\0' "$r"
typeset -p v i
print -r -- comparison-complete
)
integer matrix_status=$?
print -r -- matrix-210-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R zsh
setopt multibyte
v='ééééééééééééééééééééééééééééééé= xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx'
i=0
setopt shwordsplit; typeset -a a; a=(before${v}after); typeset -p a; r=$#a
printf '%s\0' "$r"
typeset -p v i
print -r -- comparison-complete
)
integer matrix_status=$?
print -r -- matrix-211-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R zsh
setopt multibyte
v='ééééééééééééééééééééééééééééééé= xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx'
i=0
setopt magic_equal_subst; typeset r=key=${v}
printf '%s\0' "$r"
typeset -p v i
print -r -- comparison-complete
)
integer matrix_status=$?
print -r -- matrix-212-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R zsh
setopt multibyte
v='ééééééééééééééééééééééééééééééé= xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx'
i=0
r="${v}$(print -rn -- mid)${v}"
printf '%s\0' "$r"
typeset -p v i
print -r -- comparison-complete
)
integer matrix_status=$?
print -r -- matrix-213-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R zsh
setopt multibyte
v='ééééééééééééééééééééééééééééééé= xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx'
i=0
r="${v}${(j.:.)${(s: :)v}}${v}"
printf '%s\0' "$r"
typeset -p v i
print -r -- comparison-complete
)
integer matrix_status=$?
print -r -- matrix-214-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R zsh
setopt multibyte
v='ééééééééééééééééééééééééééééééé= xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx'
i=0
r=$(< <(print -rn -- "$v"))
printf '%s\0' "$r"
typeset -p v i
print -r -- comparison-complete
)
integer matrix_status=$?
print -r -- matrix-215-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R zsh
setopt multibyte
v='ééééééééééééééééééééééééééééééé= xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx'
i=0
readfile() { REPLY=$(< "$1"); }; readfile =(print -rn -- "$v"); r=$REPLY
printf '%s\0' "$r"
typeset -p v i
print -r -- comparison-complete
)
integer matrix_status=$?
print -r -- matrix-216-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R zsh
setopt multibyte
v='ééééééééééééééééééééééééééééééé= xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx'
i=0
r=$(print -r -- "$v" > >(IFS= read -r line; print -rn -- "$line"))
printf '%s\0' "$r"
typeset -p v i
print -r -- comparison-complete
)
integer matrix_status=$?
print -r -- matrix-217-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R zsh
setopt multibyte
v='ééééééééééééééééééééééééééééééé= xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx'
i=0
r="xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx${v}yyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyy$((++i))zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz"
printf '%s\0' "$r"
typeset -p v i
print -r -- comparison-complete
)
integer matrix_status=$?
print -r -- matrix-218-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R zsh
setopt multibyte
v='ééééééééééééééééééééééééééééééé= xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx'
i=0
typeset r=xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx=${v}yyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyy
printf '%s\0' "$r"
typeset -p v i
print -r -- comparison-complete
)
integer matrix_status=$?
print -r -- matrix-219-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R zsh
setopt nomultibyte
v=''
i=0
r=prefix${v}suffix
printf '%s\0' "$r"
typeset -p v i
print -r -- comparison-complete
)
integer matrix_status=$?
print -r -- matrix-220-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R zsh
setopt nomultibyte
v=''
i=0
r="prefix${v}suffix"
printf '%s\0' "$r"
typeset -p v i
print -r -- comparison-complete
)
integer matrix_status=$?
print -r -- matrix-221-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R zsh
setopt nomultibyte
v=''
i=0
r=${(qqq)v}
printf '%s\0' "$r"
typeset -p v i
print -r -- comparison-complete
)
integer matrix_status=$?
print -r -- matrix-222-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R zsh
setopt nomultibyte
v=''
i=0
r=${(e)v}
printf '%s\0' "$r"
typeset -p v i
print -r -- comparison-complete
)
integer matrix_status=$?
print -r -- matrix-223-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R zsh
setopt nomultibyte
v=''
i=0
r=${(U)v}
printf '%s\0' "$r"
typeset -p v i
print -r -- comparison-complete
)
integer matrix_status=$?
print -r -- matrix-224-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R zsh
setopt nomultibyte
v=''
i=0
r=${v//x/REPLACED}
printf '%s\0' "$r"
typeset -p v i
print -r -- comparison-complete
)
integer matrix_status=$?
print -r -- matrix-225-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R zsh
setopt nomultibyte
v=''
i=0
r=$((++i))${v}$[i+=2]
printf '%s\0' "$r"
typeset -p v i
print -r -- comparison-complete
)
integer matrix_status=$?
print -r -- matrix-226-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R zsh
setopt nomultibyte
v=''
i=0
r=$(print -rn -- "before${v}after")
printf '%s\0' "$r"
typeset -p v i
print -r -- comparison-complete
)
integer matrix_status=$?
print -r -- matrix-227-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R zsh
setopt nomultibyte
v=''
i=0
r=`print -rn -- "before${v}after"`
printf '%s\0' "$r"
typeset -p v i
print -r -- comparison-complete
)
integer matrix_status=$?
print -r -- matrix-228-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R zsh
setopt nomultibyte
v=''
i=0
typeset r=key=${v}
printf '%s\0' "$r"
typeset -p v i
print -r -- comparison-complete
)
integer matrix_status=$?
print -r -- matrix-229-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R zsh
setopt nomultibyte
v=''
i=0
typeset r="key=${v}"
printf '%s\0' "$r"
typeset -p v i
print -r -- comparison-complete
)
integer matrix_status=$?
print -r -- matrix-230-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R zsh
setopt nomultibyte
v=''
i=0
export r=key=${v}
printf '%s\0' "$r"
typeset -p v i
print -r -- comparison-complete
)
integer matrix_status=$?
print -r -- matrix-231-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R zsh
setopt nomultibyte
v=''
i=0
typeset -a a; a=(before${v}after "key=${v}"); typeset -p a; r=$#a
printf '%s\0' "$r"
typeset -p v i
print -r -- comparison-complete
)
integer matrix_status=$?
print -r -- matrix-232-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R zsh
setopt nomultibyte
v=''
i=0
setopt shwordsplit; typeset -a a; a=(before${v}after); typeset -p a; r=$#a
printf '%s\0' "$r"
typeset -p v i
print -r -- comparison-complete
)
integer matrix_status=$?
print -r -- matrix-233-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R zsh
setopt nomultibyte
v=''
i=0
setopt magic_equal_subst; typeset r=key=${v}
printf '%s\0' "$r"
typeset -p v i
print -r -- comparison-complete
)
integer matrix_status=$?
print -r -- matrix-234-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R zsh
setopt nomultibyte
v=''
i=0
r="${v}$(print -rn -- mid)${v}"
printf '%s\0' "$r"
typeset -p v i
print -r -- comparison-complete
)
integer matrix_status=$?
print -r -- matrix-235-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R zsh
setopt nomultibyte
v=''
i=0
r="${v}${(j.:.)${(s: :)v}}${v}"
printf '%s\0' "$r"
typeset -p v i
print -r -- comparison-complete
)
integer matrix_status=$?
print -r -- matrix-236-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R zsh
setopt nomultibyte
v=''
i=0
r=$(< <(print -rn -- "$v"))
printf '%s\0' "$r"
typeset -p v i
print -r -- comparison-complete
)
integer matrix_status=$?
print -r -- matrix-237-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R zsh
setopt nomultibyte
v=''
i=0
readfile() { REPLY=$(< "$1"); }; readfile =(print -rn -- "$v"); r=$REPLY
printf '%s\0' "$r"
typeset -p v i
print -r -- comparison-complete
)
integer matrix_status=$?
print -r -- matrix-238-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R zsh
setopt nomultibyte
v=''
i=0
r=$(print -r -- "$v" > >(IFS= read -r line; print -rn -- "$line"))
printf '%s\0' "$r"
typeset -p v i
print -r -- comparison-complete
)
integer matrix_status=$?
print -r -- matrix-239-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R zsh
setopt nomultibyte
v=''
i=0
r="xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx${v}yyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyy$((++i))zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz"
printf '%s\0' "$r"
typeset -p v i
print -r -- comparison-complete
)
integer matrix_status=$?
print -r -- matrix-240-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R zsh
setopt nomultibyte
v=''
i=0
typeset r=xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx=${v}yyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyy
printf '%s\0' "$r"
typeset -p v i
print -r -- comparison-complete
)
integer matrix_status=$?
print -r -- matrix-241-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R zsh
setopt nomultibyte
v='x=y:a b'
i=0
r=prefix${v}suffix
printf '%s\0' "$r"
typeset -p v i
print -r -- comparison-complete
)
integer matrix_status=$?
print -r -- matrix-242-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R zsh
setopt nomultibyte
v='x=y:a b'
i=0
r="prefix${v}suffix"
printf '%s\0' "$r"
typeset -p v i
print -r -- comparison-complete
)
integer matrix_status=$?
print -r -- matrix-243-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R zsh
setopt nomultibyte
v='x=y:a b'
i=0
r=${(qqq)v}
printf '%s\0' "$r"
typeset -p v i
print -r -- comparison-complete
)
integer matrix_status=$?
print -r -- matrix-244-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R zsh
setopt nomultibyte
v='x=y:a b'
i=0
r=${(e)v}
printf '%s\0' "$r"
typeset -p v i
print -r -- comparison-complete
)
integer matrix_status=$?
print -r -- matrix-245-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R zsh
setopt nomultibyte
v='x=y:a b'
i=0
r=${(U)v}
printf '%s\0' "$r"
typeset -p v i
print -r -- comparison-complete
)
integer matrix_status=$?
print -r -- matrix-246-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R zsh
setopt nomultibyte
v='x=y:a b'
i=0
r=${v//x/REPLACED}
printf '%s\0' "$r"
typeset -p v i
print -r -- comparison-complete
)
integer matrix_status=$?
print -r -- matrix-247-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R zsh
setopt nomultibyte
v='x=y:a b'
i=0
r=$((++i))${v}$[i+=2]
printf '%s\0' "$r"
typeset -p v i
print -r -- comparison-complete
)
integer matrix_status=$?
print -r -- matrix-248-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R zsh
setopt nomultibyte
v='x=y:a b'
i=0
r=$(print -rn -- "before${v}after")
printf '%s\0' "$r"
typeset -p v i
print -r -- comparison-complete
)
integer matrix_status=$?
print -r -- matrix-249-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R zsh
setopt nomultibyte
v='x=y:a b'
i=0
r=`print -rn -- "before${v}after"`
printf '%s\0' "$r"
typeset -p v i
print -r -- comparison-complete
)
integer matrix_status=$?
print -r -- matrix-250-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R zsh
setopt nomultibyte
v='x=y:a b'
i=0
typeset r=key=${v}
printf '%s\0' "$r"
typeset -p v i
print -r -- comparison-complete
)
integer matrix_status=$?
print -r -- matrix-251-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R zsh
setopt nomultibyte
v='x=y:a b'
i=0
typeset r="key=${v}"
printf '%s\0' "$r"
typeset -p v i
print -r -- comparison-complete
)
integer matrix_status=$?
print -r -- matrix-252-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R zsh
setopt nomultibyte
v='x=y:a b'
i=0
export r=key=${v}
printf '%s\0' "$r"
typeset -p v i
print -r -- comparison-complete
)
integer matrix_status=$?
print -r -- matrix-253-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R zsh
setopt nomultibyte
v='x=y:a b'
i=0
typeset -a a; a=(before${v}after "key=${v}"); typeset -p a; r=$#a
printf '%s\0' "$r"
typeset -p v i
print -r -- comparison-complete
)
integer matrix_status=$?
print -r -- matrix-254-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R zsh
setopt nomultibyte
v='x=y:a b'
i=0
setopt shwordsplit; typeset -a a; a=(before${v}after); typeset -p a; r=$#a
printf '%s\0' "$r"
typeset -p v i
print -r -- comparison-complete
)
integer matrix_status=$?
print -r -- matrix-255-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R zsh
setopt nomultibyte
v='x=y:a b'
i=0
setopt magic_equal_subst; typeset r=key=${v}
printf '%s\0' "$r"
typeset -p v i
print -r -- comparison-complete
)
integer matrix_status=$?
print -r -- matrix-256-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R zsh
setopt nomultibyte
v='x=y:a b'
i=0
r="${v}$(print -rn -- mid)${v}"
printf '%s\0' "$r"
typeset -p v i
print -r -- comparison-complete
)
integer matrix_status=$?
print -r -- matrix-257-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R zsh
setopt nomultibyte
v='x=y:a b'
i=0
r="${v}${(j.:.)${(s: :)v}}${v}"
printf '%s\0' "$r"
typeset -p v i
print -r -- comparison-complete
)
integer matrix_status=$?
print -r -- matrix-258-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R zsh
setopt nomultibyte
v='x=y:a b'
i=0
r=$(< <(print -rn -- "$v"))
printf '%s\0' "$r"
typeset -p v i
print -r -- comparison-complete
)
integer matrix_status=$?
print -r -- matrix-259-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R zsh
setopt nomultibyte
v='x=y:a b'
i=0
readfile() { REPLY=$(< "$1"); }; readfile =(print -rn -- "$v"); r=$REPLY
printf '%s\0' "$r"
typeset -p v i
print -r -- comparison-complete
)
integer matrix_status=$?
print -r -- matrix-260-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R zsh
setopt nomultibyte
v='x=y:a b'
i=0
r=$(print -r -- "$v" > >(IFS= read -r line; print -rn -- "$line"))
printf '%s\0' "$r"
typeset -p v i
print -r -- comparison-complete
)
integer matrix_status=$?
print -r -- matrix-261-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R zsh
setopt nomultibyte
v='x=y:a b'
i=0
r="xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx${v}yyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyy$((++i))zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz"
printf '%s\0' "$r"
typeset -p v i
print -r -- comparison-complete
)
integer matrix_status=$?
print -r -- matrix-262-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R zsh
setopt nomultibyte
v='x=y:a b'
i=0
typeset r=xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx=${v}yyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyy
printf '%s\0' "$r"
typeset -p v i
print -r -- comparison-complete
)
integer matrix_status=$?
print -r -- matrix-263-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R zsh
setopt nomultibyte
v='é😀'
i=0
r=prefix${v}suffix
printf '%s\0' "$r"
typeset -p v i
print -r -- comparison-complete
)
integer matrix_status=$?
print -r -- matrix-264-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R zsh
setopt nomultibyte
v='é😀'
i=0
r="prefix${v}suffix"
printf '%s\0' "$r"
typeset -p v i
print -r -- comparison-complete
)
integer matrix_status=$?
print -r -- matrix-265-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R zsh
setopt nomultibyte
v='é😀'
i=0
r=${(qqq)v}
printf '%s\0' "$r"
typeset -p v i
print -r -- comparison-complete
)
integer matrix_status=$?
print -r -- matrix-266-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R zsh
setopt nomultibyte
v='é😀'
i=0
r=${(e)v}
printf '%s\0' "$r"
typeset -p v i
print -r -- comparison-complete
)
integer matrix_status=$?
print -r -- matrix-267-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R zsh
setopt nomultibyte
v='é😀'
i=0
r=${(U)v}
printf '%s\0' "$r"
typeset -p v i
print -r -- comparison-complete
)
integer matrix_status=$?
print -r -- matrix-268-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R zsh
setopt nomultibyte
v='é😀'
i=0
r=${v//x/REPLACED}
printf '%s\0' "$r"
typeset -p v i
print -r -- comparison-complete
)
integer matrix_status=$?
print -r -- matrix-269-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R zsh
setopt nomultibyte
v='é😀'
i=0
r=$((++i))${v}$[i+=2]
printf '%s\0' "$r"
typeset -p v i
print -r -- comparison-complete
)
integer matrix_status=$?
print -r -- matrix-270-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R zsh
setopt nomultibyte
v='é😀'
i=0
r=$(print -rn -- "before${v}after")
printf '%s\0' "$r"
typeset -p v i
print -r -- comparison-complete
)
integer matrix_status=$?
print -r -- matrix-271-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R zsh
setopt nomultibyte
v='é😀'
i=0
r=`print -rn -- "before${v}after"`
printf '%s\0' "$r"
typeset -p v i
print -r -- comparison-complete
)
integer matrix_status=$?
print -r -- matrix-272-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R zsh
setopt nomultibyte
v='é😀'
i=0
typeset r=key=${v}
printf '%s\0' "$r"
typeset -p v i
print -r -- comparison-complete
)
integer matrix_status=$?
print -r -- matrix-273-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R zsh
setopt nomultibyte
v='é😀'
i=0
typeset r="key=${v}"
printf '%s\0' "$r"
typeset -p v i
print -r -- comparison-complete
)
integer matrix_status=$?
print -r -- matrix-274-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R zsh
setopt nomultibyte
v='é😀'
i=0
export r=key=${v}
printf '%s\0' "$r"
typeset -p v i
print -r -- comparison-complete
)
integer matrix_status=$?
print -r -- matrix-275-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R zsh
setopt nomultibyte
v='é😀'
i=0
typeset -a a; a=(before${v}after "key=${v}"); typeset -p a; r=$#a
printf '%s\0' "$r"
typeset -p v i
print -r -- comparison-complete
)
integer matrix_status=$?
print -r -- matrix-276-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R zsh
setopt nomultibyte
v='é😀'
i=0
setopt shwordsplit; typeset -a a; a=(before${v}after); typeset -p a; r=$#a
printf '%s\0' "$r"
typeset -p v i
print -r -- comparison-complete
)
integer matrix_status=$?
print -r -- matrix-277-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R zsh
setopt nomultibyte
v='é😀'
i=0
setopt magic_equal_subst; typeset r=key=${v}
printf '%s\0' "$r"
typeset -p v i
print -r -- comparison-complete
)
integer matrix_status=$?
print -r -- matrix-278-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R zsh
setopt nomultibyte
v='é😀'
i=0
r="${v}$(print -rn -- mid)${v}"
printf '%s\0' "$r"
typeset -p v i
print -r -- comparison-complete
)
integer matrix_status=$?
print -r -- matrix-279-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R zsh
setopt nomultibyte
v='é😀'
i=0
r="${v}${(j.:.)${(s: :)v}}${v}"
printf '%s\0' "$r"
typeset -p v i
print -r -- comparison-complete
)
integer matrix_status=$?
print -r -- matrix-280-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R zsh
setopt nomultibyte
v='é😀'
i=0
r=$(< <(print -rn -- "$v"))
printf '%s\0' "$r"
typeset -p v i
print -r -- comparison-complete
)
integer matrix_status=$?
print -r -- matrix-281-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R zsh
setopt nomultibyte
v='é😀'
i=0
readfile() { REPLY=$(< "$1"); }; readfile =(print -rn -- "$v"); r=$REPLY
printf '%s\0' "$r"
typeset -p v i
print -r -- comparison-complete
)
integer matrix_status=$?
print -r -- matrix-282-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R zsh
setopt nomultibyte
v='é😀'
i=0
r=$(print -r -- "$v" > >(IFS= read -r line; print -rn -- "$line"))
printf '%s\0' "$r"
typeset -p v i
print -r -- comparison-complete
)
integer matrix_status=$?
print -r -- matrix-283-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R zsh
setopt nomultibyte
v='é😀'
i=0
r="xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx${v}yyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyy$((++i))zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz"
printf '%s\0' "$r"
typeset -p v i
print -r -- comparison-complete
)
integer matrix_status=$?
print -r -- matrix-284-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R zsh
setopt nomultibyte
v='é😀'
i=0
typeset r=xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx=${v}yyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyy
printf '%s\0' "$r"
typeset -p v i
print -r -- comparison-complete
)
integer matrix_status=$?
print -r -- matrix-285-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R zsh
setopt nomultibyte
v=$'x\0y\203\377z'
i=0
r=prefix${v}suffix
printf '%s\0' "$r"
typeset -p v i
print -r -- comparison-complete
)
integer matrix_status=$?
print -r -- matrix-286-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R zsh
setopt nomultibyte
v=$'x\0y\203\377z'
i=0
r="prefix${v}suffix"
printf '%s\0' "$r"
typeset -p v i
print -r -- comparison-complete
)
integer matrix_status=$?
print -r -- matrix-287-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R zsh
setopt nomultibyte
v=$'x\0y\203\377z'
i=0
r=${(qqq)v}
printf '%s\0' "$r"
typeset -p v i
print -r -- comparison-complete
)
integer matrix_status=$?
print -r -- matrix-288-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R zsh
setopt nomultibyte
v=$'x\0y\203\377z'
i=0
r=${(e)v}
printf '%s\0' "$r"
typeset -p v i
print -r -- comparison-complete
)
integer matrix_status=$?
print -r -- matrix-289-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R zsh
setopt nomultibyte
v=$'x\0y\203\377z'
i=0
r=${(U)v}
printf '%s\0' "$r"
typeset -p v i
print -r -- comparison-complete
)
integer matrix_status=$?
print -r -- matrix-290-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R zsh
setopt nomultibyte
v=$'x\0y\203\377z'
i=0
r=${v//x/REPLACED}
printf '%s\0' "$r"
typeset -p v i
print -r -- comparison-complete
)
integer matrix_status=$?
print -r -- matrix-291-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R zsh
setopt nomultibyte
v=$'x\0y\203\377z'
i=0
r=$((++i))${v}$[i+=2]
printf '%s\0' "$r"
typeset -p v i
print -r -- comparison-complete
)
integer matrix_status=$?
print -r -- matrix-292-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R zsh
setopt nomultibyte
v=$'x\0y\203\377z'
i=0
r=$(print -rn -- "before${v}after")
printf '%s\0' "$r"
typeset -p v i
print -r -- comparison-complete
)
integer matrix_status=$?
print -r -- matrix-293-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R zsh
setopt nomultibyte
v=$'x\0y\203\377z'
i=0
r=`print -rn -- "before${v}after"`
printf '%s\0' "$r"
typeset -p v i
print -r -- comparison-complete
)
integer matrix_status=$?
print -r -- matrix-294-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R zsh
setopt nomultibyte
v=$'x\0y\203\377z'
i=0
typeset r=key=${v}
printf '%s\0' "$r"
typeset -p v i
print -r -- comparison-complete
)
integer matrix_status=$?
print -r -- matrix-295-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R zsh
setopt nomultibyte
v=$'x\0y\203\377z'
i=0
typeset r="key=${v}"
printf '%s\0' "$r"
typeset -p v i
print -r -- comparison-complete
)
integer matrix_status=$?
print -r -- matrix-296-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R zsh
setopt nomultibyte
v=$'x\0y\203\377z'
i=0
export r=key=${v}
printf '%s\0' "$r"
typeset -p v i
print -r -- comparison-complete
)
integer matrix_status=$?
print -r -- matrix-297-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R zsh
setopt nomultibyte
v=$'x\0y\203\377z'
i=0
typeset -a a; a=(before${v}after "key=${v}"); typeset -p a; r=$#a
printf '%s\0' "$r"
typeset -p v i
print -r -- comparison-complete
)
integer matrix_status=$?
print -r -- matrix-298-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R zsh
setopt nomultibyte
v=$'x\0y\203\377z'
i=0
setopt shwordsplit; typeset -a a; a=(before${v}after); typeset -p a; r=$#a
printf '%s\0' "$r"
typeset -p v i
print -r -- comparison-complete
)
integer matrix_status=$?
print -r -- matrix-299-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R zsh
setopt nomultibyte
v=$'x\0y\203\377z'
i=0
setopt magic_equal_subst; typeset r=key=${v}
printf '%s\0' "$r"
typeset -p v i
print -r -- comparison-complete
)
integer matrix_status=$?
print -r -- matrix-300-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R zsh
setopt nomultibyte
v=$'x\0y\203\377z'
i=0
r="${v}$(print -rn -- mid)${v}"
printf '%s\0' "$r"
typeset -p v i
print -r -- comparison-complete
)
integer matrix_status=$?
print -r -- matrix-301-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R zsh
setopt nomultibyte
v=$'x\0y\203\377z'
i=0
r="${v}${(j.:.)${(s: :)v}}${v}"
printf '%s\0' "$r"
typeset -p v i
print -r -- comparison-complete
)
integer matrix_status=$?
print -r -- matrix-302-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R zsh
setopt nomultibyte
v=$'x\0y\203\377z'
i=0
r=$(< <(print -rn -- "$v"))
printf '%s\0' "$r"
typeset -p v i
print -r -- comparison-complete
)
integer matrix_status=$?
print -r -- matrix-303-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R zsh
setopt nomultibyte
v=$'x\0y\203\377z'
i=0
readfile() { REPLY=$(< "$1"); }; readfile =(print -rn -- "$v"); r=$REPLY
printf '%s\0' "$r"
typeset -p v i
print -r -- comparison-complete
)
integer matrix_status=$?
print -r -- matrix-304-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R zsh
setopt nomultibyte
v=$'x\0y\203\377z'
i=0
r=$(print -r -- "$v" > >(IFS= read -r line; print -rn -- "$line"))
printf '%s\0' "$r"
typeset -p v i
print -r -- comparison-complete
)
integer matrix_status=$?
print -r -- matrix-305-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R zsh
setopt nomultibyte
v=$'x\0y\203\377z'
i=0
r="xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx${v}yyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyy$((++i))zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz"
printf '%s\0' "$r"
typeset -p v i
print -r -- comparison-complete
)
integer matrix_status=$?
print -r -- matrix-306-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R zsh
setopt nomultibyte
v=$'x\0y\203\377z'
i=0
typeset r=xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx=${v}yyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyy
printf '%s\0' "$r"
typeset -p v i
print -r -- comparison-complete
)
integer matrix_status=$?
print -r -- matrix-307-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R zsh
setopt nomultibyte
v='$(print -r -- expanded)'
i=0
r=prefix${v}suffix
printf '%s\0' "$r"
typeset -p v i
print -r -- comparison-complete
)
integer matrix_status=$?
print -r -- matrix-308-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R zsh
setopt nomultibyte
v='$(print -r -- expanded)'
i=0
r="prefix${v}suffix"
printf '%s\0' "$r"
typeset -p v i
print -r -- comparison-complete
)
integer matrix_status=$?
print -r -- matrix-309-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R zsh
setopt nomultibyte
v='$(print -r -- expanded)'
i=0
r=${(qqq)v}
printf '%s\0' "$r"
typeset -p v i
print -r -- comparison-complete
)
integer matrix_status=$?
print -r -- matrix-310-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R zsh
setopt nomultibyte
v='$(print -r -- expanded)'
i=0
r=${(e)v}
printf '%s\0' "$r"
typeset -p v i
print -r -- comparison-complete
)
integer matrix_status=$?
print -r -- matrix-311-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R zsh
setopt nomultibyte
v='$(print -r -- expanded)'
i=0
r=${(U)v}
printf '%s\0' "$r"
typeset -p v i
print -r -- comparison-complete
)
integer matrix_status=$?
print -r -- matrix-312-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R zsh
setopt nomultibyte
v='$(print -r -- expanded)'
i=0
r=${v//x/REPLACED}
printf '%s\0' "$r"
typeset -p v i
print -r -- comparison-complete
)
integer matrix_status=$?
print -r -- matrix-313-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R zsh
setopt nomultibyte
v='$(print -r -- expanded)'
i=0
r=$((++i))${v}$[i+=2]
printf '%s\0' "$r"
typeset -p v i
print -r -- comparison-complete
)
integer matrix_status=$?
print -r -- matrix-314-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R zsh
setopt nomultibyte
v='$(print -r -- expanded)'
i=0
r=$(print -rn -- "before${v}after")
printf '%s\0' "$r"
typeset -p v i
print -r -- comparison-complete
)
integer matrix_status=$?
print -r -- matrix-315-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R zsh
setopt nomultibyte
v='$(print -r -- expanded)'
i=0
r=`print -rn -- "before${v}after"`
printf '%s\0' "$r"
typeset -p v i
print -r -- comparison-complete
)
integer matrix_status=$?
print -r -- matrix-316-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R zsh
setopt nomultibyte
v='$(print -r -- expanded)'
i=0
typeset r=key=${v}
printf '%s\0' "$r"
typeset -p v i
print -r -- comparison-complete
)
integer matrix_status=$?
print -r -- matrix-317-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R zsh
setopt nomultibyte
v='$(print -r -- expanded)'
i=0
typeset r="key=${v}"
printf '%s\0' "$r"
typeset -p v i
print -r -- comparison-complete
)
integer matrix_status=$?
print -r -- matrix-318-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R zsh
setopt nomultibyte
v='$(print -r -- expanded)'
i=0
export r=key=${v}
printf '%s\0' "$r"
typeset -p v i
print -r -- comparison-complete
)
integer matrix_status=$?
print -r -- matrix-319-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R zsh
setopt nomultibyte
v='$(print -r -- expanded)'
i=0
typeset -a a; a=(before${v}after "key=${v}"); typeset -p a; r=$#a
printf '%s\0' "$r"
typeset -p v i
print -r -- comparison-complete
)
integer matrix_status=$?
print -r -- matrix-320-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R zsh
setopt nomultibyte
v='$(print -r -- expanded)'
i=0
setopt shwordsplit; typeset -a a; a=(before${v}after); typeset -p a; r=$#a
printf '%s\0' "$r"
typeset -p v i
print -r -- comparison-complete
)
integer matrix_status=$?
print -r -- matrix-321-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R zsh
setopt nomultibyte
v='$(print -r -- expanded)'
i=0
setopt magic_equal_subst; typeset r=key=${v}
printf '%s\0' "$r"
typeset -p v i
print -r -- comparison-complete
)
integer matrix_status=$?
print -r -- matrix-322-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R zsh
setopt nomultibyte
v='$(print -r -- expanded)'
i=0
r="${v}$(print -rn -- mid)${v}"
printf '%s\0' "$r"
typeset -p v i
print -r -- comparison-complete
)
integer matrix_status=$?
print -r -- matrix-323-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R zsh
setopt nomultibyte
v='$(print -r -- expanded)'
i=0
r="${v}${(j.:.)${(s: :)v}}${v}"
printf '%s\0' "$r"
typeset -p v i
print -r -- comparison-complete
)
integer matrix_status=$?
print -r -- matrix-324-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R zsh
setopt nomultibyte
v='$(print -r -- expanded)'
i=0
r=$(< <(print -rn -- "$v"))
printf '%s\0' "$r"
typeset -p v i
print -r -- comparison-complete
)
integer matrix_status=$?
print -r -- matrix-325-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R zsh
setopt nomultibyte
v='$(print -r -- expanded)'
i=0
readfile() { REPLY=$(< "$1"); }; readfile =(print -rn -- "$v"); r=$REPLY
printf '%s\0' "$r"
typeset -p v i
print -r -- comparison-complete
)
integer matrix_status=$?
print -r -- matrix-326-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R zsh
setopt nomultibyte
v='$(print -r -- expanded)'
i=0
r=$(print -r -- "$v" > >(IFS= read -r line; print -rn -- "$line"))
printf '%s\0' "$r"
typeset -p v i
print -r -- comparison-complete
)
integer matrix_status=$?
print -r -- matrix-327-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R zsh
setopt nomultibyte
v='$(print -r -- expanded)'
i=0
r="xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx${v}yyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyy$((++i))zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz"
printf '%s\0' "$r"
typeset -p v i
print -r -- comparison-complete
)
integer matrix_status=$?
print -r -- matrix-328-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R zsh
setopt nomultibyte
v='$(print -r -- expanded)'
i=0
typeset r=xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx=${v}yyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyy
printf '%s\0' "$r"
typeset -p v i
print -r -- comparison-complete
)
integer matrix_status=$?
print -r -- matrix-329-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R zsh
setopt nomultibyte
v='${v} `print tick` = <(x)'
i=0
r=prefix${v}suffix
printf '%s\0' "$r"
typeset -p v i
print -r -- comparison-complete
)
integer matrix_status=$?
print -r -- matrix-330-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R zsh
setopt nomultibyte
v='${v} `print tick` = <(x)'
i=0
r="prefix${v}suffix"
printf '%s\0' "$r"
typeset -p v i
print -r -- comparison-complete
)
integer matrix_status=$?
print -r -- matrix-331-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R zsh
setopt nomultibyte
v='${v} `print tick` = <(x)'
i=0
r=${(qqq)v}
printf '%s\0' "$r"
typeset -p v i
print -r -- comparison-complete
)
integer matrix_status=$?
print -r -- matrix-332-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R zsh
setopt nomultibyte
v='${v} `print tick` = <(x)'
i=0
r=${(e)v}
printf '%s\0' "$r"
typeset -p v i
print -r -- comparison-complete
)
integer matrix_status=$?
print -r -- matrix-333-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R zsh
setopt nomultibyte
v='${v} `print tick` = <(x)'
i=0
r=${(U)v}
printf '%s\0' "$r"
typeset -p v i
print -r -- comparison-complete
)
integer matrix_status=$?
print -r -- matrix-334-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R zsh
setopt nomultibyte
v='${v} `print tick` = <(x)'
i=0
r=${v//x/REPLACED}
printf '%s\0' "$r"
typeset -p v i
print -r -- comparison-complete
)
integer matrix_status=$?
print -r -- matrix-335-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R zsh
setopt nomultibyte
v='${v} `print tick` = <(x)'
i=0
r=$((++i))${v}$[i+=2]
printf '%s\0' "$r"
typeset -p v i
print -r -- comparison-complete
)
integer matrix_status=$?
print -r -- matrix-336-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R zsh
setopt nomultibyte
v='${v} `print tick` = <(x)'
i=0
r=$(print -rn -- "before${v}after")
printf '%s\0' "$r"
typeset -p v i
print -r -- comparison-complete
)
integer matrix_status=$?
print -r -- matrix-337-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R zsh
setopt nomultibyte
v='${v} `print tick` = <(x)'
i=0
r=`print -rn -- "before${v}after"`
printf '%s\0' "$r"
typeset -p v i
print -r -- comparison-complete
)
integer matrix_status=$?
print -r -- matrix-338-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R zsh
setopt nomultibyte
v='${v} `print tick` = <(x)'
i=0
typeset r=key=${v}
printf '%s\0' "$r"
typeset -p v i
print -r -- comparison-complete
)
integer matrix_status=$?
print -r -- matrix-339-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R zsh
setopt nomultibyte
v='${v} `print tick` = <(x)'
i=0
typeset r="key=${v}"
printf '%s\0' "$r"
typeset -p v i
print -r -- comparison-complete
)
integer matrix_status=$?
print -r -- matrix-340-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R zsh
setopt nomultibyte
v='${v} `print tick` = <(x)'
i=0
export r=key=${v}
printf '%s\0' "$r"
typeset -p v i
print -r -- comparison-complete
)
integer matrix_status=$?
print -r -- matrix-341-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R zsh
setopt nomultibyte
v='${v} `print tick` = <(x)'
i=0
typeset -a a; a=(before${v}after "key=${v}"); typeset -p a; r=$#a
printf '%s\0' "$r"
typeset -p v i
print -r -- comparison-complete
)
integer matrix_status=$?
print -r -- matrix-342-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R zsh
setopt nomultibyte
v='${v} `print tick` = <(x)'
i=0
setopt shwordsplit; typeset -a a; a=(before${v}after); typeset -p a; r=$#a
printf '%s\0' "$r"
typeset -p v i
print -r -- comparison-complete
)
integer matrix_status=$?
print -r -- matrix-343-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R zsh
setopt nomultibyte
v='${v} `print tick` = <(x)'
i=0
setopt magic_equal_subst; typeset r=key=${v}
printf '%s\0' "$r"
typeset -p v i
print -r -- comparison-complete
)
integer matrix_status=$?
print -r -- matrix-344-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R zsh
setopt nomultibyte
v='${v} `print tick` = <(x)'
i=0
r="${v}$(print -rn -- mid)${v}"
printf '%s\0' "$r"
typeset -p v i
print -r -- comparison-complete
)
integer matrix_status=$?
print -r -- matrix-345-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R zsh
setopt nomultibyte
v='${v} `print tick` = <(x)'
i=0
r="${v}${(j.:.)${(s: :)v}}${v}"
printf '%s\0' "$r"
typeset -p v i
print -r -- comparison-complete
)
integer matrix_status=$?
print -r -- matrix-346-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R zsh
setopt nomultibyte
v='${v} `print tick` = <(x)'
i=0
r=$(< <(print -rn -- "$v"))
printf '%s\0' "$r"
typeset -p v i
print -r -- comparison-complete
)
integer matrix_status=$?
print -r -- matrix-347-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R zsh
setopt nomultibyte
v='${v} `print tick` = <(x)'
i=0
readfile() { REPLY=$(< "$1"); }; readfile =(print -rn -- "$v"); r=$REPLY
printf '%s\0' "$r"
typeset -p v i
print -r -- comparison-complete
)
integer matrix_status=$?
print -r -- matrix-348-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R zsh
setopt nomultibyte
v='${v} `print tick` = <(x)'
i=0
r=$(print -r -- "$v" > >(IFS= read -r line; print -rn -- "$line"))
printf '%s\0' "$r"
typeset -p v i
print -r -- comparison-complete
)
integer matrix_status=$?
print -r -- matrix-349-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R zsh
setopt nomultibyte
v='${v} `print tick` = <(x)'
i=0
r="xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx${v}yyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyy$((++i))zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz"
printf '%s\0' "$r"
typeset -p v i
print -r -- comparison-complete
)
integer matrix_status=$?
print -r -- matrix-350-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R zsh
setopt nomultibyte
v='${v} `print tick` = <(x)'
i=0
typeset r=xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx=${v}yyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyy
printf '%s\0' "$r"
typeset -p v i
print -r -- comparison-complete
)
integer matrix_status=$?
print -r -- matrix-351-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R zsh
setopt nomultibyte
v=$'\000\001\002\003\004\005\006\007\010\011\012\013\014\015\016\017\020\021\022\023\024\025\026\027\030\031\032\033\034\035\036\037\040\041\042\043\044\045\046\047\050\051\052\053\054\055\056\057\060\061\062\063\064\065\066\067\070\071\072\073\074\075\076\077\100\101\102\103\104\105\106\107\110\111\112\113\114\115\116\117\120\121\122\123\124\125\126\127\130\131\132\133\134\135\136\137\140\141\142\143\144\145\146\147\150\151\152\153\154\155\156\157\160\161\162\163\164\165\166\167\170\171\172\173\174\175\176\177\200\201\202\203\204\205\206\207\210\211\212\213\214\215\216\217\220\221\222\223\224\225\226\227\230\231\232\233\234\235\236\237\240\241\242\243\244\245\246\247\250\251\252\253\254\255\256\257\260\261\262\263\264\265\266\267\270\271\272\273\274\275\276\277\300\301\302\303\304\305\306\307\310\311\312\313\314\315\316\317\320\321\322\323\324\325\326\327\330\331\332\333\334\335\336\337\340\341\342\343\344\345\346\347\350\351\352\353\354\355\356\357\360\361\362\363\364\365\366\367\370\371\372\373\374\375\376\377'
i=0
r=prefix${v}suffix
printf '%s\0' "$r"
typeset -p v i
print -r -- comparison-complete
)
integer matrix_status=$?
print -r -- matrix-352-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R zsh
setopt nomultibyte
v=$'\000\001\002\003\004\005\006\007\010\011\012\013\014\015\016\017\020\021\022\023\024\025\026\027\030\031\032\033\034\035\036\037\040\041\042\043\044\045\046\047\050\051\052\053\054\055\056\057\060\061\062\063\064\065\066\067\070\071\072\073\074\075\076\077\100\101\102\103\104\105\106\107\110\111\112\113\114\115\116\117\120\121\122\123\124\125\126\127\130\131\132\133\134\135\136\137\140\141\142\143\144\145\146\147\150\151\152\153\154\155\156\157\160\161\162\163\164\165\166\167\170\171\172\173\174\175\176\177\200\201\202\203\204\205\206\207\210\211\212\213\214\215\216\217\220\221\222\223\224\225\226\227\230\231\232\233\234\235\236\237\240\241\242\243\244\245\246\247\250\251\252\253\254\255\256\257\260\261\262\263\264\265\266\267\270\271\272\273\274\275\276\277\300\301\302\303\304\305\306\307\310\311\312\313\314\315\316\317\320\321\322\323\324\325\326\327\330\331\332\333\334\335\336\337\340\341\342\343\344\345\346\347\350\351\352\353\354\355\356\357\360\361\362\363\364\365\366\367\370\371\372\373\374\375\376\377'
i=0
r="prefix${v}suffix"
printf '%s\0' "$r"
typeset -p v i
print -r -- comparison-complete
)
integer matrix_status=$?
print -r -- matrix-353-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R zsh
setopt nomultibyte
v=$'\000\001\002\003\004\005\006\007\010\011\012\013\014\015\016\017\020\021\022\023\024\025\026\027\030\031\032\033\034\035\036\037\040\041\042\043\044\045\046\047\050\051\052\053\054\055\056\057\060\061\062\063\064\065\066\067\070\071\072\073\074\075\076\077\100\101\102\103\104\105\106\107\110\111\112\113\114\115\116\117\120\121\122\123\124\125\126\127\130\131\132\133\134\135\136\137\140\141\142\143\144\145\146\147\150\151\152\153\154\155\156\157\160\161\162\163\164\165\166\167\170\171\172\173\174\175\176\177\200\201\202\203\204\205\206\207\210\211\212\213\214\215\216\217\220\221\222\223\224\225\226\227\230\231\232\233\234\235\236\237\240\241\242\243\244\245\246\247\250\251\252\253\254\255\256\257\260\261\262\263\264\265\266\267\270\271\272\273\274\275\276\277\300\301\302\303\304\305\306\307\310\311\312\313\314\315\316\317\320\321\322\323\324\325\326\327\330\331\332\333\334\335\336\337\340\341\342\343\344\345\346\347\350\351\352\353\354\355\356\357\360\361\362\363\364\365\366\367\370\371\372\373\374\375\376\377'
i=0
r=${(qqq)v}
printf '%s\0' "$r"
typeset -p v i
print -r -- comparison-complete
)
integer matrix_status=$?
print -r -- matrix-354-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R zsh
setopt nomultibyte
v=$'\000\001\002\003\004\005\006\007\010\011\012\013\014\015\016\017\020\021\022\023\024\025\026\027\030\031\032\033\034\035\036\037\040\041\042\043\044\045\046\047\050\051\052\053\054\055\056\057\060\061\062\063\064\065\066\067\070\071\072\073\074\075\076\077\100\101\102\103\104\105\106\107\110\111\112\113\114\115\116\117\120\121\122\123\124\125\126\127\130\131\132\133\134\135\136\137\140\141\142\143\144\145\146\147\150\151\152\153\154\155\156\157\160\161\162\163\164\165\166\167\170\171\172\173\174\175\176\177\200\201\202\203\204\205\206\207\210\211\212\213\214\215\216\217\220\221\222\223\224\225\226\227\230\231\232\233\234\235\236\237\240\241\242\243\244\245\246\247\250\251\252\253\254\255\256\257\260\261\262\263\264\265\266\267\270\271\272\273\274\275\276\277\300\301\302\303\304\305\306\307\310\311\312\313\314\315\316\317\320\321\322\323\324\325\326\327\330\331\332\333\334\335\336\337\340\341\342\343\344\345\346\347\350\351\352\353\354\355\356\357\360\361\362\363\364\365\366\367\370\371\372\373\374\375\376\377'
i=0
r=${(e)v}
printf '%s\0' "$r"
typeset -p v i
print -r -- comparison-complete
)
integer matrix_status=$?
print -r -- matrix-355-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R zsh
setopt nomultibyte
v=$'\000\001\002\003\004\005\006\007\010\011\012\013\014\015\016\017\020\021\022\023\024\025\026\027\030\031\032\033\034\035\036\037\040\041\042\043\044\045\046\047\050\051\052\053\054\055\056\057\060\061\062\063\064\065\066\067\070\071\072\073\074\075\076\077\100\101\102\103\104\105\106\107\110\111\112\113\114\115\116\117\120\121\122\123\124\125\126\127\130\131\132\133\134\135\136\137\140\141\142\143\144\145\146\147\150\151\152\153\154\155\156\157\160\161\162\163\164\165\166\167\170\171\172\173\174\175\176\177\200\201\202\203\204\205\206\207\210\211\212\213\214\215\216\217\220\221\222\223\224\225\226\227\230\231\232\233\234\235\236\237\240\241\242\243\244\245\246\247\250\251\252\253\254\255\256\257\260\261\262\263\264\265\266\267\270\271\272\273\274\275\276\277\300\301\302\303\304\305\306\307\310\311\312\313\314\315\316\317\320\321\322\323\324\325\326\327\330\331\332\333\334\335\336\337\340\341\342\343\344\345\346\347\350\351\352\353\354\355\356\357\360\361\362\363\364\365\366\367\370\371\372\373\374\375\376\377'
i=0
r=${(U)v}
printf '%s\0' "$r"
typeset -p v i
print -r -- comparison-complete
)
integer matrix_status=$?
print -r -- matrix-356-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R zsh
setopt nomultibyte
v=$'\000\001\002\003\004\005\006\007\010\011\012\013\014\015\016\017\020\021\022\023\024\025\026\027\030\031\032\033\034\035\036\037\040\041\042\043\044\045\046\047\050\051\052\053\054\055\056\057\060\061\062\063\064\065\066\067\070\071\072\073\074\075\076\077\100\101\102\103\104\105\106\107\110\111\112\113\114\115\116\117\120\121\122\123\124\125\126\127\130\131\132\133\134\135\136\137\140\141\142\143\144\145\146\147\150\151\152\153\154\155\156\157\160\161\162\163\164\165\166\167\170\171\172\173\174\175\176\177\200\201\202\203\204\205\206\207\210\211\212\213\214\215\216\217\220\221\222\223\224\225\226\227\230\231\232\233\234\235\236\237\240\241\242\243\244\245\246\247\250\251\252\253\254\255\256\257\260\261\262\263\264\265\266\267\270\271\272\273\274\275\276\277\300\301\302\303\304\305\306\307\310\311\312\313\314\315\316\317\320\321\322\323\324\325\326\327\330\331\332\333\334\335\336\337\340\341\342\343\344\345\346\347\350\351\352\353\354\355\356\357\360\361\362\363\364\365\366\367\370\371\372\373\374\375\376\377'
i=0
r=${v//x/REPLACED}
printf '%s\0' "$r"
typeset -p v i
print -r -- comparison-complete
)
integer matrix_status=$?
print -r -- matrix-357-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R zsh
setopt nomultibyte
v=$'\000\001\002\003\004\005\006\007\010\011\012\013\014\015\016\017\020\021\022\023\024\025\026\027\030\031\032\033\034\035\036\037\040\041\042\043\044\045\046\047\050\051\052\053\054\055\056\057\060\061\062\063\064\065\066\067\070\071\072\073\074\075\076\077\100\101\102\103\104\105\106\107\110\111\112\113\114\115\116\117\120\121\122\123\124\125\126\127\130\131\132\133\134\135\136\137\140\141\142\143\144\145\146\147\150\151\152\153\154\155\156\157\160\161\162\163\164\165\166\167\170\171\172\173\174\175\176\177\200\201\202\203\204\205\206\207\210\211\212\213\214\215\216\217\220\221\222\223\224\225\226\227\230\231\232\233\234\235\236\237\240\241\242\243\244\245\246\247\250\251\252\253\254\255\256\257\260\261\262\263\264\265\266\267\270\271\272\273\274\275\276\277\300\301\302\303\304\305\306\307\310\311\312\313\314\315\316\317\320\321\322\323\324\325\326\327\330\331\332\333\334\335\336\337\340\341\342\343\344\345\346\347\350\351\352\353\354\355\356\357\360\361\362\363\364\365\366\367\370\371\372\373\374\375\376\377'
i=0
r=$((++i))${v}$[i+=2]
printf '%s\0' "$r"
typeset -p v i
print -r -- comparison-complete
)
integer matrix_status=$?
print -r -- matrix-358-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R zsh
setopt nomultibyte
v=$'\000\001\002\003\004\005\006\007\010\011\012\013\014\015\016\017\020\021\022\023\024\025\026\027\030\031\032\033\034\035\036\037\040\041\042\043\044\045\046\047\050\051\052\053\054\055\056\057\060\061\062\063\064\065\066\067\070\071\072\073\074\075\076\077\100\101\102\103\104\105\106\107\110\111\112\113\114\115\116\117\120\121\122\123\124\125\126\127\130\131\132\133\134\135\136\137\140\141\142\143\144\145\146\147\150\151\152\153\154\155\156\157\160\161\162\163\164\165\166\167\170\171\172\173\174\175\176\177\200\201\202\203\204\205\206\207\210\211\212\213\214\215\216\217\220\221\222\223\224\225\226\227\230\231\232\233\234\235\236\237\240\241\242\243\244\245\246\247\250\251\252\253\254\255\256\257\260\261\262\263\264\265\266\267\270\271\272\273\274\275\276\277\300\301\302\303\304\305\306\307\310\311\312\313\314\315\316\317\320\321\322\323\324\325\326\327\330\331\332\333\334\335\336\337\340\341\342\343\344\345\346\347\350\351\352\353\354\355\356\357\360\361\362\363\364\365\366\367\370\371\372\373\374\375\376\377'
i=0
r=$(print -rn -- "before${v}after")
printf '%s\0' "$r"
typeset -p v i
print -r -- comparison-complete
)
integer matrix_status=$?
print -r -- matrix-359-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R zsh
setopt nomultibyte
v=$'\000\001\002\003\004\005\006\007\010\011\012\013\014\015\016\017\020\021\022\023\024\025\026\027\030\031\032\033\034\035\036\037\040\041\042\043\044\045\046\047\050\051\052\053\054\055\056\057\060\061\062\063\064\065\066\067\070\071\072\073\074\075\076\077\100\101\102\103\104\105\106\107\110\111\112\113\114\115\116\117\120\121\122\123\124\125\126\127\130\131\132\133\134\135\136\137\140\141\142\143\144\145\146\147\150\151\152\153\154\155\156\157\160\161\162\163\164\165\166\167\170\171\172\173\174\175\176\177\200\201\202\203\204\205\206\207\210\211\212\213\214\215\216\217\220\221\222\223\224\225\226\227\230\231\232\233\234\235\236\237\240\241\242\243\244\245\246\247\250\251\252\253\254\255\256\257\260\261\262\263\264\265\266\267\270\271\272\273\274\275\276\277\300\301\302\303\304\305\306\307\310\311\312\313\314\315\316\317\320\321\322\323\324\325\326\327\330\331\332\333\334\335\336\337\340\341\342\343\344\345\346\347\350\351\352\353\354\355\356\357\360\361\362\363\364\365\366\367\370\371\372\373\374\375\376\377'
i=0
r=`print -rn -- "before${v}after"`
printf '%s\0' "$r"
typeset -p v i
print -r -- comparison-complete
)
integer matrix_status=$?
print -r -- matrix-360-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R zsh
setopt nomultibyte
v=$'\000\001\002\003\004\005\006\007\010\011\012\013\014\015\016\017\020\021\022\023\024\025\026\027\030\031\032\033\034\035\036\037\040\041\042\043\044\045\046\047\050\051\052\053\054\055\056\057\060\061\062\063\064\065\066\067\070\071\072\073\074\075\076\077\100\101\102\103\104\105\106\107\110\111\112\113\114\115\116\117\120\121\122\123\124\125\126\127\130\131\132\133\134\135\136\137\140\141\142\143\144\145\146\147\150\151\152\153\154\155\156\157\160\161\162\163\164\165\166\167\170\171\172\173\174\175\176\177\200\201\202\203\204\205\206\207\210\211\212\213\214\215\216\217\220\221\222\223\224\225\226\227\230\231\232\233\234\235\236\237\240\241\242\243\244\245\246\247\250\251\252\253\254\255\256\257\260\261\262\263\264\265\266\267\270\271\272\273\274\275\276\277\300\301\302\303\304\305\306\307\310\311\312\313\314\315\316\317\320\321\322\323\324\325\326\327\330\331\332\333\334\335\336\337\340\341\342\343\344\345\346\347\350\351\352\353\354\355\356\357\360\361\362\363\364\365\366\367\370\371\372\373\374\375\376\377'
i=0
typeset r=key=${v}
printf '%s\0' "$r"
typeset -p v i
print -r -- comparison-complete
)
integer matrix_status=$?
print -r -- matrix-361-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R zsh
setopt nomultibyte
v=$'\000\001\002\003\004\005\006\007\010\011\012\013\014\015\016\017\020\021\022\023\024\025\026\027\030\031\032\033\034\035\036\037\040\041\042\043\044\045\046\047\050\051\052\053\054\055\056\057\060\061\062\063\064\065\066\067\070\071\072\073\074\075\076\077\100\101\102\103\104\105\106\107\110\111\112\113\114\115\116\117\120\121\122\123\124\125\126\127\130\131\132\133\134\135\136\137\140\141\142\143\144\145\146\147\150\151\152\153\154\155\156\157\160\161\162\163\164\165\166\167\170\171\172\173\174\175\176\177\200\201\202\203\204\205\206\207\210\211\212\213\214\215\216\217\220\221\222\223\224\225\226\227\230\231\232\233\234\235\236\237\240\241\242\243\244\245\246\247\250\251\252\253\254\255\256\257\260\261\262\263\264\265\266\267\270\271\272\273\274\275\276\277\300\301\302\303\304\305\306\307\310\311\312\313\314\315\316\317\320\321\322\323\324\325\326\327\330\331\332\333\334\335\336\337\340\341\342\343\344\345\346\347\350\351\352\353\354\355\356\357\360\361\362\363\364\365\366\367\370\371\372\373\374\375\376\377'
i=0
typeset r="key=${v}"
printf '%s\0' "$r"
typeset -p v i
print -r -- comparison-complete
)
integer matrix_status=$?
print -r -- matrix-362-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R zsh
setopt nomultibyte
v=$'\000\001\002\003\004\005\006\007\010\011\012\013\014\015\016\017\020\021\022\023\024\025\026\027\030\031\032\033\034\035\036\037\040\041\042\043\044\045\046\047\050\051\052\053\054\055\056\057\060\061\062\063\064\065\066\067\070\071\072\073\074\075\076\077\100\101\102\103\104\105\106\107\110\111\112\113\114\115\116\117\120\121\122\123\124\125\126\127\130\131\132\133\134\135\136\137\140\141\142\143\144\145\146\147\150\151\152\153\154\155\156\157\160\161\162\163\164\165\166\167\170\171\172\173\174\175\176\177\200\201\202\203\204\205\206\207\210\211\212\213\214\215\216\217\220\221\222\223\224\225\226\227\230\231\232\233\234\235\236\237\240\241\242\243\244\245\246\247\250\251\252\253\254\255\256\257\260\261\262\263\264\265\266\267\270\271\272\273\274\275\276\277\300\301\302\303\304\305\306\307\310\311\312\313\314\315\316\317\320\321\322\323\324\325\326\327\330\331\332\333\334\335\336\337\340\341\342\343\344\345\346\347\350\351\352\353\354\355\356\357\360\361\362\363\364\365\366\367\370\371\372\373\374\375\376\377'
i=0
export r=key=${v}
printf '%s\0' "$r"
typeset -p v i
print -r -- comparison-complete
)
integer matrix_status=$?
print -r -- matrix-363-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R zsh
setopt nomultibyte
v=$'\000\001\002\003\004\005\006\007\010\011\012\013\014\015\016\017\020\021\022\023\024\025\026\027\030\031\032\033\034\035\036\037\040\041\042\043\044\045\046\047\050\051\052\053\054\055\056\057\060\061\062\063\064\065\066\067\070\071\072\073\074\075\076\077\100\101\102\103\104\105\106\107\110\111\112\113\114\115\116\117\120\121\122\123\124\125\126\127\130\131\132\133\134\135\136\137\140\141\142\143\144\145\146\147\150\151\152\153\154\155\156\157\160\161\162\163\164\165\166\167\170\171\172\173\174\175\176\177\200\201\202\203\204\205\206\207\210\211\212\213\214\215\216\217\220\221\222\223\224\225\226\227\230\231\232\233\234\235\236\237\240\241\242\243\244\245\246\247\250\251\252\253\254\255\256\257\260\261\262\263\264\265\266\267\270\271\272\273\274\275\276\277\300\301\302\303\304\305\306\307\310\311\312\313\314\315\316\317\320\321\322\323\324\325\326\327\330\331\332\333\334\335\336\337\340\341\342\343\344\345\346\347\350\351\352\353\354\355\356\357\360\361\362\363\364\365\366\367\370\371\372\373\374\375\376\377'
i=0
typeset -a a; a=(before${v}after "key=${v}"); typeset -p a; r=$#a
printf '%s\0' "$r"
typeset -p v i
print -r -- comparison-complete
)
integer matrix_status=$?
print -r -- matrix-364-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R zsh
setopt nomultibyte
v=$'\000\001\002\003\004\005\006\007\010\011\012\013\014\015\016\017\020\021\022\023\024\025\026\027\030\031\032\033\034\035\036\037\040\041\042\043\044\045\046\047\050\051\052\053\054\055\056\057\060\061\062\063\064\065\066\067\070\071\072\073\074\075\076\077\100\101\102\103\104\105\106\107\110\111\112\113\114\115\116\117\120\121\122\123\124\125\126\127\130\131\132\133\134\135\136\137\140\141\142\143\144\145\146\147\150\151\152\153\154\155\156\157\160\161\162\163\164\165\166\167\170\171\172\173\174\175\176\177\200\201\202\203\204\205\206\207\210\211\212\213\214\215\216\217\220\221\222\223\224\225\226\227\230\231\232\233\234\235\236\237\240\241\242\243\244\245\246\247\250\251\252\253\254\255\256\257\260\261\262\263\264\265\266\267\270\271\272\273\274\275\276\277\300\301\302\303\304\305\306\307\310\311\312\313\314\315\316\317\320\321\322\323\324\325\326\327\330\331\332\333\334\335\336\337\340\341\342\343\344\345\346\347\350\351\352\353\354\355\356\357\360\361\362\363\364\365\366\367\370\371\372\373\374\375\376\377'
i=0
setopt shwordsplit; typeset -a a; a=(before${v}after); typeset -p a; r=$#a
printf '%s\0' "$r"
typeset -p v i
print -r -- comparison-complete
)
integer matrix_status=$?
print -r -- matrix-365-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R zsh
setopt nomultibyte
v=$'\000\001\002\003\004\005\006\007\010\011\012\013\014\015\016\017\020\021\022\023\024\025\026\027\030\031\032\033\034\035\036\037\040\041\042\043\044\045\046\047\050\051\052\053\054\055\056\057\060\061\062\063\064\065\066\067\070\071\072\073\074\075\076\077\100\101\102\103\104\105\106\107\110\111\112\113\114\115\116\117\120\121\122\123\124\125\126\127\130\131\132\133\134\135\136\137\140\141\142\143\144\145\146\147\150\151\152\153\154\155\156\157\160\161\162\163\164\165\166\167\170\171\172\173\174\175\176\177\200\201\202\203\204\205\206\207\210\211\212\213\214\215\216\217\220\221\222\223\224\225\226\227\230\231\232\233\234\235\236\237\240\241\242\243\244\245\246\247\250\251\252\253\254\255\256\257\260\261\262\263\264\265\266\267\270\271\272\273\274\275\276\277\300\301\302\303\304\305\306\307\310\311\312\313\314\315\316\317\320\321\322\323\324\325\326\327\330\331\332\333\334\335\336\337\340\341\342\343\344\345\346\347\350\351\352\353\354\355\356\357\360\361\362\363\364\365\366\367\370\371\372\373\374\375\376\377'
i=0
setopt magic_equal_subst; typeset r=key=${v}
printf '%s\0' "$r"
typeset -p v i
print -r -- comparison-complete
)
integer matrix_status=$?
print -r -- matrix-366-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R zsh
setopt nomultibyte
v=$'\000\001\002\003\004\005\006\007\010\011\012\013\014\015\016\017\020\021\022\023\024\025\026\027\030\031\032\033\034\035\036\037\040\041\042\043\044\045\046\047\050\051\052\053\054\055\056\057\060\061\062\063\064\065\066\067\070\071\072\073\074\075\076\077\100\101\102\103\104\105\106\107\110\111\112\113\114\115\116\117\120\121\122\123\124\125\126\127\130\131\132\133\134\135\136\137\140\141\142\143\144\145\146\147\150\151\152\153\154\155\156\157\160\161\162\163\164\165\166\167\170\171\172\173\174\175\176\177\200\201\202\203\204\205\206\207\210\211\212\213\214\215\216\217\220\221\222\223\224\225\226\227\230\231\232\233\234\235\236\237\240\241\242\243\244\245\246\247\250\251\252\253\254\255\256\257\260\261\262\263\264\265\266\267\270\271\272\273\274\275\276\277\300\301\302\303\304\305\306\307\310\311\312\313\314\315\316\317\320\321\322\323\324\325\326\327\330\331\332\333\334\335\336\337\340\341\342\343\344\345\346\347\350\351\352\353\354\355\356\357\360\361\362\363\364\365\366\367\370\371\372\373\374\375\376\377'
i=0
r="${v}$(print -rn -- mid)${v}"
printf '%s\0' "$r"
typeset -p v i
print -r -- comparison-complete
)
integer matrix_status=$?
print -r -- matrix-367-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R zsh
setopt nomultibyte
v=$'\000\001\002\003\004\005\006\007\010\011\012\013\014\015\016\017\020\021\022\023\024\025\026\027\030\031\032\033\034\035\036\037\040\041\042\043\044\045\046\047\050\051\052\053\054\055\056\057\060\061\062\063\064\065\066\067\070\071\072\073\074\075\076\077\100\101\102\103\104\105\106\107\110\111\112\113\114\115\116\117\120\121\122\123\124\125\126\127\130\131\132\133\134\135\136\137\140\141\142\143\144\145\146\147\150\151\152\153\154\155\156\157\160\161\162\163\164\165\166\167\170\171\172\173\174\175\176\177\200\201\202\203\204\205\206\207\210\211\212\213\214\215\216\217\220\221\222\223\224\225\226\227\230\231\232\233\234\235\236\237\240\241\242\243\244\245\246\247\250\251\252\253\254\255\256\257\260\261\262\263\264\265\266\267\270\271\272\273\274\275\276\277\300\301\302\303\304\305\306\307\310\311\312\313\314\315\316\317\320\321\322\323\324\325\326\327\330\331\332\333\334\335\336\337\340\341\342\343\344\345\346\347\350\351\352\353\354\355\356\357\360\361\362\363\364\365\366\367\370\371\372\373\374\375\376\377'
i=0
r="${v}${(j.:.)${(s: :)v}}${v}"
printf '%s\0' "$r"
typeset -p v i
print -r -- comparison-complete
)
integer matrix_status=$?
print -r -- matrix-368-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R zsh
setopt nomultibyte
v=$'\000\001\002\003\004\005\006\007\010\011\012\013\014\015\016\017\020\021\022\023\024\025\026\027\030\031\032\033\034\035\036\037\040\041\042\043\044\045\046\047\050\051\052\053\054\055\056\057\060\061\062\063\064\065\066\067\070\071\072\073\074\075\076\077\100\101\102\103\104\105\106\107\110\111\112\113\114\115\116\117\120\121\122\123\124\125\126\127\130\131\132\133\134\135\136\137\140\141\142\143\144\145\146\147\150\151\152\153\154\155\156\157\160\161\162\163\164\165\166\167\170\171\172\173\174\175\176\177\200\201\202\203\204\205\206\207\210\211\212\213\214\215\216\217\220\221\222\223\224\225\226\227\230\231\232\233\234\235\236\237\240\241\242\243\244\245\246\247\250\251\252\253\254\255\256\257\260\261\262\263\264\265\266\267\270\271\272\273\274\275\276\277\300\301\302\303\304\305\306\307\310\311\312\313\314\315\316\317\320\321\322\323\324\325\326\327\330\331\332\333\334\335\336\337\340\341\342\343\344\345\346\347\350\351\352\353\354\355\356\357\360\361\362\363\364\365\366\367\370\371\372\373\374\375\376\377'
i=0
r=$(< <(print -rn -- "$v"))
printf '%s\0' "$r"
typeset -p v i
print -r -- comparison-complete
)
integer matrix_status=$?
print -r -- matrix-369-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R zsh
setopt nomultibyte
v=$'\000\001\002\003\004\005\006\007\010\011\012\013\014\015\016\017\020\021\022\023\024\025\026\027\030\031\032\033\034\035\036\037\040\041\042\043\044\045\046\047\050\051\052\053\054\055\056\057\060\061\062\063\064\065\066\067\070\071\072\073\074\075\076\077\100\101\102\103\104\105\106\107\110\111\112\113\114\115\116\117\120\121\122\123\124\125\126\127\130\131\132\133\134\135\136\137\140\141\142\143\144\145\146\147\150\151\152\153\154\155\156\157\160\161\162\163\164\165\166\167\170\171\172\173\174\175\176\177\200\201\202\203\204\205\206\207\210\211\212\213\214\215\216\217\220\221\222\223\224\225\226\227\230\231\232\233\234\235\236\237\240\241\242\243\244\245\246\247\250\251\252\253\254\255\256\257\260\261\262\263\264\265\266\267\270\271\272\273\274\275\276\277\300\301\302\303\304\305\306\307\310\311\312\313\314\315\316\317\320\321\322\323\324\325\326\327\330\331\332\333\334\335\336\337\340\341\342\343\344\345\346\347\350\351\352\353\354\355\356\357\360\361\362\363\364\365\366\367\370\371\372\373\374\375\376\377'
i=0
readfile() { REPLY=$(< "$1"); }; readfile =(print -rn -- "$v"); r=$REPLY
printf '%s\0' "$r"
typeset -p v i
print -r -- comparison-complete
)
integer matrix_status=$?
print -r -- matrix-370-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R zsh
setopt nomultibyte
v=$'\000\001\002\003\004\005\006\007\010\011\012\013\014\015\016\017\020\021\022\023\024\025\026\027\030\031\032\033\034\035\036\037\040\041\042\043\044\045\046\047\050\051\052\053\054\055\056\057\060\061\062\063\064\065\066\067\070\071\072\073\074\075\076\077\100\101\102\103\104\105\106\107\110\111\112\113\114\115\116\117\120\121\122\123\124\125\126\127\130\131\132\133\134\135\136\137\140\141\142\143\144\145\146\147\150\151\152\153\154\155\156\157\160\161\162\163\164\165\166\167\170\171\172\173\174\175\176\177\200\201\202\203\204\205\206\207\210\211\212\213\214\215\216\217\220\221\222\223\224\225\226\227\230\231\232\233\234\235\236\237\240\241\242\243\244\245\246\247\250\251\252\253\254\255\256\257\260\261\262\263\264\265\266\267\270\271\272\273\274\275\276\277\300\301\302\303\304\305\306\307\310\311\312\313\314\315\316\317\320\321\322\323\324\325\326\327\330\331\332\333\334\335\336\337\340\341\342\343\344\345\346\347\350\351\352\353\354\355\356\357\360\361\362\363\364\365\366\367\370\371\372\373\374\375\376\377'
i=0
r=$(print -r -- "$v" > >(IFS= read -r line; print -rn -- "$line"))
printf '%s\0' "$r"
typeset -p v i
print -r -- comparison-complete
)
integer matrix_status=$?
print -r -- matrix-371-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R zsh
setopt nomultibyte
v=$'\000\001\002\003\004\005\006\007\010\011\012\013\014\015\016\017\020\021\022\023\024\025\026\027\030\031\032\033\034\035\036\037\040\041\042\043\044\045\046\047\050\051\052\053\054\055\056\057\060\061\062\063\064\065\066\067\070\071\072\073\074\075\076\077\100\101\102\103\104\105\106\107\110\111\112\113\114\115\116\117\120\121\122\123\124\125\126\127\130\131\132\133\134\135\136\137\140\141\142\143\144\145\146\147\150\151\152\153\154\155\156\157\160\161\162\163\164\165\166\167\170\171\172\173\174\175\176\177\200\201\202\203\204\205\206\207\210\211\212\213\214\215\216\217\220\221\222\223\224\225\226\227\230\231\232\233\234\235\236\237\240\241\242\243\244\245\246\247\250\251\252\253\254\255\256\257\260\261\262\263\264\265\266\267\270\271\272\273\274\275\276\277\300\301\302\303\304\305\306\307\310\311\312\313\314\315\316\317\320\321\322\323\324\325\326\327\330\331\332\333\334\335\336\337\340\341\342\343\344\345\346\347\350\351\352\353\354\355\356\357\360\361\362\363\364\365\366\367\370\371\372\373\374\375\376\377'
i=0
r="xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx${v}yyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyy$((++i))zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz"
printf '%s\0' "$r"
typeset -p v i
print -r -- comparison-complete
)
integer matrix_status=$?
print -r -- matrix-372-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R zsh
setopt nomultibyte
v=$'\000\001\002\003\004\005\006\007\010\011\012\013\014\015\016\017\020\021\022\023\024\025\026\027\030\031\032\033\034\035\036\037\040\041\042\043\044\045\046\047\050\051\052\053\054\055\056\057\060\061\062\063\064\065\066\067\070\071\072\073\074\075\076\077\100\101\102\103\104\105\106\107\110\111\112\113\114\115\116\117\120\121\122\123\124\125\126\127\130\131\132\133\134\135\136\137\140\141\142\143\144\145\146\147\150\151\152\153\154\155\156\157\160\161\162\163\164\165\166\167\170\171\172\173\174\175\176\177\200\201\202\203\204\205\206\207\210\211\212\213\214\215\216\217\220\221\222\223\224\225\226\227\230\231\232\233\234\235\236\237\240\241\242\243\244\245\246\247\250\251\252\253\254\255\256\257\260\261\262\263\264\265\266\267\270\271\272\273\274\275\276\277\300\301\302\303\304\305\306\307\310\311\312\313\314\315\316\317\320\321\322\323\324\325\326\327\330\331\332\333\334\335\336\337\340\341\342\343\344\345\346\347\350\351\352\353\354\355\356\357\360\361\362\363\364\365\366\367\370\371\372\373\374\375\376\377'
i=0
typeset r=xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx=${v}yyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyy
printf '%s\0' "$r"
typeset -p v i
print -r -- comparison-complete
)
integer matrix_status=$?
print -r -- matrix-373-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R zsh
setopt nomultibyte
v='xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx'
i=0
r=prefix${v}suffix
printf '%s\0' "$r"
typeset -p v i
print -r -- comparison-complete
)
integer matrix_status=$?
print -r -- matrix-374-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R zsh
setopt nomultibyte
v='xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx'
i=0
r="prefix${v}suffix"
printf '%s\0' "$r"
typeset -p v i
print -r -- comparison-complete
)
integer matrix_status=$?
print -r -- matrix-375-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R zsh
setopt nomultibyte
v='xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx'
i=0
r=${(qqq)v}
printf '%s\0' "$r"
typeset -p v i
print -r -- comparison-complete
)
integer matrix_status=$?
print -r -- matrix-376-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R zsh
setopt nomultibyte
v='xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx'
i=0
r=${(e)v}
printf '%s\0' "$r"
typeset -p v i
print -r -- comparison-complete
)
integer matrix_status=$?
print -r -- matrix-377-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R zsh
setopt nomultibyte
v='xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx'
i=0
r=${(U)v}
printf '%s\0' "$r"
typeset -p v i
print -r -- comparison-complete
)
integer matrix_status=$?
print -r -- matrix-378-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R zsh
setopt nomultibyte
v='xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx'
i=0
r=${v//x/REPLACED}
printf '%s\0' "$r"
typeset -p v i
print -r -- comparison-complete
)
integer matrix_status=$?
print -r -- matrix-379-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R zsh
setopt nomultibyte
v='xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx'
i=0
r=$((++i))${v}$[i+=2]
printf '%s\0' "$r"
typeset -p v i
print -r -- comparison-complete
)
integer matrix_status=$?
print -r -- matrix-380-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R zsh
setopt nomultibyte
v='xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx'
i=0
r=$(print -rn -- "before${v}after")
printf '%s\0' "$r"
typeset -p v i
print -r -- comparison-complete
)
integer matrix_status=$?
print -r -- matrix-381-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R zsh
setopt nomultibyte
v='xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx'
i=0
r=`print -rn -- "before${v}after"`
printf '%s\0' "$r"
typeset -p v i
print -r -- comparison-complete
)
integer matrix_status=$?
print -r -- matrix-382-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R zsh
setopt nomultibyte
v='xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx'
i=0
typeset r=key=${v}
printf '%s\0' "$r"
typeset -p v i
print -r -- comparison-complete
)
integer matrix_status=$?
print -r -- matrix-383-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R zsh
setopt nomultibyte
v='xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx'
i=0
typeset r="key=${v}"
printf '%s\0' "$r"
typeset -p v i
print -r -- comparison-complete
)
integer matrix_status=$?
print -r -- matrix-384-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R zsh
setopt nomultibyte
v='xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx'
i=0
export r=key=${v}
printf '%s\0' "$r"
typeset -p v i
print -r -- comparison-complete
)
integer matrix_status=$?
print -r -- matrix-385-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R zsh
setopt nomultibyte
v='xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx'
i=0
typeset -a a; a=(before${v}after "key=${v}"); typeset -p a; r=$#a
printf '%s\0' "$r"
typeset -p v i
print -r -- comparison-complete
)
integer matrix_status=$?
print -r -- matrix-386-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R zsh
setopt nomultibyte
v='xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx'
i=0
setopt shwordsplit; typeset -a a; a=(before${v}after); typeset -p a; r=$#a
printf '%s\0' "$r"
typeset -p v i
print -r -- comparison-complete
)
integer matrix_status=$?
print -r -- matrix-387-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R zsh
setopt nomultibyte
v='xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx'
i=0
setopt magic_equal_subst; typeset r=key=${v}
printf '%s\0' "$r"
typeset -p v i
print -r -- comparison-complete
)
integer matrix_status=$?
print -r -- matrix-388-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R zsh
setopt nomultibyte
v='xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx'
i=0
r="${v}$(print -rn -- mid)${v}"
printf '%s\0' "$r"
typeset -p v i
print -r -- comparison-complete
)
integer matrix_status=$?
print -r -- matrix-389-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R zsh
setopt nomultibyte
v='xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx'
i=0
r="${v}${(j.:.)${(s: :)v}}${v}"
printf '%s\0' "$r"
typeset -p v i
print -r -- comparison-complete
)
integer matrix_status=$?
print -r -- matrix-390-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R zsh
setopt nomultibyte
v='xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx'
i=0
r=$(< <(print -rn -- "$v"))
printf '%s\0' "$r"
typeset -p v i
print -r -- comparison-complete
)
integer matrix_status=$?
print -r -- matrix-391-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R zsh
setopt nomultibyte
v='xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx'
i=0
readfile() { REPLY=$(< "$1"); }; readfile =(print -rn -- "$v"); r=$REPLY
printf '%s\0' "$r"
typeset -p v i
print -r -- comparison-complete
)
integer matrix_status=$?
print -r -- matrix-392-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R zsh
setopt nomultibyte
v='xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx'
i=0
r=$(print -r -- "$v" > >(IFS= read -r line; print -rn -- "$line"))
printf '%s\0' "$r"
typeset -p v i
print -r -- comparison-complete
)
integer matrix_status=$?
print -r -- matrix-393-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R zsh
setopt nomultibyte
v='xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx'
i=0
r="xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx${v}yyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyy$((++i))zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz"
printf '%s\0' "$r"
typeset -p v i
print -r -- comparison-complete
)
integer matrix_status=$?
print -r -- matrix-394-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R zsh
setopt nomultibyte
v='xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx'
i=0
typeset r=xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx=${v}yyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyy
printf '%s\0' "$r"
typeset -p v i
print -r -- comparison-complete
)
integer matrix_status=$?
print -r -- matrix-395-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R zsh
setopt nomultibyte
v='xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx'
i=0
r=prefix${v}suffix
printf '%s\0' "$r"
typeset -p v i
print -r -- comparison-complete
)
integer matrix_status=$?
print -r -- matrix-396-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R zsh
setopt nomultibyte
v='xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx'
i=0
r="prefix${v}suffix"
printf '%s\0' "$r"
typeset -p v i
print -r -- comparison-complete
)
integer matrix_status=$?
print -r -- matrix-397-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R zsh
setopt nomultibyte
v='xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx'
i=0
r=${(qqq)v}
printf '%s\0' "$r"
typeset -p v i
print -r -- comparison-complete
)
integer matrix_status=$?
print -r -- matrix-398-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R zsh
setopt nomultibyte
v='xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx'
i=0
r=${(e)v}
printf '%s\0' "$r"
typeset -p v i
print -r -- comparison-complete
)
integer matrix_status=$?
print -r -- matrix-399-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R zsh
setopt nomultibyte
v='xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx'
i=0
r=${(U)v}
printf '%s\0' "$r"
typeset -p v i
print -r -- comparison-complete
)
integer matrix_status=$?
print -r -- matrix-400-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R zsh
setopt nomultibyte
v='xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx'
i=0
r=${v//x/REPLACED}
printf '%s\0' "$r"
typeset -p v i
print -r -- comparison-complete
)
integer matrix_status=$?
print -r -- matrix-401-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R zsh
setopt nomultibyte
v='xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx'
i=0
r=$((++i))${v}$[i+=2]
printf '%s\0' "$r"
typeset -p v i
print -r -- comparison-complete
)
integer matrix_status=$?
print -r -- matrix-402-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R zsh
setopt nomultibyte
v='xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx'
i=0
r=$(print -rn -- "before${v}after")
printf '%s\0' "$r"
typeset -p v i
print -r -- comparison-complete
)
integer matrix_status=$?
print -r -- matrix-403-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R zsh
setopt nomultibyte
v='xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx'
i=0
r=`print -rn -- "before${v}after"`
printf '%s\0' "$r"
typeset -p v i
print -r -- comparison-complete
)
integer matrix_status=$?
print -r -- matrix-404-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R zsh
setopt nomultibyte
v='xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx'
i=0
typeset r=key=${v}
printf '%s\0' "$r"
typeset -p v i
print -r -- comparison-complete
)
integer matrix_status=$?
print -r -- matrix-405-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R zsh
setopt nomultibyte
v='xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx'
i=0
typeset r="key=${v}"
printf '%s\0' "$r"
typeset -p v i
print -r -- comparison-complete
)
integer matrix_status=$?
print -r -- matrix-406-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R zsh
setopt nomultibyte
v='xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx'
i=0
export r=key=${v}
printf '%s\0' "$r"
typeset -p v i
print -r -- comparison-complete
)
integer matrix_status=$?
print -r -- matrix-407-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R zsh
setopt nomultibyte
v='xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx'
i=0
typeset -a a; a=(before${v}after "key=${v}"); typeset -p a; r=$#a
printf '%s\0' "$r"
typeset -p v i
print -r -- comparison-complete
)
integer matrix_status=$?
print -r -- matrix-408-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R zsh
setopt nomultibyte
v='xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx'
i=0
setopt shwordsplit; typeset -a a; a=(before${v}after); typeset -p a; r=$#a
printf '%s\0' "$r"
typeset -p v i
print -r -- comparison-complete
)
integer matrix_status=$?
print -r -- matrix-409-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R zsh
setopt nomultibyte
v='xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx'
i=0
setopt magic_equal_subst; typeset r=key=${v}
printf '%s\0' "$r"
typeset -p v i
print -r -- comparison-complete
)
integer matrix_status=$?
print -r -- matrix-410-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R zsh
setopt nomultibyte
v='xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx'
i=0
r="${v}$(print -rn -- mid)${v}"
printf '%s\0' "$r"
typeset -p v i
print -r -- comparison-complete
)
integer matrix_status=$?
print -r -- matrix-411-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R zsh
setopt nomultibyte
v='xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx'
i=0
r="${v}${(j.:.)${(s: :)v}}${v}"
printf '%s\0' "$r"
typeset -p v i
print -r -- comparison-complete
)
integer matrix_status=$?
print -r -- matrix-412-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R zsh
setopt nomultibyte
v='xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx'
i=0
r=$(< <(print -rn -- "$v"))
printf '%s\0' "$r"
typeset -p v i
print -r -- comparison-complete
)
integer matrix_status=$?
print -r -- matrix-413-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R zsh
setopt nomultibyte
v='xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx'
i=0
readfile() { REPLY=$(< "$1"); }; readfile =(print -rn -- "$v"); r=$REPLY
printf '%s\0' "$r"
typeset -p v i
print -r -- comparison-complete
)
integer matrix_status=$?
print -r -- matrix-414-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R zsh
setopt nomultibyte
v='xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx'
i=0
r=$(print -r -- "$v" > >(IFS= read -r line; print -rn -- "$line"))
printf '%s\0' "$r"
typeset -p v i
print -r -- comparison-complete
)
integer matrix_status=$?
print -r -- matrix-415-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R zsh
setopt nomultibyte
v='xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx'
i=0
r="xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx${v}yyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyy$((++i))zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz"
printf '%s\0' "$r"
typeset -p v i
print -r -- comparison-complete
)
integer matrix_status=$?
print -r -- matrix-416-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R zsh
setopt nomultibyte
v='xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx'
i=0
typeset r=xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx=${v}yyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyy
printf '%s\0' "$r"
typeset -p v i
print -r -- comparison-complete
)
integer matrix_status=$?
print -r -- matrix-417-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R zsh
setopt nomultibyte
v='ééééééééééééééééééééééééééééééé= xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx'
i=0
r=prefix${v}suffix
printf '%s\0' "$r"
typeset -p v i
print -r -- comparison-complete
)
integer matrix_status=$?
print -r -- matrix-418-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R zsh
setopt nomultibyte
v='ééééééééééééééééééééééééééééééé= xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx'
i=0
r="prefix${v}suffix"
printf '%s\0' "$r"
typeset -p v i
print -r -- comparison-complete
)
integer matrix_status=$?
print -r -- matrix-419-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R zsh
setopt nomultibyte
v='ééééééééééééééééééééééééééééééé= xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx'
i=0
r=${(qqq)v}
printf '%s\0' "$r"
typeset -p v i
print -r -- comparison-complete
)
integer matrix_status=$?
print -r -- matrix-420-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R zsh
setopt nomultibyte
v='ééééééééééééééééééééééééééééééé= xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx'
i=0
r=${(e)v}
printf '%s\0' "$r"
typeset -p v i
print -r -- comparison-complete
)
integer matrix_status=$?
print -r -- matrix-421-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R zsh
setopt nomultibyte
v='ééééééééééééééééééééééééééééééé= xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx'
i=0
r=${(U)v}
printf '%s\0' "$r"
typeset -p v i
print -r -- comparison-complete
)
integer matrix_status=$?
print -r -- matrix-422-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R zsh
setopt nomultibyte
v='ééééééééééééééééééééééééééééééé= xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx'
i=0
r=${v//x/REPLACED}
printf '%s\0' "$r"
typeset -p v i
print -r -- comparison-complete
)
integer matrix_status=$?
print -r -- matrix-423-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R zsh
setopt nomultibyte
v='ééééééééééééééééééééééééééééééé= xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx'
i=0
r=$((++i))${v}$[i+=2]
printf '%s\0' "$r"
typeset -p v i
print -r -- comparison-complete
)
integer matrix_status=$?
print -r -- matrix-424-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R zsh
setopt nomultibyte
v='ééééééééééééééééééééééééééééééé= xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx'
i=0
r=$(print -rn -- "before${v}after")
printf '%s\0' "$r"
typeset -p v i
print -r -- comparison-complete
)
integer matrix_status=$?
print -r -- matrix-425-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R zsh
setopt nomultibyte
v='ééééééééééééééééééééééééééééééé= xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx'
i=0
r=`print -rn -- "before${v}after"`
printf '%s\0' "$r"
typeset -p v i
print -r -- comparison-complete
)
integer matrix_status=$?
print -r -- matrix-426-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R zsh
setopt nomultibyte
v='ééééééééééééééééééééééééééééééé= xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx'
i=0
typeset r=key=${v}
printf '%s\0' "$r"
typeset -p v i
print -r -- comparison-complete
)
integer matrix_status=$?
print -r -- matrix-427-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R zsh
setopt nomultibyte
v='ééééééééééééééééééééééééééééééé= xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx'
i=0
typeset r="key=${v}"
printf '%s\0' "$r"
typeset -p v i
print -r -- comparison-complete
)
integer matrix_status=$?
print -r -- matrix-428-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R zsh
setopt nomultibyte
v='ééééééééééééééééééééééééééééééé= xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx'
i=0
export r=key=${v}
printf '%s\0' "$r"
typeset -p v i
print -r -- comparison-complete
)
integer matrix_status=$?
print -r -- matrix-429-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R zsh
setopt nomultibyte
v='ééééééééééééééééééééééééééééééé= xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx'
i=0
typeset -a a; a=(before${v}after "key=${v}"); typeset -p a; r=$#a
printf '%s\0' "$r"
typeset -p v i
print -r -- comparison-complete
)
integer matrix_status=$?
print -r -- matrix-430-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R zsh
setopt nomultibyte
v='ééééééééééééééééééééééééééééééé= xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx'
i=0
setopt shwordsplit; typeset -a a; a=(before${v}after); typeset -p a; r=$#a
printf '%s\0' "$r"
typeset -p v i
print -r -- comparison-complete
)
integer matrix_status=$?
print -r -- matrix-431-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R zsh
setopt nomultibyte
v='ééééééééééééééééééééééééééééééé= xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx'
i=0
setopt magic_equal_subst; typeset r=key=${v}
printf '%s\0' "$r"
typeset -p v i
print -r -- comparison-complete
)
integer matrix_status=$?
print -r -- matrix-432-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R zsh
setopt nomultibyte
v='ééééééééééééééééééééééééééééééé= xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx'
i=0
r="${v}$(print -rn -- mid)${v}"
printf '%s\0' "$r"
typeset -p v i
print -r -- comparison-complete
)
integer matrix_status=$?
print -r -- matrix-433-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R zsh
setopt nomultibyte
v='ééééééééééééééééééééééééééééééé= xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx'
i=0
r="${v}${(j.:.)${(s: :)v}}${v}"
printf '%s\0' "$r"
typeset -p v i
print -r -- comparison-complete
)
integer matrix_status=$?
print -r -- matrix-434-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R zsh
setopt nomultibyte
v='ééééééééééééééééééééééééééééééé= xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx'
i=0
r=$(< <(print -rn -- "$v"))
printf '%s\0' "$r"
typeset -p v i
print -r -- comparison-complete
)
integer matrix_status=$?
print -r -- matrix-435-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R zsh
setopt nomultibyte
v='ééééééééééééééééééééééééééééééé= xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx'
i=0
readfile() { REPLY=$(< "$1"); }; readfile =(print -rn -- "$v"); r=$REPLY
printf '%s\0' "$r"
typeset -p v i
print -r -- comparison-complete
)
integer matrix_status=$?
print -r -- matrix-436-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R zsh
setopt nomultibyte
v='ééééééééééééééééééééééééééééééé= xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx'
i=0
r=$(print -r -- "$v" > >(IFS= read -r line; print -rn -- "$line"))
printf '%s\0' "$r"
typeset -p v i
print -r -- comparison-complete
)
integer matrix_status=$?
print -r -- matrix-437-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R zsh
setopt nomultibyte
v='ééééééééééééééééééééééééééééééé= xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx'
i=0
r="xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx${v}yyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyy$((++i))zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz"
printf '%s\0' "$r"
typeset -p v i
print -r -- comparison-complete
)
integer matrix_status=$?
print -r -- matrix-438-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R zsh
setopt nomultibyte
v='ééééééééééééééééééééééééééééééé= xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx'
i=0
typeset r=xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx=${v}yyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyy
printf '%s\0' "$r"
typeset -p v i
print -r -- comparison-complete
)
integer matrix_status=$?
print -r -- matrix-439-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
print -r -- memcheck-complete failures=$failed_matrices
