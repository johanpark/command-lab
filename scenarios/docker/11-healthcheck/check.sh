#!/usr/bin/env bash
source /opt/cmdlab/lib/helpers.sh
bad=$(secret_get bad); port=$(secret_get port)
expect_answer "answer.txt 에 unhealthy 컨테이너 이름을 적었다" "$bad"
st=""
for i in $(seq 1 20); do
  st=$(docker inspect -f '{{if .State.Health}}{{.State.Health.Status}}{{end}}' "$bad" 2>/dev/null)
  [ "$st" = starting ] || break
  sleep 1
done
[ "$st" = healthy ] && pass "$bad 가 healthy 다" || fail "$bad 가 healthy 다 (지금: ${st:-없음 또는 중지됨})"
expect "같은 이미지(app-server:3.2)다" test "$(docker inspect -f '{{.Config.Image}}' "$bad" 2>/dev/null)" = app-server:3.2
expect "같은 포트($port → 8080)로 연결돼 있다" test "$(docker inspect -f '{{range (index .HostConfig.PortBindings "8080/tcp")}}{{.HostPort}}{{end}}' "$bad" 2>/dev/null)" = "$port"
env=$(docker inspect -f '{{range .Config.Env}}{{println .}}{{end}}' "$bad" 2>/dev/null)
grep -qx 'DB_HOST=db.internal' <<< "$env" && grep -qx 'TZ=Asia/Seoul' <<< "$env" && pass "원래 환경 변수(DB_HOST, TZ)를 그대로 가지고 있다" \
  || fail "원래 환경 변수(DB_HOST, TZ)를 그대로 가지고 있다 (APP_MODE 만 넣고 나머지를 빠뜨렸나요?)"
expect "재시작 정책이 unless-stopped 다" test "$(docker inspect -f '{{.HostConfig.RestartPolicy.Name}}' "$bad" 2>/dev/null)" = unless-stopped
expect "다른 컨테이너는 그대로다" test "$(docker inspect -f '{{.Id}}' $(cat /opt/cmdlab/secret/others) 2>/dev/null)" = "$(cat /opt/cmdlab/secret/ids)"
finish
