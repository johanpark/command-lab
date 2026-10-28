#!/usr/bin/env bash
source /opt/cmdlab/lib/helpers.sh
D="$H/homes"; E=/opt/cmdlab/secret/expected
want=$(cut -f1 "$E" | sort)
got=$(find "$D" -mindepth 1 -maxdepth 1 -type d -printf '%f\n' 2>/dev/null | sort)
if [ "$got" = "$want" ]; then pass "입사자마다 ~/homes/<계정> 폴더가 있다 (취소자 제외, 소문자, 공백 없음)"
else
  extra=$(comm -13 <(echo "$want") <(echo "$got") | sed 's/.*/[&]/' | tr '\n' ' ')
  missing=$(comm -23 <(echo "$want") <(echo "$got") | tr '\n' ' ')
  fail "입사자마다 ~/homes/<계정> 폴더가 있다 (취소자 제외, 소문자, 공백 없음)${extra:+ — 있으면 안 되는 폴더: $extra}${missing:+ — 없는 계정: $missing}"
fi
sub=0; msg=0; example=""
while IFS=$'\t' read -r acc line; do
  [ -d "$D/$acc/Documents" ] && [ -d "$D/$acc/Desktop" ] || sub=$((sub + 1))
  have=$(sed -e '1s/^\xef\xbb\xbf//' -e 's/\r$//' "$D/$acc/welcome.txt" 2>/dev/null | sed '/^$/d')
  if [ "$have" != "$line" ]; then
    msg=$((msg + 1))
    [ -n "$example" ] || example="$acc: '$(head -n 1 <<< "${have:-파일 없음}" | cut -c1-50)'"
  fi
done < "$E"
[ "$sub" -eq 0 ] && pass "모든 폴더에 Documents, Desktop 이 있다" || fail "모든 폴더에 Documents, Desktop 이 있다 (${sub}명이 빠짐)"
if [ "$msg" -eq 0 ]; then pass "welcome.txt 내용이 정확하다"
else fail "welcome.txt 내용이 정확하다 (${msg}명이 달라요. 예: $example)"; fi
c=$(sed -e '1s/^\xef\xbb\xbf//' -e 's/\r$//' "$H/created.txt" 2>/dev/null | sed '/^[[:space:]]*$/d' | sort)
[ "$c" = "$want" ] && pass "created.txt 에 만든 계정 목록이 있다" || fail "created.txt 에 만든 계정 목록이 있다 ($( [ "$(grep -c . <<< "$c")" = "$(wc -l < "$E")" ] && echo '줄 수는 맞는데 목록이 달라요 — 공백·대문자?' || echo "지금 $(grep -c . <<< "$c")줄, 기대 $(wc -l < "$E")줄"))"
finish
