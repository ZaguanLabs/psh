#!/usr/bin/env zsh
# SPDX-License-Identifier: Apache-2.0
emulate -R zsh
setopt no_aliases
typeset test_root=${0:A:h:h}
fpath=( "$test_root/functions" "${fpath[@]}" )
autoload -Uz zoup
typeset -i passed=0 failed=0
typeset REPLY

check() {
  local label=$1 input=$2 expected=$3
  local REPLY=unchanged
  if ! zoup clean -- "$input"; then
    print -ru2 -- "FAIL $label: rejected input"
    (( failed++ ))
  elif [[ $REPLY != "$expected" ]]; then
    print -ru2 -- "FAIL $label: expected ${(qqqq)expected}, got ${(qqqq)REPLY}"
    (( failed++ ))
  else
    # A cleaned document must remain stable on another pass.
    zoup clean -- "$REPLY"
    if [[ $? != 0 || $REPLY != "$expected" ]]; then
      print -ru2 -- "FAIL $label: not idempotent"
      (( failed++ ))
    else
      (( passed++ ))
    fi
  fi
  return 0
}

reject() {
  local label=$1 input=$2 REPLY=unchanged
  zoup clean -- "$input" 2>/dev/null
  if [[ $? == 1 && $REPLY == unchanged ]]; then
    (( passed++ ))
  else
    print -ru2 -- "FAIL $label: expected atomic rejection"
    (( failed++ ))
  fi
  return 0
}

check empty '' ''
check plain 'Hello &amp; goodbye' 'Hello &amp; goodbye'
check unicode 'Blåbær 日本語 é 🐚' 'Blåbær 日本語 é 🐚'
check structure '<DIV class="grid"><p>Hello</p><p>World</p></DIV>' '<div><p>Hello</p><p>World</p></div>'
check heading '<H2 ID=part style="color:red">Title</H2>' '<h2 id="part">Title</h2>'
check scripts '<p>before</p><SCRIPT src=x>if (a < b) { x="<p>bad</p>"; }</ScRiPt><p>after</p>' '<p>before</p><p>after</p>'
check script_self_closing '<script/>do not leak<p>bad</p></script>after' 'after'
check script_false_end '<script>one</scripture>two</script>after' 'after'
check script_unclosed 'before<script>everything else' 'before'
check script_double_escaped '<script><!--<script>hidden</script>still JavaScript</script><p>Read me</p>' '<p>Read me</p>'
check script_double_escaped_case '<SCRIPT><!--<ScRiPt x>hidden</sCrIpT >still hidden</SCRIPT><p>Read me</p>' '<p>Read me</p>'
check script_double_escaped_slash '<script><!--<script/>hidden</script/>still hidden</script>shown' 'shown'
check script_escaped_close '<script><!--hidden</script><p>Read me</p>' '<p>Read me</p>'
check script_double_escape_eof 'before<script><!--<script>hidden</script>still hidden<p>hidden too</p>' 'before'
check script_escaped_exit '<script><!-- --><script>hidden</script>shown' 'shown'
check script_double_exit '<script><!--<script>hidden --></script>shown' 'shown'
check script_empty_escape '<script><!--><script>hidden</script>shown' 'shown'
check script_wrong_open_name '<script><!--<scripture>hidden</script>shown' 'shown'
check script_wrong_end_name '<script><!--<script>hidden</scripture>hidden</script>hidden</script>shown' 'shown'
check script_double_not_nested '<script><!--<script><script>hidden</script>hidden</script>shown' 'shown'
check script_dash_interrupted '<script><!--<script>--<b>></script>hidden</script>shown' 'shown'
check script_double_close_attribute '<script><!--<script>hidden</script title="-->"></script>shown' 'shown'
check script_reentry '<script><!--<script>hidden</script><script>hidden</script>hidden</script>shown' 'shown'
check script_escaped_then_fresh '<script><!--hidden</script><script><script>hidden</script>shown' 'shown'
check script_in_dropped_svg '<svg><script><!--<script>hidden</script></svg>hidden</script></svg>shown' 'shown'
check script_quote_is_html_end '<script>const text="</script>";<p>Read me</p>' '";<p>Read me</p>'
check styles '<link rel=stylesheet href=x><style>p::before {content:"<b>"}</style><p style="display:grid">hi</p>' '<p>hi</p>'
check image '<img src=x srcset=y width=100 alt="A &amp; B &quot;C&quot;">' 'A &amp; B &quot;C&quot;'
check decorative 'a<img alt="" src=x>b' 'ab'
check missing_alt 'a<img src=x>b' 'ab'
check image_link '<a href=/map><img alt="Map" src=x></a>' '<a href="/map">Map</a>'
check image_escape '<img alt="a < b > c">' 'a &lt; b &gt; c'
check quoted_gt '<a href="/a>b" title='\''Say "hello"'\'' onclick="bad()">go</a>' '<a href="/a&gt;b" title="Say &quot;hello&quot;">go</a>'
check unquoted_slash '<a href=/path/>go</a>' '<a href="/path/">go</a>'
check duplicate_attributes '<a HREF=/first href=/second TITLE="" title=other>x</a>' '<a href="/first" title="">x</a>'
check boolean '<details open><summary>X</summary><p>Y</p></details>' '<details open=""><summary>X</summary><p>Y</p></details>'
check comments 'a<!-- <script>not a tag</script> -->b' 'ab'
check comment_eof 'a<!--b' 'a'
check comment_bang_close '<!--hidden--!><p>Read me</p>' '<p>Read me</p>'
check comment_first_end '<!--hidden--!>shown-->tail' 'shown-->tail'
check comment_first_normal_end '<!--hidden-->shown--!>tail' 'shown--!>tail'
check comment_bang_segments '<!--hidden<div>also hidden--!><p>Read me</p>' '<p>Read me</p>'
check comment_bang_not_close '<!--hidden--!x><p>hidden</p>-->shown' 'shown'
check comment_empty '<!--><p>Read me</p>' '<p>Read me</p>'
check comment_empty_dash '<!---><p>Read me</p>' '<p>Read me</p>'
check comment_bang_in_script '<script><!--hidden--!><script>hidden</script>still hidden</script>shown' 'shown'
check declaration '<!DOCTYPE html><?unused?><p>x</p>' '<p>x</p>'
check noscript '<noscript><p>Works without JS</p></noscript>' '<p>Works without JS</p>'
check media '<video src=x><p>Transcript</p></video><audio><a href=/a>Download</a></audio>' '<p>Transcript</p><a href="/a">Download</a>'
check canvas '<canvas><p>Chart description</p></canvas>' '<p>Chart description</p>'
check iframe 'before<iframe src=x><p>unavailable</p></iframe>after' 'beforeafter'
check svg 'before<svg><text>graphic</text><svg/><svg><path/></svg></svg>after' 'beforeafter'
check math '<math><mi>x</mi></math>after' 'after'
check template '<template><template/>hidden</template>still hidden</template>shown' 'shown'
check dropped_raw '<svg><script>"</svg>"</script></svg>shown' 'shown'
check pre $'<pre>  a\t b\n\n c\n</pre>' $'<pre>  a\t b\n\n c\n</pre>'
check newlines $'<p>a\r\nb\rc</p>\n\n' $'<p>a\nb\nc</p>\n\n'
check textarea '<textarea name=q><b>literal</b>&amp;</textarea>' '<textarea name="q">&lt;b&gt;literal&lt;/b&gt;&amp;</textarea>'
check title '<title>a < b &amp; c</title>' '<title>a &lt; b &amp; c</title>'
check xmp '<xmp><b>literal</b></xmp>' '<pre>&lt;b&gt;literal&lt;/b&gt;</pre>'
check literal_entities '<xmp>&amp; <b></xmp><textarea>&amp;</textarea>' '<pre>&amp;amp; &lt;b&gt;</pre><textarea>&amp;</textarea>'
check attribute_segments '<p title="a<b<c>d">text</p>' '<p title="a&lt;b&lt;c&gt;d">text</p>'
check comment_segments '<!--a<b<c-->ok' 'ok'
check raw_segments '<script>a<b<c</wrong><img alt=bad></script>ok' 'ok'
check raw_false_close '<textarea>a</textareax>b</textarea>' '<textarea>a&lt;/textareax&gt;b</textarea>'
check plaintext '<plaintext>a<b>c</plaintext>' '<pre>a&lt;b&gt;c&lt;/plaintext&gt;</pre>'
check literal_lt '2 < 3 and <<p>x</p>' '2 &lt; 3 and &lt;<p>x</p>'
check unknown '<custom-widget><p>Content</p></custom-widget>' '<p>Content</p>'
check lists '<ol start=3><li value=4>A</li></ol><dl><dt>B</dt><dd>C</dd></dl>' '<ol start="3"><li value="4">A</li></ol><dl><dt>B</dt><dd>C</dd></dl>'
check tables '<table><caption>T</caption><tr><th id=h scope=col>A</th><td headers=h colspan=2>B</td></tr></table>' '<table><caption>T</caption><tr><th id="h" scope="col">A</th><td headers="h" colspan="2">B</td></tr></table>'
check forms '<form action=/search method=get><label for=q>Search</label><input id=q name=q value="a b" required onfocus=x><input type=hidden name=token value=123><button type=submit>Go</button></form>' '<form action="/search" method="get"><label for="q">Search</label><input id="q" name="q" value="a b" required=""><input type="hidden" name="token" value="123"><button type="submit">Go</button></form>'
check selection '<select name=x><option value=1 selected>One</option><option disabled>Two</option></select>' '<select name="x"><option value="1" selected="">One</option><option disabled="">Two</option></select>'
check base '<base href="https://example.org/docs/" target=_blank><a href=next>Next</a>' '<base href="https://example.org/docs/"><a href="next">Next</a>'
check accessibility '<p lang=no dir=ltr aria-label="intro" hidden class=x>Hei</p>' '<p lang="no" dir="ltr" aria-label="intro" hidden="">Hei</p>'
check javascript_url '<a href="JaVaScRiPt:alert(1)">x</a>' '<a>x</a>'
check data_url '<a href="data:text/html,hello">x</a>' '<a>x</a>'
check encoded_scheme '<a href="jav&#x61;script:alert(1)">x</a><a href="javascript&#58;alert(1)">y</a>' '<a>x</a><a>y</a>'
check url_query '<a href="/search?q=a&amp;b=c">x</a><a href="https://example.org/">y</a>' '<a href="/search?q=a&amp;b=c">x</a><a href="https://example.org/">y</a>'
check mailto '<a href="mailto:a@example.org">Email</a>' '<a href="mailto:a@example.org">Email</a>'
check injection '<p id="$(print HACKED)" title="`print BAD`">${(e)bad} * [x] \</p>' '<p id="$(print HACKED)" title="`print BAD`">${(e)bad} * [x] \</p>'
reject incomplete_tag '<p'
reject incomplete_quote '<a href="unfinished>'
reject nul $'<p>a\0b</p>'
reject escape $'<p>\e[31mred</p>'
reject oversized "${(pl:1048577::x:)}"
reject oversized_tag "<p title=\"${(pl:32768::x:)}\">"
reject too_many_attributes "<p${(pl:1000:: a=x:)}>"
reject too_many_boundaries "${(pl:32769::<:)}"
typeset repeated=''
repeat 17000; do repeated+='x<br>'; done
reject too_many_tokens "$repeated"
reject oversized_tag_whitespace "<p${(pl:32768:: :)}>"

# Loading and execution do not rely on utilities in PATH.
() {
  local -a path=()
  unfunction zoup _zoup_clean _zoup_tag _zoup_escape _zoup_url _zoup_more _zoup_tag_more _zoup_script
  autoload -Uz zoup
  check no_external_commands '<p>x<script>bad</script></p>' '<p>x</p>'
}

# A caller's local result and option environment survive unchanged.
() {
  setopt local_options sh_word_split ksh_arrays glob_subst nounset
  local REPLY=before
  zoup clean -- '<p>* ? [x]</p>'
  if [[ $REPLY == '<p>* ? [x]</p>' && -o sh_word_split && -o ksh_arrays && -o glob_subst && -o nounset ]]; then
    (( passed++ ))
  else
    print -ru2 -- 'FAIL caller options'
    (( failed++ ))
  fi
}

() {
  local -r REPLY=before
  zoup clean -- '<p>x</p>' 2>/dev/null
  if [[ $? == 2 && $REPLY == before ]]; then (( passed++ )); else (( failed++ )); fi
}

() {
  local -a REPLY=(before)
  zoup clean -- '<p>x</p>' 2>/dev/null
  if [[ $? == 2 && $REPLY[1] == before ]]; then (( passed++ )); else (( failed++ )); fi
}

() {
  local -x REPLY=before
  zoup clean -- '<p>x</p>' 2>/dev/null
  if [[ $? == 2 && $REPLY == before ]]; then (( passed++ )); else (( failed++ )); fi
}

() {
  local REPLY=before
  local -a old_fpath=( "${fpath[@]}" )
  local old_locale=${LC_ALL-unset} old_dir=$PWD
  zoup clean -- '<p>x</p>'
  if [[ ${(j:,:)fpath} == ${(j:,:)old_fpath} && ${LC_ALL-unset} == "$old_locale" && $PWD == "$old_dir" ]]; then
    (( passed++ ))
  else
    print -ru2 -- 'FAIL caller environment'
    (( failed++ ))
  fi
}

for args in '' clean 'clean --stdin -- x' 'clean --unknown' 'clean -- x y'; do
  zoup ${=args} 2>/dev/null
  if [[ $? == 2 ]]; then (( passed++ )); else print -ru2 -- "FAIL usage $args"; (( failed++ )); fi
done

print -r -- "$passed passed; $failed failed"
(( failed == 0 ))
