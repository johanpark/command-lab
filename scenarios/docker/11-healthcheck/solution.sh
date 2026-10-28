docker ps --filter health=unhealthy --format '{{.Names}}' > ~/answer.txt
n=$(cat ~/answer.txt)
image=$(docker inspect -f '{{.Config.Image}}' "$n")
port=$(docker inspect -f '{{range (index .HostConfig.PortBindings "8080/tcp")}}{{.HostPort}}{{end}}' "$n")
envs=$(docker inspect -f '{{range .Config.Env}}{{println .}}{{end}}' "$n" | grep -E '^(DB_HOST|TZ)=' | sed 's/^/-e /')
docker rm -f "$n" > /dev/null
docker run -d --name "$n" -p "$port:8080" --restart unless-stopped $envs -e APP_MODE=production "$image" > /dev/null
for i in $(seq 1 20); do [ "$(docker inspect -f '{{.State.Health.Status}}' "$n")" = healthy ] && break; sleep 1; done
docker ps
