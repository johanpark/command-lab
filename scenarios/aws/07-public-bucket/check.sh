#!/usr/bin/env bash
source /opt/cmdlab/lib/helpers.sh
bad=$(secret_get bad); W=$(secret_get web); BK=$(cat /opt/cmdlab/secret/backups)
expect_answer "answer.txt 에 사고로 공개된 버킷 이름을 적었다" "$bad"
pol=$(aws s3api get-bucket-policy --bucket "$bad" --query Policy --output text 2>/dev/null)
if [ -z "$pol" ] || ! jq -e '[.Statement[] | select(.Effect == "Allow" and (.Principal == "*" or .Principal.AWS == "*"))] | length > 0' >/dev/null 2>&1 <<< "$pol"; then
  pass "$bad 에 누구나(Principal *) 허용하는 정책이 없다"
else fail "$bad 에 누구나(Principal *) 허용하는 정책이 없다 (delete-bucket-policy)"; fi
pab=$(aws s3api get-public-access-block --bucket "$bad" --query 'PublicAccessBlockConfiguration.[BlockPublicAcls,IgnorePublicAcls,BlockPublicPolicy,RestrictPublicBuckets]' --output text 2>/dev/null | tr '\t' ' ')
[ "$pab" = "True True True True" ] && pass "$bad 에 퍼블릭 액세스 차단 네 가지가 모두 켜져 있다" || fail "$bad 에 퍼블릭 액세스 차단 네 가지가 모두 켜져 있다 (지금: ${pab:-설정 없음})"
wp=$(aws s3api get-bucket-policy --bucket "$W" --query Policy --output text 2>/dev/null)
wpab=$(aws s3api get-public-access-block --bucket "$W" --query 'PublicAccessBlockConfiguration.[BlockPublicPolicy,RestrictPublicBuckets]' --output text 2>/dev/null | tr '\t' ' ')
if [ "$wp" = "$(cat "/opt/cmdlab/secret/policy-$W")" ] && [[ "$wpab" != *True* ]]; then pass "웹사이트 버킷은 그대로 공개돼 있다"
else fail "웹사이트 버킷은 그대로 공개돼 있다 (정책을 지웠거나 차단을 켜서 웹사이트가 안 보여요!)"; fi
expect "백업 버킷의 정책은 그대로다" test "$(aws s3api get-bucket-policy --bucket "$BK" --query Policy --output text 2>/dev/null)" = "$(cat "/opt/cmdlab/secret/policy-$BK")"
finish
