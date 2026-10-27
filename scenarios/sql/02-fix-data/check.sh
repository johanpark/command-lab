#!/usr/bin/env bash
source /opt/cmdlab/lib/helpers.sh
DB="$H/shop.db"; E=/opt/cmdlab/secret/expected.db
dump() { sqlite3 -noheader -list "$1" "$2"; }
same() { [ "$(dump "$DB" "$1")" = "$(dump "$E" "$1")" ]; }
expect "oldmail.com 이메일이 남아 있지 않다" test "$(dump "$DB" "SELECT COUNT(*) FROM customers WHERE email LIKE '%@oldmail.com';")" = 0
expect "cancelled 주문이 남아 있지 않다" test "$(dump "$DB" "SELECT COUNT(*) FROM orders WHERE status = 'cancelled';")" = 0
t=$(secret_get target)
expect "요청한 고객(id $t)의 도시가 제주다" test "$(dump "$DB" "SELECT city FROM customers WHERE id = $t;")" = 제주
if same "SELECT * FROM customers ORDER BY id;"; then pass "customers 테이블의 다른 데이터는 그대로다"
else
  n=$(dump "$DB" "SELECT COUNT(*) FROM customers WHERE city = '제주';")
  fail "customers 테이블의 다른 데이터는 그대로다 (제주 고객이 ${n}명? WHERE 를 확인하세요)"
fi
if same "SELECT * FROM orders ORDER BY id;"; then pass "orders 테이블의 다른 주문은 그대로다"
else fail "orders 테이블의 다른 주문은 그대로다 (주문 $(dump "$DB" "SELECT COUNT(*) FROM orders;")건, 기대 $(dump "$E" "SELECT COUNT(*) FROM orders;")건)"; fi
expect "products 테이블은 그대로다" same "SELECT * FROM products ORDER BY id;"
finish
