#!/usr/bin/env bash
source /opt/cmdlab/lib/helpers.sh
st=$(docker inspect api --format '{{.State.Status}} {{.State.Restarting}} {{.RestartCount}}' 2>/dev/null)
read -r status restarting _ <<< "$st"
[ "$status" = running ] && [ "$restarting" = false ] && pass "api 컨테이너가 안정적으로 실행 중이다" || fail "api 컨테이너가 안정적으로 실행 중이다 (지금: ${status:-없음})"
expect "이미지는 shop-api:2.0 이다" test "$(docker inspect api --format '{{.Config.Image}}' 2>/dev/null)" = shop-api:2.0
env=$(docker inspect api --format '{{range .Config.Env}}{{println .}}{{end}}' 2>/dev/null)
expect "DB_URL, API_KEY 가 컨테이너에 전달됐다" bash -c "grep -q '^DB_URL=postgres' <<< \"\$1\" && grep -q '^API_KEY=key_' <<< \"\$1\"" _ "$env"
expect "~/api.env 의 LOG_LEVEL 이 허용된 값이다" grep -qxE 'LOG_LEVEL=(debug|info|warn|error)' "$H/api.env"
expect "재시작 정책이 unless-stopped 다" test "$(docker inspect api --format '{{.HostConfig.RestartPolicy.Name}}' 2>/dev/null)" = unless-stopped
got=$(curl -fs http://localhost:3000/health 2>/dev/null)
[ "$got" = ok ] && pass "http://localhost:3000/health 가 ok 를 돌려준다" || fail "http://localhost:3000/health 가 ok 를 돌려준다 (포트 3000:3000 연결했나요?)"
finish
