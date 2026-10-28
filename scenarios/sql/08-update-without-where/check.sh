#!/usr/bin/env bash
source /opt/cmdlab/lib/helpers.sh
DB="$H/shop.db"; E=/opt/cmdlab/secret/expected.db; t=$(secret_get target)
q() { sqlite3 -noheader -list "$1" "$2" 2>/dev/null; }
cols="id, customer, amount, status, ordered_at"
if [ "$(q "$DB" "SELECT $cols FROM orders ORDER BY id;")" = "$(q "$E" "SELECT $cols FROM orders ORDER BY id;")" ]; then
  pass "오늘 들어온 주문과 오늘 바뀐 상태가 그대로다 (shipped_at 말고는 손대지 않았다)"
else
  fail "오늘 들어온 주문과 오늘 바뀐 상태가 그대로다 (지금 $(q "$DB" 'SELECT COUNT(*) FROM orders;')건, 기대 $(q "$E" 'SELECT COUNT(*) FROM orders;')건 — 백업을 통째로 덮어썼나요?)"
  finish
fi
# shipped_at 을 종류별로 비교
cmp() { # 설명 조건
  local bad
  bad=$(sqlite3 -noheader -list "$DB" "ATTACH '$E' AS e; SELECT COUNT(*) FROM orders o JOIN e.orders x ON x.id = o.id WHERE ($2) AND o.shipped_at IS NOT x.shipped_at;" 2>/dev/null)
  [ "$bad" = 0 ] && pass "$1" || fail "$1 (${bad:-?}건이 달라요)"
}
cmp "어제까지 출고된 주문의 출고 시각이 돌아왔다 (백업)" "x.shipped_at < '2026-10-28'"
cmp "오늘 출고된 주문의 출고 시각이 돌아왔다 (이벤트 로그)" "x.shipped_at >= '2026-10-28' AND x.id <> $t"
cmp "출고 전·취소 주문의 출고 시각이 비어 있다 (NULL)" "x.shipped_at IS NULL"
got=$(q "$DB" "SELECT shipped_at FROM orders WHERE id = $t;")
[ "$got" = "2026-10-28 14:05:00" ] && pass "원래 하려던 주문 $t 의 출고 시각이 들어갔다" || fail "원래 하려던 주문 $t 의 출고 시각이 들어갔다 (지금: ${got:-NULL})"
n=$(q "$DB" "SELECT COUNT(*) FROM orders WHERE shipped_at = '2026-10-28 14:05:00';")
[ "$n" = 1 ] && pass "'2026-10-28 14:05:00' 인 주문은 딱 하나다" || fail "'2026-10-28 14:05:00' 인 주문은 딱 하나다 (지금 ${n}건)"
expect "order_events 와 백업 파일은 그대로다" bash -c "[ \"\$(sqlite3 '$DB' 'SELECT COUNT(*) FROM order_events;')\" = \"\$(sqlite3 '$E' 'SELECT COUNT(*) FROM order_events;')\" ] && [ \"\$(sqlite3 '$H/backup/shop-20261027.db' 'SELECT COUNT(*) FROM orders;')\" = 180 ]"
finish
