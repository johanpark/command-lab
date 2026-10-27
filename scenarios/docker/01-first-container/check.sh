#!/usr/bin/env bash
source /opt/cmdlab/lib/helpers.sh
info=$(docker inspect web --format '{{.State.Running}} {{.Config.Image}}' 2>/dev/null)
expect "web 컨테이너가 실행 중이다" test "${info%% *}" = true
expect "web 은 shop-web:1.0 이미지로 만들었다" test "${info#* }" = shop-web:1.0
port=$(docker port web 80/tcp 2>/dev/null | head -n 1)
[[ $port == *:8080 ]] && pass "8080 포트가 컨테이너의 80 포트로 연결됐다" || fail "8080 포트가 컨테이너의 80 포트로 연결됐다 (지금: ${port:-연결 없음} — -p 8080:80)"
expect "curl http://localhost:8080 이 응답한다" curl -fs http://localhost:8080
expect_answer "answer.txt 에 오늘의 코드를 적었다" "$(secret_get code)"
expect "old-web 컨테이너를 삭제했다" bash -c "! docker inspect old-web"
finish
