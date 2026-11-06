integer failed_matrices=0
(
emulate -R zsh
setopt extendedglob multibyte
s=''
match=(); mbegin=(); mend=()
integer begin_at match_number
for needle in 'a' 'a*' '*' '?' '' 'missing' 'é*' $'a\0*' '(#b)(a*)'; do
  for begin_at in -9 -1 0 1 2 4 5 100; do
    for match_number in -2 -1 0 1 2; do
      out="${s[(ib:begin_at:n:match_number:)$needle]}"
      printf '%s\0' "$out"
      if [[ $needle == '(#b)(a*)' ]]; then typeset -p match mbegin mend; fi
    done
  done
done
for needle in 'a' 'a*' '*' '?' '' 'missing' 'é*' $'a\0*' '(#b)(a*)'; do
  for begin_at in -9 -1 0 1 2 4 5 100; do
    for match_number in -2 -1 0 1 2; do
      out="${s[(Ib:begin_at:n:match_number:)$needle]}"
      printf '%s\0' "$out"
      if [[ $needle == '(#b)(a*)' ]]; then typeset -p match mbegin mend; fi
    done
  done
done
for needle in 'a' 'a*' '*' '?' '' 'missing' 'é*' $'a\0*' '(#b)(a*)'; do
  for begin_at in -9 -1 0 1 2 4 5 100; do
    for match_number in -2 -1 0 1 2; do
      out="${s[(rb:begin_at:n:match_number:)$needle]}"
      printf '%s\0' "$out"
      if [[ $needle == '(#b)(a*)' ]]; then typeset -p match mbegin mend; fi
    done
  done
done
for needle in 'a' 'a*' '*' '?' '' 'missing' 'é*' $'a\0*' '(#b)(a*)'; do
  for begin_at in -9 -1 0 1 2 4 5 100; do
    for match_number in -2 -1 0 1 2; do
      out="${s[(Rb:begin_at:n:match_number:)$needle]}"
      printf '%s\0' "$out"
      if [[ $needle == '(#b)(a*)' ]]; then typeset -p match mbegin mend; fi
    done
  done
done
typeset -p s
print -r -- matrix-done

)
integer matrix_status=$?
print -r -- matrix-0-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R zsh
setopt extendedglob multibyte
s=''
match=(); mbegin=(); mend=()
for left in 'a' 'missing' '(#b)(a*)'; do
  for right in 'a' 'missing' '(#b)(a*)'; do
    out="${s[(r)$left,(r)$right]}"
    printf '%s\0' "$out"
    typeset -p match mbegin mend
  done
done
for left in 'a' 'missing' '(#b)(a*)'; do
  for right in 'a' 'missing' '(#b)(a*)'; do
    out="${s[(r)$left,(R)$right]}"
    printf '%s\0' "$out"
    typeset -p match mbegin mend
  done
done
for left in 'a' 'missing' '(#b)(a*)'; do
  for right in 'a' 'missing' '(#b)(a*)'; do
    out="${s[(R)$left,(r)$right]}"
    printf '%s\0' "$out"
    typeset -p match mbegin mend
  done
done
for left in 'a' 'missing' '(#b)(a*)'; do
  for right in 'a' 'missing' '(#b)(a*)'; do
    out="${s[(R)$left,(R)$right]}"
    printf '%s\0' "$out"
    typeset -p match mbegin mend
  done
done
typeset -p s
print -r -- matrix-done

)
integer matrix_status=$?
print -r -- matrix-1-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R zsh
setopt extendedglob multibyte
s='a'
match=(); mbegin=(); mend=()
integer begin_at match_number
for needle in 'a' 'a*' '*' '?' '' 'missing' 'é*' $'a\0*' '(#b)(a*)'; do
  for begin_at in -9 -1 0 1 2 4 5 100; do
    for match_number in -2 -1 0 1 2; do
      out="${s[(ib:begin_at:n:match_number:)$needle]}"
      printf '%s\0' "$out"
      if [[ $needle == '(#b)(a*)' ]]; then typeset -p match mbegin mend; fi
    done
  done
done
for needle in 'a' 'a*' '*' '?' '' 'missing' 'é*' $'a\0*' '(#b)(a*)'; do
  for begin_at in -9 -1 0 1 2 4 5 100; do
    for match_number in -2 -1 0 1 2; do
      out="${s[(Ib:begin_at:n:match_number:)$needle]}"
      printf '%s\0' "$out"
      if [[ $needle == '(#b)(a*)' ]]; then typeset -p match mbegin mend; fi
    done
  done
done
for needle in 'a' 'a*' '*' '?' '' 'missing' 'é*' $'a\0*' '(#b)(a*)'; do
  for begin_at in -9 -1 0 1 2 4 5 100; do
    for match_number in -2 -1 0 1 2; do
      out="${s[(rb:begin_at:n:match_number:)$needle]}"
      printf '%s\0' "$out"
      if [[ $needle == '(#b)(a*)' ]]; then typeset -p match mbegin mend; fi
    done
  done
done
for needle in 'a' 'a*' '*' '?' '' 'missing' 'é*' $'a\0*' '(#b)(a*)'; do
  for begin_at in -9 -1 0 1 2 4 5 100; do
    for match_number in -2 -1 0 1 2; do
      out="${s[(Rb:begin_at:n:match_number:)$needle]}"
      printf '%s\0' "$out"
      if [[ $needle == '(#b)(a*)' ]]; then typeset -p match mbegin mend; fi
    done
  done
done
typeset -p s
print -r -- matrix-done

)
integer matrix_status=$?
print -r -- matrix-2-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R zsh
setopt extendedglob multibyte
s='a'
match=(); mbegin=(); mend=()
for left in 'a' 'missing' '(#b)(a*)'; do
  for right in 'a' 'missing' '(#b)(a*)'; do
    out="${s[(r)$left,(r)$right]}"
    printf '%s\0' "$out"
    typeset -p match mbegin mend
  done
done
for left in 'a' 'missing' '(#b)(a*)'; do
  for right in 'a' 'missing' '(#b)(a*)'; do
    out="${s[(r)$left,(R)$right]}"
    printf '%s\0' "$out"
    typeset -p match mbegin mend
  done
done
for left in 'a' 'missing' '(#b)(a*)'; do
  for right in 'a' 'missing' '(#b)(a*)'; do
    out="${s[(R)$left,(r)$right]}"
    printf '%s\0' "$out"
    typeset -p match mbegin mend
  done
done
for left in 'a' 'missing' '(#b)(a*)'; do
  for right in 'a' 'missing' '(#b)(a*)'; do
    out="${s[(R)$left,(R)$right]}"
    printf '%s\0' "$out"
    typeset -p match mbegin mend
  done
done
typeset -p s
print -r -- matrix-done

)
integer matrix_status=$?
print -r -- matrix-3-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R zsh
setopt extendedglob multibyte
s='abc a def a'
match=(); mbegin=(); mend=()
integer begin_at match_number
for needle in 'a' 'a*' '*' '?' '' 'missing' 'é*' $'a\0*' '(#b)(a*)'; do
  for begin_at in -9 -1 0 1 2 4 5 100; do
    for match_number in -2 -1 0 1 2; do
      out="${s[(ib:begin_at:n:match_number:)$needle]}"
      printf '%s\0' "$out"
      if [[ $needle == '(#b)(a*)' ]]; then typeset -p match mbegin mend; fi
    done
  done
done
for needle in 'a' 'a*' '*' '?' '' 'missing' 'é*' $'a\0*' '(#b)(a*)'; do
  for begin_at in -9 -1 0 1 2 4 5 100; do
    for match_number in -2 -1 0 1 2; do
      out="${s[(Ib:begin_at:n:match_number:)$needle]}"
      printf '%s\0' "$out"
      if [[ $needle == '(#b)(a*)' ]]; then typeset -p match mbegin mend; fi
    done
  done
done
for needle in 'a' 'a*' '*' '?' '' 'missing' 'é*' $'a\0*' '(#b)(a*)'; do
  for begin_at in -9 -1 0 1 2 4 5 100; do
    for match_number in -2 -1 0 1 2; do
      out="${s[(rb:begin_at:n:match_number:)$needle]}"
      printf '%s\0' "$out"
      if [[ $needle == '(#b)(a*)' ]]; then typeset -p match mbegin mend; fi
    done
  done
done
for needle in 'a' 'a*' '*' '?' '' 'missing' 'é*' $'a\0*' '(#b)(a*)'; do
  for begin_at in -9 -1 0 1 2 4 5 100; do
    for match_number in -2 -1 0 1 2; do
      out="${s[(Rb:begin_at:n:match_number:)$needle]}"
      printf '%s\0' "$out"
      if [[ $needle == '(#b)(a*)' ]]; then typeset -p match mbegin mend; fi
    done
  done
done
typeset -p s
print -r -- matrix-done

)
integer matrix_status=$?
print -r -- matrix-4-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R zsh
setopt extendedglob multibyte
s='abc a def a'
match=(); mbegin=(); mend=()
for left in 'a' 'missing' '(#b)(a*)'; do
  for right in 'a' 'missing' '(#b)(a*)'; do
    out="${s[(r)$left,(r)$right]}"
    printf '%s\0' "$out"
    typeset -p match mbegin mend
  done
done
for left in 'a' 'missing' '(#b)(a*)'; do
  for right in 'a' 'missing' '(#b)(a*)'; do
    out="${s[(r)$left,(R)$right]}"
    printf '%s\0' "$out"
    typeset -p match mbegin mend
  done
done
for left in 'a' 'missing' '(#b)(a*)'; do
  for right in 'a' 'missing' '(#b)(a*)'; do
    out="${s[(R)$left,(r)$right]}"
    printf '%s\0' "$out"
    typeset -p match mbegin mend
  done
done
for left in 'a' 'missing' '(#b)(a*)'; do
  for right in 'a' 'missing' '(#b)(a*)'; do
    out="${s[(R)$left,(R)$right]}"
    printf '%s\0' "$out"
    typeset -p match mbegin mend
  done
done
typeset -p s
print -r -- matrix-done

)
integer matrix_status=$?
print -r -- matrix-5-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R zsh
setopt extendedglob multibyte
s='éa😀aé'
match=(); mbegin=(); mend=()
integer begin_at match_number
for needle in 'a' 'a*' '*' '?' '' 'missing' 'é*' $'a\0*' '(#b)(a*)'; do
  for begin_at in -9 -1 0 1 2 4 5 100; do
    for match_number in -2 -1 0 1 2; do
      out="${s[(ib:begin_at:n:match_number:)$needle]}"
      printf '%s\0' "$out"
      if [[ $needle == '(#b)(a*)' ]]; then typeset -p match mbegin mend; fi
    done
  done
done
for needle in 'a' 'a*' '*' '?' '' 'missing' 'é*' $'a\0*' '(#b)(a*)'; do
  for begin_at in -9 -1 0 1 2 4 5 100; do
    for match_number in -2 -1 0 1 2; do
      out="${s[(Ib:begin_at:n:match_number:)$needle]}"
      printf '%s\0' "$out"
      if [[ $needle == '(#b)(a*)' ]]; then typeset -p match mbegin mend; fi
    done
  done
done
for needle in 'a' 'a*' '*' '?' '' 'missing' 'é*' $'a\0*' '(#b)(a*)'; do
  for begin_at in -9 -1 0 1 2 4 5 100; do
    for match_number in -2 -1 0 1 2; do
      out="${s[(rb:begin_at:n:match_number:)$needle]}"
      printf '%s\0' "$out"
      if [[ $needle == '(#b)(a*)' ]]; then typeset -p match mbegin mend; fi
    done
  done
done
for needle in 'a' 'a*' '*' '?' '' 'missing' 'é*' $'a\0*' '(#b)(a*)'; do
  for begin_at in -9 -1 0 1 2 4 5 100; do
    for match_number in -2 -1 0 1 2; do
      out="${s[(Rb:begin_at:n:match_number:)$needle]}"
      printf '%s\0' "$out"
      if [[ $needle == '(#b)(a*)' ]]; then typeset -p match mbegin mend; fi
    done
  done
done
typeset -p s
print -r -- matrix-done

)
integer matrix_status=$?
print -r -- matrix-6-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R zsh
setopt extendedglob multibyte
s='éa😀aé'
match=(); mbegin=(); mend=()
for left in 'a' 'missing' '(#b)(a*)'; do
  for right in 'a' 'missing' '(#b)(a*)'; do
    out="${s[(r)$left,(r)$right]}"
    printf '%s\0' "$out"
    typeset -p match mbegin mend
  done
done
for left in 'a' 'missing' '(#b)(a*)'; do
  for right in 'a' 'missing' '(#b)(a*)'; do
    out="${s[(r)$left,(R)$right]}"
    printf '%s\0' "$out"
    typeset -p match mbegin mend
  done
done
for left in 'a' 'missing' '(#b)(a*)'; do
  for right in 'a' 'missing' '(#b)(a*)'; do
    out="${s[(R)$left,(r)$right]}"
    printf '%s\0' "$out"
    typeset -p match mbegin mend
  done
done
for left in 'a' 'missing' '(#b)(a*)'; do
  for right in 'a' 'missing' '(#b)(a*)'; do
    out="${s[(R)$left,(R)$right]}"
    printf '%s\0' "$out"
    typeset -p match mbegin mend
  done
done
typeset -p s
print -r -- matrix-done

)
integer matrix_status=$?
print -r -- matrix-7-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R zsh
setopt extendedglob multibyte
s=$'a\0b\203\377a'
match=(); mbegin=(); mend=()
integer begin_at match_number
for needle in 'a' 'a*' '*' '?' '' 'missing' 'é*' $'a\0*' '(#b)(a*)'; do
  for begin_at in -9 -1 0 1 2 4 5 100; do
    for match_number in -2 -1 0 1 2; do
      out="${s[(ib:begin_at:n:match_number:)$needle]}"
      printf '%s\0' "$out"
      if [[ $needle == '(#b)(a*)' ]]; then typeset -p match mbegin mend; fi
    done
  done
done
for needle in 'a' 'a*' '*' '?' '' 'missing' 'é*' $'a\0*' '(#b)(a*)'; do
  for begin_at in -9 -1 0 1 2 4 5 100; do
    for match_number in -2 -1 0 1 2; do
      out="${s[(Ib:begin_at:n:match_number:)$needle]}"
      printf '%s\0' "$out"
      if [[ $needle == '(#b)(a*)' ]]; then typeset -p match mbegin mend; fi
    done
  done
done
for needle in 'a' 'a*' '*' '?' '' 'missing' 'é*' $'a\0*' '(#b)(a*)'; do
  for begin_at in -9 -1 0 1 2 4 5 100; do
    for match_number in -2 -1 0 1 2; do
      out="${s[(rb:begin_at:n:match_number:)$needle]}"
      printf '%s\0' "$out"
      if [[ $needle == '(#b)(a*)' ]]; then typeset -p match mbegin mend; fi
    done
  done
done
for needle in 'a' 'a*' '*' '?' '' 'missing' 'é*' $'a\0*' '(#b)(a*)'; do
  for begin_at in -9 -1 0 1 2 4 5 100; do
    for match_number in -2 -1 0 1 2; do
      out="${s[(Rb:begin_at:n:match_number:)$needle]}"
      printf '%s\0' "$out"
      if [[ $needle == '(#b)(a*)' ]]; then typeset -p match mbegin mend; fi
    done
  done
done
typeset -p s
print -r -- matrix-done

)
integer matrix_status=$?
print -r -- matrix-8-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R zsh
setopt extendedglob multibyte
s=$'a\0b\203\377a'
match=(); mbegin=(); mend=()
for left in 'a' 'missing' '(#b)(a*)'; do
  for right in 'a' 'missing' '(#b)(a*)'; do
    out="${s[(r)$left,(r)$right]}"
    printf '%s\0' "$out"
    typeset -p match mbegin mend
  done
done
for left in 'a' 'missing' '(#b)(a*)'; do
  for right in 'a' 'missing' '(#b)(a*)'; do
    out="${s[(r)$left,(R)$right]}"
    printf '%s\0' "$out"
    typeset -p match mbegin mend
  done
done
for left in 'a' 'missing' '(#b)(a*)'; do
  for right in 'a' 'missing' '(#b)(a*)'; do
    out="${s[(R)$left,(r)$right]}"
    printf '%s\0' "$out"
    typeset -p match mbegin mend
  done
done
for left in 'a' 'missing' '(#b)(a*)'; do
  for right in 'a' 'missing' '(#b)(a*)'; do
    out="${s[(R)$left,(R)$right]}"
    printf '%s\0' "$out"
    typeset -p match mbegin mend
  done
done
typeset -p s
print -r -- matrix-done

)
integer matrix_status=$?
print -r -- matrix-9-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R zsh
setopt extendedglob multibyte
s='é 👩‍💻 a'
match=(); mbegin=(); mend=()
integer begin_at match_number
for needle in 'a' 'a*' '*' '?' '' 'missing' 'é*' $'a\0*' '(#b)(a*)'; do
  for begin_at in -9 -1 0 1 2 4 5 100; do
    for match_number in -2 -1 0 1 2; do
      out="${s[(ib:begin_at:n:match_number:)$needle]}"
      printf '%s\0' "$out"
      if [[ $needle == '(#b)(a*)' ]]; then typeset -p match mbegin mend; fi
    done
  done
done
for needle in 'a' 'a*' '*' '?' '' 'missing' 'é*' $'a\0*' '(#b)(a*)'; do
  for begin_at in -9 -1 0 1 2 4 5 100; do
    for match_number in -2 -1 0 1 2; do
      out="${s[(Ib:begin_at:n:match_number:)$needle]}"
      printf '%s\0' "$out"
      if [[ $needle == '(#b)(a*)' ]]; then typeset -p match mbegin mend; fi
    done
  done
done
for needle in 'a' 'a*' '*' '?' '' 'missing' 'é*' $'a\0*' '(#b)(a*)'; do
  for begin_at in -9 -1 0 1 2 4 5 100; do
    for match_number in -2 -1 0 1 2; do
      out="${s[(rb:begin_at:n:match_number:)$needle]}"
      printf '%s\0' "$out"
      if [[ $needle == '(#b)(a*)' ]]; then typeset -p match mbegin mend; fi
    done
  done
done
for needle in 'a' 'a*' '*' '?' '' 'missing' 'é*' $'a\0*' '(#b)(a*)'; do
  for begin_at in -9 -1 0 1 2 4 5 100; do
    for match_number in -2 -1 0 1 2; do
      out="${s[(Rb:begin_at:n:match_number:)$needle]}"
      printf '%s\0' "$out"
      if [[ $needle == '(#b)(a*)' ]]; then typeset -p match mbegin mend; fi
    done
  done
done
typeset -p s
print -r -- matrix-done

)
integer matrix_status=$?
print -r -- matrix-10-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R zsh
setopt extendedglob multibyte
s='é 👩‍💻 a'
match=(); mbegin=(); mend=()
for left in 'a' 'missing' '(#b)(a*)'; do
  for right in 'a' 'missing' '(#b)(a*)'; do
    out="${s[(r)$left,(r)$right]}"
    printf '%s\0' "$out"
    typeset -p match mbegin mend
  done
done
for left in 'a' 'missing' '(#b)(a*)'; do
  for right in 'a' 'missing' '(#b)(a*)'; do
    out="${s[(r)$left,(R)$right]}"
    printf '%s\0' "$out"
    typeset -p match mbegin mend
  done
done
for left in 'a' 'missing' '(#b)(a*)'; do
  for right in 'a' 'missing' '(#b)(a*)'; do
    out="${s[(R)$left,(r)$right]}"
    printf '%s\0' "$out"
    typeset -p match mbegin mend
  done
done
for left in 'a' 'missing' '(#b)(a*)'; do
  for right in 'a' 'missing' '(#b)(a*)'; do
    out="${s[(R)$left,(R)$right]}"
    printf '%s\0' "$out"
    typeset -p match mbegin mend
  done
done
typeset -p s
print -r -- matrix-done

)
integer matrix_status=$?
print -r -- matrix-11-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R zsh
setopt extendedglob multibyte
s=$'a\303\251b\303'
match=(); mbegin=(); mend=()
integer begin_at match_number
for needle in 'a' 'a*' '*' '?' '' 'missing' 'é*' $'a\0*' '(#b)(a*)'; do
  for begin_at in -9 -1 0 1 2 4 5 100; do
    for match_number in -2 -1 0 1 2; do
      out="${s[(ib:begin_at:n:match_number:)$needle]}"
      printf '%s\0' "$out"
      if [[ $needle == '(#b)(a*)' ]]; then typeset -p match mbegin mend; fi
    done
  done
done
for needle in 'a' 'a*' '*' '?' '' 'missing' 'é*' $'a\0*' '(#b)(a*)'; do
  for begin_at in -9 -1 0 1 2 4 5 100; do
    for match_number in -2 -1 0 1 2; do
      out="${s[(Ib:begin_at:n:match_number:)$needle]}"
      printf '%s\0' "$out"
      if [[ $needle == '(#b)(a*)' ]]; then typeset -p match mbegin mend; fi
    done
  done
done
for needle in 'a' 'a*' '*' '?' '' 'missing' 'é*' $'a\0*' '(#b)(a*)'; do
  for begin_at in -9 -1 0 1 2 4 5 100; do
    for match_number in -2 -1 0 1 2; do
      out="${s[(rb:begin_at:n:match_number:)$needle]}"
      printf '%s\0' "$out"
      if [[ $needle == '(#b)(a*)' ]]; then typeset -p match mbegin mend; fi
    done
  done
done
for needle in 'a' 'a*' '*' '?' '' 'missing' 'é*' $'a\0*' '(#b)(a*)'; do
  for begin_at in -9 -1 0 1 2 4 5 100; do
    for match_number in -2 -1 0 1 2; do
      out="${s[(Rb:begin_at:n:match_number:)$needle]}"
      printf '%s\0' "$out"
      if [[ $needle == '(#b)(a*)' ]]; then typeset -p match mbegin mend; fi
    done
  done
done
typeset -p s
print -r -- matrix-done

)
integer matrix_status=$?
print -r -- matrix-12-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R zsh
setopt extendedglob multibyte
s=$'a\303\251b\303'
match=(); mbegin=(); mend=()
for left in 'a' 'missing' '(#b)(a*)'; do
  for right in 'a' 'missing' '(#b)(a*)'; do
    out="${s[(r)$left,(r)$right]}"
    printf '%s\0' "$out"
    typeset -p match mbegin mend
  done
done
for left in 'a' 'missing' '(#b)(a*)'; do
  for right in 'a' 'missing' '(#b)(a*)'; do
    out="${s[(r)$left,(R)$right]}"
    printf '%s\0' "$out"
    typeset -p match mbegin mend
  done
done
for left in 'a' 'missing' '(#b)(a*)'; do
  for right in 'a' 'missing' '(#b)(a*)'; do
    out="${s[(R)$left,(r)$right]}"
    printf '%s\0' "$out"
    typeset -p match mbegin mend
  done
done
for left in 'a' 'missing' '(#b)(a*)'; do
  for right in 'a' 'missing' '(#b)(a*)'; do
    out="${s[(R)$left,(R)$right]}"
    printf '%s\0' "$out"
    typeset -p match mbegin mend
  done
done
typeset -p s
print -r -- matrix-done

)
integer matrix_status=$?
print -r -- matrix-13-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R zsh
setopt extendedglob nomultibyte
s=''
match=(); mbegin=(); mend=()
integer begin_at match_number
for needle in 'a' 'a*' '*' '?' '' 'missing' 'é*' $'a\0*' '(#b)(a*)'; do
  for begin_at in -9 -1 0 1 2 4 5 100; do
    for match_number in -2 -1 0 1 2; do
      out="${s[(ib:begin_at:n:match_number:)$needle]}"
      printf '%s\0' "$out"
      if [[ $needle == '(#b)(a*)' ]]; then typeset -p match mbegin mend; fi
    done
  done
done
for needle in 'a' 'a*' '*' '?' '' 'missing' 'é*' $'a\0*' '(#b)(a*)'; do
  for begin_at in -9 -1 0 1 2 4 5 100; do
    for match_number in -2 -1 0 1 2; do
      out="${s[(Ib:begin_at:n:match_number:)$needle]}"
      printf '%s\0' "$out"
      if [[ $needle == '(#b)(a*)' ]]; then typeset -p match mbegin mend; fi
    done
  done
done
for needle in 'a' 'a*' '*' '?' '' 'missing' 'é*' $'a\0*' '(#b)(a*)'; do
  for begin_at in -9 -1 0 1 2 4 5 100; do
    for match_number in -2 -1 0 1 2; do
      out="${s[(rb:begin_at:n:match_number:)$needle]}"
      printf '%s\0' "$out"
      if [[ $needle == '(#b)(a*)' ]]; then typeset -p match mbegin mend; fi
    done
  done
done
for needle in 'a' 'a*' '*' '?' '' 'missing' 'é*' $'a\0*' '(#b)(a*)'; do
  for begin_at in -9 -1 0 1 2 4 5 100; do
    for match_number in -2 -1 0 1 2; do
      out="${s[(Rb:begin_at:n:match_number:)$needle]}"
      printf '%s\0' "$out"
      if [[ $needle == '(#b)(a*)' ]]; then typeset -p match mbegin mend; fi
    done
  done
done
typeset -p s
print -r -- matrix-done

)
integer matrix_status=$?
print -r -- matrix-14-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R zsh
setopt extendedglob nomultibyte
s=''
match=(); mbegin=(); mend=()
for left in 'a' 'missing' '(#b)(a*)'; do
  for right in 'a' 'missing' '(#b)(a*)'; do
    out="${s[(r)$left,(r)$right]}"
    printf '%s\0' "$out"
    typeset -p match mbegin mend
  done
done
for left in 'a' 'missing' '(#b)(a*)'; do
  for right in 'a' 'missing' '(#b)(a*)'; do
    out="${s[(r)$left,(R)$right]}"
    printf '%s\0' "$out"
    typeset -p match mbegin mend
  done
done
for left in 'a' 'missing' '(#b)(a*)'; do
  for right in 'a' 'missing' '(#b)(a*)'; do
    out="${s[(R)$left,(r)$right]}"
    printf '%s\0' "$out"
    typeset -p match mbegin mend
  done
done
for left in 'a' 'missing' '(#b)(a*)'; do
  for right in 'a' 'missing' '(#b)(a*)'; do
    out="${s[(R)$left,(R)$right]}"
    printf '%s\0' "$out"
    typeset -p match mbegin mend
  done
done
typeset -p s
print -r -- matrix-done

)
integer matrix_status=$?
print -r -- matrix-15-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R zsh
setopt extendedglob nomultibyte
s='a'
match=(); mbegin=(); mend=()
integer begin_at match_number
for needle in 'a' 'a*' '*' '?' '' 'missing' 'é*' $'a\0*' '(#b)(a*)'; do
  for begin_at in -9 -1 0 1 2 4 5 100; do
    for match_number in -2 -1 0 1 2; do
      out="${s[(ib:begin_at:n:match_number:)$needle]}"
      printf '%s\0' "$out"
      if [[ $needle == '(#b)(a*)' ]]; then typeset -p match mbegin mend; fi
    done
  done
done
for needle in 'a' 'a*' '*' '?' '' 'missing' 'é*' $'a\0*' '(#b)(a*)'; do
  for begin_at in -9 -1 0 1 2 4 5 100; do
    for match_number in -2 -1 0 1 2; do
      out="${s[(Ib:begin_at:n:match_number:)$needle]}"
      printf '%s\0' "$out"
      if [[ $needle == '(#b)(a*)' ]]; then typeset -p match mbegin mend; fi
    done
  done
done
for needle in 'a' 'a*' '*' '?' '' 'missing' 'é*' $'a\0*' '(#b)(a*)'; do
  for begin_at in -9 -1 0 1 2 4 5 100; do
    for match_number in -2 -1 0 1 2; do
      out="${s[(rb:begin_at:n:match_number:)$needle]}"
      printf '%s\0' "$out"
      if [[ $needle == '(#b)(a*)' ]]; then typeset -p match mbegin mend; fi
    done
  done
done
for needle in 'a' 'a*' '*' '?' '' 'missing' 'é*' $'a\0*' '(#b)(a*)'; do
  for begin_at in -9 -1 0 1 2 4 5 100; do
    for match_number in -2 -1 0 1 2; do
      out="${s[(Rb:begin_at:n:match_number:)$needle]}"
      printf '%s\0' "$out"
      if [[ $needle == '(#b)(a*)' ]]; then typeset -p match mbegin mend; fi
    done
  done
done
typeset -p s
print -r -- matrix-done

)
integer matrix_status=$?
print -r -- matrix-16-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R zsh
setopt extendedglob nomultibyte
s='a'
match=(); mbegin=(); mend=()
for left in 'a' 'missing' '(#b)(a*)'; do
  for right in 'a' 'missing' '(#b)(a*)'; do
    out="${s[(r)$left,(r)$right]}"
    printf '%s\0' "$out"
    typeset -p match mbegin mend
  done
done
for left in 'a' 'missing' '(#b)(a*)'; do
  for right in 'a' 'missing' '(#b)(a*)'; do
    out="${s[(r)$left,(R)$right]}"
    printf '%s\0' "$out"
    typeset -p match mbegin mend
  done
done
for left in 'a' 'missing' '(#b)(a*)'; do
  for right in 'a' 'missing' '(#b)(a*)'; do
    out="${s[(R)$left,(r)$right]}"
    printf '%s\0' "$out"
    typeset -p match mbegin mend
  done
done
for left in 'a' 'missing' '(#b)(a*)'; do
  for right in 'a' 'missing' '(#b)(a*)'; do
    out="${s[(R)$left,(R)$right]}"
    printf '%s\0' "$out"
    typeset -p match mbegin mend
  done
done
typeset -p s
print -r -- matrix-done

)
integer matrix_status=$?
print -r -- matrix-17-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R zsh
setopt extendedglob nomultibyte
s='abc a def a'
match=(); mbegin=(); mend=()
integer begin_at match_number
for needle in 'a' 'a*' '*' '?' '' 'missing' 'é*' $'a\0*' '(#b)(a*)'; do
  for begin_at in -9 -1 0 1 2 4 5 100; do
    for match_number in -2 -1 0 1 2; do
      out="${s[(ib:begin_at:n:match_number:)$needle]}"
      printf '%s\0' "$out"
      if [[ $needle == '(#b)(a*)' ]]; then typeset -p match mbegin mend; fi
    done
  done
done
for needle in 'a' 'a*' '*' '?' '' 'missing' 'é*' $'a\0*' '(#b)(a*)'; do
  for begin_at in -9 -1 0 1 2 4 5 100; do
    for match_number in -2 -1 0 1 2; do
      out="${s[(Ib:begin_at:n:match_number:)$needle]}"
      printf '%s\0' "$out"
      if [[ $needle == '(#b)(a*)' ]]; then typeset -p match mbegin mend; fi
    done
  done
done
for needle in 'a' 'a*' '*' '?' '' 'missing' 'é*' $'a\0*' '(#b)(a*)'; do
  for begin_at in -9 -1 0 1 2 4 5 100; do
    for match_number in -2 -1 0 1 2; do
      out="${s[(rb:begin_at:n:match_number:)$needle]}"
      printf '%s\0' "$out"
      if [[ $needle == '(#b)(a*)' ]]; then typeset -p match mbegin mend; fi
    done
  done
done
for needle in 'a' 'a*' '*' '?' '' 'missing' 'é*' $'a\0*' '(#b)(a*)'; do
  for begin_at in -9 -1 0 1 2 4 5 100; do
    for match_number in -2 -1 0 1 2; do
      out="${s[(Rb:begin_at:n:match_number:)$needle]}"
      printf '%s\0' "$out"
      if [[ $needle == '(#b)(a*)' ]]; then typeset -p match mbegin mend; fi
    done
  done
done
typeset -p s
print -r -- matrix-done

)
integer matrix_status=$?
print -r -- matrix-18-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R zsh
setopt extendedglob nomultibyte
s='abc a def a'
match=(); mbegin=(); mend=()
for left in 'a' 'missing' '(#b)(a*)'; do
  for right in 'a' 'missing' '(#b)(a*)'; do
    out="${s[(r)$left,(r)$right]}"
    printf '%s\0' "$out"
    typeset -p match mbegin mend
  done
done
for left in 'a' 'missing' '(#b)(a*)'; do
  for right in 'a' 'missing' '(#b)(a*)'; do
    out="${s[(r)$left,(R)$right]}"
    printf '%s\0' "$out"
    typeset -p match mbegin mend
  done
done
for left in 'a' 'missing' '(#b)(a*)'; do
  for right in 'a' 'missing' '(#b)(a*)'; do
    out="${s[(R)$left,(r)$right]}"
    printf '%s\0' "$out"
    typeset -p match mbegin mend
  done
done
for left in 'a' 'missing' '(#b)(a*)'; do
  for right in 'a' 'missing' '(#b)(a*)'; do
    out="${s[(R)$left,(R)$right]}"
    printf '%s\0' "$out"
    typeset -p match mbegin mend
  done
done
typeset -p s
print -r -- matrix-done

)
integer matrix_status=$?
print -r -- matrix-19-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R zsh
setopt extendedglob nomultibyte
s='éa😀aé'
match=(); mbegin=(); mend=()
integer begin_at match_number
for needle in 'a' 'a*' '*' '?' '' 'missing' 'é*' $'a\0*' '(#b)(a*)'; do
  for begin_at in -9 -1 0 1 2 4 5 100; do
    for match_number in -2 -1 0 1 2; do
      out="${s[(ib:begin_at:n:match_number:)$needle]}"
      printf '%s\0' "$out"
      if [[ $needle == '(#b)(a*)' ]]; then typeset -p match mbegin mend; fi
    done
  done
done
for needle in 'a' 'a*' '*' '?' '' 'missing' 'é*' $'a\0*' '(#b)(a*)'; do
  for begin_at in -9 -1 0 1 2 4 5 100; do
    for match_number in -2 -1 0 1 2; do
      out="${s[(Ib:begin_at:n:match_number:)$needle]}"
      printf '%s\0' "$out"
      if [[ $needle == '(#b)(a*)' ]]; then typeset -p match mbegin mend; fi
    done
  done
done
for needle in 'a' 'a*' '*' '?' '' 'missing' 'é*' $'a\0*' '(#b)(a*)'; do
  for begin_at in -9 -1 0 1 2 4 5 100; do
    for match_number in -2 -1 0 1 2; do
      out="${s[(rb:begin_at:n:match_number:)$needle]}"
      printf '%s\0' "$out"
      if [[ $needle == '(#b)(a*)' ]]; then typeset -p match mbegin mend; fi
    done
  done
done
for needle in 'a' 'a*' '*' '?' '' 'missing' 'é*' $'a\0*' '(#b)(a*)'; do
  for begin_at in -9 -1 0 1 2 4 5 100; do
    for match_number in -2 -1 0 1 2; do
      out="${s[(Rb:begin_at:n:match_number:)$needle]}"
      printf '%s\0' "$out"
      if [[ $needle == '(#b)(a*)' ]]; then typeset -p match mbegin mend; fi
    done
  done
done
typeset -p s
print -r -- matrix-done

)
integer matrix_status=$?
print -r -- matrix-20-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R zsh
setopt extendedglob nomultibyte
s='éa😀aé'
match=(); mbegin=(); mend=()
for left in 'a' 'missing' '(#b)(a*)'; do
  for right in 'a' 'missing' '(#b)(a*)'; do
    out="${s[(r)$left,(r)$right]}"
    printf '%s\0' "$out"
    typeset -p match mbegin mend
  done
done
for left in 'a' 'missing' '(#b)(a*)'; do
  for right in 'a' 'missing' '(#b)(a*)'; do
    out="${s[(r)$left,(R)$right]}"
    printf '%s\0' "$out"
    typeset -p match mbegin mend
  done
done
for left in 'a' 'missing' '(#b)(a*)'; do
  for right in 'a' 'missing' '(#b)(a*)'; do
    out="${s[(R)$left,(r)$right]}"
    printf '%s\0' "$out"
    typeset -p match mbegin mend
  done
done
for left in 'a' 'missing' '(#b)(a*)'; do
  for right in 'a' 'missing' '(#b)(a*)'; do
    out="${s[(R)$left,(R)$right]}"
    printf '%s\0' "$out"
    typeset -p match mbegin mend
  done
done
typeset -p s
print -r -- matrix-done

)
integer matrix_status=$?
print -r -- matrix-21-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R zsh
setopt extendedglob nomultibyte
s=$'a\0b\203\377a'
match=(); mbegin=(); mend=()
integer begin_at match_number
for needle in 'a' 'a*' '*' '?' '' 'missing' 'é*' $'a\0*' '(#b)(a*)'; do
  for begin_at in -9 -1 0 1 2 4 5 100; do
    for match_number in -2 -1 0 1 2; do
      out="${s[(ib:begin_at:n:match_number:)$needle]}"
      printf '%s\0' "$out"
      if [[ $needle == '(#b)(a*)' ]]; then typeset -p match mbegin mend; fi
    done
  done
done
for needle in 'a' 'a*' '*' '?' '' 'missing' 'é*' $'a\0*' '(#b)(a*)'; do
  for begin_at in -9 -1 0 1 2 4 5 100; do
    for match_number in -2 -1 0 1 2; do
      out="${s[(Ib:begin_at:n:match_number:)$needle]}"
      printf '%s\0' "$out"
      if [[ $needle == '(#b)(a*)' ]]; then typeset -p match mbegin mend; fi
    done
  done
done
for needle in 'a' 'a*' '*' '?' '' 'missing' 'é*' $'a\0*' '(#b)(a*)'; do
  for begin_at in -9 -1 0 1 2 4 5 100; do
    for match_number in -2 -1 0 1 2; do
      out="${s[(rb:begin_at:n:match_number:)$needle]}"
      printf '%s\0' "$out"
      if [[ $needle == '(#b)(a*)' ]]; then typeset -p match mbegin mend; fi
    done
  done
done
for needle in 'a' 'a*' '*' '?' '' 'missing' 'é*' $'a\0*' '(#b)(a*)'; do
  for begin_at in -9 -1 0 1 2 4 5 100; do
    for match_number in -2 -1 0 1 2; do
      out="${s[(Rb:begin_at:n:match_number:)$needle]}"
      printf '%s\0' "$out"
      if [[ $needle == '(#b)(a*)' ]]; then typeset -p match mbegin mend; fi
    done
  done
done
typeset -p s
print -r -- matrix-done

)
integer matrix_status=$?
print -r -- matrix-22-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R zsh
setopt extendedglob nomultibyte
s=$'a\0b\203\377a'
match=(); mbegin=(); mend=()
for left in 'a' 'missing' '(#b)(a*)'; do
  for right in 'a' 'missing' '(#b)(a*)'; do
    out="${s[(r)$left,(r)$right]}"
    printf '%s\0' "$out"
    typeset -p match mbegin mend
  done
done
for left in 'a' 'missing' '(#b)(a*)'; do
  for right in 'a' 'missing' '(#b)(a*)'; do
    out="${s[(r)$left,(R)$right]}"
    printf '%s\0' "$out"
    typeset -p match mbegin mend
  done
done
for left in 'a' 'missing' '(#b)(a*)'; do
  for right in 'a' 'missing' '(#b)(a*)'; do
    out="${s[(R)$left,(r)$right]}"
    printf '%s\0' "$out"
    typeset -p match mbegin mend
  done
done
for left in 'a' 'missing' '(#b)(a*)'; do
  for right in 'a' 'missing' '(#b)(a*)'; do
    out="${s[(R)$left,(R)$right]}"
    printf '%s\0' "$out"
    typeset -p match mbegin mend
  done
done
typeset -p s
print -r -- matrix-done

)
integer matrix_status=$?
print -r -- matrix-23-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R zsh
setopt extendedglob nomultibyte
s='é 👩‍💻 a'
match=(); mbegin=(); mend=()
integer begin_at match_number
for needle in 'a' 'a*' '*' '?' '' 'missing' 'é*' $'a\0*' '(#b)(a*)'; do
  for begin_at in -9 -1 0 1 2 4 5 100; do
    for match_number in -2 -1 0 1 2; do
      out="${s[(ib:begin_at:n:match_number:)$needle]}"
      printf '%s\0' "$out"
      if [[ $needle == '(#b)(a*)' ]]; then typeset -p match mbegin mend; fi
    done
  done
done
for needle in 'a' 'a*' '*' '?' '' 'missing' 'é*' $'a\0*' '(#b)(a*)'; do
  for begin_at in -9 -1 0 1 2 4 5 100; do
    for match_number in -2 -1 0 1 2; do
      out="${s[(Ib:begin_at:n:match_number:)$needle]}"
      printf '%s\0' "$out"
      if [[ $needle == '(#b)(a*)' ]]; then typeset -p match mbegin mend; fi
    done
  done
done
for needle in 'a' 'a*' '*' '?' '' 'missing' 'é*' $'a\0*' '(#b)(a*)'; do
  for begin_at in -9 -1 0 1 2 4 5 100; do
    for match_number in -2 -1 0 1 2; do
      out="${s[(rb:begin_at:n:match_number:)$needle]}"
      printf '%s\0' "$out"
      if [[ $needle == '(#b)(a*)' ]]; then typeset -p match mbegin mend; fi
    done
  done
done
for needle in 'a' 'a*' '*' '?' '' 'missing' 'é*' $'a\0*' '(#b)(a*)'; do
  for begin_at in -9 -1 0 1 2 4 5 100; do
    for match_number in -2 -1 0 1 2; do
      out="${s[(Rb:begin_at:n:match_number:)$needle]}"
      printf '%s\0' "$out"
      if [[ $needle == '(#b)(a*)' ]]; then typeset -p match mbegin mend; fi
    done
  done
done
typeset -p s
print -r -- matrix-done

)
integer matrix_status=$?
print -r -- matrix-24-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R zsh
setopt extendedglob nomultibyte
s='é 👩‍💻 a'
match=(); mbegin=(); mend=()
for left in 'a' 'missing' '(#b)(a*)'; do
  for right in 'a' 'missing' '(#b)(a*)'; do
    out="${s[(r)$left,(r)$right]}"
    printf '%s\0' "$out"
    typeset -p match mbegin mend
  done
done
for left in 'a' 'missing' '(#b)(a*)'; do
  for right in 'a' 'missing' '(#b)(a*)'; do
    out="${s[(r)$left,(R)$right]}"
    printf '%s\0' "$out"
    typeset -p match mbegin mend
  done
done
for left in 'a' 'missing' '(#b)(a*)'; do
  for right in 'a' 'missing' '(#b)(a*)'; do
    out="${s[(R)$left,(r)$right]}"
    printf '%s\0' "$out"
    typeset -p match mbegin mend
  done
done
for left in 'a' 'missing' '(#b)(a*)'; do
  for right in 'a' 'missing' '(#b)(a*)'; do
    out="${s[(R)$left,(R)$right]}"
    printf '%s\0' "$out"
    typeset -p match mbegin mend
  done
done
typeset -p s
print -r -- matrix-done

)
integer matrix_status=$?
print -r -- matrix-25-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R zsh
setopt extendedglob nomultibyte
s=$'a\303\251b\303'
match=(); mbegin=(); mend=()
integer begin_at match_number
for needle in 'a' 'a*' '*' '?' '' 'missing' 'é*' $'a\0*' '(#b)(a*)'; do
  for begin_at in -9 -1 0 1 2 4 5 100; do
    for match_number in -2 -1 0 1 2; do
      out="${s[(ib:begin_at:n:match_number:)$needle]}"
      printf '%s\0' "$out"
      if [[ $needle == '(#b)(a*)' ]]; then typeset -p match mbegin mend; fi
    done
  done
done
for needle in 'a' 'a*' '*' '?' '' 'missing' 'é*' $'a\0*' '(#b)(a*)'; do
  for begin_at in -9 -1 0 1 2 4 5 100; do
    for match_number in -2 -1 0 1 2; do
      out="${s[(Ib:begin_at:n:match_number:)$needle]}"
      printf '%s\0' "$out"
      if [[ $needle == '(#b)(a*)' ]]; then typeset -p match mbegin mend; fi
    done
  done
done
for needle in 'a' 'a*' '*' '?' '' 'missing' 'é*' $'a\0*' '(#b)(a*)'; do
  for begin_at in -9 -1 0 1 2 4 5 100; do
    for match_number in -2 -1 0 1 2; do
      out="${s[(rb:begin_at:n:match_number:)$needle]}"
      printf '%s\0' "$out"
      if [[ $needle == '(#b)(a*)' ]]; then typeset -p match mbegin mend; fi
    done
  done
done
for needle in 'a' 'a*' '*' '?' '' 'missing' 'é*' $'a\0*' '(#b)(a*)'; do
  for begin_at in -9 -1 0 1 2 4 5 100; do
    for match_number in -2 -1 0 1 2; do
      out="${s[(Rb:begin_at:n:match_number:)$needle]}"
      printf '%s\0' "$out"
      if [[ $needle == '(#b)(a*)' ]]; then typeset -p match mbegin mend; fi
    done
  done
done
typeset -p s
print -r -- matrix-done

)
integer matrix_status=$?
print -r -- matrix-26-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R zsh
setopt extendedglob nomultibyte
s=$'a\303\251b\303'
match=(); mbegin=(); mend=()
for left in 'a' 'missing' '(#b)(a*)'; do
  for right in 'a' 'missing' '(#b)(a*)'; do
    out="${s[(r)$left,(r)$right]}"
    printf '%s\0' "$out"
    typeset -p match mbegin mend
  done
done
for left in 'a' 'missing' '(#b)(a*)'; do
  for right in 'a' 'missing' '(#b)(a*)'; do
    out="${s[(r)$left,(R)$right]}"
    printf '%s\0' "$out"
    typeset -p match mbegin mend
  done
done
for left in 'a' 'missing' '(#b)(a*)'; do
  for right in 'a' 'missing' '(#b)(a*)'; do
    out="${s[(R)$left,(r)$right]}"
    printf '%s\0' "$out"
    typeset -p match mbegin mend
  done
done
for left in 'a' 'missing' '(#b)(a*)'; do
  for right in 'a' 'missing' '(#b)(a*)'; do
    out="${s[(R)$left,(R)$right]}"
    printf '%s\0' "$out"
    typeset -p match mbegin mend
  done
done
typeset -p s
print -r -- matrix-done

)
integer matrix_status=$?
print -r -- matrix-27-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R ksh
setopt extendedglob multibyte
s=''
match=(); mbegin=(); mend=()
integer begin_at match_number
for needle in 'a' 'a*' '*' '?' '' 'missing' 'é*' $'a\0*' '(#b)(a*)'; do
  for begin_at in -9 -1 0 1 2 4 5 100; do
    for match_number in -2 -1 0 1 2; do
      out="${s[(ib:begin_at:n:match_number:)$needle]}"
      printf '%s\0' "$out"
      if [[ $needle == '(#b)(a*)' ]]; then typeset -p match mbegin mend; fi
    done
  done
done
for needle in 'a' 'a*' '*' '?' '' 'missing' 'é*' $'a\0*' '(#b)(a*)'; do
  for begin_at in -9 -1 0 1 2 4 5 100; do
    for match_number in -2 -1 0 1 2; do
      out="${s[(Ib:begin_at:n:match_number:)$needle]}"
      printf '%s\0' "$out"
      if [[ $needle == '(#b)(a*)' ]]; then typeset -p match mbegin mend; fi
    done
  done
done
for needle in 'a' 'a*' '*' '?' '' 'missing' 'é*' $'a\0*' '(#b)(a*)'; do
  for begin_at in -9 -1 0 1 2 4 5 100; do
    for match_number in -2 -1 0 1 2; do
      out="${s[(rb:begin_at:n:match_number:)$needle]}"
      printf '%s\0' "$out"
      if [[ $needle == '(#b)(a*)' ]]; then typeset -p match mbegin mend; fi
    done
  done
done
for needle in 'a' 'a*' '*' '?' '' 'missing' 'é*' $'a\0*' '(#b)(a*)'; do
  for begin_at in -9 -1 0 1 2 4 5 100; do
    for match_number in -2 -1 0 1 2; do
      out="${s[(Rb:begin_at:n:match_number:)$needle]}"
      printf '%s\0' "$out"
      if [[ $needle == '(#b)(a*)' ]]; then typeset -p match mbegin mend; fi
    done
  done
done
typeset -p s
print -r -- matrix-done

)
integer matrix_status=$?
print -r -- matrix-28-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R ksh
setopt extendedglob multibyte
s=''
match=(); mbegin=(); mend=()
for left in 'a' 'missing' '(#b)(a*)'; do
  for right in 'a' 'missing' '(#b)(a*)'; do
    out="${s[(r)$left,(r)$right]}"
    printf '%s\0' "$out"
    typeset -p match mbegin mend
  done
done
for left in 'a' 'missing' '(#b)(a*)'; do
  for right in 'a' 'missing' '(#b)(a*)'; do
    out="${s[(r)$left,(R)$right]}"
    printf '%s\0' "$out"
    typeset -p match mbegin mend
  done
done
for left in 'a' 'missing' '(#b)(a*)'; do
  for right in 'a' 'missing' '(#b)(a*)'; do
    out="${s[(R)$left,(r)$right]}"
    printf '%s\0' "$out"
    typeset -p match mbegin mend
  done
done
for left in 'a' 'missing' '(#b)(a*)'; do
  for right in 'a' 'missing' '(#b)(a*)'; do
    out="${s[(R)$left,(R)$right]}"
    printf '%s\0' "$out"
    typeset -p match mbegin mend
  done
done
typeset -p s
print -r -- matrix-done

)
integer matrix_status=$?
print -r -- matrix-29-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R ksh
setopt extendedglob multibyte
s='a'
match=(); mbegin=(); mend=()
integer begin_at match_number
for needle in 'a' 'a*' '*' '?' '' 'missing' 'é*' $'a\0*' '(#b)(a*)'; do
  for begin_at in -9 -1 0 1 2 4 5 100; do
    for match_number in -2 -1 0 1 2; do
      out="${s[(ib:begin_at:n:match_number:)$needle]}"
      printf '%s\0' "$out"
      if [[ $needle == '(#b)(a*)' ]]; then typeset -p match mbegin mend; fi
    done
  done
done
for needle in 'a' 'a*' '*' '?' '' 'missing' 'é*' $'a\0*' '(#b)(a*)'; do
  for begin_at in -9 -1 0 1 2 4 5 100; do
    for match_number in -2 -1 0 1 2; do
      out="${s[(Ib:begin_at:n:match_number:)$needle]}"
      printf '%s\0' "$out"
      if [[ $needle == '(#b)(a*)' ]]; then typeset -p match mbegin mend; fi
    done
  done
done
for needle in 'a' 'a*' '*' '?' '' 'missing' 'é*' $'a\0*' '(#b)(a*)'; do
  for begin_at in -9 -1 0 1 2 4 5 100; do
    for match_number in -2 -1 0 1 2; do
      out="${s[(rb:begin_at:n:match_number:)$needle]}"
      printf '%s\0' "$out"
      if [[ $needle == '(#b)(a*)' ]]; then typeset -p match mbegin mend; fi
    done
  done
done
for needle in 'a' 'a*' '*' '?' '' 'missing' 'é*' $'a\0*' '(#b)(a*)'; do
  for begin_at in -9 -1 0 1 2 4 5 100; do
    for match_number in -2 -1 0 1 2; do
      out="${s[(Rb:begin_at:n:match_number:)$needle]}"
      printf '%s\0' "$out"
      if [[ $needle == '(#b)(a*)' ]]; then typeset -p match mbegin mend; fi
    done
  done
done
typeset -p s
print -r -- matrix-done

)
integer matrix_status=$?
print -r -- matrix-30-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R ksh
setopt extendedglob multibyte
s='a'
match=(); mbegin=(); mend=()
for left in 'a' 'missing' '(#b)(a*)'; do
  for right in 'a' 'missing' '(#b)(a*)'; do
    out="${s[(r)$left,(r)$right]}"
    printf '%s\0' "$out"
    typeset -p match mbegin mend
  done
done
for left in 'a' 'missing' '(#b)(a*)'; do
  for right in 'a' 'missing' '(#b)(a*)'; do
    out="${s[(r)$left,(R)$right]}"
    printf '%s\0' "$out"
    typeset -p match mbegin mend
  done
done
for left in 'a' 'missing' '(#b)(a*)'; do
  for right in 'a' 'missing' '(#b)(a*)'; do
    out="${s[(R)$left,(r)$right]}"
    printf '%s\0' "$out"
    typeset -p match mbegin mend
  done
done
for left in 'a' 'missing' '(#b)(a*)'; do
  for right in 'a' 'missing' '(#b)(a*)'; do
    out="${s[(R)$left,(R)$right]}"
    printf '%s\0' "$out"
    typeset -p match mbegin mend
  done
done
typeset -p s
print -r -- matrix-done

)
integer matrix_status=$?
print -r -- matrix-31-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R ksh
setopt extendedglob multibyte
s='abc a def a'
match=(); mbegin=(); mend=()
integer begin_at match_number
for needle in 'a' 'a*' '*' '?' '' 'missing' 'é*' $'a\0*' '(#b)(a*)'; do
  for begin_at in -9 -1 0 1 2 4 5 100; do
    for match_number in -2 -1 0 1 2; do
      out="${s[(ib:begin_at:n:match_number:)$needle]}"
      printf '%s\0' "$out"
      if [[ $needle == '(#b)(a*)' ]]; then typeset -p match mbegin mend; fi
    done
  done
done
for needle in 'a' 'a*' '*' '?' '' 'missing' 'é*' $'a\0*' '(#b)(a*)'; do
  for begin_at in -9 -1 0 1 2 4 5 100; do
    for match_number in -2 -1 0 1 2; do
      out="${s[(Ib:begin_at:n:match_number:)$needle]}"
      printf '%s\0' "$out"
      if [[ $needle == '(#b)(a*)' ]]; then typeset -p match mbegin mend; fi
    done
  done
done
for needle in 'a' 'a*' '*' '?' '' 'missing' 'é*' $'a\0*' '(#b)(a*)'; do
  for begin_at in -9 -1 0 1 2 4 5 100; do
    for match_number in -2 -1 0 1 2; do
      out="${s[(rb:begin_at:n:match_number:)$needle]}"
      printf '%s\0' "$out"
      if [[ $needle == '(#b)(a*)' ]]; then typeset -p match mbegin mend; fi
    done
  done
done
for needle in 'a' 'a*' '*' '?' '' 'missing' 'é*' $'a\0*' '(#b)(a*)'; do
  for begin_at in -9 -1 0 1 2 4 5 100; do
    for match_number in -2 -1 0 1 2; do
      out="${s[(Rb:begin_at:n:match_number:)$needle]}"
      printf '%s\0' "$out"
      if [[ $needle == '(#b)(a*)' ]]; then typeset -p match mbegin mend; fi
    done
  done
done
typeset -p s
print -r -- matrix-done

)
integer matrix_status=$?
print -r -- matrix-32-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R ksh
setopt extendedglob multibyte
s='abc a def a'
match=(); mbegin=(); mend=()
for left in 'a' 'missing' '(#b)(a*)'; do
  for right in 'a' 'missing' '(#b)(a*)'; do
    out="${s[(r)$left,(r)$right]}"
    printf '%s\0' "$out"
    typeset -p match mbegin mend
  done
done
for left in 'a' 'missing' '(#b)(a*)'; do
  for right in 'a' 'missing' '(#b)(a*)'; do
    out="${s[(r)$left,(R)$right]}"
    printf '%s\0' "$out"
    typeset -p match mbegin mend
  done
done
for left in 'a' 'missing' '(#b)(a*)'; do
  for right in 'a' 'missing' '(#b)(a*)'; do
    out="${s[(R)$left,(r)$right]}"
    printf '%s\0' "$out"
    typeset -p match mbegin mend
  done
done
for left in 'a' 'missing' '(#b)(a*)'; do
  for right in 'a' 'missing' '(#b)(a*)'; do
    out="${s[(R)$left,(R)$right]}"
    printf '%s\0' "$out"
    typeset -p match mbegin mend
  done
done
typeset -p s
print -r -- matrix-done

)
integer matrix_status=$?
print -r -- matrix-33-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R ksh
setopt extendedglob multibyte
s='éa😀aé'
match=(); mbegin=(); mend=()
integer begin_at match_number
for needle in 'a' 'a*' '*' '?' '' 'missing' 'é*' $'a\0*' '(#b)(a*)'; do
  for begin_at in -9 -1 0 1 2 4 5 100; do
    for match_number in -2 -1 0 1 2; do
      out="${s[(ib:begin_at:n:match_number:)$needle]}"
      printf '%s\0' "$out"
      if [[ $needle == '(#b)(a*)' ]]; then typeset -p match mbegin mend; fi
    done
  done
done
for needle in 'a' 'a*' '*' '?' '' 'missing' 'é*' $'a\0*' '(#b)(a*)'; do
  for begin_at in -9 -1 0 1 2 4 5 100; do
    for match_number in -2 -1 0 1 2; do
      out="${s[(Ib:begin_at:n:match_number:)$needle]}"
      printf '%s\0' "$out"
      if [[ $needle == '(#b)(a*)' ]]; then typeset -p match mbegin mend; fi
    done
  done
done
for needle in 'a' 'a*' '*' '?' '' 'missing' 'é*' $'a\0*' '(#b)(a*)'; do
  for begin_at in -9 -1 0 1 2 4 5 100; do
    for match_number in -2 -1 0 1 2; do
      out="${s[(rb:begin_at:n:match_number:)$needle]}"
      printf '%s\0' "$out"
      if [[ $needle == '(#b)(a*)' ]]; then typeset -p match mbegin mend; fi
    done
  done
done
for needle in 'a' 'a*' '*' '?' '' 'missing' 'é*' $'a\0*' '(#b)(a*)'; do
  for begin_at in -9 -1 0 1 2 4 5 100; do
    for match_number in -2 -1 0 1 2; do
      out="${s[(Rb:begin_at:n:match_number:)$needle]}"
      printf '%s\0' "$out"
      if [[ $needle == '(#b)(a*)' ]]; then typeset -p match mbegin mend; fi
    done
  done
done
typeset -p s
print -r -- matrix-done

)
integer matrix_status=$?
print -r -- matrix-34-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R ksh
setopt extendedglob multibyte
s='éa😀aé'
match=(); mbegin=(); mend=()
for left in 'a' 'missing' '(#b)(a*)'; do
  for right in 'a' 'missing' '(#b)(a*)'; do
    out="${s[(r)$left,(r)$right]}"
    printf '%s\0' "$out"
    typeset -p match mbegin mend
  done
done
for left in 'a' 'missing' '(#b)(a*)'; do
  for right in 'a' 'missing' '(#b)(a*)'; do
    out="${s[(r)$left,(R)$right]}"
    printf '%s\0' "$out"
    typeset -p match mbegin mend
  done
done
for left in 'a' 'missing' '(#b)(a*)'; do
  for right in 'a' 'missing' '(#b)(a*)'; do
    out="${s[(R)$left,(r)$right]}"
    printf '%s\0' "$out"
    typeset -p match mbegin mend
  done
done
for left in 'a' 'missing' '(#b)(a*)'; do
  for right in 'a' 'missing' '(#b)(a*)'; do
    out="${s[(R)$left,(R)$right]}"
    printf '%s\0' "$out"
    typeset -p match mbegin mend
  done
done
typeset -p s
print -r -- matrix-done

)
integer matrix_status=$?
print -r -- matrix-35-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R ksh
setopt extendedglob multibyte
s=$'a\0b\203\377a'
match=(); mbegin=(); mend=()
integer begin_at match_number
for needle in 'a' 'a*' '*' '?' '' 'missing' 'é*' $'a\0*' '(#b)(a*)'; do
  for begin_at in -9 -1 0 1 2 4 5 100; do
    for match_number in -2 -1 0 1 2; do
      out="${s[(ib:begin_at:n:match_number:)$needle]}"
      printf '%s\0' "$out"
      if [[ $needle == '(#b)(a*)' ]]; then typeset -p match mbegin mend; fi
    done
  done
done
for needle in 'a' 'a*' '*' '?' '' 'missing' 'é*' $'a\0*' '(#b)(a*)'; do
  for begin_at in -9 -1 0 1 2 4 5 100; do
    for match_number in -2 -1 0 1 2; do
      out="${s[(Ib:begin_at:n:match_number:)$needle]}"
      printf '%s\0' "$out"
      if [[ $needle == '(#b)(a*)' ]]; then typeset -p match mbegin mend; fi
    done
  done
done
for needle in 'a' 'a*' '*' '?' '' 'missing' 'é*' $'a\0*' '(#b)(a*)'; do
  for begin_at in -9 -1 0 1 2 4 5 100; do
    for match_number in -2 -1 0 1 2; do
      out="${s[(rb:begin_at:n:match_number:)$needle]}"
      printf '%s\0' "$out"
      if [[ $needle == '(#b)(a*)' ]]; then typeset -p match mbegin mend; fi
    done
  done
done
for needle in 'a' 'a*' '*' '?' '' 'missing' 'é*' $'a\0*' '(#b)(a*)'; do
  for begin_at in -9 -1 0 1 2 4 5 100; do
    for match_number in -2 -1 0 1 2; do
      out="${s[(Rb:begin_at:n:match_number:)$needle]}"
      printf '%s\0' "$out"
      if [[ $needle == '(#b)(a*)' ]]; then typeset -p match mbegin mend; fi
    done
  done
done
typeset -p s
print -r -- matrix-done

)
integer matrix_status=$?
print -r -- matrix-36-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R ksh
setopt extendedglob multibyte
s=$'a\0b\203\377a'
match=(); mbegin=(); mend=()
for left in 'a' 'missing' '(#b)(a*)'; do
  for right in 'a' 'missing' '(#b)(a*)'; do
    out="${s[(r)$left,(r)$right]}"
    printf '%s\0' "$out"
    typeset -p match mbegin mend
  done
done
for left in 'a' 'missing' '(#b)(a*)'; do
  for right in 'a' 'missing' '(#b)(a*)'; do
    out="${s[(r)$left,(R)$right]}"
    printf '%s\0' "$out"
    typeset -p match mbegin mend
  done
done
for left in 'a' 'missing' '(#b)(a*)'; do
  for right in 'a' 'missing' '(#b)(a*)'; do
    out="${s[(R)$left,(r)$right]}"
    printf '%s\0' "$out"
    typeset -p match mbegin mend
  done
done
for left in 'a' 'missing' '(#b)(a*)'; do
  for right in 'a' 'missing' '(#b)(a*)'; do
    out="${s[(R)$left,(R)$right]}"
    printf '%s\0' "$out"
    typeset -p match mbegin mend
  done
done
typeset -p s
print -r -- matrix-done

)
integer matrix_status=$?
print -r -- matrix-37-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R ksh
setopt extendedglob multibyte
s='é 👩‍💻 a'
match=(); mbegin=(); mend=()
integer begin_at match_number
for needle in 'a' 'a*' '*' '?' '' 'missing' 'é*' $'a\0*' '(#b)(a*)'; do
  for begin_at in -9 -1 0 1 2 4 5 100; do
    for match_number in -2 -1 0 1 2; do
      out="${s[(ib:begin_at:n:match_number:)$needle]}"
      printf '%s\0' "$out"
      if [[ $needle == '(#b)(a*)' ]]; then typeset -p match mbegin mend; fi
    done
  done
done
for needle in 'a' 'a*' '*' '?' '' 'missing' 'é*' $'a\0*' '(#b)(a*)'; do
  for begin_at in -9 -1 0 1 2 4 5 100; do
    for match_number in -2 -1 0 1 2; do
      out="${s[(Ib:begin_at:n:match_number:)$needle]}"
      printf '%s\0' "$out"
      if [[ $needle == '(#b)(a*)' ]]; then typeset -p match mbegin mend; fi
    done
  done
done
for needle in 'a' 'a*' '*' '?' '' 'missing' 'é*' $'a\0*' '(#b)(a*)'; do
  for begin_at in -9 -1 0 1 2 4 5 100; do
    for match_number in -2 -1 0 1 2; do
      out="${s[(rb:begin_at:n:match_number:)$needle]}"
      printf '%s\0' "$out"
      if [[ $needle == '(#b)(a*)' ]]; then typeset -p match mbegin mend; fi
    done
  done
done
for needle in 'a' 'a*' '*' '?' '' 'missing' 'é*' $'a\0*' '(#b)(a*)'; do
  for begin_at in -9 -1 0 1 2 4 5 100; do
    for match_number in -2 -1 0 1 2; do
      out="${s[(Rb:begin_at:n:match_number:)$needle]}"
      printf '%s\0' "$out"
      if [[ $needle == '(#b)(a*)' ]]; then typeset -p match mbegin mend; fi
    done
  done
done
typeset -p s
print -r -- matrix-done

)
integer matrix_status=$?
print -r -- matrix-38-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R ksh
setopt extendedglob multibyte
s='é 👩‍💻 a'
match=(); mbegin=(); mend=()
for left in 'a' 'missing' '(#b)(a*)'; do
  for right in 'a' 'missing' '(#b)(a*)'; do
    out="${s[(r)$left,(r)$right]}"
    printf '%s\0' "$out"
    typeset -p match mbegin mend
  done
done
for left in 'a' 'missing' '(#b)(a*)'; do
  for right in 'a' 'missing' '(#b)(a*)'; do
    out="${s[(r)$left,(R)$right]}"
    printf '%s\0' "$out"
    typeset -p match mbegin mend
  done
done
for left in 'a' 'missing' '(#b)(a*)'; do
  for right in 'a' 'missing' '(#b)(a*)'; do
    out="${s[(R)$left,(r)$right]}"
    printf '%s\0' "$out"
    typeset -p match mbegin mend
  done
done
for left in 'a' 'missing' '(#b)(a*)'; do
  for right in 'a' 'missing' '(#b)(a*)'; do
    out="${s[(R)$left,(R)$right]}"
    printf '%s\0' "$out"
    typeset -p match mbegin mend
  done
done
typeset -p s
print -r -- matrix-done

)
integer matrix_status=$?
print -r -- matrix-39-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R ksh
setopt extendedglob multibyte
s=$'a\303\251b\303'
match=(); mbegin=(); mend=()
integer begin_at match_number
for needle in 'a' 'a*' '*' '?' '' 'missing' 'é*' $'a\0*' '(#b)(a*)'; do
  for begin_at in -9 -1 0 1 2 4 5 100; do
    for match_number in -2 -1 0 1 2; do
      out="${s[(ib:begin_at:n:match_number:)$needle]}"
      printf '%s\0' "$out"
      if [[ $needle == '(#b)(a*)' ]]; then typeset -p match mbegin mend; fi
    done
  done
done
for needle in 'a' 'a*' '*' '?' '' 'missing' 'é*' $'a\0*' '(#b)(a*)'; do
  for begin_at in -9 -1 0 1 2 4 5 100; do
    for match_number in -2 -1 0 1 2; do
      out="${s[(Ib:begin_at:n:match_number:)$needle]}"
      printf '%s\0' "$out"
      if [[ $needle == '(#b)(a*)' ]]; then typeset -p match mbegin mend; fi
    done
  done
done
for needle in 'a' 'a*' '*' '?' '' 'missing' 'é*' $'a\0*' '(#b)(a*)'; do
  for begin_at in -9 -1 0 1 2 4 5 100; do
    for match_number in -2 -1 0 1 2; do
      out="${s[(rb:begin_at:n:match_number:)$needle]}"
      printf '%s\0' "$out"
      if [[ $needle == '(#b)(a*)' ]]; then typeset -p match mbegin mend; fi
    done
  done
done
for needle in 'a' 'a*' '*' '?' '' 'missing' 'é*' $'a\0*' '(#b)(a*)'; do
  for begin_at in -9 -1 0 1 2 4 5 100; do
    for match_number in -2 -1 0 1 2; do
      out="${s[(Rb:begin_at:n:match_number:)$needle]}"
      printf '%s\0' "$out"
      if [[ $needle == '(#b)(a*)' ]]; then typeset -p match mbegin mend; fi
    done
  done
done
typeset -p s
print -r -- matrix-done

)
integer matrix_status=$?
print -r -- matrix-40-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R ksh
setopt extendedglob multibyte
s=$'a\303\251b\303'
match=(); mbegin=(); mend=()
for left in 'a' 'missing' '(#b)(a*)'; do
  for right in 'a' 'missing' '(#b)(a*)'; do
    out="${s[(r)$left,(r)$right]}"
    printf '%s\0' "$out"
    typeset -p match mbegin mend
  done
done
for left in 'a' 'missing' '(#b)(a*)'; do
  for right in 'a' 'missing' '(#b)(a*)'; do
    out="${s[(r)$left,(R)$right]}"
    printf '%s\0' "$out"
    typeset -p match mbegin mend
  done
done
for left in 'a' 'missing' '(#b)(a*)'; do
  for right in 'a' 'missing' '(#b)(a*)'; do
    out="${s[(R)$left,(r)$right]}"
    printf '%s\0' "$out"
    typeset -p match mbegin mend
  done
done
for left in 'a' 'missing' '(#b)(a*)'; do
  for right in 'a' 'missing' '(#b)(a*)'; do
    out="${s[(R)$left,(R)$right]}"
    printf '%s\0' "$out"
    typeset -p match mbegin mend
  done
done
typeset -p s
print -r -- matrix-done

)
integer matrix_status=$?
print -r -- matrix-41-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R ksh
setopt extendedglob nomultibyte
s=''
match=(); mbegin=(); mend=()
integer begin_at match_number
for needle in 'a' 'a*' '*' '?' '' 'missing' 'é*' $'a\0*' '(#b)(a*)'; do
  for begin_at in -9 -1 0 1 2 4 5 100; do
    for match_number in -2 -1 0 1 2; do
      out="${s[(ib:begin_at:n:match_number:)$needle]}"
      printf '%s\0' "$out"
      if [[ $needle == '(#b)(a*)' ]]; then typeset -p match mbegin mend; fi
    done
  done
done
for needle in 'a' 'a*' '*' '?' '' 'missing' 'é*' $'a\0*' '(#b)(a*)'; do
  for begin_at in -9 -1 0 1 2 4 5 100; do
    for match_number in -2 -1 0 1 2; do
      out="${s[(Ib:begin_at:n:match_number:)$needle]}"
      printf '%s\0' "$out"
      if [[ $needle == '(#b)(a*)' ]]; then typeset -p match mbegin mend; fi
    done
  done
done
for needle in 'a' 'a*' '*' '?' '' 'missing' 'é*' $'a\0*' '(#b)(a*)'; do
  for begin_at in -9 -1 0 1 2 4 5 100; do
    for match_number in -2 -1 0 1 2; do
      out="${s[(rb:begin_at:n:match_number:)$needle]}"
      printf '%s\0' "$out"
      if [[ $needle == '(#b)(a*)' ]]; then typeset -p match mbegin mend; fi
    done
  done
done
for needle in 'a' 'a*' '*' '?' '' 'missing' 'é*' $'a\0*' '(#b)(a*)'; do
  for begin_at in -9 -1 0 1 2 4 5 100; do
    for match_number in -2 -1 0 1 2; do
      out="${s[(Rb:begin_at:n:match_number:)$needle]}"
      printf '%s\0' "$out"
      if [[ $needle == '(#b)(a*)' ]]; then typeset -p match mbegin mend; fi
    done
  done
done
typeset -p s
print -r -- matrix-done

)
integer matrix_status=$?
print -r -- matrix-42-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R ksh
setopt extendedglob nomultibyte
s=''
match=(); mbegin=(); mend=()
for left in 'a' 'missing' '(#b)(a*)'; do
  for right in 'a' 'missing' '(#b)(a*)'; do
    out="${s[(r)$left,(r)$right]}"
    printf '%s\0' "$out"
    typeset -p match mbegin mend
  done
done
for left in 'a' 'missing' '(#b)(a*)'; do
  for right in 'a' 'missing' '(#b)(a*)'; do
    out="${s[(r)$left,(R)$right]}"
    printf '%s\0' "$out"
    typeset -p match mbegin mend
  done
done
for left in 'a' 'missing' '(#b)(a*)'; do
  for right in 'a' 'missing' '(#b)(a*)'; do
    out="${s[(R)$left,(r)$right]}"
    printf '%s\0' "$out"
    typeset -p match mbegin mend
  done
done
for left in 'a' 'missing' '(#b)(a*)'; do
  for right in 'a' 'missing' '(#b)(a*)'; do
    out="${s[(R)$left,(R)$right]}"
    printf '%s\0' "$out"
    typeset -p match mbegin mend
  done
done
typeset -p s
print -r -- matrix-done

)
integer matrix_status=$?
print -r -- matrix-43-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R ksh
setopt extendedglob nomultibyte
s='a'
match=(); mbegin=(); mend=()
integer begin_at match_number
for needle in 'a' 'a*' '*' '?' '' 'missing' 'é*' $'a\0*' '(#b)(a*)'; do
  for begin_at in -9 -1 0 1 2 4 5 100; do
    for match_number in -2 -1 0 1 2; do
      out="${s[(ib:begin_at:n:match_number:)$needle]}"
      printf '%s\0' "$out"
      if [[ $needle == '(#b)(a*)' ]]; then typeset -p match mbegin mend; fi
    done
  done
done
for needle in 'a' 'a*' '*' '?' '' 'missing' 'é*' $'a\0*' '(#b)(a*)'; do
  for begin_at in -9 -1 0 1 2 4 5 100; do
    for match_number in -2 -1 0 1 2; do
      out="${s[(Ib:begin_at:n:match_number:)$needle]}"
      printf '%s\0' "$out"
      if [[ $needle == '(#b)(a*)' ]]; then typeset -p match mbegin mend; fi
    done
  done
done
for needle in 'a' 'a*' '*' '?' '' 'missing' 'é*' $'a\0*' '(#b)(a*)'; do
  for begin_at in -9 -1 0 1 2 4 5 100; do
    for match_number in -2 -1 0 1 2; do
      out="${s[(rb:begin_at:n:match_number:)$needle]}"
      printf '%s\0' "$out"
      if [[ $needle == '(#b)(a*)' ]]; then typeset -p match mbegin mend; fi
    done
  done
done
for needle in 'a' 'a*' '*' '?' '' 'missing' 'é*' $'a\0*' '(#b)(a*)'; do
  for begin_at in -9 -1 0 1 2 4 5 100; do
    for match_number in -2 -1 0 1 2; do
      out="${s[(Rb:begin_at:n:match_number:)$needle]}"
      printf '%s\0' "$out"
      if [[ $needle == '(#b)(a*)' ]]; then typeset -p match mbegin mend; fi
    done
  done
done
typeset -p s
print -r -- matrix-done

)
integer matrix_status=$?
print -r -- matrix-44-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R ksh
setopt extendedglob nomultibyte
s='a'
match=(); mbegin=(); mend=()
for left in 'a' 'missing' '(#b)(a*)'; do
  for right in 'a' 'missing' '(#b)(a*)'; do
    out="${s[(r)$left,(r)$right]}"
    printf '%s\0' "$out"
    typeset -p match mbegin mend
  done
done
for left in 'a' 'missing' '(#b)(a*)'; do
  for right in 'a' 'missing' '(#b)(a*)'; do
    out="${s[(r)$left,(R)$right]}"
    printf '%s\0' "$out"
    typeset -p match mbegin mend
  done
done
for left in 'a' 'missing' '(#b)(a*)'; do
  for right in 'a' 'missing' '(#b)(a*)'; do
    out="${s[(R)$left,(r)$right]}"
    printf '%s\0' "$out"
    typeset -p match mbegin mend
  done
done
for left in 'a' 'missing' '(#b)(a*)'; do
  for right in 'a' 'missing' '(#b)(a*)'; do
    out="${s[(R)$left,(R)$right]}"
    printf '%s\0' "$out"
    typeset -p match mbegin mend
  done
done
typeset -p s
print -r -- matrix-done

)
integer matrix_status=$?
print -r -- matrix-45-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R ksh
setopt extendedglob nomultibyte
s='abc a def a'
match=(); mbegin=(); mend=()
integer begin_at match_number
for needle in 'a' 'a*' '*' '?' '' 'missing' 'é*' $'a\0*' '(#b)(a*)'; do
  for begin_at in -9 -1 0 1 2 4 5 100; do
    for match_number in -2 -1 0 1 2; do
      out="${s[(ib:begin_at:n:match_number:)$needle]}"
      printf '%s\0' "$out"
      if [[ $needle == '(#b)(a*)' ]]; then typeset -p match mbegin mend; fi
    done
  done
done
for needle in 'a' 'a*' '*' '?' '' 'missing' 'é*' $'a\0*' '(#b)(a*)'; do
  for begin_at in -9 -1 0 1 2 4 5 100; do
    for match_number in -2 -1 0 1 2; do
      out="${s[(Ib:begin_at:n:match_number:)$needle]}"
      printf '%s\0' "$out"
      if [[ $needle == '(#b)(a*)' ]]; then typeset -p match mbegin mend; fi
    done
  done
done
for needle in 'a' 'a*' '*' '?' '' 'missing' 'é*' $'a\0*' '(#b)(a*)'; do
  for begin_at in -9 -1 0 1 2 4 5 100; do
    for match_number in -2 -1 0 1 2; do
      out="${s[(rb:begin_at:n:match_number:)$needle]}"
      printf '%s\0' "$out"
      if [[ $needle == '(#b)(a*)' ]]; then typeset -p match mbegin mend; fi
    done
  done
done
for needle in 'a' 'a*' '*' '?' '' 'missing' 'é*' $'a\0*' '(#b)(a*)'; do
  for begin_at in -9 -1 0 1 2 4 5 100; do
    for match_number in -2 -1 0 1 2; do
      out="${s[(Rb:begin_at:n:match_number:)$needle]}"
      printf '%s\0' "$out"
      if [[ $needle == '(#b)(a*)' ]]; then typeset -p match mbegin mend; fi
    done
  done
done
typeset -p s
print -r -- matrix-done

)
integer matrix_status=$?
print -r -- matrix-46-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R ksh
setopt extendedglob nomultibyte
s='abc a def a'
match=(); mbegin=(); mend=()
for left in 'a' 'missing' '(#b)(a*)'; do
  for right in 'a' 'missing' '(#b)(a*)'; do
    out="${s[(r)$left,(r)$right]}"
    printf '%s\0' "$out"
    typeset -p match mbegin mend
  done
done
for left in 'a' 'missing' '(#b)(a*)'; do
  for right in 'a' 'missing' '(#b)(a*)'; do
    out="${s[(r)$left,(R)$right]}"
    printf '%s\0' "$out"
    typeset -p match mbegin mend
  done
done
for left in 'a' 'missing' '(#b)(a*)'; do
  for right in 'a' 'missing' '(#b)(a*)'; do
    out="${s[(R)$left,(r)$right]}"
    printf '%s\0' "$out"
    typeset -p match mbegin mend
  done
done
for left in 'a' 'missing' '(#b)(a*)'; do
  for right in 'a' 'missing' '(#b)(a*)'; do
    out="${s[(R)$left,(R)$right]}"
    printf '%s\0' "$out"
    typeset -p match mbegin mend
  done
done
typeset -p s
print -r -- matrix-done

)
integer matrix_status=$?
print -r -- matrix-47-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R ksh
setopt extendedglob nomultibyte
s='éa😀aé'
match=(); mbegin=(); mend=()
integer begin_at match_number
for needle in 'a' 'a*' '*' '?' '' 'missing' 'é*' $'a\0*' '(#b)(a*)'; do
  for begin_at in -9 -1 0 1 2 4 5 100; do
    for match_number in -2 -1 0 1 2; do
      out="${s[(ib:begin_at:n:match_number:)$needle]}"
      printf '%s\0' "$out"
      if [[ $needle == '(#b)(a*)' ]]; then typeset -p match mbegin mend; fi
    done
  done
done
for needle in 'a' 'a*' '*' '?' '' 'missing' 'é*' $'a\0*' '(#b)(a*)'; do
  for begin_at in -9 -1 0 1 2 4 5 100; do
    for match_number in -2 -1 0 1 2; do
      out="${s[(Ib:begin_at:n:match_number:)$needle]}"
      printf '%s\0' "$out"
      if [[ $needle == '(#b)(a*)' ]]; then typeset -p match mbegin mend; fi
    done
  done
done
for needle in 'a' 'a*' '*' '?' '' 'missing' 'é*' $'a\0*' '(#b)(a*)'; do
  for begin_at in -9 -1 0 1 2 4 5 100; do
    for match_number in -2 -1 0 1 2; do
      out="${s[(rb:begin_at:n:match_number:)$needle]}"
      printf '%s\0' "$out"
      if [[ $needle == '(#b)(a*)' ]]; then typeset -p match mbegin mend; fi
    done
  done
done
for needle in 'a' 'a*' '*' '?' '' 'missing' 'é*' $'a\0*' '(#b)(a*)'; do
  for begin_at in -9 -1 0 1 2 4 5 100; do
    for match_number in -2 -1 0 1 2; do
      out="${s[(Rb:begin_at:n:match_number:)$needle]}"
      printf '%s\0' "$out"
      if [[ $needle == '(#b)(a*)' ]]; then typeset -p match mbegin mend; fi
    done
  done
done
typeset -p s
print -r -- matrix-done

)
integer matrix_status=$?
print -r -- matrix-48-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R ksh
setopt extendedglob nomultibyte
s='éa😀aé'
match=(); mbegin=(); mend=()
for left in 'a' 'missing' '(#b)(a*)'; do
  for right in 'a' 'missing' '(#b)(a*)'; do
    out="${s[(r)$left,(r)$right]}"
    printf '%s\0' "$out"
    typeset -p match mbegin mend
  done
done
for left in 'a' 'missing' '(#b)(a*)'; do
  for right in 'a' 'missing' '(#b)(a*)'; do
    out="${s[(r)$left,(R)$right]}"
    printf '%s\0' "$out"
    typeset -p match mbegin mend
  done
done
for left in 'a' 'missing' '(#b)(a*)'; do
  for right in 'a' 'missing' '(#b)(a*)'; do
    out="${s[(R)$left,(r)$right]}"
    printf '%s\0' "$out"
    typeset -p match mbegin mend
  done
done
for left in 'a' 'missing' '(#b)(a*)'; do
  for right in 'a' 'missing' '(#b)(a*)'; do
    out="${s[(R)$left,(R)$right]}"
    printf '%s\0' "$out"
    typeset -p match mbegin mend
  done
done
typeset -p s
print -r -- matrix-done

)
integer matrix_status=$?
print -r -- matrix-49-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R ksh
setopt extendedglob nomultibyte
s=$'a\0b\203\377a'
match=(); mbegin=(); mend=()
integer begin_at match_number
for needle in 'a' 'a*' '*' '?' '' 'missing' 'é*' $'a\0*' '(#b)(a*)'; do
  for begin_at in -9 -1 0 1 2 4 5 100; do
    for match_number in -2 -1 0 1 2; do
      out="${s[(ib:begin_at:n:match_number:)$needle]}"
      printf '%s\0' "$out"
      if [[ $needle == '(#b)(a*)' ]]; then typeset -p match mbegin mend; fi
    done
  done
done
for needle in 'a' 'a*' '*' '?' '' 'missing' 'é*' $'a\0*' '(#b)(a*)'; do
  for begin_at in -9 -1 0 1 2 4 5 100; do
    for match_number in -2 -1 0 1 2; do
      out="${s[(Ib:begin_at:n:match_number:)$needle]}"
      printf '%s\0' "$out"
      if [[ $needle == '(#b)(a*)' ]]; then typeset -p match mbegin mend; fi
    done
  done
done
for needle in 'a' 'a*' '*' '?' '' 'missing' 'é*' $'a\0*' '(#b)(a*)'; do
  for begin_at in -9 -1 0 1 2 4 5 100; do
    for match_number in -2 -1 0 1 2; do
      out="${s[(rb:begin_at:n:match_number:)$needle]}"
      printf '%s\0' "$out"
      if [[ $needle == '(#b)(a*)' ]]; then typeset -p match mbegin mend; fi
    done
  done
done
for needle in 'a' 'a*' '*' '?' '' 'missing' 'é*' $'a\0*' '(#b)(a*)'; do
  for begin_at in -9 -1 0 1 2 4 5 100; do
    for match_number in -2 -1 0 1 2; do
      out="${s[(Rb:begin_at:n:match_number:)$needle]}"
      printf '%s\0' "$out"
      if [[ $needle == '(#b)(a*)' ]]; then typeset -p match mbegin mend; fi
    done
  done
done
typeset -p s
print -r -- matrix-done

)
integer matrix_status=$?
print -r -- matrix-50-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R ksh
setopt extendedglob nomultibyte
s=$'a\0b\203\377a'
match=(); mbegin=(); mend=()
for left in 'a' 'missing' '(#b)(a*)'; do
  for right in 'a' 'missing' '(#b)(a*)'; do
    out="${s[(r)$left,(r)$right]}"
    printf '%s\0' "$out"
    typeset -p match mbegin mend
  done
done
for left in 'a' 'missing' '(#b)(a*)'; do
  for right in 'a' 'missing' '(#b)(a*)'; do
    out="${s[(r)$left,(R)$right]}"
    printf '%s\0' "$out"
    typeset -p match mbegin mend
  done
done
for left in 'a' 'missing' '(#b)(a*)'; do
  for right in 'a' 'missing' '(#b)(a*)'; do
    out="${s[(R)$left,(r)$right]}"
    printf '%s\0' "$out"
    typeset -p match mbegin mend
  done
done
for left in 'a' 'missing' '(#b)(a*)'; do
  for right in 'a' 'missing' '(#b)(a*)'; do
    out="${s[(R)$left,(R)$right]}"
    printf '%s\0' "$out"
    typeset -p match mbegin mend
  done
done
typeset -p s
print -r -- matrix-done

)
integer matrix_status=$?
print -r -- matrix-51-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R ksh
setopt extendedglob nomultibyte
s='é 👩‍💻 a'
match=(); mbegin=(); mend=()
integer begin_at match_number
for needle in 'a' 'a*' '*' '?' '' 'missing' 'é*' $'a\0*' '(#b)(a*)'; do
  for begin_at in -9 -1 0 1 2 4 5 100; do
    for match_number in -2 -1 0 1 2; do
      out="${s[(ib:begin_at:n:match_number:)$needle]}"
      printf '%s\0' "$out"
      if [[ $needle == '(#b)(a*)' ]]; then typeset -p match mbegin mend; fi
    done
  done
done
for needle in 'a' 'a*' '*' '?' '' 'missing' 'é*' $'a\0*' '(#b)(a*)'; do
  for begin_at in -9 -1 0 1 2 4 5 100; do
    for match_number in -2 -1 0 1 2; do
      out="${s[(Ib:begin_at:n:match_number:)$needle]}"
      printf '%s\0' "$out"
      if [[ $needle == '(#b)(a*)' ]]; then typeset -p match mbegin mend; fi
    done
  done
done
for needle in 'a' 'a*' '*' '?' '' 'missing' 'é*' $'a\0*' '(#b)(a*)'; do
  for begin_at in -9 -1 0 1 2 4 5 100; do
    for match_number in -2 -1 0 1 2; do
      out="${s[(rb:begin_at:n:match_number:)$needle]}"
      printf '%s\0' "$out"
      if [[ $needle == '(#b)(a*)' ]]; then typeset -p match mbegin mend; fi
    done
  done
done
for needle in 'a' 'a*' '*' '?' '' 'missing' 'é*' $'a\0*' '(#b)(a*)'; do
  for begin_at in -9 -1 0 1 2 4 5 100; do
    for match_number in -2 -1 0 1 2; do
      out="${s[(Rb:begin_at:n:match_number:)$needle]}"
      printf '%s\0' "$out"
      if [[ $needle == '(#b)(a*)' ]]; then typeset -p match mbegin mend; fi
    done
  done
done
typeset -p s
print -r -- matrix-done

)
integer matrix_status=$?
print -r -- matrix-52-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R ksh
setopt extendedglob nomultibyte
s='é 👩‍💻 a'
match=(); mbegin=(); mend=()
for left in 'a' 'missing' '(#b)(a*)'; do
  for right in 'a' 'missing' '(#b)(a*)'; do
    out="${s[(r)$left,(r)$right]}"
    printf '%s\0' "$out"
    typeset -p match mbegin mend
  done
done
for left in 'a' 'missing' '(#b)(a*)'; do
  for right in 'a' 'missing' '(#b)(a*)'; do
    out="${s[(r)$left,(R)$right]}"
    printf '%s\0' "$out"
    typeset -p match mbegin mend
  done
done
for left in 'a' 'missing' '(#b)(a*)'; do
  for right in 'a' 'missing' '(#b)(a*)'; do
    out="${s[(R)$left,(r)$right]}"
    printf '%s\0' "$out"
    typeset -p match mbegin mend
  done
done
for left in 'a' 'missing' '(#b)(a*)'; do
  for right in 'a' 'missing' '(#b)(a*)'; do
    out="${s[(R)$left,(R)$right]}"
    printf '%s\0' "$out"
    typeset -p match mbegin mend
  done
done
typeset -p s
print -r -- matrix-done

)
integer matrix_status=$?
print -r -- matrix-53-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R ksh
setopt extendedglob nomultibyte
s=$'a\303\251b\303'
match=(); mbegin=(); mend=()
integer begin_at match_number
for needle in 'a' 'a*' '*' '?' '' 'missing' 'é*' $'a\0*' '(#b)(a*)'; do
  for begin_at in -9 -1 0 1 2 4 5 100; do
    for match_number in -2 -1 0 1 2; do
      out="${s[(ib:begin_at:n:match_number:)$needle]}"
      printf '%s\0' "$out"
      if [[ $needle == '(#b)(a*)' ]]; then typeset -p match mbegin mend; fi
    done
  done
done
for needle in 'a' 'a*' '*' '?' '' 'missing' 'é*' $'a\0*' '(#b)(a*)'; do
  for begin_at in -9 -1 0 1 2 4 5 100; do
    for match_number in -2 -1 0 1 2; do
      out="${s[(Ib:begin_at:n:match_number:)$needle]}"
      printf '%s\0' "$out"
      if [[ $needle == '(#b)(a*)' ]]; then typeset -p match mbegin mend; fi
    done
  done
done
for needle in 'a' 'a*' '*' '?' '' 'missing' 'é*' $'a\0*' '(#b)(a*)'; do
  for begin_at in -9 -1 0 1 2 4 5 100; do
    for match_number in -2 -1 0 1 2; do
      out="${s[(rb:begin_at:n:match_number:)$needle]}"
      printf '%s\0' "$out"
      if [[ $needle == '(#b)(a*)' ]]; then typeset -p match mbegin mend; fi
    done
  done
done
for needle in 'a' 'a*' '*' '?' '' 'missing' 'é*' $'a\0*' '(#b)(a*)'; do
  for begin_at in -9 -1 0 1 2 4 5 100; do
    for match_number in -2 -1 0 1 2; do
      out="${s[(Rb:begin_at:n:match_number:)$needle]}"
      printf '%s\0' "$out"
      if [[ $needle == '(#b)(a*)' ]]; then typeset -p match mbegin mend; fi
    done
  done
done
typeset -p s
print -r -- matrix-done

)
integer matrix_status=$?
print -r -- matrix-54-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R ksh
setopt extendedglob nomultibyte
s=$'a\303\251b\303'
match=(); mbegin=(); mend=()
for left in 'a' 'missing' '(#b)(a*)'; do
  for right in 'a' 'missing' '(#b)(a*)'; do
    out="${s[(r)$left,(r)$right]}"
    printf '%s\0' "$out"
    typeset -p match mbegin mend
  done
done
for left in 'a' 'missing' '(#b)(a*)'; do
  for right in 'a' 'missing' '(#b)(a*)'; do
    out="${s[(r)$left,(R)$right]}"
    printf '%s\0' "$out"
    typeset -p match mbegin mend
  done
done
for left in 'a' 'missing' '(#b)(a*)'; do
  for right in 'a' 'missing' '(#b)(a*)'; do
    out="${s[(R)$left,(r)$right]}"
    printf '%s\0' "$out"
    typeset -p match mbegin mend
  done
done
for left in 'a' 'missing' '(#b)(a*)'; do
  for right in 'a' 'missing' '(#b)(a*)'; do
    out="${s[(R)$left,(R)$right]}"
    printf '%s\0' "$out"
    typeset -p match mbegin mend
  done
done
typeset -p s
print -r -- matrix-done

)
integer matrix_status=$?
print -r -- matrix-55-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R sh
setopt extendedglob multibyte
s=''
match=(); mbegin=(); mend=()
integer begin_at match_number
for needle in 'a' 'a*' '*' '?' '' 'missing' 'é*' $'a\0*' '(#b)(a*)'; do
  for begin_at in -9 -1 0 1 2 4 5 100; do
    for match_number in -2 -1 0 1 2; do
      out="${s[(ib:begin_at:n:match_number:)$needle]}"
      printf '%s\0' "$out"
      if [[ $needle == '(#b)(a*)' ]]; then typeset -p match mbegin mend; fi
    done
  done
done
for needle in 'a' 'a*' '*' '?' '' 'missing' 'é*' $'a\0*' '(#b)(a*)'; do
  for begin_at in -9 -1 0 1 2 4 5 100; do
    for match_number in -2 -1 0 1 2; do
      out="${s[(Ib:begin_at:n:match_number:)$needle]}"
      printf '%s\0' "$out"
      if [[ $needle == '(#b)(a*)' ]]; then typeset -p match mbegin mend; fi
    done
  done
done
for needle in 'a' 'a*' '*' '?' '' 'missing' 'é*' $'a\0*' '(#b)(a*)'; do
  for begin_at in -9 -1 0 1 2 4 5 100; do
    for match_number in -2 -1 0 1 2; do
      out="${s[(rb:begin_at:n:match_number:)$needle]}"
      printf '%s\0' "$out"
      if [[ $needle == '(#b)(a*)' ]]; then typeset -p match mbegin mend; fi
    done
  done
done
for needle in 'a' 'a*' '*' '?' '' 'missing' 'é*' $'a\0*' '(#b)(a*)'; do
  for begin_at in -9 -1 0 1 2 4 5 100; do
    for match_number in -2 -1 0 1 2; do
      out="${s[(Rb:begin_at:n:match_number:)$needle]}"
      printf '%s\0' "$out"
      if [[ $needle == '(#b)(a*)' ]]; then typeset -p match mbegin mend; fi
    done
  done
done
typeset -p s
print -r -- matrix-done

)
integer matrix_status=$?
print -r -- matrix-56-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R sh
setopt extendedglob multibyte
s=''
match=(); mbegin=(); mend=()
for left in 'a' 'missing' '(#b)(a*)'; do
  for right in 'a' 'missing' '(#b)(a*)'; do
    out="${s[(r)$left,(r)$right]}"
    printf '%s\0' "$out"
    typeset -p match mbegin mend
  done
done
for left in 'a' 'missing' '(#b)(a*)'; do
  for right in 'a' 'missing' '(#b)(a*)'; do
    out="${s[(r)$left,(R)$right]}"
    printf '%s\0' "$out"
    typeset -p match mbegin mend
  done
done
for left in 'a' 'missing' '(#b)(a*)'; do
  for right in 'a' 'missing' '(#b)(a*)'; do
    out="${s[(R)$left,(r)$right]}"
    printf '%s\0' "$out"
    typeset -p match mbegin mend
  done
done
for left in 'a' 'missing' '(#b)(a*)'; do
  for right in 'a' 'missing' '(#b)(a*)'; do
    out="${s[(R)$left,(R)$right]}"
    printf '%s\0' "$out"
    typeset -p match mbegin mend
  done
done
typeset -p s
print -r -- matrix-done

)
integer matrix_status=$?
print -r -- matrix-57-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R sh
setopt extendedglob multibyte
s='a'
match=(); mbegin=(); mend=()
integer begin_at match_number
for needle in 'a' 'a*' '*' '?' '' 'missing' 'é*' $'a\0*' '(#b)(a*)'; do
  for begin_at in -9 -1 0 1 2 4 5 100; do
    for match_number in -2 -1 0 1 2; do
      out="${s[(ib:begin_at:n:match_number:)$needle]}"
      printf '%s\0' "$out"
      if [[ $needle == '(#b)(a*)' ]]; then typeset -p match mbegin mend; fi
    done
  done
done
for needle in 'a' 'a*' '*' '?' '' 'missing' 'é*' $'a\0*' '(#b)(a*)'; do
  for begin_at in -9 -1 0 1 2 4 5 100; do
    for match_number in -2 -1 0 1 2; do
      out="${s[(Ib:begin_at:n:match_number:)$needle]}"
      printf '%s\0' "$out"
      if [[ $needle == '(#b)(a*)' ]]; then typeset -p match mbegin mend; fi
    done
  done
done
for needle in 'a' 'a*' '*' '?' '' 'missing' 'é*' $'a\0*' '(#b)(a*)'; do
  for begin_at in -9 -1 0 1 2 4 5 100; do
    for match_number in -2 -1 0 1 2; do
      out="${s[(rb:begin_at:n:match_number:)$needle]}"
      printf '%s\0' "$out"
      if [[ $needle == '(#b)(a*)' ]]; then typeset -p match mbegin mend; fi
    done
  done
done
for needle in 'a' 'a*' '*' '?' '' 'missing' 'é*' $'a\0*' '(#b)(a*)'; do
  for begin_at in -9 -1 0 1 2 4 5 100; do
    for match_number in -2 -1 0 1 2; do
      out="${s[(Rb:begin_at:n:match_number:)$needle]}"
      printf '%s\0' "$out"
      if [[ $needle == '(#b)(a*)' ]]; then typeset -p match mbegin mend; fi
    done
  done
done
typeset -p s
print -r -- matrix-done

)
integer matrix_status=$?
print -r -- matrix-58-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R sh
setopt extendedglob multibyte
s='a'
match=(); mbegin=(); mend=()
for left in 'a' 'missing' '(#b)(a*)'; do
  for right in 'a' 'missing' '(#b)(a*)'; do
    out="${s[(r)$left,(r)$right]}"
    printf '%s\0' "$out"
    typeset -p match mbegin mend
  done
done
for left in 'a' 'missing' '(#b)(a*)'; do
  for right in 'a' 'missing' '(#b)(a*)'; do
    out="${s[(r)$left,(R)$right]}"
    printf '%s\0' "$out"
    typeset -p match mbegin mend
  done
done
for left in 'a' 'missing' '(#b)(a*)'; do
  for right in 'a' 'missing' '(#b)(a*)'; do
    out="${s[(R)$left,(r)$right]}"
    printf '%s\0' "$out"
    typeset -p match mbegin mend
  done
done
for left in 'a' 'missing' '(#b)(a*)'; do
  for right in 'a' 'missing' '(#b)(a*)'; do
    out="${s[(R)$left,(R)$right]}"
    printf '%s\0' "$out"
    typeset -p match mbegin mend
  done
done
typeset -p s
print -r -- matrix-done

)
integer matrix_status=$?
print -r -- matrix-59-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R sh
setopt extendedglob multibyte
s='abc a def a'
match=(); mbegin=(); mend=()
integer begin_at match_number
for needle in 'a' 'a*' '*' '?' '' 'missing' 'é*' $'a\0*' '(#b)(a*)'; do
  for begin_at in -9 -1 0 1 2 4 5 100; do
    for match_number in -2 -1 0 1 2; do
      out="${s[(ib:begin_at:n:match_number:)$needle]}"
      printf '%s\0' "$out"
      if [[ $needle == '(#b)(a*)' ]]; then typeset -p match mbegin mend; fi
    done
  done
done
for needle in 'a' 'a*' '*' '?' '' 'missing' 'é*' $'a\0*' '(#b)(a*)'; do
  for begin_at in -9 -1 0 1 2 4 5 100; do
    for match_number in -2 -1 0 1 2; do
      out="${s[(Ib:begin_at:n:match_number:)$needle]}"
      printf '%s\0' "$out"
      if [[ $needle == '(#b)(a*)' ]]; then typeset -p match mbegin mend; fi
    done
  done
done
for needle in 'a' 'a*' '*' '?' '' 'missing' 'é*' $'a\0*' '(#b)(a*)'; do
  for begin_at in -9 -1 0 1 2 4 5 100; do
    for match_number in -2 -1 0 1 2; do
      out="${s[(rb:begin_at:n:match_number:)$needle]}"
      printf '%s\0' "$out"
      if [[ $needle == '(#b)(a*)' ]]; then typeset -p match mbegin mend; fi
    done
  done
done
for needle in 'a' 'a*' '*' '?' '' 'missing' 'é*' $'a\0*' '(#b)(a*)'; do
  for begin_at in -9 -1 0 1 2 4 5 100; do
    for match_number in -2 -1 0 1 2; do
      out="${s[(Rb:begin_at:n:match_number:)$needle]}"
      printf '%s\0' "$out"
      if [[ $needle == '(#b)(a*)' ]]; then typeset -p match mbegin mend; fi
    done
  done
done
typeset -p s
print -r -- matrix-done

)
integer matrix_status=$?
print -r -- matrix-60-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R sh
setopt extendedglob multibyte
s='abc a def a'
match=(); mbegin=(); mend=()
for left in 'a' 'missing' '(#b)(a*)'; do
  for right in 'a' 'missing' '(#b)(a*)'; do
    out="${s[(r)$left,(r)$right]}"
    printf '%s\0' "$out"
    typeset -p match mbegin mend
  done
done
for left in 'a' 'missing' '(#b)(a*)'; do
  for right in 'a' 'missing' '(#b)(a*)'; do
    out="${s[(r)$left,(R)$right]}"
    printf '%s\0' "$out"
    typeset -p match mbegin mend
  done
done
for left in 'a' 'missing' '(#b)(a*)'; do
  for right in 'a' 'missing' '(#b)(a*)'; do
    out="${s[(R)$left,(r)$right]}"
    printf '%s\0' "$out"
    typeset -p match mbegin mend
  done
done
for left in 'a' 'missing' '(#b)(a*)'; do
  for right in 'a' 'missing' '(#b)(a*)'; do
    out="${s[(R)$left,(R)$right]}"
    printf '%s\0' "$out"
    typeset -p match mbegin mend
  done
done
typeset -p s
print -r -- matrix-done

)
integer matrix_status=$?
print -r -- matrix-61-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R sh
setopt extendedglob multibyte
s='éa😀aé'
match=(); mbegin=(); mend=()
integer begin_at match_number
for needle in 'a' 'a*' '*' '?' '' 'missing' 'é*' $'a\0*' '(#b)(a*)'; do
  for begin_at in -9 -1 0 1 2 4 5 100; do
    for match_number in -2 -1 0 1 2; do
      out="${s[(ib:begin_at:n:match_number:)$needle]}"
      printf '%s\0' "$out"
      if [[ $needle == '(#b)(a*)' ]]; then typeset -p match mbegin mend; fi
    done
  done
done
for needle in 'a' 'a*' '*' '?' '' 'missing' 'é*' $'a\0*' '(#b)(a*)'; do
  for begin_at in -9 -1 0 1 2 4 5 100; do
    for match_number in -2 -1 0 1 2; do
      out="${s[(Ib:begin_at:n:match_number:)$needle]}"
      printf '%s\0' "$out"
      if [[ $needle == '(#b)(a*)' ]]; then typeset -p match mbegin mend; fi
    done
  done
done
for needle in 'a' 'a*' '*' '?' '' 'missing' 'é*' $'a\0*' '(#b)(a*)'; do
  for begin_at in -9 -1 0 1 2 4 5 100; do
    for match_number in -2 -1 0 1 2; do
      out="${s[(rb:begin_at:n:match_number:)$needle]}"
      printf '%s\0' "$out"
      if [[ $needle == '(#b)(a*)' ]]; then typeset -p match mbegin mend; fi
    done
  done
done
for needle in 'a' 'a*' '*' '?' '' 'missing' 'é*' $'a\0*' '(#b)(a*)'; do
  for begin_at in -9 -1 0 1 2 4 5 100; do
    for match_number in -2 -1 0 1 2; do
      out="${s[(Rb:begin_at:n:match_number:)$needle]}"
      printf '%s\0' "$out"
      if [[ $needle == '(#b)(a*)' ]]; then typeset -p match mbegin mend; fi
    done
  done
done
typeset -p s
print -r -- matrix-done

)
integer matrix_status=$?
print -r -- matrix-62-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R sh
setopt extendedglob multibyte
s='éa😀aé'
match=(); mbegin=(); mend=()
for left in 'a' 'missing' '(#b)(a*)'; do
  for right in 'a' 'missing' '(#b)(a*)'; do
    out="${s[(r)$left,(r)$right]}"
    printf '%s\0' "$out"
    typeset -p match mbegin mend
  done
done
for left in 'a' 'missing' '(#b)(a*)'; do
  for right in 'a' 'missing' '(#b)(a*)'; do
    out="${s[(r)$left,(R)$right]}"
    printf '%s\0' "$out"
    typeset -p match mbegin mend
  done
done
for left in 'a' 'missing' '(#b)(a*)'; do
  for right in 'a' 'missing' '(#b)(a*)'; do
    out="${s[(R)$left,(r)$right]}"
    printf '%s\0' "$out"
    typeset -p match mbegin mend
  done
done
for left in 'a' 'missing' '(#b)(a*)'; do
  for right in 'a' 'missing' '(#b)(a*)'; do
    out="${s[(R)$left,(R)$right]}"
    printf '%s\0' "$out"
    typeset -p match mbegin mend
  done
done
typeset -p s
print -r -- matrix-done

)
integer matrix_status=$?
print -r -- matrix-63-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R sh
setopt extendedglob multibyte
s=$'a\0b\203\377a'
match=(); mbegin=(); mend=()
integer begin_at match_number
for needle in 'a' 'a*' '*' '?' '' 'missing' 'é*' $'a\0*' '(#b)(a*)'; do
  for begin_at in -9 -1 0 1 2 4 5 100; do
    for match_number in -2 -1 0 1 2; do
      out="${s[(ib:begin_at:n:match_number:)$needle]}"
      printf '%s\0' "$out"
      if [[ $needle == '(#b)(a*)' ]]; then typeset -p match mbegin mend; fi
    done
  done
done
for needle in 'a' 'a*' '*' '?' '' 'missing' 'é*' $'a\0*' '(#b)(a*)'; do
  for begin_at in -9 -1 0 1 2 4 5 100; do
    for match_number in -2 -1 0 1 2; do
      out="${s[(Ib:begin_at:n:match_number:)$needle]}"
      printf '%s\0' "$out"
      if [[ $needle == '(#b)(a*)' ]]; then typeset -p match mbegin mend; fi
    done
  done
done
for needle in 'a' 'a*' '*' '?' '' 'missing' 'é*' $'a\0*' '(#b)(a*)'; do
  for begin_at in -9 -1 0 1 2 4 5 100; do
    for match_number in -2 -1 0 1 2; do
      out="${s[(rb:begin_at:n:match_number:)$needle]}"
      printf '%s\0' "$out"
      if [[ $needle == '(#b)(a*)' ]]; then typeset -p match mbegin mend; fi
    done
  done
done
for needle in 'a' 'a*' '*' '?' '' 'missing' 'é*' $'a\0*' '(#b)(a*)'; do
  for begin_at in -9 -1 0 1 2 4 5 100; do
    for match_number in -2 -1 0 1 2; do
      out="${s[(Rb:begin_at:n:match_number:)$needle]}"
      printf '%s\0' "$out"
      if [[ $needle == '(#b)(a*)' ]]; then typeset -p match mbegin mend; fi
    done
  done
done
typeset -p s
print -r -- matrix-done

)
integer matrix_status=$?
print -r -- matrix-64-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R sh
setopt extendedglob multibyte
s=$'a\0b\203\377a'
match=(); mbegin=(); mend=()
for left in 'a' 'missing' '(#b)(a*)'; do
  for right in 'a' 'missing' '(#b)(a*)'; do
    out="${s[(r)$left,(r)$right]}"
    printf '%s\0' "$out"
    typeset -p match mbegin mend
  done
done
for left in 'a' 'missing' '(#b)(a*)'; do
  for right in 'a' 'missing' '(#b)(a*)'; do
    out="${s[(r)$left,(R)$right]}"
    printf '%s\0' "$out"
    typeset -p match mbegin mend
  done
done
for left in 'a' 'missing' '(#b)(a*)'; do
  for right in 'a' 'missing' '(#b)(a*)'; do
    out="${s[(R)$left,(r)$right]}"
    printf '%s\0' "$out"
    typeset -p match mbegin mend
  done
done
for left in 'a' 'missing' '(#b)(a*)'; do
  for right in 'a' 'missing' '(#b)(a*)'; do
    out="${s[(R)$left,(R)$right]}"
    printf '%s\0' "$out"
    typeset -p match mbegin mend
  done
done
typeset -p s
print -r -- matrix-done

)
integer matrix_status=$?
print -r -- matrix-65-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R sh
setopt extendedglob multibyte
s='é 👩‍💻 a'
match=(); mbegin=(); mend=()
integer begin_at match_number
for needle in 'a' 'a*' '*' '?' '' 'missing' 'é*' $'a\0*' '(#b)(a*)'; do
  for begin_at in -9 -1 0 1 2 4 5 100; do
    for match_number in -2 -1 0 1 2; do
      out="${s[(ib:begin_at:n:match_number:)$needle]}"
      printf '%s\0' "$out"
      if [[ $needle == '(#b)(a*)' ]]; then typeset -p match mbegin mend; fi
    done
  done
done
for needle in 'a' 'a*' '*' '?' '' 'missing' 'é*' $'a\0*' '(#b)(a*)'; do
  for begin_at in -9 -1 0 1 2 4 5 100; do
    for match_number in -2 -1 0 1 2; do
      out="${s[(Ib:begin_at:n:match_number:)$needle]}"
      printf '%s\0' "$out"
      if [[ $needle == '(#b)(a*)' ]]; then typeset -p match mbegin mend; fi
    done
  done
done
for needle in 'a' 'a*' '*' '?' '' 'missing' 'é*' $'a\0*' '(#b)(a*)'; do
  for begin_at in -9 -1 0 1 2 4 5 100; do
    for match_number in -2 -1 0 1 2; do
      out="${s[(rb:begin_at:n:match_number:)$needle]}"
      printf '%s\0' "$out"
      if [[ $needle == '(#b)(a*)' ]]; then typeset -p match mbegin mend; fi
    done
  done
done
for needle in 'a' 'a*' '*' '?' '' 'missing' 'é*' $'a\0*' '(#b)(a*)'; do
  for begin_at in -9 -1 0 1 2 4 5 100; do
    for match_number in -2 -1 0 1 2; do
      out="${s[(Rb:begin_at:n:match_number:)$needle]}"
      printf '%s\0' "$out"
      if [[ $needle == '(#b)(a*)' ]]; then typeset -p match mbegin mend; fi
    done
  done
done
typeset -p s
print -r -- matrix-done

)
integer matrix_status=$?
print -r -- matrix-66-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R sh
setopt extendedglob multibyte
s='é 👩‍💻 a'
match=(); mbegin=(); mend=()
for left in 'a' 'missing' '(#b)(a*)'; do
  for right in 'a' 'missing' '(#b)(a*)'; do
    out="${s[(r)$left,(r)$right]}"
    printf '%s\0' "$out"
    typeset -p match mbegin mend
  done
done
for left in 'a' 'missing' '(#b)(a*)'; do
  for right in 'a' 'missing' '(#b)(a*)'; do
    out="${s[(r)$left,(R)$right]}"
    printf '%s\0' "$out"
    typeset -p match mbegin mend
  done
done
for left in 'a' 'missing' '(#b)(a*)'; do
  for right in 'a' 'missing' '(#b)(a*)'; do
    out="${s[(R)$left,(r)$right]}"
    printf '%s\0' "$out"
    typeset -p match mbegin mend
  done
done
for left in 'a' 'missing' '(#b)(a*)'; do
  for right in 'a' 'missing' '(#b)(a*)'; do
    out="${s[(R)$left,(R)$right]}"
    printf '%s\0' "$out"
    typeset -p match mbegin mend
  done
done
typeset -p s
print -r -- matrix-done

)
integer matrix_status=$?
print -r -- matrix-67-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R sh
setopt extendedglob multibyte
s=$'a\303\251b\303'
match=(); mbegin=(); mend=()
integer begin_at match_number
for needle in 'a' 'a*' '*' '?' '' 'missing' 'é*' $'a\0*' '(#b)(a*)'; do
  for begin_at in -9 -1 0 1 2 4 5 100; do
    for match_number in -2 -1 0 1 2; do
      out="${s[(ib:begin_at:n:match_number:)$needle]}"
      printf '%s\0' "$out"
      if [[ $needle == '(#b)(a*)' ]]; then typeset -p match mbegin mend; fi
    done
  done
done
for needle in 'a' 'a*' '*' '?' '' 'missing' 'é*' $'a\0*' '(#b)(a*)'; do
  for begin_at in -9 -1 0 1 2 4 5 100; do
    for match_number in -2 -1 0 1 2; do
      out="${s[(Ib:begin_at:n:match_number:)$needle]}"
      printf '%s\0' "$out"
      if [[ $needle == '(#b)(a*)' ]]; then typeset -p match mbegin mend; fi
    done
  done
done
for needle in 'a' 'a*' '*' '?' '' 'missing' 'é*' $'a\0*' '(#b)(a*)'; do
  for begin_at in -9 -1 0 1 2 4 5 100; do
    for match_number in -2 -1 0 1 2; do
      out="${s[(rb:begin_at:n:match_number:)$needle]}"
      printf '%s\0' "$out"
      if [[ $needle == '(#b)(a*)' ]]; then typeset -p match mbegin mend; fi
    done
  done
done
for needle in 'a' 'a*' '*' '?' '' 'missing' 'é*' $'a\0*' '(#b)(a*)'; do
  for begin_at in -9 -1 0 1 2 4 5 100; do
    for match_number in -2 -1 0 1 2; do
      out="${s[(Rb:begin_at:n:match_number:)$needle]}"
      printf '%s\0' "$out"
      if [[ $needle == '(#b)(a*)' ]]; then typeset -p match mbegin mend; fi
    done
  done
done
typeset -p s
print -r -- matrix-done

)
integer matrix_status=$?
print -r -- matrix-68-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R sh
setopt extendedglob multibyte
s=$'a\303\251b\303'
match=(); mbegin=(); mend=()
for left in 'a' 'missing' '(#b)(a*)'; do
  for right in 'a' 'missing' '(#b)(a*)'; do
    out="${s[(r)$left,(r)$right]}"
    printf '%s\0' "$out"
    typeset -p match mbegin mend
  done
done
for left in 'a' 'missing' '(#b)(a*)'; do
  for right in 'a' 'missing' '(#b)(a*)'; do
    out="${s[(r)$left,(R)$right]}"
    printf '%s\0' "$out"
    typeset -p match mbegin mend
  done
done
for left in 'a' 'missing' '(#b)(a*)'; do
  for right in 'a' 'missing' '(#b)(a*)'; do
    out="${s[(R)$left,(r)$right]}"
    printf '%s\0' "$out"
    typeset -p match mbegin mend
  done
done
for left in 'a' 'missing' '(#b)(a*)'; do
  for right in 'a' 'missing' '(#b)(a*)'; do
    out="${s[(R)$left,(R)$right]}"
    printf '%s\0' "$out"
    typeset -p match mbegin mend
  done
done
typeset -p s
print -r -- matrix-done

)
integer matrix_status=$?
print -r -- matrix-69-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R sh
setopt extendedglob nomultibyte
s=''
match=(); mbegin=(); mend=()
integer begin_at match_number
for needle in 'a' 'a*' '*' '?' '' 'missing' 'é*' $'a\0*' '(#b)(a*)'; do
  for begin_at in -9 -1 0 1 2 4 5 100; do
    for match_number in -2 -1 0 1 2; do
      out="${s[(ib:begin_at:n:match_number:)$needle]}"
      printf '%s\0' "$out"
      if [[ $needle == '(#b)(a*)' ]]; then typeset -p match mbegin mend; fi
    done
  done
done
for needle in 'a' 'a*' '*' '?' '' 'missing' 'é*' $'a\0*' '(#b)(a*)'; do
  for begin_at in -9 -1 0 1 2 4 5 100; do
    for match_number in -2 -1 0 1 2; do
      out="${s[(Ib:begin_at:n:match_number:)$needle]}"
      printf '%s\0' "$out"
      if [[ $needle == '(#b)(a*)' ]]; then typeset -p match mbegin mend; fi
    done
  done
done
for needle in 'a' 'a*' '*' '?' '' 'missing' 'é*' $'a\0*' '(#b)(a*)'; do
  for begin_at in -9 -1 0 1 2 4 5 100; do
    for match_number in -2 -1 0 1 2; do
      out="${s[(rb:begin_at:n:match_number:)$needle]}"
      printf '%s\0' "$out"
      if [[ $needle == '(#b)(a*)' ]]; then typeset -p match mbegin mend; fi
    done
  done
done
for needle in 'a' 'a*' '*' '?' '' 'missing' 'é*' $'a\0*' '(#b)(a*)'; do
  for begin_at in -9 -1 0 1 2 4 5 100; do
    for match_number in -2 -1 0 1 2; do
      out="${s[(Rb:begin_at:n:match_number:)$needle]}"
      printf '%s\0' "$out"
      if [[ $needle == '(#b)(a*)' ]]; then typeset -p match mbegin mend; fi
    done
  done
done
typeset -p s
print -r -- matrix-done

)
integer matrix_status=$?
print -r -- matrix-70-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R sh
setopt extendedglob nomultibyte
s=''
match=(); mbegin=(); mend=()
for left in 'a' 'missing' '(#b)(a*)'; do
  for right in 'a' 'missing' '(#b)(a*)'; do
    out="${s[(r)$left,(r)$right]}"
    printf '%s\0' "$out"
    typeset -p match mbegin mend
  done
done
for left in 'a' 'missing' '(#b)(a*)'; do
  for right in 'a' 'missing' '(#b)(a*)'; do
    out="${s[(r)$left,(R)$right]}"
    printf '%s\0' "$out"
    typeset -p match mbegin mend
  done
done
for left in 'a' 'missing' '(#b)(a*)'; do
  for right in 'a' 'missing' '(#b)(a*)'; do
    out="${s[(R)$left,(r)$right]}"
    printf '%s\0' "$out"
    typeset -p match mbegin mend
  done
done
for left in 'a' 'missing' '(#b)(a*)'; do
  for right in 'a' 'missing' '(#b)(a*)'; do
    out="${s[(R)$left,(R)$right]}"
    printf '%s\0' "$out"
    typeset -p match mbegin mend
  done
done
typeset -p s
print -r -- matrix-done

)
integer matrix_status=$?
print -r -- matrix-71-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R sh
setopt extendedglob nomultibyte
s='a'
match=(); mbegin=(); mend=()
integer begin_at match_number
for needle in 'a' 'a*' '*' '?' '' 'missing' 'é*' $'a\0*' '(#b)(a*)'; do
  for begin_at in -9 -1 0 1 2 4 5 100; do
    for match_number in -2 -1 0 1 2; do
      out="${s[(ib:begin_at:n:match_number:)$needle]}"
      printf '%s\0' "$out"
      if [[ $needle == '(#b)(a*)' ]]; then typeset -p match mbegin mend; fi
    done
  done
done
for needle in 'a' 'a*' '*' '?' '' 'missing' 'é*' $'a\0*' '(#b)(a*)'; do
  for begin_at in -9 -1 0 1 2 4 5 100; do
    for match_number in -2 -1 0 1 2; do
      out="${s[(Ib:begin_at:n:match_number:)$needle]}"
      printf '%s\0' "$out"
      if [[ $needle == '(#b)(a*)' ]]; then typeset -p match mbegin mend; fi
    done
  done
done
for needle in 'a' 'a*' '*' '?' '' 'missing' 'é*' $'a\0*' '(#b)(a*)'; do
  for begin_at in -9 -1 0 1 2 4 5 100; do
    for match_number in -2 -1 0 1 2; do
      out="${s[(rb:begin_at:n:match_number:)$needle]}"
      printf '%s\0' "$out"
      if [[ $needle == '(#b)(a*)' ]]; then typeset -p match mbegin mend; fi
    done
  done
done
for needle in 'a' 'a*' '*' '?' '' 'missing' 'é*' $'a\0*' '(#b)(a*)'; do
  for begin_at in -9 -1 0 1 2 4 5 100; do
    for match_number in -2 -1 0 1 2; do
      out="${s[(Rb:begin_at:n:match_number:)$needle]}"
      printf '%s\0' "$out"
      if [[ $needle == '(#b)(a*)' ]]; then typeset -p match mbegin mend; fi
    done
  done
done
typeset -p s
print -r -- matrix-done

)
integer matrix_status=$?
print -r -- matrix-72-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R sh
setopt extendedglob nomultibyte
s='a'
match=(); mbegin=(); mend=()
for left in 'a' 'missing' '(#b)(a*)'; do
  for right in 'a' 'missing' '(#b)(a*)'; do
    out="${s[(r)$left,(r)$right]}"
    printf '%s\0' "$out"
    typeset -p match mbegin mend
  done
done
for left in 'a' 'missing' '(#b)(a*)'; do
  for right in 'a' 'missing' '(#b)(a*)'; do
    out="${s[(r)$left,(R)$right]}"
    printf '%s\0' "$out"
    typeset -p match mbegin mend
  done
done
for left in 'a' 'missing' '(#b)(a*)'; do
  for right in 'a' 'missing' '(#b)(a*)'; do
    out="${s[(R)$left,(r)$right]}"
    printf '%s\0' "$out"
    typeset -p match mbegin mend
  done
done
for left in 'a' 'missing' '(#b)(a*)'; do
  for right in 'a' 'missing' '(#b)(a*)'; do
    out="${s[(R)$left,(R)$right]}"
    printf '%s\0' "$out"
    typeset -p match mbegin mend
  done
done
typeset -p s
print -r -- matrix-done

)
integer matrix_status=$?
print -r -- matrix-73-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R sh
setopt extendedglob nomultibyte
s='abc a def a'
match=(); mbegin=(); mend=()
integer begin_at match_number
for needle in 'a' 'a*' '*' '?' '' 'missing' 'é*' $'a\0*' '(#b)(a*)'; do
  for begin_at in -9 -1 0 1 2 4 5 100; do
    for match_number in -2 -1 0 1 2; do
      out="${s[(ib:begin_at:n:match_number:)$needle]}"
      printf '%s\0' "$out"
      if [[ $needle == '(#b)(a*)' ]]; then typeset -p match mbegin mend; fi
    done
  done
done
for needle in 'a' 'a*' '*' '?' '' 'missing' 'é*' $'a\0*' '(#b)(a*)'; do
  for begin_at in -9 -1 0 1 2 4 5 100; do
    for match_number in -2 -1 0 1 2; do
      out="${s[(Ib:begin_at:n:match_number:)$needle]}"
      printf '%s\0' "$out"
      if [[ $needle == '(#b)(a*)' ]]; then typeset -p match mbegin mend; fi
    done
  done
done
for needle in 'a' 'a*' '*' '?' '' 'missing' 'é*' $'a\0*' '(#b)(a*)'; do
  for begin_at in -9 -1 0 1 2 4 5 100; do
    for match_number in -2 -1 0 1 2; do
      out="${s[(rb:begin_at:n:match_number:)$needle]}"
      printf '%s\0' "$out"
      if [[ $needle == '(#b)(a*)' ]]; then typeset -p match mbegin mend; fi
    done
  done
done
for needle in 'a' 'a*' '*' '?' '' 'missing' 'é*' $'a\0*' '(#b)(a*)'; do
  for begin_at in -9 -1 0 1 2 4 5 100; do
    for match_number in -2 -1 0 1 2; do
      out="${s[(Rb:begin_at:n:match_number:)$needle]}"
      printf '%s\0' "$out"
      if [[ $needle == '(#b)(a*)' ]]; then typeset -p match mbegin mend; fi
    done
  done
done
typeset -p s
print -r -- matrix-done

)
integer matrix_status=$?
print -r -- matrix-74-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R sh
setopt extendedglob nomultibyte
s='abc a def a'
match=(); mbegin=(); mend=()
for left in 'a' 'missing' '(#b)(a*)'; do
  for right in 'a' 'missing' '(#b)(a*)'; do
    out="${s[(r)$left,(r)$right]}"
    printf '%s\0' "$out"
    typeset -p match mbegin mend
  done
done
for left in 'a' 'missing' '(#b)(a*)'; do
  for right in 'a' 'missing' '(#b)(a*)'; do
    out="${s[(r)$left,(R)$right]}"
    printf '%s\0' "$out"
    typeset -p match mbegin mend
  done
done
for left in 'a' 'missing' '(#b)(a*)'; do
  for right in 'a' 'missing' '(#b)(a*)'; do
    out="${s[(R)$left,(r)$right]}"
    printf '%s\0' "$out"
    typeset -p match mbegin mend
  done
done
for left in 'a' 'missing' '(#b)(a*)'; do
  for right in 'a' 'missing' '(#b)(a*)'; do
    out="${s[(R)$left,(R)$right]}"
    printf '%s\0' "$out"
    typeset -p match mbegin mend
  done
done
typeset -p s
print -r -- matrix-done

)
integer matrix_status=$?
print -r -- matrix-75-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R sh
setopt extendedglob nomultibyte
s='éa😀aé'
match=(); mbegin=(); mend=()
integer begin_at match_number
for needle in 'a' 'a*' '*' '?' '' 'missing' 'é*' $'a\0*' '(#b)(a*)'; do
  for begin_at in -9 -1 0 1 2 4 5 100; do
    for match_number in -2 -1 0 1 2; do
      out="${s[(ib:begin_at:n:match_number:)$needle]}"
      printf '%s\0' "$out"
      if [[ $needle == '(#b)(a*)' ]]; then typeset -p match mbegin mend; fi
    done
  done
done
for needle in 'a' 'a*' '*' '?' '' 'missing' 'é*' $'a\0*' '(#b)(a*)'; do
  for begin_at in -9 -1 0 1 2 4 5 100; do
    for match_number in -2 -1 0 1 2; do
      out="${s[(Ib:begin_at:n:match_number:)$needle]}"
      printf '%s\0' "$out"
      if [[ $needle == '(#b)(a*)' ]]; then typeset -p match mbegin mend; fi
    done
  done
done
for needle in 'a' 'a*' '*' '?' '' 'missing' 'é*' $'a\0*' '(#b)(a*)'; do
  for begin_at in -9 -1 0 1 2 4 5 100; do
    for match_number in -2 -1 0 1 2; do
      out="${s[(rb:begin_at:n:match_number:)$needle]}"
      printf '%s\0' "$out"
      if [[ $needle == '(#b)(a*)' ]]; then typeset -p match mbegin mend; fi
    done
  done
done
for needle in 'a' 'a*' '*' '?' '' 'missing' 'é*' $'a\0*' '(#b)(a*)'; do
  for begin_at in -9 -1 0 1 2 4 5 100; do
    for match_number in -2 -1 0 1 2; do
      out="${s[(Rb:begin_at:n:match_number:)$needle]}"
      printf '%s\0' "$out"
      if [[ $needle == '(#b)(a*)' ]]; then typeset -p match mbegin mend; fi
    done
  done
done
typeset -p s
print -r -- matrix-done

)
integer matrix_status=$?
print -r -- matrix-76-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R sh
setopt extendedglob nomultibyte
s='éa😀aé'
match=(); mbegin=(); mend=()
for left in 'a' 'missing' '(#b)(a*)'; do
  for right in 'a' 'missing' '(#b)(a*)'; do
    out="${s[(r)$left,(r)$right]}"
    printf '%s\0' "$out"
    typeset -p match mbegin mend
  done
done
for left in 'a' 'missing' '(#b)(a*)'; do
  for right in 'a' 'missing' '(#b)(a*)'; do
    out="${s[(r)$left,(R)$right]}"
    printf '%s\0' "$out"
    typeset -p match mbegin mend
  done
done
for left in 'a' 'missing' '(#b)(a*)'; do
  for right in 'a' 'missing' '(#b)(a*)'; do
    out="${s[(R)$left,(r)$right]}"
    printf '%s\0' "$out"
    typeset -p match mbegin mend
  done
done
for left in 'a' 'missing' '(#b)(a*)'; do
  for right in 'a' 'missing' '(#b)(a*)'; do
    out="${s[(R)$left,(R)$right]}"
    printf '%s\0' "$out"
    typeset -p match mbegin mend
  done
done
typeset -p s
print -r -- matrix-done

)
integer matrix_status=$?
print -r -- matrix-77-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R sh
setopt extendedglob nomultibyte
s=$'a\0b\203\377a'
match=(); mbegin=(); mend=()
integer begin_at match_number
for needle in 'a' 'a*' '*' '?' '' 'missing' 'é*' $'a\0*' '(#b)(a*)'; do
  for begin_at in -9 -1 0 1 2 4 5 100; do
    for match_number in -2 -1 0 1 2; do
      out="${s[(ib:begin_at:n:match_number:)$needle]}"
      printf '%s\0' "$out"
      if [[ $needle == '(#b)(a*)' ]]; then typeset -p match mbegin mend; fi
    done
  done
done
for needle in 'a' 'a*' '*' '?' '' 'missing' 'é*' $'a\0*' '(#b)(a*)'; do
  for begin_at in -9 -1 0 1 2 4 5 100; do
    for match_number in -2 -1 0 1 2; do
      out="${s[(Ib:begin_at:n:match_number:)$needle]}"
      printf '%s\0' "$out"
      if [[ $needle == '(#b)(a*)' ]]; then typeset -p match mbegin mend; fi
    done
  done
done
for needle in 'a' 'a*' '*' '?' '' 'missing' 'é*' $'a\0*' '(#b)(a*)'; do
  for begin_at in -9 -1 0 1 2 4 5 100; do
    for match_number in -2 -1 0 1 2; do
      out="${s[(rb:begin_at:n:match_number:)$needle]}"
      printf '%s\0' "$out"
      if [[ $needle == '(#b)(a*)' ]]; then typeset -p match mbegin mend; fi
    done
  done
done
for needle in 'a' 'a*' '*' '?' '' 'missing' 'é*' $'a\0*' '(#b)(a*)'; do
  for begin_at in -9 -1 0 1 2 4 5 100; do
    for match_number in -2 -1 0 1 2; do
      out="${s[(Rb:begin_at:n:match_number:)$needle]}"
      printf '%s\0' "$out"
      if [[ $needle == '(#b)(a*)' ]]; then typeset -p match mbegin mend; fi
    done
  done
done
typeset -p s
print -r -- matrix-done

)
integer matrix_status=$?
print -r -- matrix-78-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R sh
setopt extendedglob nomultibyte
s=$'a\0b\203\377a'
match=(); mbegin=(); mend=()
for left in 'a' 'missing' '(#b)(a*)'; do
  for right in 'a' 'missing' '(#b)(a*)'; do
    out="${s[(r)$left,(r)$right]}"
    printf '%s\0' "$out"
    typeset -p match mbegin mend
  done
done
for left in 'a' 'missing' '(#b)(a*)'; do
  for right in 'a' 'missing' '(#b)(a*)'; do
    out="${s[(r)$left,(R)$right]}"
    printf '%s\0' "$out"
    typeset -p match mbegin mend
  done
done
for left in 'a' 'missing' '(#b)(a*)'; do
  for right in 'a' 'missing' '(#b)(a*)'; do
    out="${s[(R)$left,(r)$right]}"
    printf '%s\0' "$out"
    typeset -p match mbegin mend
  done
done
for left in 'a' 'missing' '(#b)(a*)'; do
  for right in 'a' 'missing' '(#b)(a*)'; do
    out="${s[(R)$left,(R)$right]}"
    printf '%s\0' "$out"
    typeset -p match mbegin mend
  done
done
typeset -p s
print -r -- matrix-done

)
integer matrix_status=$?
print -r -- matrix-79-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R sh
setopt extendedglob nomultibyte
s='é 👩‍💻 a'
match=(); mbegin=(); mend=()
integer begin_at match_number
for needle in 'a' 'a*' '*' '?' '' 'missing' 'é*' $'a\0*' '(#b)(a*)'; do
  for begin_at in -9 -1 0 1 2 4 5 100; do
    for match_number in -2 -1 0 1 2; do
      out="${s[(ib:begin_at:n:match_number:)$needle]}"
      printf '%s\0' "$out"
      if [[ $needle == '(#b)(a*)' ]]; then typeset -p match mbegin mend; fi
    done
  done
done
for needle in 'a' 'a*' '*' '?' '' 'missing' 'é*' $'a\0*' '(#b)(a*)'; do
  for begin_at in -9 -1 0 1 2 4 5 100; do
    for match_number in -2 -1 0 1 2; do
      out="${s[(Ib:begin_at:n:match_number:)$needle]}"
      printf '%s\0' "$out"
      if [[ $needle == '(#b)(a*)' ]]; then typeset -p match mbegin mend; fi
    done
  done
done
for needle in 'a' 'a*' '*' '?' '' 'missing' 'é*' $'a\0*' '(#b)(a*)'; do
  for begin_at in -9 -1 0 1 2 4 5 100; do
    for match_number in -2 -1 0 1 2; do
      out="${s[(rb:begin_at:n:match_number:)$needle]}"
      printf '%s\0' "$out"
      if [[ $needle == '(#b)(a*)' ]]; then typeset -p match mbegin mend; fi
    done
  done
done
for needle in 'a' 'a*' '*' '?' '' 'missing' 'é*' $'a\0*' '(#b)(a*)'; do
  for begin_at in -9 -1 0 1 2 4 5 100; do
    for match_number in -2 -1 0 1 2; do
      out="${s[(Rb:begin_at:n:match_number:)$needle]}"
      printf '%s\0' "$out"
      if [[ $needle == '(#b)(a*)' ]]; then typeset -p match mbegin mend; fi
    done
  done
done
typeset -p s
print -r -- matrix-done

)
integer matrix_status=$?
print -r -- matrix-80-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R sh
setopt extendedglob nomultibyte
s='é 👩‍💻 a'
match=(); mbegin=(); mend=()
for left in 'a' 'missing' '(#b)(a*)'; do
  for right in 'a' 'missing' '(#b)(a*)'; do
    out="${s[(r)$left,(r)$right]}"
    printf '%s\0' "$out"
    typeset -p match mbegin mend
  done
done
for left in 'a' 'missing' '(#b)(a*)'; do
  for right in 'a' 'missing' '(#b)(a*)'; do
    out="${s[(r)$left,(R)$right]}"
    printf '%s\0' "$out"
    typeset -p match mbegin mend
  done
done
for left in 'a' 'missing' '(#b)(a*)'; do
  for right in 'a' 'missing' '(#b)(a*)'; do
    out="${s[(R)$left,(r)$right]}"
    printf '%s\0' "$out"
    typeset -p match mbegin mend
  done
done
for left in 'a' 'missing' '(#b)(a*)'; do
  for right in 'a' 'missing' '(#b)(a*)'; do
    out="${s[(R)$left,(R)$right]}"
    printf '%s\0' "$out"
    typeset -p match mbegin mend
  done
done
typeset -p s
print -r -- matrix-done

)
integer matrix_status=$?
print -r -- matrix-81-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R sh
setopt extendedglob nomultibyte
s=$'a\303\251b\303'
match=(); mbegin=(); mend=()
integer begin_at match_number
for needle in 'a' 'a*' '*' '?' '' 'missing' 'é*' $'a\0*' '(#b)(a*)'; do
  for begin_at in -9 -1 0 1 2 4 5 100; do
    for match_number in -2 -1 0 1 2; do
      out="${s[(ib:begin_at:n:match_number:)$needle]}"
      printf '%s\0' "$out"
      if [[ $needle == '(#b)(a*)' ]]; then typeset -p match mbegin mend; fi
    done
  done
done
for needle in 'a' 'a*' '*' '?' '' 'missing' 'é*' $'a\0*' '(#b)(a*)'; do
  for begin_at in -9 -1 0 1 2 4 5 100; do
    for match_number in -2 -1 0 1 2; do
      out="${s[(Ib:begin_at:n:match_number:)$needle]}"
      printf '%s\0' "$out"
      if [[ $needle == '(#b)(a*)' ]]; then typeset -p match mbegin mend; fi
    done
  done
done
for needle in 'a' 'a*' '*' '?' '' 'missing' 'é*' $'a\0*' '(#b)(a*)'; do
  for begin_at in -9 -1 0 1 2 4 5 100; do
    for match_number in -2 -1 0 1 2; do
      out="${s[(rb:begin_at:n:match_number:)$needle]}"
      printf '%s\0' "$out"
      if [[ $needle == '(#b)(a*)' ]]; then typeset -p match mbegin mend; fi
    done
  done
done
for needle in 'a' 'a*' '*' '?' '' 'missing' 'é*' $'a\0*' '(#b)(a*)'; do
  for begin_at in -9 -1 0 1 2 4 5 100; do
    for match_number in -2 -1 0 1 2; do
      out="${s[(Rb:begin_at:n:match_number:)$needle]}"
      printf '%s\0' "$out"
      if [[ $needle == '(#b)(a*)' ]]; then typeset -p match mbegin mend; fi
    done
  done
done
typeset -p s
print -r -- matrix-done

)
integer matrix_status=$?
print -r -- matrix-82-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
(
emulate -R sh
setopt extendedglob nomultibyte
s=$'a\303\251b\303'
match=(); mbegin=(); mend=()
for left in 'a' 'missing' '(#b)(a*)'; do
  for right in 'a' 'missing' '(#b)(a*)'; do
    out="${s[(r)$left,(r)$right]}"
    printf '%s\0' "$out"
    typeset -p match mbegin mend
  done
done
for left in 'a' 'missing' '(#b)(a*)'; do
  for right in 'a' 'missing' '(#b)(a*)'; do
    out="${s[(r)$left,(R)$right]}"
    printf '%s\0' "$out"
    typeset -p match mbegin mend
  done
done
for left in 'a' 'missing' '(#b)(a*)'; do
  for right in 'a' 'missing' '(#b)(a*)'; do
    out="${s[(R)$left,(r)$right]}"
    printf '%s\0' "$out"
    typeset -p match mbegin mend
  done
done
for left in 'a' 'missing' '(#b)(a*)'; do
  for right in 'a' 'missing' '(#b)(a*)'; do
    out="${s[(R)$left,(R)$right]}"
    printf '%s\0' "$out"
    typeset -p match mbegin mend
  done
done
typeset -p s
print -r -- matrix-done

)
integer matrix_status=$?
print -r -- matrix-83-status=$matrix_status
(( matrix_status )) && (( failed_matrices++ ))
print -r -- memcheck-complete failures=$failed_matrices
