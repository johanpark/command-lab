#!/usr/bin/env bash
source /opt/cmdlab/lib/helpers.sh
set -e
A="$H/app"
mkdir -p "$A"/{bin,config,logs,public}
echo ok > "$A/public/health"
echo "<h1>Shop v2.3.0</h1>" > "$A/public/index.html"
cat > "$A/bin/shop-server" <<'SERVER'
#!/bin/bash
# 쇼핑몰 서버 v2.3.0 (busybox httpd 로 정적 파일을 서비스한다)
CONF="$HOME/app/config/app.env"
log() { echo "$(date '+%F %T') $*"; }
log "INFO  shop-server v2.3.0 starting (pid $$)"
if [ ! -r "$CONF" ]; then log "FATAL cannot read config $CONF: Permission denied"; exit 1; fi
# shellcheck disable=SC1090
source "$CONF"
if ! [[ "$PORT" =~ ^[0-9]+$ ]]; then log "FATAL invalid PORT value '$PORT' in $CONF (must be a number)"; exit 1; fi
if [ ! -d "$DOC_ROOT" ]; then log "FATAL DOC_ROOT does not exist: $DOC_ROOT"; exit 1; fi
log "INFO  serving $DOC_ROOT on 127.0.0.1:$PORT"
busybox httpd -f -p "127.0.0.1:$PORT" -h "$DOC_ROOT" &
child=$!
trap 'kill $child 2>/dev/null; log "INFO  stopped"; exit 0' TERM INT
wait $child
SERVER
chmod 755 "$A/bin/shop-server"
cat > "$H/deploy.sh" <<'DEPLOY'
#!/usr/bin/env bash
APP="$HOME/app"
echo "▶ 이전 버전 중지"
pkill -x shop-server 2>/dev/null && sleep 1
echo "▶ 새 버전 시작"
setsid nohup "$APP/bin/shop-server" >> "$APP/logs/app.log" 2>&1 < /dev/null &
echo "▶ 헬스 체크 (http://localhost:9000/health)"
for i in 1 2 3 4 5; do
  if [ "$(curl -fs http://localhost:9000/health 2>/dev/null)" = ok ]; then
    echo "✅ 배포 성공"; exit 0
  fi
  sleep 1
done
echo "❌ 배포 실패: 헬스 체크에 응답하지 않습니다. 로그를 확인하세요 (~/app/logs)"
exit 1
DEPLOY
chmod 755 "$H/deploy.sh"
# 고장 난 설정: 1) root 만 읽을 수 있음 2) PORT 에 알파벳 O 3) DOC_ROOT 오타
printf '# shop-server 설정\nPORT=9OOO\nDOC_ROOT=%s/publc\nLOG_LEVEL=info\n' "$A" > "$A/config/app.env"
# 어제 로그 (지금 장애와는 상관없는 에러들)
{
  for h in 09 11 14 16 18; do
    echo "$(date -d yesterday +%F) $h:12:03 INFO  shop-server v2.2.9 serving on 127.0.0.1:9000"
    echo "$(date -d yesterday +%F) $h:40:51 ERROR database timeout after 30s (orders.list)"
    echo "$(date -d yesterday +%F) $h:41:02 WARN  retrying payment webhook"
  done
} > "$A/logs/app.log.1"
touch -d yesterday "$A/logs/app.log.1"
printf '127.0.0.1 - - "GET /health" 200\n' > "$A/logs/access.log"
give "$A" "$H/deploy.sh"
chown root:root "$A/config/app.env"; chmod 600 "$A/config/app.env"
# 한 번 배포를 시도해서 실패 로그를 남겨 둔다
as_learner "$H/deploy.sh" >/dev/null 2>&1 || true
