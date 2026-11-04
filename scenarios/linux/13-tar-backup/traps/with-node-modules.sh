# 설명: --exclude 를 빼면 새 백업에 node_modules 가 들어간다
# 실패해야: node_modules 가 없다
tar -xzf ~/backups/project-2026-10-20.tar.gz -C ~ project/src/config.js
tar -czf ~/backups/project-today.tar.gz -C ~ project
