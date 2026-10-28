#!/usr/bin/env bash
source /opt/cmdlab/lib/helpers.sh
U=/srv/uploads; HB="$U/heartbeat.txt"
info=$(docker inspect -f '{{.State.Running}}|{{.Config.User}}|{{.Config.Image}}|{{range .Mounts}}{{.Source}}:{{.Destination}} {{end}}' uploader 2>/dev/null)
IFS='|' read -r running user image mounts <<< "$info"
expect "uploader 가 실행 중이다" test "$running" = true
case "$user" in
  ""|0|root|0:*|root:*) fail "root 가 아닌 사용자로 실행된다 (지금: '${user:-root(기본값)}')" ;;
  *) pass "root 가 아닌 사용자로 실행된다 ($user)" ;;
esac
expect "같은 이미지(uploader:2.3)로 /srv/uploads 를 /data/uploads 에 연결하고 있다" bash -c "[ '$image' = uploader:2.3 ] && grep -q '/srv/uploads:/data/uploads' <<< '$mounts'"
fresh=0
for i in $(seq 1 8); do
  if [ -f "$HB" ] && [ $(( $(date +%s) - $(stat -c %Y "$HB") )) -le 8 ]; then fresh=1; break; fi
  sleep 1
done
[ "$fresh" = 1 ] && pass "컨테이너가 /srv/uploads 에 쓰고 있다 (heartbeat.txt 갱신 중)" \
  || fail "컨테이너가 /srv/uploads 에 쓰고 있다 ($(docker logs --tail 1 uploader 2>&1 | cut -c1-100))"
bad=$(find "$U" -perm -o+w 2>/dev/null | head -n 3 | tr '\n' ' ')
[ -z "$bad" ] && pass "아무나 쓸 수 있는(777) 폴더나 파일이 없다" || fail "아무나 쓸 수 있는(777) 폴더나 파일이 없다 (지금: $bad— chmod 777 대신 chown 으로)"
expect "기존 업로드 파일이 그대로다" md5sum --quiet -c /opt/cmdlab/secret/files
finish
