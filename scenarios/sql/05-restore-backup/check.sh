#!/usr/bin/env bash
source /opt/cmdlab/lib/helpers.sh
DB="$H/shop.db"
q() { sqlite3 -noheader -list "$DB" "$1" 2>/dev/null; }
got=$(q "SELECT * FROM customers ORDER BY id;")
want=$(cat /opt/cmdlab/secret/expected)
if [ "$got" = "$want" ]; then pass "customers 가 사고 직전 상태와 똑같다"
else
  fail "customers 가 사고 직전 상태와 똑같다 (지금 $(q 'SELECT COUNT(*) FROM customers;')명, 기대 $(echo "$want" | wc -l)명)"
fi
expect "오늘 가입한 고객(22, 23)이 남아 있다" test "$(q 'SELECT COUNT(*) FROM customers WHERE id IN (22, 23);')" = 2
expect "오늘 수정한 이메일(new_...)이 남아 있다" test "$(q "SELECT COUNT(*) FROM customers WHERE email LIKE 'new_%';")" = 1
expect "부산 고객이 모두 돌아왔다" test "$(q "SELECT COUNT(*) FROM customers WHERE city = '부산';")" = "$(sqlite3 -noheader -list /opt/cmdlab/secret/before.db "SELECT COUNT(*) FROM customers WHERE city = '부산';")"
expect "백업 파일은 그대로다" test "$(sqlite3 "$H/backup/shop-nightly.db" 'SELECT COUNT(*) FROM customers;')" = 20
finish
