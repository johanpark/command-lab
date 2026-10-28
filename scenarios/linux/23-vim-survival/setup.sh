#!/usr/bin/env bash
source /opt/cmdlab/lib/helpers.sh
set -e
# nano 를 숨긴다 (vim 명령과 기본 설정은 이미지에 들어 있다)
[ -e /usr/bin/nano ] && mv /usr/bin/nano /usr/bin/.nano-hidden
cat > "$H/app.conf" <<'CONF'
# 쇼핑몰 서버 설정
name = shop
port = 8080
debug = true
workers = 4
log_level = info
CONF
give "$H/app.conf"
