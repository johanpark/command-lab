#!/usr/bin/env bash
source /opt/cmdlab/lib/helpers.sh
set -e
S="$H/services"
mkdir -p "$S"
svc=(billing orders users search notify)
for s in "${svc[@]}"; do
  mkdir -p "$S/$s"
  {
    echo "[app]"
    echo "name = $s"
    echo "port = $(rand_int 8000 8999)"
    case $(rand_int 1 3) in 1) echo "debug = true";; 2) echo "debug=true";; 3) echo "debug  =  true";; esac
    echo
    echo "[database]"
    echo "host = old-db.internal"
    echo "port = 5432"
    echo "replica = old-db.internal:5433, old-db.internal:5434"
    echo "# 장애 대응 문서: https://wiki.local/old-db.internal"
    echo
    echo "[log]"
    echo "debug_sql = true"
  } > "$S/$s/config.ini"
done
# 하위 폴더가 더 깊은 서비스, debug=false 가 이미 있는 서비스
mkdir -p "$S/legacy/batch/conf"
printf '[app]\nname = batch\ndebug = false\n\n[database]\nhost = old-db.internal\n' > "$S/legacy/batch/conf/config.ini"
printf 'old-db.internal 은 2026-10-31 에 종료됩니다.\n' > "$S/README.txt"
give "$S"
# 기대 결과 저장
rm -rf /opt/cmdlab/secret/expected && mkdir -p /opt/cmdlab/secret/expected
( cd "$S" && find . -name config.ini ) | while read -r f; do
  mkdir -p "/opt/cmdlab/secret/expected/$(dirname "$f")"
  sed -e 's/old-db\.internal/new-db.internal/g' -e 's/^debug *= *true$/debug = false/' "$S/$f" > "/opt/cmdlab/secret/expected/$f"
done
