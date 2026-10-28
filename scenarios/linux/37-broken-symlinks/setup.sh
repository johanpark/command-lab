#!/usr/bin/env bash
source /opt/cmdlab/lib/helpers.sh
set -e
S="$H/site"
rm -rf "$S"; mkdir -p "$S"/{releases/v2,releases/v3,shared,assets/img,logs} /srv/uploads
echo "v2" > "$S/releases/v2/index.html"; echo "v3" > "$S/releases/v3/index.html"
echo "db: main" > "$S/shared/config.yml"
echo "photo" > /srv/uploads/a.jpg
for i in 1 2 3 4; do echo "img$i" > "$S/assets/img/banner$i.png"; done
echo "log" > "$S/logs/2026-10-27.log"
cd "$S"
# 정상 링크
ln -s releases/v3 current
ln -s releases/v2 previous
ln -s ../../shared/config.yml releases/v3/config.yml
ln -s logs/2026-10-27.log latest.log
ln -s img/banner1.png assets/hero.png
# 깨진 링크
ln -s /mnt/old-nfs/uploads releases/v3/uploads
ln -s releases/v1 legacy
ln -s legacy old              # 깨진 링크를 가리키는 링크
ln -s /etc/app/env.prod .env  # 숨김
ln -s ../shared/robots.txt releases/robots.txt
n=$(rand_int 2 4)
for i in $(seq 1 "$n"); do ln -s "img/promo$i.png" "assets/promo$i.png"; done
secret_set count $((5 + n))
find "$S" -type l ! -xtype l -printf '%P\t%l\n' | sort > /opt/cmdlab/secret/good
find "$S" -type f -printf '%P\n' | sort > /opt/cmdlab/secret/files
give "$S"
