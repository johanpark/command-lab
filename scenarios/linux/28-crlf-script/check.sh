#!/usr/bin/env bash
source /opt/cmdlab/lib/helpers.sh
D="$H/deploy"
n=$(grep -rl $'\r' "$D" --include='*.sh' 2>/dev/null | wc -l)
[ "$n" -eq 0 ] && pass "모든 .sh 파일에서 CRLF(\\r)를 없앴다" || fail "모든 .sh 파일에서 CRLF(\\r)를 없앴다 (${n}개 남음 — lib 폴더도 확인)"
expect "deploy.sh, lib/stamp.sh 에 실행 권한이 있다" test -x "$D/deploy.sh" -a -x "$D/lib/stamp.sh"
expect_answer "배포가 완료됐다 (~/site/version.txt)" "$(secret_get ver)" "$H/site/version.txt"
finish
