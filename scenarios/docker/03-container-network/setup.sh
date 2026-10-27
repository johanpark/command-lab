#!/usr/bin/env bash
source /opt/cmdlab/lib/helpers.sh
source /usr/local/lib/lab-docker.sh
set -e
wait_docker
ensure_busybox
B=$(mktemp -d); mkdir -p "$B/data" && echo pong > "$B/data/ping"
build_image shop-db:1.0 "$B" <<'DOCKERFILE'
FROM busybox
COPY data /data
CMD ["httpd", "-f", "-p", "5000", "-h", "/data"]
DOCKERFILE
B=$(mktemp -d)
cat > "$B/app.sh" <<'APP'
#!/bin/sh
while true; do
  if [ "$(wget -qO- -T 2 http://db:5000/ping 2>/dev/null)" = pong ]; then
    echo "$(date '+%T') OK connected to db"
  else
    echo "$(date '+%T') ERROR cannot reach db:5000 (bad address 'db')"
  fi
  sleep 2
done
APP
build_image shop-app:1.0 "$B" <<'DOCKERFILE'
FROM busybox
COPY app.sh /app.sh
RUN chmod +x /app.sh
CMD ["/app.sh"]
DOCKERFILE
docker run -d --name db shop-db:1.0 >/dev/null
docker run -d --name app shop-app:1.0 >/dev/null
