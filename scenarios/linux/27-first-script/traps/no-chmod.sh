# 설명: chmod +x 를 빼먹으면 스크립트를 실행할 수 없다
# 실패해야: 실행 권한이 있다
mkdir -p ~/bin
cat > ~/bin/backup.sh <<'SCRIPT'
#!/usr/bin/env bash
[ -z "$1" ] && { echo "사용법: backup.sh <폴더>"; exit 1; }
[ -d "$1" ] || { echo "폴더 없음: $1"; exit 2; }
mkdir -p ~/backups
out=~/backups/$(basename "$1")-$(date +%Y%m%d).tar.gz
tar -czf "$out" -C "$(dirname "$1")" "$(basename "$1")" && echo "$out"
SCRIPT
