# 설명: 사용법·오류를 출력만 하고 exit 코드를 지정하지 않으면 0 으로 끝난다
# 실패해야: 종료 코드 1
# 실패해야: 종료 코드 2
mkdir -p ~/bin
cat > ~/bin/backup.sh <<'SCRIPT'
#!/usr/bin/env bash
if [ -z "$1" ]; then echo "사용법: backup.sh <폴더>"; exit; fi
if [ ! -d "$1" ]; then echo "폴더 없음: $1"; exit; fi
mkdir -p ~/backups
out=~/backups/$(basename "$1")-$(date +%Y%m%d).tar.gz
tar -czf "$out" -C "$(dirname "$1")" "$(basename "$1")"
echo "$out"
SCRIPT
chmod +x ~/bin/backup.sh
