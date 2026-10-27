#!/usr/bin/env bash
source /opt/cmdlab/lib/helpers.sh
set -e
groupadd -f designers
usermod -aG designers "$LEARNER"
mkdir -p /srv/website/{css,js}
echo "<h1>회사 홈페이지</h1>" > /srv/website/index.html
echo "body { margin: 0 }" > /srv/website/css/style.css
chown -R root:root /srv/website
chmod 755 /srv/website
id kim >/dev/null 2>&1 && userdel -r kim 2>/dev/null || true
getent group webdev >/dev/null && groupdel webdev || true
