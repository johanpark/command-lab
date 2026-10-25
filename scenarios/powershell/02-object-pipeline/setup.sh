#!/usr/bin/env bash
source /opt/cmdlab/lib/helpers.sh
set -e
awk -v seed="$RANDOM" 'BEGIN {
  srand(seed)
  split("서울 부산 대구 인천 광주", region, " ")
  split("키보드 마우스 모니터 노트북 헤드셋 웹캠", product, " ")
  split("90 40 450 1800 150 80", base, " ")
  print "id,date,region,product,amount"
  for (i = 0; i < 120; i++) {
    p = 1 + int(rand() * 6)
    r = 1 + int(rand() * 5)
    a = int(base[p] * (0.6 + rand() * 0.8))
    printf "%d,2026-10-%02d,%s,%s,%d\n", 1001 + i, 1 + int(rand() * 28), region[r], product[p], a
  }
}' > "$H/sales.csv"
give "$H/sales.csv"
tail -n +2 "$H/sales.csv" | awk -F, '{ s[$3] += $5 } END { for (r in s) print s[r], r }' | sort -rn | head -n 1 | awk '{print $2}' > /opt/cmdlab/secret/top
tail -n +2 "$H/sales.csv" | awk -F, '$5 >= 500 { print $1 }' | sort > /opt/cmdlab/secret/big-ids
