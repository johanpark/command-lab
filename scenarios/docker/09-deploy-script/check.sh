#!/usr/bin/env bash
source /opt/cmdlab/lib/helpers.sh
S="$H/deploy.sh"
serving() { curl -fs http://localhost:8080 2>/dev/null | grep -q "v$1"; }
deploy() { (cd "$H" && runuser -u "$LEARNER" -- env HOME="$H" "$S" "$1") >/dev/null 2>&1; }
serving 1.1 && pass "지금 1.1 이 배포돼 있다" || fail "지금 1.1 이 배포돼 있다 (curl http://localhost:8080)"
expect "deploy.sh 에 set -e 가 그대로 있다" grep -qE '^\s*set -[a-z]*e' "$S"
# 이미 web 이 있을 때 (1.2 로 갔다가)
if deploy 1.2 && sleep 0.5 && serving 1.2; then pass "web 이 이미 있을 때 다시 배포하면 성공한다 (1.1 → 1.2)"
else fail "web 이 이미 있을 때 다시 배포하면 성공한다 (1.1 → 1.2)"; fi
# web 이 아예 없을 때
docker rm -f web >/dev/null 2>&1
if deploy 1.1 && sleep 0.5 && serving 1.1; then pass "web 이 없을 때 배포해도 성공한다"
else fail "web 이 없을 때 배포해도 성공한다 (web 이 없으면 docker stop / docker rm 이 실패해서 set -e 로 멈춰요 — || true)"; docker run -d --name web -p 8080:80 shop-web:1.1 >/dev/null 2>&1; fi
expect "web 컨테이너는 하나뿐이다" test "$(docker ps -aq --filter name='^web$' | wc -l)" -eq 1
finish
