#!/usr/bin/env bash
source /opt/cmdlab/lib/helpers.sh
expect "shop-net 네트워크가 있다" docker network inspect shop-net
nets() { docker inspect "$1" --format '{{range $k, $v := .NetworkSettings.Networks}}{{println $k}}{{end}}' 2>/dev/null; }
expect "db 가 shop-net 에 연결됐다" grep -qx shop-net <<< "$(nets db)"
expect "app 이 shop-net 에 연결됐다" grep -qx shop-net <<< "$(nets app)"
expect "app 과 db 가 둘 다 실행 중이다" bash -c '[ "$(docker inspect -f "{{.State.Running}}" app db | sort -u)" = true ]'
expect "app 안에서 db:5000 에 접속된다" bash -c '[ "$(docker exec app wget -qO- -T 2 http://db:5000/ping)" = pong ]'
finish
