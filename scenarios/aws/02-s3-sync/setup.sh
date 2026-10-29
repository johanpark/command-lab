#!/usr/bin/env bash
source /opt/cmdlab/lib/helpers.sh
source /usr/local/lib/lab-aws.sh
set -e
wait_aws
sfx=$(rand_int 1000 9999); B="shop-backups-$sfx"; W="shop-website-$sfx"
secret_set backups "$B"; secret_set website "$W"
aws s3 mb "s3://$B" >/dev/null; aws s3 mb "s3://$W" >/dev/null
printf '%s\n%s\n' "$B" "$W" > "$H/buckets.txt"
# 백업 버킷에는 지난 백업이 이미 있다 (건드리면 안 됨)
T=$(mktemp -d); echo "old dump" > "$T/dump.sql.gz"
aws s3 cp "$T/dump.sql.gz" "s3://$B/db/2026-10-28/dump.sql.gz" >/dev/null
# 오늘 백업
D="$H/backup/db-2026-10-29"; rm -rf "$H/backup"; mkdir -p "$D"
head -c 30000 /dev/urandom > "$D/dump.sql.gz"; echo "CREATE TABLE orders (...);" > "$D/schema.sql"
echo "$(date +%F) nightly backup, rows=$(rand_int 10000 99999)" > "$D/MANIFEST.txt"
# 웹사이트: 버킷에는 옛 버전이 올라가 있다
S="$H/site"; rm -rf "$S"; mkdir -p "$S"/{css,img,drafts}
echo "<h1>shop $(rand_int 2 9).0</h1>" > "$S/index.html"; echo "<h1>about</h1>" > "$S/about.html"
echo "body{color:#333}" > "$S/css/site.css"; head -c 3000 /dev/urandom > "$S/img/logo.png"
echo "<h1>WIP 블랙프라이데이</h1>" > "$S/drafts/black-friday.html"
O=$(mktemp -d); mkdir -p "$O"/{css,img}
echo "<h1>shop 1.0</h1>" > "$O/index.html"; echo "<h1>about</h1>" > "$O/about.html"; echo "body{}" > "$O/css/site.css"
echo "<h1>여름 세일</h1>" > "$O/summer-sale.html"; head -c 2000 /dev/urandom > "$O/img/summer-banner.png"; head -c 3000 /dev/urandom > "$O/img/logo.png"
aws s3 sync "$O/" "s3://$W/" >/dev/null
# 로컬 사이트가 버킷의 옛 버전보다 확실히 새 파일이 되게 (sync 는 크기·수정 시각으로 비교한다)
sleep 1; find "$S" -type f -exec touch {} +
give "$H/backup" "$S" "$H/buckets.txt"
(cd "$D" && md5sum *) | awk '{print "db/2026-10-29/" $2, $1}' | sort > /opt/cmdlab/secret/backup
(cd "$S" && find . -type f ! -path './drafts/*' -exec md5sum {} +) | awk '{sub("^\\./", "", $2); print $2, $1}' | sort > /opt/cmdlab/secret/site
