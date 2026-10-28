#!/usr/bin/env bash
source /opt/cmdlab/lib/helpers.sh
source /usr/local/lib/lab-docker.sh
set -e
wait_docker
ensure_busybox
W="$H/webapp"; rm -rf "$W"; mkdir -p "$W"/{public/css,src,logs,node_modules/{left-pad,lodash,react}}
cat > "$W/Dockerfile" <<'DOCKERFILE'
FROM busybox
WORKDIR /app
COPY . .
EXPOSE 8080
CMD ["httpd", "-f", "-p", "8080", "-h", "/app/public"]
DOCKERFILE
echo "<h1>Hello from webapp</h1>" > "$W/public/index.html"
echo "body { font-family: sans-serif; }" > "$W/public/css/style.css"
echo "// 빌드 전 소스" > "$W/src/main.js"
printf 'DB_PASSWORD=%s\nAPI_KEY=sk_live_%s\n' "$(rand_pick hunter2 p@ssw0rd s3cret!)" "$(rand_int 100000 999999)" > "$W/.env"
for d in left-pad lodash react; do head -c $((6 * 1024 * 1024)) /dev/urandom > "$W/node_modules/$d/bundle.js"; done
for i in 1 2 3; do head -c $((4 * 1024 * 1024)) /dev/urandom | base64 > "$W/logs/access-2026-10-2$i.log"; done
give "$W"
# Git 저장소 흉내 (이 환경엔 git 이 없어서 기록 파일만)
mkdir -p "$W/.git/objects/pack" && echo "ref: refs/heads/main" > "$W/.git/HEAD"
head -c $((3 * 1024 * 1024)) /dev/urandom > "$W/.git/objects/pack/pack-1a2b3c.pack"
give "$W"
docker rmi -f webapp:1.1 >/dev/null 2>&1 || true
docker build -q -t webapp:1.0 "$W" >/dev/null
