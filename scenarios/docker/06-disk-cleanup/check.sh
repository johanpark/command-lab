#!/usr/bin/env bash
source /opt/cmdlab/lib/helpers.sh
n=$(docker ps -aq --filter status=exited --filter status=created | wc -l)
[ "$n" -eq 0 ] && pass "멈춘 컨테이너가 없다" || fail "멈춘 컨테이너가 없다 (${n}개 남음)"
n=$(docker images -q --filter dangling=true | wc -l)
[ "$n" -eq 0 ] && pass "이름 없는(<none>) 이미지가 없다" || fail "이름 없는(<none>) 이미지가 없다 (${n}개 남음)"
n=$(docker volume ls -q --filter dangling=true | wc -l)
[ "$n" -eq 0 ] && pass "안 쓰는 볼륨이 없다" || fail "안 쓰는 볼륨이 없다 (${n}개 남음 — 이름 붙은 볼륨은 prune -a)"
expect "web 컨테이너는 그대로 실행 중이다" test "$(docker inspect -f '{{.State.Running}}' web 2>/dev/null)" = true
expect "shop-web:1.0 이미지와 web-data 볼륨은 그대로다" bash -c 'docker image inspect shop-web:1.0 && docker volume inspect web-data'
expect "보관용 backup-tool:1.0 이미지는 그대로다 (-a 로 지우지 않음)" docker image inspect backup-tool:1.0
finish
