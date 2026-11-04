# 설명: chmod -R 755 로 한 번에 하면 모든 파일에 실행 권한이 붙는다
# 실패해야: 일반 파일이 모두 644
chmod -R 755 /srv/www
chmod 640 /srv/www/config/secret.php
