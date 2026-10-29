#!/usr/bin/env bash
source /opt/cmdlab/lib/helpers.sh
B=$(secret_get bucket)
res=$(python3 /opt/cmdlab/scenario/lifecycle_eval.py "$B" 2>&1)
while IFS=$'\t' read -r st msg; do
  case "$st" in ok) pass "$msg" ;; no) fail "$msg" ;; *) fail "규칙 확인 중 오류: $st $msg" ;; esac
done <<< "$res"
expect "버킷 안의 파일은 그대로다 (손으로 지우지 않음)" test "$(aws s3 ls "s3://$B/" --recursive | wc -l)" = 13
finish
