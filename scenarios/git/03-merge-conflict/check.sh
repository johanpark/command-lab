#!/usr/bin/env bash
source /opt/cmdlab/lib/helpers.sh
R="$H/website"
g() { git -C "$R" "$@"; }
F="$R/index.html"
expect "현재 브랜치가 main 이다" test "$(g branch --show-current)" = main
expect "머지가 끝났다 (진행 중인 머지 없음)" test ! -e "$R/.git/MERGE_HEAD"
expect "feature/new-title 이 main 에 합쳐졌다" g merge-base --is-ancestor "$(secret_get feature)" HEAD
expect "충돌 표시가 남아 있지 않다" bash -c "! grep -qE '^(<<<<<<<|=======|>>>>>>>)' '$F'"
expect "제목이 '<h1>커맨드 연습장 - 매일 조금씩</h1>' 이다" grep -qxE '[[:space:]]*<h1>커맨드 연습장 - 매일 조금씩</h1>[[:space:]]*' "$F"
expect "제목(h1)이 하나뿐이다" test "$(grep -c '<h1>' "$F")" -eq 1
expect "동료의 footer 가 살아 있다" grep -q '<footer>© 2026 Command Lab</footer>' "$F"
expect "나의 nav 가 살아 있다" grep -q '<nav>홈 · 시나리오 · 기록</nav>' "$F"
expect "해결한 내용이 커밋됐다 (git status 깨끗)" test -z "$(g status --porcelain 2>/dev/null)"
finish
