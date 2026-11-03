#!/usr/bin/env bash
source /opt/cmdlab/lib/helpers.sh
S=/opt/cmdlab/secret; OFF=$(secret_get office); R=$(secret_get rate); ALB=$(cat $S/alb)
norm() { sed -E 's#^([0-9.]+)$#\1/32#' | sort -u; }
id=$(aws wafv2 list-ip-sets --scope REGIONAL --query "IPSets[?Name=='blocked-ips'].Id | [0]" --output text 2>/dev/null)
if [ -z "$id" ] || [ "$id" = None ]; then fail "blocked-ips 에 공격 출발지만 들어 있다 (IP 집합이 없어요)"; IPARN=""
else
  IPARN=$(aws wafv2 list-ip-sets --scope REGIONAL --query "IPSets[?Name=='blocked-ips'].ARN | [0]" --output text)
  got=$(aws wafv2 get-ip-set --name blocked-ips --scope REGIONAL --id "$id" --query 'IPSet.Addresses' --output text | tr '\t' '\n' | grep . | norm)
  if grep -q "^$OFF/" <<< "$got"; then fail "blocked-ips 에 공격 출발지만 들어 있다 (회사 사무실 IP 가 들어 있어요: $OFF — QA 팀이 막혀요)"
  elif [ "$got" = "$(norm < $S/attack)" ]; then pass "blocked-ips 에 공격 출발지만 들어 있다"
  else fail "blocked-ips 에 공격 출발지만 들어 있다 (빠짐: $(comm -23 <(norm < $S/attack) <(echo "$got") | paste -sd' ') / 남는 것: $(comm -13 <(norm < $S/attack) <(echo "$got") | paste -sd' '))"; fi
fi
aid=$(aws wafv2 list-web-acls --scope REGIONAL --query "WebACLs[?Name=='shop-waf'].Id | [0]" --output text 2>/dev/null)
if [ -z "$aid" ] || [ "$aid" = None ]; then fail "shop-waf 웹 ACL 이 규칙대로 있다 (웹 ACL 이 없어요)"
else
  W=$(aws wafv2 get-web-acl --name shop-waf --scope REGIONAL --id "$aid" --query WebACL --output json)
  [ "$(jq -r '.DefaultAction | keys[0]' <<< "$W")" = Allow ] && pass "shop-waf 의 기본 동작이 허용이다" || fail "shop-waf 의 기본 동작이 허용이다 (기본이 차단이면 정상 손님도 다 막혀요)"
  jq -e --arg a "$IPARN" '.Rules | any(.Statement.IPSetReferenceStatement.ARN == $a and (.Action | has("Block")))' >/dev/null <<< "$W" \
    && pass "blocked-ips 를 차단하는 규칙이 있다" || fail "blocked-ips 를 차단하는 규칙이 있다"
  rl=$(jq -r '[.Rules[] | select(.Statement.RateBasedStatement and (.Action | has("Block"))) | .Statement.RateBasedStatement | "\(.Limit) \(.AggregateKeyType // "IP")"] | join(",")' <<< "$W")
  [ "$rl" = "$R IP" ] && pass "IP 당 5분 $R 회 속도 제한 규칙이 있다" || fail "IP 당 5분 $R 회 속도 제한 규칙이 있다 (지금: ${rl:-없음})"
  # WAF 는 Priority 가 작은 규칙부터 보고, 처음 걸린 Allow/Block 에서 끝난다 → 차단 규칙보다 앞의 Allow 는 공격을 통과시킬 수 있다
  early=$(jq -r --arg a "$IPARN" '(.Rules | map(select(.Action | has("Block")) | select(.Statement.IPSetReferenceStatement.ARN == $a or .Statement.RateBasedStatement)) | map(.Priority) | max) as $last
    | [.Rules[] | select((.Action | has("Allow")) and $last != null and .Priority < $last) | "\(.Name)(\(.Priority))"] | join(" ")' <<< "$W")
  [ -z "$early" ] && pass "차단 규칙보다 먼저 평가되는 허용 규칙이 없다" \
    || fail "차단 규칙보다 먼저 평가되는 허용 규칙이 없다 ($early — 우선순위가 앞선 Allow 에 걸리면 뒤의 차단 규칙은 보지도 않아요)"
fi
on=$(aws wafv2 get-web-acl-for-resource --resource-arn "$ALB" --query WebACL.Name --output text 2>/dev/null)
[ "$on" = shop-waf ] && pass "shop-alb 에 shop-waf 가 연결돼 있다" || fail "shop-alb 에 shop-waf 가 연결돼 있다 (지금: ${on:-없음})"
off=$(aws wafv2 get-web-acl-for-resource --resource-arn "$(cat $S/admin)" --query WebACL.Name --output text 2>/dev/null)
[ -z "$off" ] || [ "$off" = None ] && pass "admin-alb 는 그대로다" || fail "admin-alb 는 그대로다 (웹 ACL 이 연결됐어요)"
finish
