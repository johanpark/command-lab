# 설명: 예외(스크립트·비밀 설정)를 먼저 하고 644 를 나중에 하면 예외가 덮인다
# 실패해야: bin/*.sh 는 755
chmod 755 /srv/www/bin/*.sh
chmod 640 /srv/www/config/secret.php
find /srv/www -type d -exec chmod 755 {} +
find /srv/www -type f -exec chmod 644 {} +
