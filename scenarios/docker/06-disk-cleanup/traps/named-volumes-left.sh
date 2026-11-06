# 설명: volume prune 에 -a 를 빼면 이름 붙은 안 쓰는 볼륨이 남는다
# 실패해야: 안 쓰는 볼륨이 없다
docker container prune -f > /dev/null
docker image prune -f > /dev/null
docker volume prune -f > /dev/null
