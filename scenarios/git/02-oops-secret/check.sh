#!/usr/bin/env bash
source /opt/cmdlab/lib/helpers.sh
R="$H/shop-api"
g() { git -C "$R" "$@"; }
leak=0
for c in $(g rev-list --all 2>/dev/null); do
  if g cat-file -e "$c:.env" 2>/dev/null; then leak=1; fi
done
[ "$leak" -eq 0 ] && pass "어떤 커밋에도 .env 가 없다" || fail "어떤 커밋에도 .env 가 없다 (아직 남아 있는 커밋이 있어요: git log --all --stat 확인)"
expect "src/orders.js 는 커밋에 남아 있다" g cat-file -e HEAD:src/orders.js
expect "앞선 두 커밋(프로젝트 시작, 장바구니 API)은 그대로다" g merge-base --is-ancestor "$(secret_get parent)" HEAD
expect "내 컴퓨터의 .env 파일은 그대로 있다" grep -q DB_PASSWORD "$R/.env"
expect ".gitignore 에 .env 가 있고 커밋됐다" bash -c "git -C '$R' show HEAD:.gitignore | grep -qxE '/?\\.env'"
expect "git status 가 깨끗하다" test -z "$(g status --porcelain 2>/dev/null)"
finish
