# 설명: 상한을 256MB 가 아니라 512MB 로 잘못 건다
# 실패해야: 메모리 상한 256MB
docker stats --no-stream --format '{{.MemUsage}} {{.Name}}' | sort -rh | head -n 1 | awk '{print $NF}' > ~/answer.txt
hog=$(cat ~/answer.txt); image=$(docker inspect -f '{{.Config.Image}}' "$hog")
docker rm -f "$hog" > /dev/null
docker run -d --name "$hog" --memory 512m --restart unless-stopped "$image" > /dev/null
sleep 2
