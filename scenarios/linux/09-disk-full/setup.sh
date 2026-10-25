#!/usr/bin/env bash
source /opt/cmdlab/lib/helpers.sh
set -e
A="$H/app"
mkdir -p "$A"/{config,uploads/2026/{09,10},logs/archive,.cache/thumbs,bin}
echo "port: 8080" > "$A/config/app.yaml"
echo "#!/bin/sh" > "$A/bin/start.sh"
for i in $(seq 1 30); do head -c "$(rand_int 100000 900000)" /dev/urandom > "$A/uploads/2026/$(rand_pick 09 10)/photo_$i.jpg"; done
for i in $(seq 1 15); do head -c "$(rand_int 10000 90000)" /dev/urandom > "$A/.cache/thumbs/t_$i.png"; done
for d in 01 02 03 04 05; do head -c "$(rand_int 500000 3000000)" /dev/urandom > "$A/logs/archive/app-2026-10-$d.log.gz"; done
head -c 3000000 /dev/urandom > "$A/logs/app.log"
head -c 9000000 /dev/urandom > "$A/uploads/2026/10/promo-video.mp4"

# 범인: 위치를 무작위로
where=$(rand_pick "$A/.cache/core.dump" "$A/logs/archive/debug-full.log" "$A/uploads/2026/09/.tmp_upload_88231" "$A/bin/old-build.tar")
head -c $((60 * 1024 * 1024)) /dev/zero > "$where"
secret_set big "$where"
give "$A"
find "$A" -type f ! -path "$where" | sort > /opt/cmdlab/secret/keep
