#!/usr/bin/env bash
source /opt/cmdlab/lib/helpers.sh
source /usr/local/lib/lab-docker.sh
set -e
wait_docker
ensure_busybox
code="SHOP-$(rand_int 1000 9999)"
secret_set code "$code"
B=$(mktemp -d); printf '<h1>쇼핑몰</h1>\n<p>버전 코드: %s</p>\n' "$code" > "$B/index.html"
build_image shop-web:1.0 "$B" <<'DOCKERFILE'
FROM busybox
COPY index.html /www/index.html
CMD ["httpd", "-f", "-v", "-p", "80", "-h", "/www"]
DOCKERFILE
B=$(mktemp -d); mkdir -p "$B/www" && echo ok > "$B/www/health"
printf '#!/bin/sh\necho "shop-api 2.0 listening on :3000"\nexec httpd -f -p 3000 -h /app/www\n' > "$B/start.sh"
build_image shop-api:2.0 "$B" <<'DOCKERFILE'
FROM busybox
COPY start.sh /app/start.sh
COPY www /app/www
RUN chmod +x /app/start.sh
CMD ["/app/start.sh"]
DOCKERFILE
mkdir -p "$H/shop"
cat > "$H/shop/compose.yaml" <<'YAML'
# 쇼핑몰: 웹 + API
services:
  web:
    image: shop-web:1.O
    ports:
      - "80:8080"
    depends_on:
      - api
    restart: unless-stopped

  api:
    image: shop-api:2.0
    environment:
      DB_URL: postgres://db.internal:5432/shop
    ports:
      - "3000:3000"
    restart: unless-stopped
YAML
give "$H/shop"
