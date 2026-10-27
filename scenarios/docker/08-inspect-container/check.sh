#!/usr/bin/env bash
source /opt/cmdlab/lib/helpers.sh
expect_answer "answer.txt 에 DB_HOST 값을 적었다" "$(secret_get db)"
expect_answer "tz.txt 에 환경 변수 TZ 값을 적었다" "$(secret_get tz)" "$H/tz.txt"
expect "~/error.log 에 컨테이너의 에러 로그를 복사했다" cmp -s "$H/error.log" /opt/cmdlab/secret/error.log
expect "legacy-app 은 그대로 실행 중이다" test "$(docker inspect -f '{{.State.Running}}' legacy-app 2>/dev/null)" = true
finish
