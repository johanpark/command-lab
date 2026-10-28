#!/usr/bin/env bash
source /opt/cmdlab/lib/helpers.sh
source /usr/local/lib/lab-docker.sh
set -e
wait_docker
ensure_busybox
hog=$(rand_pick report-cache image-resizer session-store)
secret_set hog "$hog"
build_image "$hog:2.1" <<'DOCKERFILE'
FROM busybox
CMD ["sh", "-c", "echo loading cache...; x=$(head -c 60000000 /dev/zero | tr '\\0' a); echo cache loaded; while true; do sleep 3600; done"]
DOCKERFILE
build_image small-svc:1.0 <<'DOCKERFILE'
FROM busybox
CMD ["sh", "-c", "while true; do sleep 3600; done"]
DOCKERFILE
for n in web api worker; do docker run -d --name "$n" --memory 128m --restart unless-stopped small-svc:1.0 >/dev/null; done
docker run -d --name "$hog" --restart unless-stopped "$hog:2.1" >/dev/null
for i in $(seq 1 40); do docker logs "$hog" 2>&1 | grep -q 'cache loaded' && break; sleep 0.5; done
docker ps -q | sort > /opt/cmdlab/secret/ids0
docker inspect -f '{{.Id}}' web api worker > /opt/cmdlab/secret/others
