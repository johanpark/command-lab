#!/usr/bin/env bash
source /opt/cmdlab/lib/helpers.sh
A="$H/app"
expect "~/app/current 는 (폴더가 아니라) 심볼릭 링크다" test -L "$A/current"
target=$(readlink -f "$A/current" 2>/dev/null)
[ "$target" = "$A/releases/2.3.1" ] && pass "current 가 releases/2.3.1 을 가리킨다" || fail "current 가 releases/2.3.1 을 가리킨다 (지금: ${target:-없음})"
[ "$(curl -fs http://localhost:8080/health 2>/dev/null)" = ok ] && pass "헬스 체크가 ok 다" || fail "헬스 체크가 ok 다 (restart.sh 로 재시작했나요?)"
[ "$(curl -fs http://localhost:8080/version.txt 2>/dev/null)" = 2.3.1 ] && pass "서비스 중인 버전이 2.3.1 이다" || fail "서비스 중인 버전이 2.3.1 이다"
if [ "$(cd "$A/releases/2.4.0" 2>/dev/null && find . | sort)" = "$(cat /opt/cmdlab/secret/v240-files)" ]; then pass "2.4.0 폴더는 그대로다 (원인 분석용)"
else fail "2.4.0 폴더는 그대로다 (원인 분석용) — 안에 새 링크가 생기지 않았나요? ln 에 -n 이 필요해요"; fi
expect_answer "answer.txt 에 2.4.0 에서 빠진 파일 이름을 적었다" "$(secret_get missing)"
finish
