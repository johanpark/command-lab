#!/usr/bin/env bash
source /opt/cmdlab/lib/helpers.sh
lo=$(secret_get leftover)
expect_answer "answer.txt 에 8080 을 잡고 있던 컨테이너 이름을 적었다" "$lo"
expect "$lo 컨테이너를 지웠다" bash -c "! docker inspect '$lo' >/dev/null 2>&1"
info=$(docker inspect -f '{{.State.Running}} {{.Config.Image}} {{.HostConfig.RestartPolicy.Name}}' shop 2>/dev/null)
read -r running image policy <<< "$info"
[ "$running" = true ] && [ "$image" = shop-web:2.0 ] && pass "shop 이 shop-web:2.0 으로 실행 중이다" || fail "shop 이 shop-web:2.0 으로 실행 중이다 (지금: ${info:-없음})"
port=$(docker port shop 80/tcp 2>/dev/null | head -n 1)
[[ $port == *:8080 ]] && pass "shop 이 8080 → 80 으로 연결됐다" || fail "shop 이 8080 → 80 으로 연결됐다 (지금: ${port:-연결 없음} — 로드밸런서는 8080 만 봐요)"
[ "$policy" = unless-stopped ] && pass "재시작 정책이 unless-stopped 다" || fail "재시작 정책이 unless-stopped 다 (지금: ${policy:-없음})"
curl -fs http://localhost:8080 2>/dev/null | grep -q 'v2.0' && pass "curl localhost:8080 이 v2.0 을 보여준다" || fail "curl localhost:8080 이 v2.0 을 보여준다"
expect "admin, api 컨테이너는 그대로다" test "$(docker inspect -f '{{.Id}}' admin api 2>/dev/null)" = "$(cat /opt/cmdlab/secret/keep)"
finish
