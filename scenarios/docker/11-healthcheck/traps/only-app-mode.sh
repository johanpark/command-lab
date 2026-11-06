# 설명: APP_MODE 만 넣고 다시 만들면 원래 있던 DB_HOST·TZ 가 빠진다
# 실패해야: 원래 환경 변수(DB_HOST, TZ)
docker ps --filter health=unhealthy --format '{{.Names}}' > ~/answer.txt
n=$(cat ~/answer.txt)
image=$(docker inspect -f '{{.Config.Image}}' "$n")
port=$(docker inspect -f '{{range (index .HostConfig.PortBindings "8080/tcp")}}{{.HostPort}}{{end}}' "$n")
docker rm -f "$n" > /dev/null
docker run -d --name "$n" -p "$port:8080" --restart unless-stopped -e APP_MODE=production "$image" > /dev/null
sleep 5
