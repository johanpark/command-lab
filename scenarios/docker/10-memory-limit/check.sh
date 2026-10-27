#!/usr/bin/env bash
source /opt/cmdlab/lib/helpers.sh
hog=$(secret_get hog)
expect_answer "answer.txt 에 메모리를 가장 많이 쓰는 컨테이너 이름을 적었다" "$hog"
info=$(docker inspect -f '{{.State.Running}} {{.Config.Image}} {{.HostConfig.Memory}}' "$hog" 2>/dev/null)
read -r running image mem <<< "$info"
expect "$hog 가 실행 중이다" test "$running" = true
expect "$hog 는 같은 이미지($hog:2.1)로 만들었다" test "$image" = "$hog:2.1"
[ "$mem" = 268435456 ] && pass "$hog 에 메모리 상한 256MB 가 걸려 있다" || fail "$hog 에 메모리 상한 256MB 가 걸려 있다 (지금: ${mem:-없음} 바이트, 0 = 무제한)"
expect "다른 컨테이너(web, api, worker)는 그대로다" bash -c "[ \"\$(docker inspect -f '{{.Id}}' web api worker 2>/dev/null)\" = \"\$(cat /opt/cmdlab/secret/others)\" ]"
finish
