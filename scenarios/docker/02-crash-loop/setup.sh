#!/usr/bin/env bash
source /opt/cmdlab/lib/helpers.sh
source /usr/local/lib/lab-docker.sh
set -e
wait_docker
ensure_busybox
B=$(mktemp -d)
cat > "$B/start.sh" <<'APP'
#!/bin/sh
echo "$(date '+%F %T') INFO  shop-api 2.0 starting"
[ -n "$DB_URL" ] || { echo "$(date '+%F %T') FATAL environment variable DB_URL is not set"; exit 1; }
[ -n "$API_KEY" ] || { echo "$(date '+%F %T') FATAL environment variable API_KEY is not set"; exit 1; }
case "$LOG_LEVEL" in
  debug|info|warn|error) ;;
  *) echo "$(date '+%F %T') FATAL invalid LOG_LEVEL '$LOG_LEVEL' (allowed: debug, info, warn, error)"; exit 1 ;;
esac
echo "$(date '+%F %T') INFO  connected to $DB_URL"
echo "$(date '+%F %T') INFO  listening on :3000"
exec httpd -f -p 3000 -h /app/www
APP
mkdir -p "$B/www" && echo ok > "$B/www/health"
build_image shop-api:2.0 "$B" <<'DOCKERFILE'
FROM busybox
COPY start.sh /app/start.sh
COPY www /app/www
RUN chmod +x /app/start.sh
CMD ["/app/start.sh"]
DOCKERFILE
printf 'DB_URL=postgres://db.internal:5432/shop\nAPI_KEY=key_%s\nLOG_LEVEL=verbose\n' "$(rand_int 100000 999999)" > "$H/api.env"
give "$H/api.env"
docker run -d --name api -p 3000:3000 --restart always shop-api:2.0 >/dev/null
sleep 2
