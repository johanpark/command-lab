#!/usr/bin/env bash
source /opt/cmdlab/lib/helpers.sh
source /usr/local/lib/lab-docker.sh
set -e
wait_docker
ensure_busybox
B=$(mktemp -d); echo '<h1>shop</h1>' > "$B/index.html"
build_image shop-web:1.0 "$B" <<'DOCKERFILE'
FROM busybox
COPY index.html /www/index.html
CMD ["httpd", "-f", "-p", "80", "-h", "/www"]
DOCKERFILE
build_image backup-tool:1.0 <<'DOCKERFILE'
FROM busybox
RUN echo "backup tool" > /README
CMD ["sh"]
DOCKERFILE
# 같은 태그로 여러 번 빌드 → 예전 것들은 이름 없는(<none>) 이미지가 된다
for i in $(seq 1 $(rand_int 3 5)); do
  B=$(mktemp -d); head -c 300000 /dev/urandom > "$B/data.bin"
  build_image report:latest "$B" <<DOCKERFILE
FROM busybox
COPY data.bin /data.bin
RUN echo build $i > /build.txt
DOCKERFILE
done
docker volume create web-data >/dev/null
docker run -d --name web -p 8080:80 -v web-data:/data shop-web:1.0 >/dev/null
for i in $(seq 1 $(rand_int 4 7)); do docker run --name "test-run-$i" busybox echo "test $i done" >/dev/null; done
for v in tmp-cache-1 tmp-cache-2 old-build-cache; do docker volume create "$v" >/dev/null; done
docker run -v /scratch busybox true >/dev/null   # 익명 볼륨이 남는 컨테이너
