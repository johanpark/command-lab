cd ~
# MEM % 는 각자의 상한 대비 비율이라 헷갈린다. 절대 사용량(MEM USAGE)으로 고른다
docker stats --no-stream --format '{{.MemUsage}} {{.Name}}' | sort -rh | head -n 1 | awk '{print $NF}' > ~/answer.txt
hog=$(cat ~/answer.txt)
image=$(docker inspect -f '{{.Config.Image}}' "$hog")
docker rm -f "$hog" > /dev/null
docker run -d --name "$hog" --memory 256m --restart unless-stopped "$image" > /dev/null
sleep 3
