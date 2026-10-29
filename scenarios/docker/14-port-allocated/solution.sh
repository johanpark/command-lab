docker ps --filter publish=8080 --format '{{.Names}}' > ~/answer.txt
docker rm -f "$(cat ~/answer.txt)" > /dev/null
docker run -d --name shop -p 8080:80 --restart unless-stopped shop-web:2.0 > /dev/null
sleep 1
curl -s localhost:8080
