#!/usr/bin/env bash
source /opt/cmdlab/lib/helpers.sh
res=$(python3 /opt/cmdlab/scenario/iam_eval.py "$(secret_get bucket)" "$(secret_get other)" 2>&1)
while IFS=$'\t' read -r st msg; do
  case "$st" in ok) pass "$msg" ;; no) fail "$msg" ;; *) fail "권한 계산 중 오류: $st $msg" ;; esac
done <<< "$res"
expect "다른 사용자(deploy-bot)의 권한은 그대로다" bash -c "aws iam list-attached-user-policies --user-name deploy-bot --query 'AttachedPolicies[].PolicyName' --output text | grep -qx AmazonEC2FullAccess"
finish
