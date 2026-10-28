#!/usr/bin/env bash
source /opt/cmdlab/lib/helpers.sh
set -e
DB="$H/shop.db"; BK="$H/backup/shop-20261027.db"
rm -f "$DB"; rm -rf "$H/backup"; mkdir -p "$H/backup"
# 1) 어젯밤까지의 상태를 만들고 백업
{
cat <<'SQL'
CREATE TABLE orders (id INTEGER PRIMARY KEY, customer TEXT, amount INTEGER, status TEXT, ordered_at TEXT, shipped_at TEXT);
CREATE TABLE order_events (id INTEGER PRIMARY KEY, order_id INTEGER, event TEXT, at TEXT);
SQL
awk -v seed="$RANDOM" -v q="'" 'BEGIN {
  srand(seed)
  split("kim lee park choi jung kang cho yoon jang lim han oh", cu, " ")
  ev = 0
  for (i = 1; i <= 180; i++) {
    day = 1 + int((i - 1) / 7)                     # 10월 1일 ~ 26일에 고르게
    od = sprintf("2026-10-%02d %02d:%02d:00", day, 9 + int(rand() * 10), int(rand() * 60))
    r = rand(); st = "shipped"; sh = "NULL"
    if (i > 150 && r < 0.5) st = "paid"            # 최근 주문 일부는 아직 출고 전
    else if (r < 0.06) st = "cancelled"
    if (st == "shipped") {
      sd = day + 1 + int(rand() * 2); if (sd > 27) sd = 27
      sh = sprintf(q "2026-10-%02d %02d:%02d:00" q, sd, 10 + int(rand() * 8), int(rand() * 60))
      if (sd >= 26) printf "INSERT INTO order_events VALUES (%d, %d, " q "shipped" q ", %s);\n", ++ev, i, sh
    }
    printf "INSERT INTO orders VALUES (%d, " q "%s" q ", %d, " q "%s" q ", " q "%s" q ", %s);\n", i, cu[1 + int(rand() * 12)], 1000 * (5 + int(rand() * 300)), st, od, sh
  }
}'
} | sqlite3 "$DB"
cp "$DB" "$BK"
# 2) 오늘(10/28) 오전~오후 2시까지의 정상 변경
q() { sqlite3 "$DB" "$1"; }
ev=$(q "SELECT MAX(id) FROM order_events;")
# 어제 결제된 주문 중 일부가 오늘 출고
for id in $(q "SELECT id FROM orders WHERE status = 'paid' ORDER BY RANDOM() LIMIT $(rand_int 5 9);"); do
  t="2026-10-28 $(printf '%02d:%02d:00' $(rand_int 9 13) $(rand_int 0 59))"; ev=$((ev + 1))
  q "UPDATE orders SET status = 'shipped', shipped_at = '$t' WHERE id = $id; INSERT INTO order_events VALUES ($ev, $id, 'shipped', '$t');"
done
# 일부는 취소
q "UPDATE orders SET status = 'cancelled' WHERE id IN (SELECT id FROM orders WHERE status = 'paid' ORDER BY RANDOM() LIMIT 2);"
# 오늘 새 주문 (대부분 출고 전, 몇 개는 바로 출고)
for i in $(seq 181 $((180 + $(rand_int 12 20)))); do
  t="2026-10-28 $(printf '%02d:%02d:00' $(rand_int 8 12) $(rand_int 0 59))"
  if [ $((RANDOM % 4)) -eq 0 ]; then
    s="2026-10-28 $(printf '%02d:%02d:00' 13 $(rand_int 0 59))"; ev=$((ev + 1))
    q "INSERT INTO orders VALUES ($i, 'web', $(rand_int 5 300)000, 'shipped', '$t', '$s'); INSERT INTO order_events VALUES ($ev, $i, 'shipped', '$s');"
  else
    q "INSERT INTO orders VALUES ($i, 'web', $(rand_int 5 300)000, 'paid', '$t', NULL);"
  fi
done
# 물류 시스템이 상태만 shipped 로 바꾸고 시각을 못 남긴 주문 (사람이 넣어야 함)
target=$(q "SELECT id FROM orders WHERE status = 'paid' ORDER BY RANDOM() LIMIT 1;")
q "UPDATE orders SET status = 'shipped' WHERE id = $target;"
secret_set target "$target"
# 이벤트 로그는 최근 3일치만 (10/26 이후)
q "DELETE FROM order_events WHERE at < '2026-10-26';"
# 3) 정답 = 사고 직전 상태 + 원래 하려던 UPDATE
cp "$DB" /opt/cmdlab/secret/expected.db
sqlite3 /opt/cmdlab/secret/expected.db "UPDATE orders SET shipped_at = '2026-10-28 14:05:00' WHERE id = $target;"
# 4) 사고
q "UPDATE orders SET shipped_at = '2026-10-28 14:05:00';"
cat > "$H/incident.txt" <<TXT
[장애 보고] orders.shipped_at 일괄 변경 사고

14:05  물류팀 요청: "주문 $target 번은 출고됐는데 시스템에 출고 시각이 안 남았어요.
       2026-10-28 14:05:00 으로 넣어 주세요."
14:06  운영 DB 에서 실행:
         UPDATE orders SET shipped_at = '2026-10-28 14:05:00';
       → WHERE 절 누락. orders 의 모든 행이 바뀜.
14:07  쓰기 중단, 복구 시작

참고
- 백업: ~/backup/shop-20261027.db (어젯밤 23:00, 매일 자동)
- order_events: 앱이 출고(shipped) 등 이벤트를 남기는 테이블. 최근 3일치만 보관.
- 오늘 사고 전까지 새 주문과 상태 변경이 계속 있었음 (백업 이후 변경분).
TXT
give "$DB" "$H/backup" "$H/incident.txt"
