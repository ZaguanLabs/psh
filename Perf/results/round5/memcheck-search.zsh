(
emulate -R zsh
setopt extendedglob multibyte
typeset -a a=()
match=(); mbegin=(); mend=()
integer begin_at match_number
for needle in 'a' 'a*' '*' '?' '' 'missing' 'é*' $'a\0*' '(#b)(a*)'; do
  for begin_at in -9 -1 0 1 2 4 5 100; do
    for match_number in -2 -1 0 1 2; do
      out="${a[(ib:begin_at:n:match_number:)$needle]}"
      printf '%s\0' "$out"
      if [[ $needle == '(#b)(a*)' ]]; then typeset -p match mbegin mend; fi
    done
  done
done
for needle in 'a' 'a*' '*' '?' '' 'missing' 'é*' $'a\0*' '(#b)(a*)'; do
  for begin_at in -9 -1 0 1 2 4 5 100; do
    for match_number in -2 -1 0 1 2; do
      out="${a[(Ib:begin_at:n:match_number:)$needle]}"
      printf '%s\0' "$out"
      if [[ $needle == '(#b)(a*)' ]]; then typeset -p match mbegin mend; fi
    done
  done
done
for needle in 'a' 'a*' '*' '?' '' 'missing' 'é*' $'a\0*' '(#b)(a*)'; do
  for begin_at in -9 -1 0 1 2 4 5 100; do
    for match_number in -2 -1 0 1 2; do
      out="${a[(rb:begin_at:n:match_number:)$needle]}"
      printf '%s\0' "$out"
      if [[ $needle == '(#b)(a*)' ]]; then typeset -p match mbegin mend; fi
    done
  done
done
for needle in 'a' 'a*' '*' '?' '' 'missing' 'é*' $'a\0*' '(#b)(a*)'; do
  for begin_at in -9 -1 0 1 2 4 5 100; do
    for match_number in -2 -1 0 1 2; do
      out="${a[(Rb:begin_at:n:match_number:)$needle]}"
      printf '%s\0' "$out"
      if [[ $needle == '(#b)(a*)' ]]; then typeset -p match mbegin mend; fi
    done
  done
done
typeset -p a
print -r -- matrix-done

) || exit 1
(
emulate -R zsh
setopt extendedglob multibyte
typeset -a a=('')
match=(); mbegin=(); mend=()
integer begin_at match_number
for needle in 'a' 'a*' '*' '?' '' 'missing' 'é*' $'a\0*' '(#b)(a*)'; do
  for begin_at in -9 -1 0 1 2 4 5 100; do
    for match_number in -2 -1 0 1 2; do
      out="${a[(ib:begin_at:n:match_number:)$needle]}"
      printf '%s\0' "$out"
      if [[ $needle == '(#b)(a*)' ]]; then typeset -p match mbegin mend; fi
    done
  done
done
for needle in 'a' 'a*' '*' '?' '' 'missing' 'é*' $'a\0*' '(#b)(a*)'; do
  for begin_at in -9 -1 0 1 2 4 5 100; do
    for match_number in -2 -1 0 1 2; do
      out="${a[(Ib:begin_at:n:match_number:)$needle]}"
      printf '%s\0' "$out"
      if [[ $needle == '(#b)(a*)' ]]; then typeset -p match mbegin mend; fi
    done
  done
done
for needle in 'a' 'a*' '*' '?' '' 'missing' 'é*' $'a\0*' '(#b)(a*)'; do
  for begin_at in -9 -1 0 1 2 4 5 100; do
    for match_number in -2 -1 0 1 2; do
      out="${a[(rb:begin_at:n:match_number:)$needle]}"
      printf '%s\0' "$out"
      if [[ $needle == '(#b)(a*)' ]]; then typeset -p match mbegin mend; fi
    done
  done
done
for needle in 'a' 'a*' '*' '?' '' 'missing' 'é*' $'a\0*' '(#b)(a*)'; do
  for begin_at in -9 -1 0 1 2 4 5 100; do
    for match_number in -2 -1 0 1 2; do
      out="${a[(Rb:begin_at:n:match_number:)$needle]}"
      printf '%s\0' "$out"
      if [[ $needle == '(#b)(a*)' ]]; then typeset -p match mbegin mend; fi
    done
  done
done
typeset -p a
print -r -- matrix-done

) || exit 1
(
emulate -R zsh
setopt extendedglob multibyte
typeset -a a=(a '' ab a é $'a\0b' 'two words')
match=(); mbegin=(); mend=()
integer begin_at match_number
for needle in 'a' 'a*' '*' '?' '' 'missing' 'é*' $'a\0*' '(#b)(a*)'; do
  for begin_at in -9 -1 0 1 2 4 5 100; do
    for match_number in -2 -1 0 1 2; do
      out="${a[(ib:begin_at:n:match_number:)$needle]}"
      printf '%s\0' "$out"
      if [[ $needle == '(#b)(a*)' ]]; then typeset -p match mbegin mend; fi
    done
  done
done
for needle in 'a' 'a*' '*' '?' '' 'missing' 'é*' $'a\0*' '(#b)(a*)'; do
  for begin_at in -9 -1 0 1 2 4 5 100; do
    for match_number in -2 -1 0 1 2; do
      out="${a[(Ib:begin_at:n:match_number:)$needle]}"
      printf '%s\0' "$out"
      if [[ $needle == '(#b)(a*)' ]]; then typeset -p match mbegin mend; fi
    done
  done
done
for needle in 'a' 'a*' '*' '?' '' 'missing' 'é*' $'a\0*' '(#b)(a*)'; do
  for begin_at in -9 -1 0 1 2 4 5 100; do
    for match_number in -2 -1 0 1 2; do
      out="${a[(rb:begin_at:n:match_number:)$needle]}"
      printf '%s\0' "$out"
      if [[ $needle == '(#b)(a*)' ]]; then typeset -p match mbegin mend; fi
    done
  done
done
for needle in 'a' 'a*' '*' '?' '' 'missing' 'é*' $'a\0*' '(#b)(a*)'; do
  for begin_at in -9 -1 0 1 2 4 5 100; do
    for match_number in -2 -1 0 1 2; do
      out="${a[(Rb:begin_at:n:match_number:)$needle]}"
      printf '%s\0' "$out"
      if [[ $needle == '(#b)(a*)' ]]; then typeset -p match mbegin mend; fi
    done
  done
done
typeset -p a
print -r -- matrix-done

) || exit 1
(
emulate -R zsh
setopt extendedglob multibyte
typeset -a a=(zero one two three four five six seven eight a)
match=(); mbegin=(); mend=()
integer begin_at match_number
for needle in 'a' 'a*' '*' '?' '' 'missing' 'é*' $'a\0*' '(#b)(a*)'; do
  for begin_at in -9 -1 0 1 2 4 5 100; do
    for match_number in -2 -1 0 1 2; do
      out="${a[(ib:begin_at:n:match_number:)$needle]}"
      printf '%s\0' "$out"
      if [[ $needle == '(#b)(a*)' ]]; then typeset -p match mbegin mend; fi
    done
  done
done
for needle in 'a' 'a*' '*' '?' '' 'missing' 'é*' $'a\0*' '(#b)(a*)'; do
  for begin_at in -9 -1 0 1 2 4 5 100; do
    for match_number in -2 -1 0 1 2; do
      out="${a[(Ib:begin_at:n:match_number:)$needle]}"
      printf '%s\0' "$out"
      if [[ $needle == '(#b)(a*)' ]]; then typeset -p match mbegin mend; fi
    done
  done
done
for needle in 'a' 'a*' '*' '?' '' 'missing' 'é*' $'a\0*' '(#b)(a*)'; do
  for begin_at in -9 -1 0 1 2 4 5 100; do
    for match_number in -2 -1 0 1 2; do
      out="${a[(rb:begin_at:n:match_number:)$needle]}"
      printf '%s\0' "$out"
      if [[ $needle == '(#b)(a*)' ]]; then typeset -p match mbegin mend; fi
    done
  done
done
for needle in 'a' 'a*' '*' '?' '' 'missing' 'é*' $'a\0*' '(#b)(a*)'; do
  for begin_at in -9 -1 0 1 2 4 5 100; do
    for match_number in -2 -1 0 1 2; do
      out="${a[(Rb:begin_at:n:match_number:)$needle]}"
      printf '%s\0' "$out"
      if [[ $needle == '(#b)(a*)' ]]; then typeset -p match mbegin mend; fi
    done
  done
done
typeset -p a
print -r -- matrix-done

) || exit 1
(
emulate -R zsh
setopt extendedglob nomultibyte
typeset -a a=()
match=(); mbegin=(); mend=()
integer begin_at match_number
for needle in 'a' 'a*' '*' '?' '' 'missing' 'é*' $'a\0*' '(#b)(a*)'; do
  for begin_at in -9 -1 0 1 2 4 5 100; do
    for match_number in -2 -1 0 1 2; do
      out="${a[(ib:begin_at:n:match_number:)$needle]}"
      printf '%s\0' "$out"
      if [[ $needle == '(#b)(a*)' ]]; then typeset -p match mbegin mend; fi
    done
  done
done
for needle in 'a' 'a*' '*' '?' '' 'missing' 'é*' $'a\0*' '(#b)(a*)'; do
  for begin_at in -9 -1 0 1 2 4 5 100; do
    for match_number in -2 -1 0 1 2; do
      out="${a[(Ib:begin_at:n:match_number:)$needle]}"
      printf '%s\0' "$out"
      if [[ $needle == '(#b)(a*)' ]]; then typeset -p match mbegin mend; fi
    done
  done
done
for needle in 'a' 'a*' '*' '?' '' 'missing' 'é*' $'a\0*' '(#b)(a*)'; do
  for begin_at in -9 -1 0 1 2 4 5 100; do
    for match_number in -2 -1 0 1 2; do
      out="${a[(rb:begin_at:n:match_number:)$needle]}"
      printf '%s\0' "$out"
      if [[ $needle == '(#b)(a*)' ]]; then typeset -p match mbegin mend; fi
    done
  done
done
for needle in 'a' 'a*' '*' '?' '' 'missing' 'é*' $'a\0*' '(#b)(a*)'; do
  for begin_at in -9 -1 0 1 2 4 5 100; do
    for match_number in -2 -1 0 1 2; do
      out="${a[(Rb:begin_at:n:match_number:)$needle]}"
      printf '%s\0' "$out"
      if [[ $needle == '(#b)(a*)' ]]; then typeset -p match mbegin mend; fi
    done
  done
done
typeset -p a
print -r -- matrix-done

) || exit 1
(
emulate -R zsh
setopt extendedglob nomultibyte
typeset -a a=('')
match=(); mbegin=(); mend=()
integer begin_at match_number
for needle in 'a' 'a*' '*' '?' '' 'missing' 'é*' $'a\0*' '(#b)(a*)'; do
  for begin_at in -9 -1 0 1 2 4 5 100; do
    for match_number in -2 -1 0 1 2; do
      out="${a[(ib:begin_at:n:match_number:)$needle]}"
      printf '%s\0' "$out"
      if [[ $needle == '(#b)(a*)' ]]; then typeset -p match mbegin mend; fi
    done
  done
done
for needle in 'a' 'a*' '*' '?' '' 'missing' 'é*' $'a\0*' '(#b)(a*)'; do
  for begin_at in -9 -1 0 1 2 4 5 100; do
    for match_number in -2 -1 0 1 2; do
      out="${a[(Ib:begin_at:n:match_number:)$needle]}"
      printf '%s\0' "$out"
      if [[ $needle == '(#b)(a*)' ]]; then typeset -p match mbegin mend; fi
    done
  done
done
for needle in 'a' 'a*' '*' '?' '' 'missing' 'é*' $'a\0*' '(#b)(a*)'; do
  for begin_at in -9 -1 0 1 2 4 5 100; do
    for match_number in -2 -1 0 1 2; do
      out="${a[(rb:begin_at:n:match_number:)$needle]}"
      printf '%s\0' "$out"
      if [[ $needle == '(#b)(a*)' ]]; then typeset -p match mbegin mend; fi
    done
  done
done
for needle in 'a' 'a*' '*' '?' '' 'missing' 'é*' $'a\0*' '(#b)(a*)'; do
  for begin_at in -9 -1 0 1 2 4 5 100; do
    for match_number in -2 -1 0 1 2; do
      out="${a[(Rb:begin_at:n:match_number:)$needle]}"
      printf '%s\0' "$out"
      if [[ $needle == '(#b)(a*)' ]]; then typeset -p match mbegin mend; fi
    done
  done
done
typeset -p a
print -r -- matrix-done

) || exit 1
(
emulate -R zsh
setopt extendedglob nomultibyte
typeset -a a=(a '' ab a é $'a\0b' 'two words')
match=(); mbegin=(); mend=()
integer begin_at match_number
for needle in 'a' 'a*' '*' '?' '' 'missing' 'é*' $'a\0*' '(#b)(a*)'; do
  for begin_at in -9 -1 0 1 2 4 5 100; do
    for match_number in -2 -1 0 1 2; do
      out="${a[(ib:begin_at:n:match_number:)$needle]}"
      printf '%s\0' "$out"
      if [[ $needle == '(#b)(a*)' ]]; then typeset -p match mbegin mend; fi
    done
  done
done
for needle in 'a' 'a*' '*' '?' '' 'missing' 'é*' $'a\0*' '(#b)(a*)'; do
  for begin_at in -9 -1 0 1 2 4 5 100; do
    for match_number in -2 -1 0 1 2; do
      out="${a[(Ib:begin_at:n:match_number:)$needle]}"
      printf '%s\0' "$out"
      if [[ $needle == '(#b)(a*)' ]]; then typeset -p match mbegin mend; fi
    done
  done
done
for needle in 'a' 'a*' '*' '?' '' 'missing' 'é*' $'a\0*' '(#b)(a*)'; do
  for begin_at in -9 -1 0 1 2 4 5 100; do
    for match_number in -2 -1 0 1 2; do
      out="${a[(rb:begin_at:n:match_number:)$needle]}"
      printf '%s\0' "$out"
      if [[ $needle == '(#b)(a*)' ]]; then typeset -p match mbegin mend; fi
    done
  done
done
for needle in 'a' 'a*' '*' '?' '' 'missing' 'é*' $'a\0*' '(#b)(a*)'; do
  for begin_at in -9 -1 0 1 2 4 5 100; do
    for match_number in -2 -1 0 1 2; do
      out="${a[(Rb:begin_at:n:match_number:)$needle]}"
      printf '%s\0' "$out"
      if [[ $needle == '(#b)(a*)' ]]; then typeset -p match mbegin mend; fi
    done
  done
done
typeset -p a
print -r -- matrix-done

) || exit 1
(
emulate -R zsh
setopt extendedglob nomultibyte
typeset -a a=(zero one two three four five six seven eight a)
match=(); mbegin=(); mend=()
integer begin_at match_number
for needle in 'a' 'a*' '*' '?' '' 'missing' 'é*' $'a\0*' '(#b)(a*)'; do
  for begin_at in -9 -1 0 1 2 4 5 100; do
    for match_number in -2 -1 0 1 2; do
      out="${a[(ib:begin_at:n:match_number:)$needle]}"
      printf '%s\0' "$out"
      if [[ $needle == '(#b)(a*)' ]]; then typeset -p match mbegin mend; fi
    done
  done
done
for needle in 'a' 'a*' '*' '?' '' 'missing' 'é*' $'a\0*' '(#b)(a*)'; do
  for begin_at in -9 -1 0 1 2 4 5 100; do
    for match_number in -2 -1 0 1 2; do
      out="${a[(Ib:begin_at:n:match_number:)$needle]}"
      printf '%s\0' "$out"
      if [[ $needle == '(#b)(a*)' ]]; then typeset -p match mbegin mend; fi
    done
  done
done
for needle in 'a' 'a*' '*' '?' '' 'missing' 'é*' $'a\0*' '(#b)(a*)'; do
  for begin_at in -9 -1 0 1 2 4 5 100; do
    for match_number in -2 -1 0 1 2; do
      out="${a[(rb:begin_at:n:match_number:)$needle]}"
      printf '%s\0' "$out"
      if [[ $needle == '(#b)(a*)' ]]; then typeset -p match mbegin mend; fi
    done
  done
done
for needle in 'a' 'a*' '*' '?' '' 'missing' 'é*' $'a\0*' '(#b)(a*)'; do
  for begin_at in -9 -1 0 1 2 4 5 100; do
    for match_number in -2 -1 0 1 2; do
      out="${a[(Rb:begin_at:n:match_number:)$needle]}"
      printf '%s\0' "$out"
      if [[ $needle == '(#b)(a*)' ]]; then typeset -p match mbegin mend; fi
    done
  done
done
typeset -p a
print -r -- matrix-done

) || exit 1
(
emulate -R ksh
setopt extendedglob multibyte
typeset -a a=()
match=(); mbegin=(); mend=()
integer begin_at match_number
for needle in 'a' 'a*' '*' '?' '' 'missing' 'é*' $'a\0*' '(#b)(a*)'; do
  for begin_at in -9 -1 0 1 2 4 5 100; do
    for match_number in -2 -1 0 1 2; do
      out="${a[(ib:begin_at:n:match_number:)$needle]}"
      printf '%s\0' "$out"
      if [[ $needle == '(#b)(a*)' ]]; then typeset -p match mbegin mend; fi
    done
  done
done
for needle in 'a' 'a*' '*' '?' '' 'missing' 'é*' $'a\0*' '(#b)(a*)'; do
  for begin_at in -9 -1 0 1 2 4 5 100; do
    for match_number in -2 -1 0 1 2; do
      out="${a[(Ib:begin_at:n:match_number:)$needle]}"
      printf '%s\0' "$out"
      if [[ $needle == '(#b)(a*)' ]]; then typeset -p match mbegin mend; fi
    done
  done
done
for needle in 'a' 'a*' '*' '?' '' 'missing' 'é*' $'a\0*' '(#b)(a*)'; do
  for begin_at in -9 -1 0 1 2 4 5 100; do
    for match_number in -2 -1 0 1 2; do
      out="${a[(rb:begin_at:n:match_number:)$needle]}"
      printf '%s\0' "$out"
      if [[ $needle == '(#b)(a*)' ]]; then typeset -p match mbegin mend; fi
    done
  done
done
for needle in 'a' 'a*' '*' '?' '' 'missing' 'é*' $'a\0*' '(#b)(a*)'; do
  for begin_at in -9 -1 0 1 2 4 5 100; do
    for match_number in -2 -1 0 1 2; do
      out="${a[(Rb:begin_at:n:match_number:)$needle]}"
      printf '%s\0' "$out"
      if [[ $needle == '(#b)(a*)' ]]; then typeset -p match mbegin mend; fi
    done
  done
done
typeset -p a
print -r -- matrix-done

) || exit 1
(
emulate -R ksh
setopt extendedglob multibyte
typeset -a a=('')
match=(); mbegin=(); mend=()
integer begin_at match_number
for needle in 'a' 'a*' '*' '?' '' 'missing' 'é*' $'a\0*' '(#b)(a*)'; do
  for begin_at in -9 -1 0 1 2 4 5 100; do
    for match_number in -2 -1 0 1 2; do
      out="${a[(ib:begin_at:n:match_number:)$needle]}"
      printf '%s\0' "$out"
      if [[ $needle == '(#b)(a*)' ]]; then typeset -p match mbegin mend; fi
    done
  done
done
for needle in 'a' 'a*' '*' '?' '' 'missing' 'é*' $'a\0*' '(#b)(a*)'; do
  for begin_at in -9 -1 0 1 2 4 5 100; do
    for match_number in -2 -1 0 1 2; do
      out="${a[(Ib:begin_at:n:match_number:)$needle]}"
      printf '%s\0' "$out"
      if [[ $needle == '(#b)(a*)' ]]; then typeset -p match mbegin mend; fi
    done
  done
done
for needle in 'a' 'a*' '*' '?' '' 'missing' 'é*' $'a\0*' '(#b)(a*)'; do
  for begin_at in -9 -1 0 1 2 4 5 100; do
    for match_number in -2 -1 0 1 2; do
      out="${a[(rb:begin_at:n:match_number:)$needle]}"
      printf '%s\0' "$out"
      if [[ $needle == '(#b)(a*)' ]]; then typeset -p match mbegin mend; fi
    done
  done
done
for needle in 'a' 'a*' '*' '?' '' 'missing' 'é*' $'a\0*' '(#b)(a*)'; do
  for begin_at in -9 -1 0 1 2 4 5 100; do
    for match_number in -2 -1 0 1 2; do
      out="${a[(Rb:begin_at:n:match_number:)$needle]}"
      printf '%s\0' "$out"
      if [[ $needle == '(#b)(a*)' ]]; then typeset -p match mbegin mend; fi
    done
  done
done
typeset -p a
print -r -- matrix-done

) || exit 1
(
emulate -R ksh
setopt extendedglob multibyte
typeset -a a=(a '' ab a é $'a\0b' 'two words')
match=(); mbegin=(); mend=()
integer begin_at match_number
for needle in 'a' 'a*' '*' '?' '' 'missing' 'é*' $'a\0*' '(#b)(a*)'; do
  for begin_at in -9 -1 0 1 2 4 5 100; do
    for match_number in -2 -1 0 1 2; do
      out="${a[(ib:begin_at:n:match_number:)$needle]}"
      printf '%s\0' "$out"
      if [[ $needle == '(#b)(a*)' ]]; then typeset -p match mbegin mend; fi
    done
  done
done
for needle in 'a' 'a*' '*' '?' '' 'missing' 'é*' $'a\0*' '(#b)(a*)'; do
  for begin_at in -9 -1 0 1 2 4 5 100; do
    for match_number in -2 -1 0 1 2; do
      out="${a[(Ib:begin_at:n:match_number:)$needle]}"
      printf '%s\0' "$out"
      if [[ $needle == '(#b)(a*)' ]]; then typeset -p match mbegin mend; fi
    done
  done
done
for needle in 'a' 'a*' '*' '?' '' 'missing' 'é*' $'a\0*' '(#b)(a*)'; do
  for begin_at in -9 -1 0 1 2 4 5 100; do
    for match_number in -2 -1 0 1 2; do
      out="${a[(rb:begin_at:n:match_number:)$needle]}"
      printf '%s\0' "$out"
      if [[ $needle == '(#b)(a*)' ]]; then typeset -p match mbegin mend; fi
    done
  done
done
for needle in 'a' 'a*' '*' '?' '' 'missing' 'é*' $'a\0*' '(#b)(a*)'; do
  for begin_at in -9 -1 0 1 2 4 5 100; do
    for match_number in -2 -1 0 1 2; do
      out="${a[(Rb:begin_at:n:match_number:)$needle]}"
      printf '%s\0' "$out"
      if [[ $needle == '(#b)(a*)' ]]; then typeset -p match mbegin mend; fi
    done
  done
done
typeset -p a
print -r -- matrix-done

) || exit 1
(
emulate -R ksh
setopt extendedglob multibyte
typeset -a a=(zero one two three four five six seven eight a)
match=(); mbegin=(); mend=()
integer begin_at match_number
for needle in 'a' 'a*' '*' '?' '' 'missing' 'é*' $'a\0*' '(#b)(a*)'; do
  for begin_at in -9 -1 0 1 2 4 5 100; do
    for match_number in -2 -1 0 1 2; do
      out="${a[(ib:begin_at:n:match_number:)$needle]}"
      printf '%s\0' "$out"
      if [[ $needle == '(#b)(a*)' ]]; then typeset -p match mbegin mend; fi
    done
  done
done
for needle in 'a' 'a*' '*' '?' '' 'missing' 'é*' $'a\0*' '(#b)(a*)'; do
  for begin_at in -9 -1 0 1 2 4 5 100; do
    for match_number in -2 -1 0 1 2; do
      out="${a[(Ib:begin_at:n:match_number:)$needle]}"
      printf '%s\0' "$out"
      if [[ $needle == '(#b)(a*)' ]]; then typeset -p match mbegin mend; fi
    done
  done
done
for needle in 'a' 'a*' '*' '?' '' 'missing' 'é*' $'a\0*' '(#b)(a*)'; do
  for begin_at in -9 -1 0 1 2 4 5 100; do
    for match_number in -2 -1 0 1 2; do
      out="${a[(rb:begin_at:n:match_number:)$needle]}"
      printf '%s\0' "$out"
      if [[ $needle == '(#b)(a*)' ]]; then typeset -p match mbegin mend; fi
    done
  done
done
for needle in 'a' 'a*' '*' '?' '' 'missing' 'é*' $'a\0*' '(#b)(a*)'; do
  for begin_at in -9 -1 0 1 2 4 5 100; do
    for match_number in -2 -1 0 1 2; do
      out="${a[(Rb:begin_at:n:match_number:)$needle]}"
      printf '%s\0' "$out"
      if [[ $needle == '(#b)(a*)' ]]; then typeset -p match mbegin mend; fi
    done
  done
done
typeset -p a
print -r -- matrix-done

) || exit 1
(
emulate -R ksh
setopt extendedglob nomultibyte
typeset -a a=()
match=(); mbegin=(); mend=()
integer begin_at match_number
for needle in 'a' 'a*' '*' '?' '' 'missing' 'é*' $'a\0*' '(#b)(a*)'; do
  for begin_at in -9 -1 0 1 2 4 5 100; do
    for match_number in -2 -1 0 1 2; do
      out="${a[(ib:begin_at:n:match_number:)$needle]}"
      printf '%s\0' "$out"
      if [[ $needle == '(#b)(a*)' ]]; then typeset -p match mbegin mend; fi
    done
  done
done
for needle in 'a' 'a*' '*' '?' '' 'missing' 'é*' $'a\0*' '(#b)(a*)'; do
  for begin_at in -9 -1 0 1 2 4 5 100; do
    for match_number in -2 -1 0 1 2; do
      out="${a[(Ib:begin_at:n:match_number:)$needle]}"
      printf '%s\0' "$out"
      if [[ $needle == '(#b)(a*)' ]]; then typeset -p match mbegin mend; fi
    done
  done
done
for needle in 'a' 'a*' '*' '?' '' 'missing' 'é*' $'a\0*' '(#b)(a*)'; do
  for begin_at in -9 -1 0 1 2 4 5 100; do
    for match_number in -2 -1 0 1 2; do
      out="${a[(rb:begin_at:n:match_number:)$needle]}"
      printf '%s\0' "$out"
      if [[ $needle == '(#b)(a*)' ]]; then typeset -p match mbegin mend; fi
    done
  done
done
for needle in 'a' 'a*' '*' '?' '' 'missing' 'é*' $'a\0*' '(#b)(a*)'; do
  for begin_at in -9 -1 0 1 2 4 5 100; do
    for match_number in -2 -1 0 1 2; do
      out="${a[(Rb:begin_at:n:match_number:)$needle]}"
      printf '%s\0' "$out"
      if [[ $needle == '(#b)(a*)' ]]; then typeset -p match mbegin mend; fi
    done
  done
done
typeset -p a
print -r -- matrix-done

) || exit 1
(
emulate -R ksh
setopt extendedglob nomultibyte
typeset -a a=('')
match=(); mbegin=(); mend=()
integer begin_at match_number
for needle in 'a' 'a*' '*' '?' '' 'missing' 'é*' $'a\0*' '(#b)(a*)'; do
  for begin_at in -9 -1 0 1 2 4 5 100; do
    for match_number in -2 -1 0 1 2; do
      out="${a[(ib:begin_at:n:match_number:)$needle]}"
      printf '%s\0' "$out"
      if [[ $needle == '(#b)(a*)' ]]; then typeset -p match mbegin mend; fi
    done
  done
done
for needle in 'a' 'a*' '*' '?' '' 'missing' 'é*' $'a\0*' '(#b)(a*)'; do
  for begin_at in -9 -1 0 1 2 4 5 100; do
    for match_number in -2 -1 0 1 2; do
      out="${a[(Ib:begin_at:n:match_number:)$needle]}"
      printf '%s\0' "$out"
      if [[ $needle == '(#b)(a*)' ]]; then typeset -p match mbegin mend; fi
    done
  done
done
for needle in 'a' 'a*' '*' '?' '' 'missing' 'é*' $'a\0*' '(#b)(a*)'; do
  for begin_at in -9 -1 0 1 2 4 5 100; do
    for match_number in -2 -1 0 1 2; do
      out="${a[(rb:begin_at:n:match_number:)$needle]}"
      printf '%s\0' "$out"
      if [[ $needle == '(#b)(a*)' ]]; then typeset -p match mbegin mend; fi
    done
  done
done
for needle in 'a' 'a*' '*' '?' '' 'missing' 'é*' $'a\0*' '(#b)(a*)'; do
  for begin_at in -9 -1 0 1 2 4 5 100; do
    for match_number in -2 -1 0 1 2; do
      out="${a[(Rb:begin_at:n:match_number:)$needle]}"
      printf '%s\0' "$out"
      if [[ $needle == '(#b)(a*)' ]]; then typeset -p match mbegin mend; fi
    done
  done
done
typeset -p a
print -r -- matrix-done

) || exit 1
(
emulate -R ksh
setopt extendedglob nomultibyte
typeset -a a=(a '' ab a é $'a\0b' 'two words')
match=(); mbegin=(); mend=()
integer begin_at match_number
for needle in 'a' 'a*' '*' '?' '' 'missing' 'é*' $'a\0*' '(#b)(a*)'; do
  for begin_at in -9 -1 0 1 2 4 5 100; do
    for match_number in -2 -1 0 1 2; do
      out="${a[(ib:begin_at:n:match_number:)$needle]}"
      printf '%s\0' "$out"
      if [[ $needle == '(#b)(a*)' ]]; then typeset -p match mbegin mend; fi
    done
  done
done
for needle in 'a' 'a*' '*' '?' '' 'missing' 'é*' $'a\0*' '(#b)(a*)'; do
  for begin_at in -9 -1 0 1 2 4 5 100; do
    for match_number in -2 -1 0 1 2; do
      out="${a[(Ib:begin_at:n:match_number:)$needle]}"
      printf '%s\0' "$out"
      if [[ $needle == '(#b)(a*)' ]]; then typeset -p match mbegin mend; fi
    done
  done
done
for needle in 'a' 'a*' '*' '?' '' 'missing' 'é*' $'a\0*' '(#b)(a*)'; do
  for begin_at in -9 -1 0 1 2 4 5 100; do
    for match_number in -2 -1 0 1 2; do
      out="${a[(rb:begin_at:n:match_number:)$needle]}"
      printf '%s\0' "$out"
      if [[ $needle == '(#b)(a*)' ]]; then typeset -p match mbegin mend; fi
    done
  done
done
for needle in 'a' 'a*' '*' '?' '' 'missing' 'é*' $'a\0*' '(#b)(a*)'; do
  for begin_at in -9 -1 0 1 2 4 5 100; do
    for match_number in -2 -1 0 1 2; do
      out="${a[(Rb:begin_at:n:match_number:)$needle]}"
      printf '%s\0' "$out"
      if [[ $needle == '(#b)(a*)' ]]; then typeset -p match mbegin mend; fi
    done
  done
done
typeset -p a
print -r -- matrix-done

) || exit 1
(
emulate -R ksh
setopt extendedglob nomultibyte
typeset -a a=(zero one two three four five six seven eight a)
match=(); mbegin=(); mend=()
integer begin_at match_number
for needle in 'a' 'a*' '*' '?' '' 'missing' 'é*' $'a\0*' '(#b)(a*)'; do
  for begin_at in -9 -1 0 1 2 4 5 100; do
    for match_number in -2 -1 0 1 2; do
      out="${a[(ib:begin_at:n:match_number:)$needle]}"
      printf '%s\0' "$out"
      if [[ $needle == '(#b)(a*)' ]]; then typeset -p match mbegin mend; fi
    done
  done
done
for needle in 'a' 'a*' '*' '?' '' 'missing' 'é*' $'a\0*' '(#b)(a*)'; do
  for begin_at in -9 -1 0 1 2 4 5 100; do
    for match_number in -2 -1 0 1 2; do
      out="${a[(Ib:begin_at:n:match_number:)$needle]}"
      printf '%s\0' "$out"
      if [[ $needle == '(#b)(a*)' ]]; then typeset -p match mbegin mend; fi
    done
  done
done
for needle in 'a' 'a*' '*' '?' '' 'missing' 'é*' $'a\0*' '(#b)(a*)'; do
  for begin_at in -9 -1 0 1 2 4 5 100; do
    for match_number in -2 -1 0 1 2; do
      out="${a[(rb:begin_at:n:match_number:)$needle]}"
      printf '%s\0' "$out"
      if [[ $needle == '(#b)(a*)' ]]; then typeset -p match mbegin mend; fi
    done
  done
done
for needle in 'a' 'a*' '*' '?' '' 'missing' 'é*' $'a\0*' '(#b)(a*)'; do
  for begin_at in -9 -1 0 1 2 4 5 100; do
    for match_number in -2 -1 0 1 2; do
      out="${a[(Rb:begin_at:n:match_number:)$needle]}"
      printf '%s\0' "$out"
      if [[ $needle == '(#b)(a*)' ]]; then typeset -p match mbegin mend; fi
    done
  done
done
typeset -p a
print -r -- matrix-done

) || exit 1
(
emulate -R sh
setopt extendedglob multibyte
typeset -a a=()
match=(); mbegin=(); mend=()
integer begin_at match_number
for needle in 'a' 'a*' '*' '?' '' 'missing' 'é*' $'a\0*' '(#b)(a*)'; do
  for begin_at in -9 -1 0 1 2 4 5 100; do
    for match_number in -2 -1 0 1 2; do
      out="${a[(ib:begin_at:n:match_number:)$needle]}"
      printf '%s\0' "$out"
      if [[ $needle == '(#b)(a*)' ]]; then typeset -p match mbegin mend; fi
    done
  done
done
for needle in 'a' 'a*' '*' '?' '' 'missing' 'é*' $'a\0*' '(#b)(a*)'; do
  for begin_at in -9 -1 0 1 2 4 5 100; do
    for match_number in -2 -1 0 1 2; do
      out="${a[(Ib:begin_at:n:match_number:)$needle]}"
      printf '%s\0' "$out"
      if [[ $needle == '(#b)(a*)' ]]; then typeset -p match mbegin mend; fi
    done
  done
done
for needle in 'a' 'a*' '*' '?' '' 'missing' 'é*' $'a\0*' '(#b)(a*)'; do
  for begin_at in -9 -1 0 1 2 4 5 100; do
    for match_number in -2 -1 0 1 2; do
      out="${a[(rb:begin_at:n:match_number:)$needle]}"
      printf '%s\0' "$out"
      if [[ $needle == '(#b)(a*)' ]]; then typeset -p match mbegin mend; fi
    done
  done
done
for needle in 'a' 'a*' '*' '?' '' 'missing' 'é*' $'a\0*' '(#b)(a*)'; do
  for begin_at in -9 -1 0 1 2 4 5 100; do
    for match_number in -2 -1 0 1 2; do
      out="${a[(Rb:begin_at:n:match_number:)$needle]}"
      printf '%s\0' "$out"
      if [[ $needle == '(#b)(a*)' ]]; then typeset -p match mbegin mend; fi
    done
  done
done
typeset -p a
print -r -- matrix-done

) || exit 1
(
emulate -R sh
setopt extendedglob multibyte
typeset -a a=('')
match=(); mbegin=(); mend=()
integer begin_at match_number
for needle in 'a' 'a*' '*' '?' '' 'missing' 'é*' $'a\0*' '(#b)(a*)'; do
  for begin_at in -9 -1 0 1 2 4 5 100; do
    for match_number in -2 -1 0 1 2; do
      out="${a[(ib:begin_at:n:match_number:)$needle]}"
      printf '%s\0' "$out"
      if [[ $needle == '(#b)(a*)' ]]; then typeset -p match mbegin mend; fi
    done
  done
done
for needle in 'a' 'a*' '*' '?' '' 'missing' 'é*' $'a\0*' '(#b)(a*)'; do
  for begin_at in -9 -1 0 1 2 4 5 100; do
    for match_number in -2 -1 0 1 2; do
      out="${a[(Ib:begin_at:n:match_number:)$needle]}"
      printf '%s\0' "$out"
      if [[ $needle == '(#b)(a*)' ]]; then typeset -p match mbegin mend; fi
    done
  done
done
for needle in 'a' 'a*' '*' '?' '' 'missing' 'é*' $'a\0*' '(#b)(a*)'; do
  for begin_at in -9 -1 0 1 2 4 5 100; do
    for match_number in -2 -1 0 1 2; do
      out="${a[(rb:begin_at:n:match_number:)$needle]}"
      printf '%s\0' "$out"
      if [[ $needle == '(#b)(a*)' ]]; then typeset -p match mbegin mend; fi
    done
  done
done
for needle in 'a' 'a*' '*' '?' '' 'missing' 'é*' $'a\0*' '(#b)(a*)'; do
  for begin_at in -9 -1 0 1 2 4 5 100; do
    for match_number in -2 -1 0 1 2; do
      out="${a[(Rb:begin_at:n:match_number:)$needle]}"
      printf '%s\0' "$out"
      if [[ $needle == '(#b)(a*)' ]]; then typeset -p match mbegin mend; fi
    done
  done
done
typeset -p a
print -r -- matrix-done

) || exit 1
(
emulate -R sh
setopt extendedglob multibyte
typeset -a a=(a '' ab a é $'a\0b' 'two words')
match=(); mbegin=(); mend=()
integer begin_at match_number
for needle in 'a' 'a*' '*' '?' '' 'missing' 'é*' $'a\0*' '(#b)(a*)'; do
  for begin_at in -9 -1 0 1 2 4 5 100; do
    for match_number in -2 -1 0 1 2; do
      out="${a[(ib:begin_at:n:match_number:)$needle]}"
      printf '%s\0' "$out"
      if [[ $needle == '(#b)(a*)' ]]; then typeset -p match mbegin mend; fi
    done
  done
done
for needle in 'a' 'a*' '*' '?' '' 'missing' 'é*' $'a\0*' '(#b)(a*)'; do
  for begin_at in -9 -1 0 1 2 4 5 100; do
    for match_number in -2 -1 0 1 2; do
      out="${a[(Ib:begin_at:n:match_number:)$needle]}"
      printf '%s\0' "$out"
      if [[ $needle == '(#b)(a*)' ]]; then typeset -p match mbegin mend; fi
    done
  done
done
for needle in 'a' 'a*' '*' '?' '' 'missing' 'é*' $'a\0*' '(#b)(a*)'; do
  for begin_at in -9 -1 0 1 2 4 5 100; do
    for match_number in -2 -1 0 1 2; do
      out="${a[(rb:begin_at:n:match_number:)$needle]}"
      printf '%s\0' "$out"
      if [[ $needle == '(#b)(a*)' ]]; then typeset -p match mbegin mend; fi
    done
  done
done
for needle in 'a' 'a*' '*' '?' '' 'missing' 'é*' $'a\0*' '(#b)(a*)'; do
  for begin_at in -9 -1 0 1 2 4 5 100; do
    for match_number in -2 -1 0 1 2; do
      out="${a[(Rb:begin_at:n:match_number:)$needle]}"
      printf '%s\0' "$out"
      if [[ $needle == '(#b)(a*)' ]]; then typeset -p match mbegin mend; fi
    done
  done
done
typeset -p a
print -r -- matrix-done

) || exit 1
(
emulate -R sh
setopt extendedglob multibyte
typeset -a a=(zero one two three four five six seven eight a)
match=(); mbegin=(); mend=()
integer begin_at match_number
for needle in 'a' 'a*' '*' '?' '' 'missing' 'é*' $'a\0*' '(#b)(a*)'; do
  for begin_at in -9 -1 0 1 2 4 5 100; do
    for match_number in -2 -1 0 1 2; do
      out="${a[(ib:begin_at:n:match_number:)$needle]}"
      printf '%s\0' "$out"
      if [[ $needle == '(#b)(a*)' ]]; then typeset -p match mbegin mend; fi
    done
  done
done
for needle in 'a' 'a*' '*' '?' '' 'missing' 'é*' $'a\0*' '(#b)(a*)'; do
  for begin_at in -9 -1 0 1 2 4 5 100; do
    for match_number in -2 -1 0 1 2; do
      out="${a[(Ib:begin_at:n:match_number:)$needle]}"
      printf '%s\0' "$out"
      if [[ $needle == '(#b)(a*)' ]]; then typeset -p match mbegin mend; fi
    done
  done
done
for needle in 'a' 'a*' '*' '?' '' 'missing' 'é*' $'a\0*' '(#b)(a*)'; do
  for begin_at in -9 -1 0 1 2 4 5 100; do
    for match_number in -2 -1 0 1 2; do
      out="${a[(rb:begin_at:n:match_number:)$needle]}"
      printf '%s\0' "$out"
      if [[ $needle == '(#b)(a*)' ]]; then typeset -p match mbegin mend; fi
    done
  done
done
for needle in 'a' 'a*' '*' '?' '' 'missing' 'é*' $'a\0*' '(#b)(a*)'; do
  for begin_at in -9 -1 0 1 2 4 5 100; do
    for match_number in -2 -1 0 1 2; do
      out="${a[(Rb:begin_at:n:match_number:)$needle]}"
      printf '%s\0' "$out"
      if [[ $needle == '(#b)(a*)' ]]; then typeset -p match mbegin mend; fi
    done
  done
done
typeset -p a
print -r -- matrix-done

) || exit 1
(
emulate -R sh
setopt extendedglob nomultibyte
typeset -a a=()
match=(); mbegin=(); mend=()
integer begin_at match_number
for needle in 'a' 'a*' '*' '?' '' 'missing' 'é*' $'a\0*' '(#b)(a*)'; do
  for begin_at in -9 -1 0 1 2 4 5 100; do
    for match_number in -2 -1 0 1 2; do
      out="${a[(ib:begin_at:n:match_number:)$needle]}"
      printf '%s\0' "$out"
      if [[ $needle == '(#b)(a*)' ]]; then typeset -p match mbegin mend; fi
    done
  done
done
for needle in 'a' 'a*' '*' '?' '' 'missing' 'é*' $'a\0*' '(#b)(a*)'; do
  for begin_at in -9 -1 0 1 2 4 5 100; do
    for match_number in -2 -1 0 1 2; do
      out="${a[(Ib:begin_at:n:match_number:)$needle]}"
      printf '%s\0' "$out"
      if [[ $needle == '(#b)(a*)' ]]; then typeset -p match mbegin mend; fi
    done
  done
done
for needle in 'a' 'a*' '*' '?' '' 'missing' 'é*' $'a\0*' '(#b)(a*)'; do
  for begin_at in -9 -1 0 1 2 4 5 100; do
    for match_number in -2 -1 0 1 2; do
      out="${a[(rb:begin_at:n:match_number:)$needle]}"
      printf '%s\0' "$out"
      if [[ $needle == '(#b)(a*)' ]]; then typeset -p match mbegin mend; fi
    done
  done
done
for needle in 'a' 'a*' '*' '?' '' 'missing' 'é*' $'a\0*' '(#b)(a*)'; do
  for begin_at in -9 -1 0 1 2 4 5 100; do
    for match_number in -2 -1 0 1 2; do
      out="${a[(Rb:begin_at:n:match_number:)$needle]}"
      printf '%s\0' "$out"
      if [[ $needle == '(#b)(a*)' ]]; then typeset -p match mbegin mend; fi
    done
  done
done
typeset -p a
print -r -- matrix-done

) || exit 1
(
emulate -R sh
setopt extendedglob nomultibyte
typeset -a a=('')
match=(); mbegin=(); mend=()
integer begin_at match_number
for needle in 'a' 'a*' '*' '?' '' 'missing' 'é*' $'a\0*' '(#b)(a*)'; do
  for begin_at in -9 -1 0 1 2 4 5 100; do
    for match_number in -2 -1 0 1 2; do
      out="${a[(ib:begin_at:n:match_number:)$needle]}"
      printf '%s\0' "$out"
      if [[ $needle == '(#b)(a*)' ]]; then typeset -p match mbegin mend; fi
    done
  done
done
for needle in 'a' 'a*' '*' '?' '' 'missing' 'é*' $'a\0*' '(#b)(a*)'; do
  for begin_at in -9 -1 0 1 2 4 5 100; do
    for match_number in -2 -1 0 1 2; do
      out="${a[(Ib:begin_at:n:match_number:)$needle]}"
      printf '%s\0' "$out"
      if [[ $needle == '(#b)(a*)' ]]; then typeset -p match mbegin mend; fi
    done
  done
done
for needle in 'a' 'a*' '*' '?' '' 'missing' 'é*' $'a\0*' '(#b)(a*)'; do
  for begin_at in -9 -1 0 1 2 4 5 100; do
    for match_number in -2 -1 0 1 2; do
      out="${a[(rb:begin_at:n:match_number:)$needle]}"
      printf '%s\0' "$out"
      if [[ $needle == '(#b)(a*)' ]]; then typeset -p match mbegin mend; fi
    done
  done
done
for needle in 'a' 'a*' '*' '?' '' 'missing' 'é*' $'a\0*' '(#b)(a*)'; do
  for begin_at in -9 -1 0 1 2 4 5 100; do
    for match_number in -2 -1 0 1 2; do
      out="${a[(Rb:begin_at:n:match_number:)$needle]}"
      printf '%s\0' "$out"
      if [[ $needle == '(#b)(a*)' ]]; then typeset -p match mbegin mend; fi
    done
  done
done
typeset -p a
print -r -- matrix-done

) || exit 1
(
emulate -R sh
setopt extendedglob nomultibyte
typeset -a a=(a '' ab a é $'a\0b' 'two words')
match=(); mbegin=(); mend=()
integer begin_at match_number
for needle in 'a' 'a*' '*' '?' '' 'missing' 'é*' $'a\0*' '(#b)(a*)'; do
  for begin_at in -9 -1 0 1 2 4 5 100; do
    for match_number in -2 -1 0 1 2; do
      out="${a[(ib:begin_at:n:match_number:)$needle]}"
      printf '%s\0' "$out"
      if [[ $needle == '(#b)(a*)' ]]; then typeset -p match mbegin mend; fi
    done
  done
done
for needle in 'a' 'a*' '*' '?' '' 'missing' 'é*' $'a\0*' '(#b)(a*)'; do
  for begin_at in -9 -1 0 1 2 4 5 100; do
    for match_number in -2 -1 0 1 2; do
      out="${a[(Ib:begin_at:n:match_number:)$needle]}"
      printf '%s\0' "$out"
      if [[ $needle == '(#b)(a*)' ]]; then typeset -p match mbegin mend; fi
    done
  done
done
for needle in 'a' 'a*' '*' '?' '' 'missing' 'é*' $'a\0*' '(#b)(a*)'; do
  for begin_at in -9 -1 0 1 2 4 5 100; do
    for match_number in -2 -1 0 1 2; do
      out="${a[(rb:begin_at:n:match_number:)$needle]}"
      printf '%s\0' "$out"
      if [[ $needle == '(#b)(a*)' ]]; then typeset -p match mbegin mend; fi
    done
  done
done
for needle in 'a' 'a*' '*' '?' '' 'missing' 'é*' $'a\0*' '(#b)(a*)'; do
  for begin_at in -9 -1 0 1 2 4 5 100; do
    for match_number in -2 -1 0 1 2; do
      out="${a[(Rb:begin_at:n:match_number:)$needle]}"
      printf '%s\0' "$out"
      if [[ $needle == '(#b)(a*)' ]]; then typeset -p match mbegin mend; fi
    done
  done
done
typeset -p a
print -r -- matrix-done

) || exit 1
(
emulate -R sh
setopt extendedglob nomultibyte
typeset -a a=(zero one two three four five six seven eight a)
match=(); mbegin=(); mend=()
integer begin_at match_number
for needle in 'a' 'a*' '*' '?' '' 'missing' 'é*' $'a\0*' '(#b)(a*)'; do
  for begin_at in -9 -1 0 1 2 4 5 100; do
    for match_number in -2 -1 0 1 2; do
      out="${a[(ib:begin_at:n:match_number:)$needle]}"
      printf '%s\0' "$out"
      if [[ $needle == '(#b)(a*)' ]]; then typeset -p match mbegin mend; fi
    done
  done
done
for needle in 'a' 'a*' '*' '?' '' 'missing' 'é*' $'a\0*' '(#b)(a*)'; do
  for begin_at in -9 -1 0 1 2 4 5 100; do
    for match_number in -2 -1 0 1 2; do
      out="${a[(Ib:begin_at:n:match_number:)$needle]}"
      printf '%s\0' "$out"
      if [[ $needle == '(#b)(a*)' ]]; then typeset -p match mbegin mend; fi
    done
  done
done
for needle in 'a' 'a*' '*' '?' '' 'missing' 'é*' $'a\0*' '(#b)(a*)'; do
  for begin_at in -9 -1 0 1 2 4 5 100; do
    for match_number in -2 -1 0 1 2; do
      out="${a[(rb:begin_at:n:match_number:)$needle]}"
      printf '%s\0' "$out"
      if [[ $needle == '(#b)(a*)' ]]; then typeset -p match mbegin mend; fi
    done
  done
done
for needle in 'a' 'a*' '*' '?' '' 'missing' 'é*' $'a\0*' '(#b)(a*)'; do
  for begin_at in -9 -1 0 1 2 4 5 100; do
    for match_number in -2 -1 0 1 2; do
      out="${a[(Rb:begin_at:n:match_number:)$needle]}"
      printf '%s\0' "$out"
      if [[ $needle == '(#b)(a*)' ]]; then typeset -p match mbegin mend; fi
    done
  done
done
typeset -p a
print -r -- matrix-done

) || exit 1
module_path=("/home/stig/dev/challenge/zsh-perf/zsh-5.9.2/.work/append-module" $module_path)
zmodload psh_append_fixture || exit 1
for mode in stable changing self-replacing custom-setter public-api; do
 for kind in index value beyond; do
 psh-array-fixture "$mode" || exit 1
 case $kind in
 index) print -r -- "${psh_fixture_array[(i)c]}";;
 value) print -r -- "${psh_fixture_array[(r)first]}";;
 beyond) print -r -- "${psh_fixture_array[(ib:100:)c]}";;
 esac
 psh-array-fixture report || exit 1
 done
done
zmodload -u psh_append_fixture || exit 1
(( ! ${+psh_fixture_array} )) || exit 1
print -r -- memcheck-complete
