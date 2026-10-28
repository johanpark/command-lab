`chmod -R 755 /srv/www` 로 한 번에 하면 **모든 파일에 실행 권한(x)** 이 붙어요. 반대로 `chmod -R 644` 를 하면 폴더에 x 가 없어져서 **아무도 폴더에 들어갈 수 없어요.** 폴더와 파일은 따로 해야 해요.
---
폴더만: `find /srv/www -type d -exec chmod 755 {} +` / 파일만: `find /srv/www -type f -exec chmod 644 {} +`
---
그다음 예외: `chmod 755 /srv/www/bin/*.sh`, `chmod 640 /srv/www/config/secret.php`. **순서가 중요해요.** 예외를 먼저 하고 644 를 나중에 하면 다시 덮어써요.
---
확인: `find /srv/www -exec stat -c '%a %n' {} +` 로 전체를 훑어보세요. 777 이 하나도 없어야 해요.
