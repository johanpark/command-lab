# 설명: 비밀 설정을 600 으로 막으면 웹 서버(www-data 그룹)도 못 읽는다
# 실패해야: 웹 서버(www-data)가
# 실패해야: secret.php 는 640
find /srv/www -type d -exec chmod 755 {} +
find /srv/www -type f -exec chmod 644 {} +
chmod 755 /srv/www/bin/*.sh
chmod 600 /srv/www/config/secret.php
