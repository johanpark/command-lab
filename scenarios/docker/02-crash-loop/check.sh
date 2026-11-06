#!/usr/bin/env bash
source /opt/cmdlab/lib/helpers.sh
# 계속 죽었다 살아나는 컨테이너도 한순간엔 running 이라, 잠깐 사이를 두고 두 번 보고 재시작 횟수가 늘지 않았는지 확인한다
st1=$(docker inspect api --format '{{.State.Status}} {{.State.Restarting}} {{.RestartCount}}' 2>/dev/null)
sleep 3
st2=$(docker inspect api --format '{{.State.Status}} {{.State.Restarting}} {{.RestartCount}}' 2>/dev/null)
read -r status restarting n1 <<< "$st1"; read -r status2 restarting2 n2 <<< "$st2"
if [ "$status" = running ] && [ "$status2" = running ] && [ "$restarting2" = false ] && [ "$n1" = "$n2" ]; then pass "api 컨테이너가 안정적으로 실행 중이다"
else fail "api 컨테이너가 안정적으로 실행 중이다 (지금: ${status2:-없음}$([ -n "$n2" ] && [ "$n1" != "$n2" ] && echo ", 몇 초 사이에 또 재시작했어요 — docker logs api"))"; fi
expect "이미지는 shop-api:2.0 이다" test "$(docker inspect api --format '{{.Config.Image}}' 2>/dev/null)" = shop-api:2.0
env=$(docker inspect api --format '{{range .Config.Env}}{{println .}}{{end}}' 2>/dev/null)
expect "DB_URL, API_KEY 가 컨테이너에 전달됐다" bash -c "grep -q '^DB_URL=postgres' <<< \"\$1\" && grep -q '^API_KEY=key_' <<< \"\$1\"" _ "$env"
expect "~/api.env 의 LOG_LEVEL 이 허용된 값이다" grep -qxE 'LOG_LEVEL=(debug|info|warn|error)' "$H/api.env"
expect "재시작 정책이 unless-stopped 다" test "$(docker inspect api --format '{{.HostConfig.RestartPolicy.Name}}' 2>/dev/null)" = unless-stopped
got=$(curl -fs http://localhost:3000/health 2>/dev/null)
[ "$got" = ok ] && pass "http://localhost:3000/health 가 ok 를 돌려준다" || fail "http://localhost:3000/health 가 ok 를 돌려준다 (포트 3000:3000 연결했나요?)"
finish
