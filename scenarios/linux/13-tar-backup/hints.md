먼저 `tar -tzf ~/backups/project-2026-10-20.tar.gz` 로 안에 뭐가 들었는지, 경로가 어떻게 생겼는지(`project/src/...`) 보세요.
---
아카이브 안의 경로가 `project/src/config.js` 라면, 홈(`~`)에서 그 경로만 지정해 풀면 원래 자리에 들어가요: `tar -xzf ~/backups/project-2026-10-20.tar.gz -C ~ project/src/config.js`
---
불안하면 임시 폴더에 풀어서 확인 후 복사해도 돼요: `mkdir /tmp/r && tar -xzf ... -C /tmp/r` → `cp /tmp/r/project/src/config.js ~/project/src/`
---
새 백업: `tar -czf ~/backups/project-today.tar.gz --exclude=node_modules -C ~ project` 그다음 `tar -tzf ~/backups/project-today.tar.gz | grep node_modules` 로 정말 빠졌는지 확인!
