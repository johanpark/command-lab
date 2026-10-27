#!/usr/bin/env bash
source /opt/cmdlab/lib/helpers.sh
set -e
gawk -v seed="$RANDOM" 'BEGIN {
  srand(seed)
  n = split("음료:콜라:1800 음료:생수:900 음료:커피우유:1500 과자:감자칩:1700 과자:초코과자:2200 라면:컵라면:1300 라면:봉지라면:950 생활용품:물티슈:2500 생활용품:건전지:4500 냉동식품:만두:6900 냉동식품:아이스크림:1200", items, " ")
  print "date,category,item,qty,unit_price"
  for (i = 0; i < 250; i++) {
    split(items[1 + int(rand() * n)], p, ":")
    printf "2026-10-%02d,%s,%s,%d,%d\n", 1 + int(rand() * 28), p[1], p[2], 1 + int(rand() * 12), p[3]
  }
}' > "$H/sales.csv"
give "$H/sales.csv"
gawk -F, 'NR > 1 { s[$2] += $4 * $5 } END { for (c in s) print c, s[c] }' "$H/sales.csv" | sort -k2 -nr > /opt/cmdlab/secret/report
gawk -F, 'NR > 1 { q[$3] += $4 } END { for (i in q) print q[i], i }' "$H/sales.csv" | sort -nr > /opt/cmdlab/secret/qty
# 수량 1등이 동점이면 다시 만들게 하지 않고, 동점 상품 모두 정답으로 인정한다
