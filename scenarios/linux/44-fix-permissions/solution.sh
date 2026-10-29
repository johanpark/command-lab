find /srv/www -type d -exec chmod 755 {} +
find /srv/www -type f -exec chmod 644 {} +
chmod 755 /srv/www/bin/*.sh
chmod 640 /srv/www/config/secret.php
