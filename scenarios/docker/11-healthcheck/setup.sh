#!/usr/bin/env bash
source /opt/cmdlab/lib/helpers.sh
source /usr/local/lib/lab-docker.sh
set -e
wait_docker
ensure_busybox
B=$(mktemp -d)
cat > "$B/start.sh" <<'APP'
#!/bin/sh
mode=${APP_MODE:-production}
echo "$(date '+%F %T') INFO  app-server 3.2 starting (APP_MODE=$mode, DB_HOST=$DB_HOST)"
mkdir -p /tmp/www && echo '<h1>app-server</h1>' > /tmp/www/index.html
case "$mode" in
  production)  echo ok > /tmp/www/health; echo "$(date '+%F %T') INFO  health endpoint enabled" ;;
  maintenance) echo "$(date '+%F %T') WARN  maintenance mode: /health disabled" ;;
  *)           echo "$(date '+%F %T') WARN  unknown APP_MODE '$mode' (allowed: production, maintenance) -> falling back to maintenance mode: /health disabled" ;;
esac
echo "$(date '+%F %T') INFO  listening on :8080"
exec httpd -f -p 8080 -h /tmp/www
APP
build_image app-server:3.2 "$B" <<'DOCKERFILE'
FROM busybox
COPY start.sh /app/start.sh
RUN chmod +x /app/start.sh
HEALTHCHECK --interval=3s --timeout=2s --retries=2 CMD wget -q -O /dev/null http://127.0.0.1:8080/health || exit 1
CMD ["/app/start.sh"]
DOCKERFILE
names=(order-api member-api coupon-api)
bad=$(rand_pick "${names[@]}")
secret_set bad "$bad"
typo=$(rand_pick prodution producton prduction)
port=18080
for n in "${names[@]}"; do
  port=$((port + 1))
  mode=production; [ "$n" = "$bad" ] && { mode=$typo; secret_set port "$port"; }
  docker run -d --name "$n" -p "$port:8080" --restart unless-stopped \
    -e APP_MODE="$mode" -e DB_HOST=db.internal -e TZ=Asia/Seoul app-server:3.2 >/dev/null
done
printf '%s\n' "${names[@]}" | grep -vx "$bad" > /opt/cmdlab/secret/others
docker inspect -f '{{.Id}}' $(cat /opt/cmdlab/secret/others) > /opt/cmdlab/secret/ids
for i in $(seq 1 40); do
  [ "$(docker inspect -f '{{.State.Health.Status}}' "$bad")" = unhealthy ] && break; sleep 0.5
done
