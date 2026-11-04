# 설명: 포트가 겹친다고 8081 로 띄우면 로드밸런서(8080)가 못 찾는다
# 실패해야: 8080 → 80 으로 연결
docker ps --filter publish=8080 --format '{{.Names}}' > ~/answer.txt
docker run -d --name shop -p 8081:80 --restart unless-stopped shop-web:2.0 > /dev/null
