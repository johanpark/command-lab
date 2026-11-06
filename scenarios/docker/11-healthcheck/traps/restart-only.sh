# 설명: docker restart 로는 설정(환경 변수)이 바뀌지 않아 계속 unhealthy 다
# 실패해야: healthy 다
docker ps --filter health=unhealthy --format '{{.Names}}' > ~/answer.txt
docker restart "$(cat ~/answer.txt)" > /dev/null
