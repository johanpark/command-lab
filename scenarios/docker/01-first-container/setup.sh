#!/usr/bin/env bash
source /opt/cmdlab/lib/helpers.sh
source /usr/local/lib/lab-docker.sh
set -e
wait_docker
ensure_busybox
code="SHOP-$(rand_int 1000 9999)"
secret_set code "$code"
B=$(mktemp -d)
printf '<h1>쇼핑몰</h1>\n<p>오늘의 코드: %s</p>\n' "$code" > "$B/index.html"
build_image shop-web:1.0 "$B" <<'DOCKERFILE'
FROM busybox
COPY index.html /www/index.html
CMD ["httpd", "-f", "-v", "-p", "80", "-h", "/www"]
DOCKERFILE
docker create --name old-web shop-web:1.0 >/dev/null
docker start old-web >/dev/null && sleep 0.5 && docker stop -t 1 old-web >/dev/null
