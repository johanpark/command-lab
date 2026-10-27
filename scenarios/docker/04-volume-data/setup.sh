#!/usr/bin/env bash
source /opt/cmdlab/lib/helpers.sh
source /usr/local/lib/lab-docker.sh
set -e
wait_docker
ensure_busybox
for v in 1.0 1.1; do
  build_image "memo:$v" <<DOCKERFILE
FROM busybox
RUN mkdir -p /data
CMD ["sh", "-c", "echo memo-service $v started; while true; do sleep 3600; done"]
DOCKERFILE
done
docker run -d --name memo memo:1.0 >/dev/null
memos=$(printf '%s\n' "- 우유 사기" "- 금요일 $(rand_int 2 6)시 회의" "- 서버 점검 공지 ($(rand_int 100 999)번)" "- 비밀번호 바꾸기")
docker exec -i memo sh -c 'cat > /data/memos.txt' <<< "$memos"
echo "$memos" > /opt/cmdlab/secret/memos
