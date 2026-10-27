#!/usr/bin/env bash
source /opt/cmdlab/lib/helpers.sh
source /usr/local/lib/lab-docker.sh
set -e
wait_docker
ensure_busybox
db="db-$(rand_pick seoul busan daegu)-$(rand_int 10 99).corp.local"
tz=$(rand_pick Asia/Seoul Asia/Tokyo UTC Europe/London)
secret_set db "$db"; secret_set tz "$tz"
B=$(mktemp -d); mkdir -p "$B/etc" "$B/log"
printf '# legacy app\nAPP_PORT=7000\nDB_HOST=%s\nDB_PORT=5432\nCACHE=off\n' "$db" > "$B/etc/app.conf"
for i in $(seq 1 30); do echo "2023-0$((i % 9 + 1))-1$((i % 9)) ERROR request $i failed: timeout"; done > "$B/log/error.log"
build_image legacy-app:0.9 "$B" <<'DOCKERFILE'
FROM busybox
COPY etc /etc/legacy
COPY log /var/log/legacy
CMD ["sh", "-c", "echo legacy-app started; while true; do sleep 3600; done"]
DOCKERFILE
cp "$B/log/error.log" /opt/cmdlab/secret/error.log
docker run -d --name legacy-app -e "TZ=$tz" -e APP_MODE=production -p 7000:7000 legacy-app:0.9 >/dev/null
