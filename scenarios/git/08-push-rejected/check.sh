#!/usr/bin/env bash
source /opt/cmdlab/lib/helpers.sh
B=/srv/git/team-app.git; L="$H/team-app"
r0=$(secret_get remote0)
remote=$(git -C "$B" rev-parse main 2>/dev/null)
expect "동료의 커밋이 원격 main 에 그대로 있다 (force push 하지 않음)" git -C "$B" merge-base --is-ancestor "$r0" main
expect "내 커밋(README 실행 방법)이 원격 main 에 올라갔다" bash -c "git -C '$B' show main:README.md | grep -q '실행 방법'"
merges=$(git -C "$B" rev-list --merges --count main 2>/dev/null)
[ "$merges" = 0 ] && pass "원격 main 기록이 한 줄이다 (머지 커밋 없음)" || fail "원격 main 기록이 한 줄이다 (머지 커밋 ${merges}개 — git pull --rebase 를 써 보세요)"
expect "내 main 과 원격 main 이 같다" test "$(git -C "$L" rev-parse main 2>/dev/null)" = "$remote"
expect "git status 가 깨끗하다 (리베이스 진행 중 아님)" bash -c "[ -z \"\$(git -C '$L' status --porcelain)\" ] && [ ! -d '$L/.git/rebase-merge' ] && [ ! -d '$L/.git/rebase-apply' ]"
finish
