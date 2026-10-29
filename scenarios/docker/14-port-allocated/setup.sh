#!/usr/bin/env bash
source /opt/cmdlab/lib/helpers.sh
source /usr/local/lib/lab-docker.sh
set -e
wait_docker
ensure_busybox
for v in 1.9 2.0; do
  B=$(mktemp -d); mkdir -p "$B/www"; echo "<h1>shop v$v</h1>" > "$B/www/index.html"
  build_image "shop-web:$v" "$B" <<'DOCKERFILE'
FROM busybox
COPY www /www
CMD ["httpd", "-f", "-p", "80", "-h", "/www"]
DOCKERFILE
done
docker rm -f $(docker ps -aq) >/dev/null 2>&1 || true
leftover=$(rand_pick test-run-3 tmp-check jinho-test quick-demo)
secret_set leftover "$leftover"
# 서비스 중인 컨테이너들 (8080 이 아닌 포트)
docker run -d --name admin -p 8081:80 --restart unless-stopped shop-web:1.9 >/dev/null
docker run -d --name api -p 3000:80 --restart unless-stopped shop-web:1.9 >/dev/null
docker run -d --name "$(rand_pick metrics monitor)" -p 9100:80 shop-web:1.9 >/dev/null
# 범인: 어제 테스트하고 남긴 컨테이너가 8080 을 잡고 있다
docker run -d --name "$leftover" -p 8080:80 shop-web:1.9 >/dev/null
docker inspect -f '{{.Id}}' admin api > /opt/cmdlab/secret/keep
