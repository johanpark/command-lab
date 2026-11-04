# 설명: MEM % 로 고르면 상한이 작은 컨테이너가 높게 나와 엉뚱한 범인을 고른다
# 실패해야: 메모리를 가장 많이 쓰는 컨테이너
docker stats --no-stream --format '{{.MemPerc}} {{.Name}}' | sort -rn | head -n 1 | awk '{print $NF}' > ~/answer.txt
