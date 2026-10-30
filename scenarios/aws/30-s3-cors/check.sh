#!/usr/bin/env bash
source /opt/cmdlab/lib/helpers.sh
B=$(secret_get bucket); D=/opt/cmdlab/scenario
C=$(aws s3api get-bucket-cors --bucket "$B" --output json 2>/dev/null)
if [ -z "$C" ]; then fail "CORS 설정이 있다 (지워졌어요)"; finish; fi
while IFS=$'\t' read -r r msg; do
  [ "$r" = ok ] && pass "$msg" || fail "$msg"
done < <(python3 "$D/cors_eval.py" <<< "$C")
pol=$(aws s3api get-bucket-policy --bucket "$B" >/dev/null 2>&1 && echo yes)
pab=$(aws s3api get-public-access-block --bucket "$B" --query 'PublicAccessBlockConfiguration.[BlockPublicAcls,IgnorePublicAcls,BlockPublicPolicy,RestrictPublicBuckets]' --output text 2>/dev/null | tr '\t' ' ')
[ -z "$pol" ] && [ "$pab" = "True True True True" ] && pass "버킷은 계속 비공개다" || fail "버킷은 계속 비공개다 (CORS 는 공개와 상관없어요. 정책·차단 설정은 되돌리세요)"
finish
