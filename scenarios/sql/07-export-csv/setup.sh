#!/usr/bin/env bash
source /opt/cmdlab/lib/helpers.sh
set -e
DB="$H/shop.db"; rm -f "$DB" "$H/report.csv"
{
echo "CREATE TABLE orders (id INTEGER PRIMARY KEY, customer TEXT, amount INTEGER, status TEXT, ordered_at TEXT);"
awk -v seed="$RANDOM" -v q="'" 'BEGIN {
  srand(seed)
  split("kim lee park choi jung kang cho yoon jang lim", cu, " ")
  split("paid paid paid paid paid paid cancelled refunded", st, " ")
  n = 300 + int(rand() * 200)
  for (i = 1; i <= n; i++) {
    m = 1 + int(rand() * 10); if (m == 6 && rand() < 0.9) m = 7   # 6월은 거의 없음
    printf "INSERT INTO orders VALUES (%d, " q "%s" q ", %d, " q "%s" q ", " q "2026-%02d-%02d %02d:%02d:%02d" q ");\n", \
      i, cu[1 + int(rand() * 10)], 1000 * (5 + int(rand() * 200)), st[1 + int(rand() * 8)], m, 1 + int(rand() * 28), int(rand() * 24), int(rand() * 60), int(rand() * 60)
  }
}'
} | sqlite3 "$DB"
give "$DB"
sqlite3 -csv -header "$DB" "SELECT strftime('%Y-%m', ordered_at) AS 월, COUNT(*) AS 주문수, SUM(amount) AS 매출 FROM orders WHERE status = 'paid' GROUP BY 월 ORDER BY 월;" | tr -d '\r' > /opt/cmdlab/secret/expected.csv
