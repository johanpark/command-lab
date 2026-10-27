#!/usr/bin/env bash
source /opt/cmdlab/lib/helpers.sh
expect "memo-data 볼륨이 있다" docker volume inspect memo-data
info=$(docker inspect memo --format '{{.State.Running}} {{.Config.Image}}' 2>/dev/null)
expect "memo 컨테이너가 실행 중이다" test "${info%% *}" = true
expect "memo 는 새 버전 memo:1.1 이미지다" test "${info#* }" = memo:1.1
mnt=$(docker inspect memo --format '{{range .Mounts}}{{if eq .Destination "/data"}}{{.Type}} {{.Name}}{{end}}{{end}}' 2>/dev/null)
[ "$mnt" = "volume memo-data" ] && pass "/data 에 memo-data 볼륨이 연결됐다" || fail "/data 에 memo-data 볼륨이 연결됐다 (지금: ${mnt:-연결 없음})"
if [ "$(docker exec memo cat /data/memos.txt 2>/dev/null)" = "$(cat /opt/cmdlab/secret/memos)" ]; then pass "기존 메모가 그대로 있다"
else fail "기존 메모가 그대로 있다 (docker exec memo cat /data/memos.txt 로 확인)"; fi
finish
