# 설명: docker system prune -a 로 한 번에 지우면 보관용 이미지까지 사라진다
# 실패해야: backup-tool:1.0
docker system prune -a -f --volumes > /dev/null
docker volume prune -a -f > /dev/null
