#!/usr/bin/env bash
source /opt/cmdlab/lib/helpers.sh
set -e
B="$H/backup"; mkdir -p "$B"
cat > "$B/long-backup.sh" <<'SH'
#!/bin/bash
# 30분쯤 걸리는 백업 (실습용: 실제로는 기다리기만 해요)
echo "$(date '+%F %T') 백업 시작"
for i in $(seq 1 900); do
  sleep 2
  [ $((i % 5)) -eq 0 ] && echo "$(date '+%F %T') 진행 $((i * 100 / 900))% ($((i * 37)) MB)"
done
echo "$(date '+%F %T') 백업 완료"
SH
chmod +x "$B/long-backup.sh"
give "$B"
