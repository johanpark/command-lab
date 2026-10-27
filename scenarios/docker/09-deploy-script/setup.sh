#!/usr/bin/env bash
source /opt/cmdlab/lib/helpers.sh
source /usr/local/lib/lab-docker.sh
set -e
wait_docker
ensure_busybox
for v in 1.0 1.1 1.2; do
  B=$(mktemp -d); echo "<h1>shop v$v</h1>" > "$B/index.html"
  build_image "shop-web:$v" "$B" <<'DOCKERFILE'
FROM busybox
COPY index.html /www/index.html
CMD ["httpd", "-f", "-p", "80", "-h", "/www"]
DOCKERFILE
done
cat > "$H/deploy.sh" <<'SH'
#!/usr/bin/env bash
# 사용법: ./deploy.sh <버전>
set -e
VERSION=${1:?사용법: ./deploy.sh <버전>}
echo "▶ shop-web:$VERSION 배포"
docker run -d --name web -p 8080:80 --restart unless-stopped "shop-web:$VERSION"
echo "✅ 배포 완료 (shop-web:$VERSION)"
SH
chmod 755 "$H/deploy.sh"; give "$H/deploy.sh"
docker run -d --name web -p 8080:80 --restart unless-stopped shop-web:1.0 >/dev/null
