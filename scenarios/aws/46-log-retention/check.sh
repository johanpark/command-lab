#!/usr/bin/env bash
source /opt/cmdlab/lib/helpers.sh
S=/opt/cmdlab/secret
G=$(aws logs describe-log-groups --output json 2>/dev/null | jq -c '[.logGroups[] | {n: .logGroupName, r: (.retentionInDays // 0)}]')
ret() { jq -r --arg n "$1" '.[] | select(.n == $n) | .r' <<< "$G"; }   # 없으면 빈 값, 만료 안 함이면 0
show() { local r; r=$(ret "$1"); [ -z "$r" ] && echo "없음" || { [ "$r" = 0 ] && echo "만료 안 함" || echo "${r}일"; }; }
bad=""; gone=""; for f in $(cat $S/live); do r=$(ret "/aws/lambda/$f"); [ -z "$r" ] && gone+="$f " || { [ "$r" = 14 ] || bad+="$f($(show /aws/lambda/$f)) "; }; done
[ -z "$gone" ] && pass "지금 있는 함수의 로그 그룹은 지우지 않았다" || fail "지금 있는 함수의 로그 그룹은 지우지 않았다 (지워진 것: ${gone% } — 함수는 살아 있어요. 이름이 비슷한 것과 헷갈리지 않았나요?)"
[ -z "$bad" ] && pass "람다 로그 그룹은 14일 보관이다" || fail "람다 로그 그룹은 14일 보관이다 (지금: ${bad% })"
left=""; for f in $(cat $S/gone); do [ -n "$(ret "/aws/lambda/$f")" ] && left+="$f "; done
[ -z "$left" ] && pass "없어진 함수의 로그 그룹을 지웠다" || fail "없어진 함수의 로그 그룹을 지웠다 (남은 것: ${left% } — aws lambda list-functions 에 없는 함수예요)"
bad=""; for a in web api worker; do [ "$(ret /shop/app/$a)" = 30 ] || bad+="$a($(show /shop/app/$a)) "; done
[ -z "$bad" ] && pass "/shop/app/* 은 30일 보관이다" || fail "/shop/app/* 은 30일 보관이다 (지금: ${bad% })"
l=$(ret /shop/audit/login); p=$(ret /shop/audit/payment)
if [ "$p" != 731 ]; then fail "/shop/audit/* 은 400일 이상이고, 더 길던 건 그대로다 (payment 가 731일 → $(show /shop/audit/payment) 로 바뀌었어요 — 법무 요구보다 길게 잡힌 건 줄이면 안 돼요)"
elif [ "${l:-0}" -ge 400 ] 2>/dev/null; then pass "/shop/audit/* 은 400일 이상이고, 더 길던 건 그대로다"
else fail "/shop/audit/* 은 400일 이상이고, 더 길던 건 그대로다 (login: $(show /shop/audit/login))"; fi
[ "$(ret /shop/batch/nightly)" = 0 ] && [ "$(ret /vpc/flow-logs)" = 90 ] && pass "규칙에 없는 그룹(/shop/batch/nightly, /vpc/flow-logs)은 그대로다" \
  || fail "규칙에 없는 그룹(/shop/batch/nightly, /vpc/flow-logs)은 그대로다 (지금: nightly $(show /shop/batch/nightly), flow-logs $(show /vpc/flow-logs))"
finish
