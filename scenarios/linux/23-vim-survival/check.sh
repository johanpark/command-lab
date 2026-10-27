#!/usr/bin/env bash
source /opt/cmdlab/lib/helpers.sh
F="$H/app.conf"
expect "port 가 9090 이다" grep -qxE 'port *= *9090' "$F"
expect "debug 줄이 지워졌다" bash -c "! grep -q '^debug' '$F'"
expect "맨 끝 줄이 timezone = Asia/Seoul 이다" test "$(sed '/^[[:space:]]*$/d' "$F" | tail -n 1)" = "timezone = Asia/Seoul"
expect "다른 설정(name, workers, log_level)은 그대로다" bash -c "grep -qx 'name = shop' '$F' && grep -qx 'workers = 4' '$F' && grep -qx 'log_level = info' '$F'"
expect "vim 임시 파일(.swp)이 남아 있지 않다 (vim 을 제대로 나왔다)" bash -c "! ls -a '$H' | grep -q '\.app\.conf\.sw.'"
finish
