`id learner` 로 지금 소속 그룹을 확인하고, `ls -ld /srv/website` 로 폴더 상태를 보세요.
---
`sudo useradd -m -s /bin/bash kim` → `sudo groupadd webdev` → `id kim` 으로 확인
---
⚠️ `usermod -G webdev learner` 는 learner 의 보조 그룹을 **webdev 하나로 덮어써서** designers 에서 빠져요. 반드시 `-aG` (append)! `sudo usermod -aG webdev learner`, `sudo usermod -aG webdev kim`
---
`sudo chgrp webdev /srv/website` → `sudo chmod 2770 /srv/website`. 맨 앞 `2` 가 setgid, `770` 이 rwx/rwx/---. `ls -ld` 에 `drwxrws---` 가 보이면 성공!
