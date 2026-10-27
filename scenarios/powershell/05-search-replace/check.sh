#!/usr/bin/env bash
source /opt/cmdlab/lib/helpers.sh
C="$H/configs"
if [ ! -f "$H/leaks.txt" ]; then fail "leaks.txt 에 평문 비밀번호가 있는 파일 이름이 있다 (파일이 없어요)"
else
  got=$(tr -d '\r' < "$H/leaks.txt" | sed -e 's#.*/##' -e 's/[[:space:]]*$//' -e '/^$/d' | sort -u)
  want=$(sort -u /opt/cmdlab/secret/leaks)
  [ "$got" = "$want" ] && pass "leaks.txt 에 평문 비밀번호가 있는 파일 이름이 있다 ($(echo "$want" | wc -l)개)" \
    || fail "leaks.txt 에 평문 비밀번호가 있는 파일 이름이 있다 (기대 $(echo "$want" | wc -l)개, 지금 $(echo "$got" | sed '/^$/d' | wc -l)개 — 주석(# password=) 은 빼야 해요)"
fi
left=$(grep -l 'http://' "$C"/*.ini 2>/dev/null | wc -l)
[ "$left" -eq 0 ] && pass "모든 .ini 에서 http:// 가 https:// 로 바뀌었다" || fail "모든 .ini 에서 http:// 가 https:// 로 바뀌었다 (${left}개 파일에 남음)"
bad=0; for f in /opt/cmdlab/secret/expected/*.ini; do
  diff -q <(tr -d '\r' < "$C/$(basename "$f")" 2>/dev/null) "$f" >/dev/null || bad=$((bad + 1))
done
[ "$bad" -eq 0 ] && pass "그 밖의 내용은 그대로다 (파일이 비거나 깨지지 않음)" || fail "그 밖의 내용은 그대로다 (${bad}개 파일이 기대와 달라요 — 비어 버리진 않았나요?)"
expect "README.txt 는 건드리지 않았다" grep -q '^http 로 시작' "$C/README.txt"
finish
