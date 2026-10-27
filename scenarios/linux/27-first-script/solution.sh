mkdir -p ~/bin
cat > ~/bin/backup.sh <<'SCRIPT'
#!/usr/bin/env bash
# 사용법: backup.sh <폴더>
if [ -z "$1" ]; then
  echo "사용법: backup.sh <폴더>"
  exit 1
fi
if [ ! -d "$1" ]; then
  echo "폴더 없음: $1"
  exit 2
fi
mkdir -p ~/backups
out=~/backups/$(basename "$1")-$(date +%Y%m%d).tar.gz
tar -czf "$out" -C "$(dirname "$1")" "$(basename "$1")"
echo "$out"
SCRIPT
chmod +x ~/bin/backup.sh
