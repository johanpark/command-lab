#!/usr/bin/env bash
source /opt/cmdlab/lib/helpers.sh
S="$H/services"
left=$(grep -rl --include=config.ini 'old-db\.internal' "$S" 2>/dev/null | wc -l)
[ "$left" -eq 0 ] && pass "설정 파일에 old-db.internal 이 남아 있지 않다" || fail "설정 파일에 old-db.internal 이 남아 있지 않다 (${left}개 파일에 남음 — g 옵션, 깊은 하위 폴더 확인)"
dbg=$(grep -rE --include=config.ini '^debug *= *true' "$S" 2>/dev/null | wc -l)
[ "$dbg" -eq 0 ] && pass "debug = true 가 남아 있지 않다" || fail "debug = true 가 남아 있지 않다 (${dbg}곳 남음 — 띄어쓰기가 다른 줄 확인)"
diff_count=0
while IFS= read -r f; do
  cmp -s "/opt/cmdlab/secret/expected/$f" "$S/$f" || diff_count=$((diff_count + 1))
done < <(cd /opt/cmdlab/secret/expected && find . -name config.ini)
[ "$diff_count" -eq 0 ] && pass "그 밖의 내용은 그대로다" || fail "그 밖의 내용은 그대로다 (${diff_count}개 파일이 기대와 달라요. debug_sql 같은 다른 줄까지 바꾸지 않았나요?)"
finish
