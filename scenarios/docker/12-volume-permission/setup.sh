#!/usr/bin/env bash
source /opt/cmdlab/lib/helpers.sh
source /usr/local/lib/lab-docker.sh
set -e
wait_docker
ensure_busybox
B=$(mktemp -d)
cat > "$B/run.sh" <<'APP'
#!/bin/sh
echo "$(date '+%F %T') INFO  uploader 2.3 starting as $(id)"
while true; do
  if date '+%F %T' > /data/uploads/heartbeat.txt 2>/dev/null; then
    echo "$(date '+%F %T') OK    heartbeat written"
  else
    echo "$(date '+%F %T') ERROR cannot write /data/uploads/heartbeat.txt (uid=$(id -u))"
  fi
  sleep 3
done
APP
build_image uploader:2.3 "$B" <<'DOCKERFILE'
FROM busybox
COPY run.sh /app/run.sh
RUN chmod 755 /app/run.sh && mkdir -p /data/uploads
USER 1000:1000
CMD ["/app/run.sh"]
DOCKERFILE
rm -rf /srv/uploads; mkdir -p /srv/uploads/2026-10
for i in 1 2 3; do head -c 2000 /dev/urandom > "/srv/uploads/2026-10/photo$i.jpg"; done
chown -R root:root /srv/uploads; chmod -R 755 /srv/uploads
find /srv/uploads -type f -exec md5sum {} + > /opt/cmdlab/secret/files
docker rm -f uploader >/dev/null 2>&1 || true
docker run -d --name uploader -v /srv/uploads:/data/uploads --restart unless-stopped uploader:2.3 >/dev/null
sleep 2
