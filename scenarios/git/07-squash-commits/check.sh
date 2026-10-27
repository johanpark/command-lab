#!/usr/bin/env bash
source /opt/cmdlab/lib/helpers.sh
R="$H/todo-app"
g() { git -C "$R" "$@"; }
main0=$(secret_get main)
expect "main 브랜치는 그대로다" test "$(g rev-parse main 2>/dev/null)" = "$main0"
expect "지금 feature/login 브랜치에 있다" test "$(g branch --show-current)" = feature/login
n=$(g rev-list --count main..feature/login 2>/dev/null)
[ "$n" = 1 ] && pass "main 이후 커밋이 하나다" || fail "main 이후 커밋이 하나다 (지금: ${n:-?}개)"
expect "그 커밋이 main 바로 위에 있다" test "$(g rev-parse 'feature/login^' 2>/dev/null)" = "$main0"
msg=$(g log -1 --format=%s feature/login 2>/dev/null)
[ "$msg" = "로그인 기능 추가" ] && pass "커밋 메시지가 '로그인 기능 추가' 다" || fail "커밋 메시지가 '로그인 기능 추가' 다 (지금: '$msg')"
expect "최종 파일 내용은 정리 전과 똑같다" test "$(g rev-parse 'feature/login^{tree}' 2>/dev/null)" = "$(secret_get tree)"
expect "git status 가 깨끗하다 (리베이스 진행 중 아님)" bash -c "[ -z \"\$(git -C '$R' status --porcelain)\" ] && [ ! -d '$R/.git/rebase-merge' ]"
finish
