# 설명: 포트를 비우려고 컨테이너를 다 지우면 admin·api 까지 사라진다
# 실패해야: admin, api 컨테이너는 그대로
docker ps --filter publish=8080 --format '{{.Names}}' > ~/answer.txt
docker rm -f $(docker ps -aq) > /dev/null
docker run -d --name shop -p 8080:80 --restart unless-stopped shop-web:2.0 > /dev/null
sleep 1
