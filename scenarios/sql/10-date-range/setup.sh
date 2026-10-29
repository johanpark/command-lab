#!/usr/bin/env bash
source /opt/cmdlab/lib/helpers.sh
set -e
DB="$H/shop.db"; rm -f "$DB"
{
echo "CREATE TABLE payments (id INTEGER PRIMARY KEY, order_id INTEGER, amount INTEGER, paid_at TEXT);"
awk -v seed="$RANDOM" -v q="'" 'BEGIN {
  srand(seed); id = 0
  # 9월 말 ~ 11월 초, 10월 31일은 행사라 결제가 몰림
  for (d = 25; d <= 30; d++) for (k = 0; k < 6 + int(rand() * 6); k++) row(9, d)
  for (d = 1; d <= 31; d++) { n = (d == 31) ? 40 + int(rand() * 20) : 8 + int(rand() * 8); for (k = 0; k < n; k++) row(10, d) }
  for (d = 1; d <= 3; d++) for (k = 0; k < 6 + int(rand() * 6); k++) row(11, d)
  # 경계: 9/30 23:59, 10/1 00:00:00, 10/31 23:59:59, 11/1 00:00:00
  edge("2026-09-30 23:59:58"); edge("2026-10-01 00:00:00"); edge("2026-10-31 23:59:59"); edge("2026-11-01 00:00:00")
}
function row(m, d) { printf "INSERT INTO payments VALUES (%d, %d, %d, " q "2026-%02d-%02d %02d:%02d:%02d" q ");\n", ++id, 5000 + id, 1000 * (5 + int(rand() * 200)), m, d, int(rand() * 24), int(rand() * 60), int(rand() * 60) }
function edge(t) { printf "INSERT INTO payments VALUES (%d, %d, %d, " q "%s" q ");\n", ++id, 5000 + id, 1000 * (5 + int(rand() * 200)), t }'
} | sqlite3 "$DB"
cat > "$H/report.sql" <<'SQL'
-- 10월 매출 보고서 (작성: 전 담당자)
SELECT COUNT(*) AS 건수, SUM(amount) AS 합계 FROM payments
WHERE paid_at BETWEEN '2026-10-01' AND '2026-10-31';
SQL
give "$DB" "$H/report.sql"
q() { sqlite3 -noheader -list "$DB" "$1"; }
secret_set count "$(q "SELECT COUNT(*) FROM payments WHERE paid_at >= '2026-10-01' AND paid_at < '2026-11-01';")"
secret_set total "$(q "SELECT SUM(amount) FROM payments WHERE paid_at >= '2026-10-01' AND paid_at < '2026-11-01';")"
