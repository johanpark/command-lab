#!/usr/bin/env bash
source /opt/cmdlab/lib/helpers.sh
set -e
P="$H/photos"; B=/mnt/backup/photos
mkdir -p "$P"/{2026-09,2026-10} "$B"
mk() { head -c "$(rand_int 2000 6000)" /dev/urandom > "$1"; touch -d "$(rand_int 5 60) days ago" "$1"; }
for i in $(seq 1 6); do mk "$P/2026-09/IMG_$i.jpg"; done
for i in $(seq 1 4); do mk "$P/2026-10/IMG_$i.jpg"; done
# 지난 백업 = 그때의 원본
cp -a "$P/." "$B/"
echo "old" > "$B/2026-09/IMG_old1.jpg"; echo "old" > "$B/2026-09/IMG_old2.jpg"   # 원본에서 지운 사진
# 백업 이후의 변화
for i in 5 6 7; do mk "$P/2026-10/IMG_$i.jpg"; done
mkdir -p "$P/2026-11" && mk "$P/2026-11/IMG_1.jpg"
head -c 3000 /dev/urandom > "$P/2026-09/IMG_2.jpg"     # 보정한 사진 (내용·시각 변경)
chmod 600 "$P/2026-09/IMG_3.jpg"                       # 비공개로 바꾼 사진
give "$P"; chown -R "$LEARNER:$LEARNER" /mnt/backup
