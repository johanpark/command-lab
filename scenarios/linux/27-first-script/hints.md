`mkdir -p ~/bin && nano ~/bin/backup.sh` 로 시작하세요. 첫 줄은 `#!/usr/bin/env bash`. 저장 후 `chmod +x ~/bin/backup.sh`
---
인자 확인: `if [ -z "$1" ]; then echo "사용법: backup.sh <폴더>"; exit 1; fi`. 폴더 확인: `if [ ! -d "$1" ]; then echo "폴더 없음: $1"; exit 2; fi`
---
백업 만들기: `mkdir -p ~/backups`, `out=~/backups/$(basename "$1")-$(date +%Y%m%d).tar.gz`, `tar -czf "$out" -C "$(dirname "$1")" "$(basename "$1")"`, `echo "$out"`
---
테스트: `~/bin/backup.sh; echo $?` (1), `~/bin/backup.sh ~/없는폴더; echo $?` (2), `~/bin/backup.sh ~/projects/site; echo $?` (0), `tar -tzf ~/backups/site-*.tar.gz`
