#!/usr/bin/env bash
source /opt/cmdlab/lib/helpers.sh
S=/opt/cmdlab/secret; D=/opt/cmdlab/scenario
R=$(aws iam get-role --role-name vendor-audit --output json 2>/dev/null)
if [ -z "$R" ]; then fail "vendor-audit 역할이 있다"
else
  pass "vendor-audit 역할이 있다"
  while IFS=$'\t' read -r ok msg; do
    case "$msg" in 업체*|맡을*) t="업체 계정만 이 역할을 맡을 수 있다" ;; *) t="외부 ID 가 맞을 때만 맡을 수 있다" ;; esac
    [ "$ok" = OK ] && pass "$t" || fail "$t ($msg)"
  done < <(python3 "$D/trust_eval.py" "$(jq -c .Role.AssumeRolePolicyDocument <<< "$R")" "$(secret_get vendor)" "$(secret_get xid)")
  pol=$(aws iam list-attached-role-policies --role-name vendor-audit --query 'AttachedPolicies[].PolicyName' --output text | tr '\t' '\n' | sort | paste -sd' ')
  inl=$(aws iam list-role-policies --role-name vendor-audit --query 'PolicyNames' --output text | tr '\t' ' ')
  [ "$pol" = SecurityAudit ] && [ -z "$inl" ] && pass "권한은 SecurityAudit 하나뿐이다" \
    || fail "권한은 SecurityAudit 하나뿐이다 (연결된 정책: ${pol:-없음}${inl:+ / 인라인: $inl})"
  ms=$(jq -r .Role.MaxSessionDuration <<< "$R")
  [ "$ms" = 3600 ] && pass "최대 세션 시간이 1시간이다" || fail "최대 세션 시간이 1시간이다 (지금: ${ms}초)"
fi
st=$(aws iam list-access-keys --user-name vendor-audit-2025 --output json 2>/dev/null | jq -r --arg k "$(cat $S/oldkey)" '.AccessKeyMetadata[] | select(.AccessKeyId == $k) | .Status')
case "$st" in
  Inactive) pass "작년 키(vendor-audit-2025)는 꺼져 있고, 사용자·키는 남아 있다" ;;
  Active) fail "작년 키(vendor-audit-2025)는 꺼져 있고, 사용자·키는 남아 있다 (아직 Active 예요)" ;;
  *) fail "작년 키(vendor-audit-2025)는 꺼져 있고, 사용자·키는 남아 있다 (사용자나 키가 지워졌어요 — 감사 기록용으로 남겨야 해요)" ;;
esac
o=$(aws iam list-access-keys --user-name vendor-billing-sync --query 'AccessKeyMetadata[0].Status' --output text 2>/dev/null)
[ "$o" = Active ] && pass "다른 팀 키(vendor-billing-sync)는 그대로다" || fail "다른 팀 키(vendor-billing-sync)는 그대로다 (지금: ${o:-없음})"
finish
