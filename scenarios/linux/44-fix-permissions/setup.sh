#!/usr/bin/env bash
source /opt/cmdlab/lib/helpers.sh
set -e
W=/srv/www; rm -rf "$W"
mkdir -p "$W"/{public/css,public/js,public/img,uploads/2026/10,config,bin,logs}
echo "<h1>shop</h1>" > "$W/public/index.html"; echo "<h1>about</h1>" > "$W/public/about.html"
echo "body{}" > "$W/public/css/site.css"; echo "console.log(1)" > "$W/public/js/app.js"
head -c 2000 /dev/urandom > "$W/public/img/logo.png"
for i in $(seq 1 $(rand_int 3 6)); do head -c 3000 /dev/urandom > "$W/uploads/2026/10/photo$i.jpg"; done
echo "<?php \$db_password = 'p@ss$(rand_int 1000 9999)';" > "$W/config/secret.php"
echo "<?php \$site_name = 'shop';" > "$W/config/site.php"
printf '#!/bin/sh\necho deploy\n' > "$W/bin/deploy.sh"; printf '#!/bin/sh\necho backup\n' > "$W/bin/backup.sh"
echo "bin 의 스크립트 설명" > "$W/bin/README.txt"
echo "access log" > "$W/logs/access.log"
chown -R "$LEARNER:www-data" "$W"
chmod -R 777 "$W"
find "$W" -type f -exec md5sum {} + | sort -k2 > /opt/cmdlab/secret/md5
find "$W" | sort > /opt/cmdlab/secret/all
