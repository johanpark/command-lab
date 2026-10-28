#!/usr/bin/env bash
source /opt/cmdlab/lib/helpers.sh
R="$H/app"; g() { git -C "$R" "$@"; }
main=$(cat /opt/cmdlab/secret/main); pay=$(cat /opt/cmdlab/secret/payment)
got=$(g rev-parse -q --verify main 2>/dev/null)
[ "$got" = "$main" ] && pass "main 이 reset 직전 커밋(다국어 지원)으로 돌아왔다" \
  || fail "main 이 reset 직전 커밋(다국어 지원)으로 돌아왔다 (지금: $(g log -1 --format='%h %s' main 2>/dev/null))"
got=$(g rev-parse -q --verify feature/payment 2>/dev/null)
if [ "$got" = "$pay" ]; then pass "feature/payment 가 삭제 직전 커밋(결제 실패 재시도)으로 되살아났다"
elif [ -n "$got" ]; then fail "feature/payment 가 삭제 직전 커밋(결제 실패 재시도)으로 되살아났다 (지금: $(g log -1 --format='%h %s' feature/payment))"
else fail "feature/payment 가 삭제 직전 커밋(결제 실패 재시도)으로 되살아났다 (브랜치가 없어요)"; fi
expect "지금 main 브랜치에 있다" test "$(g branch --show-current 2>/dev/null)" = main
expect "git status 가 깨끗하다" test -z "$(g status --porcelain 2>/dev/null)"
finish
