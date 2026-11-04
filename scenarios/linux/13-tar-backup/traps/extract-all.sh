# 설명: 백업을 통째로 풀면 백업 뒤에 고친 파일까지 옛날 내용으로 덮인다
# 실패해야: 최신 상태 그대로
tar -xzf ~/backups/project-2026-10-20.tar.gz -C ~
tar -czf ~/backups/project-today.tar.gz --exclude=node_modules -C ~ project
