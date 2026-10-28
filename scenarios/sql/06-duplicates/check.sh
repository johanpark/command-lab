#!/usr/bin/env bash
source /opt/cmdlab/lib/helpers.sh
DB="$H/members.db"; E=/opt/cmdlab/secret/expected.db
q() { sqlite3 -noheader -list "$1" "$2" 2>/dev/null; }
expect_cell "answer.txt 에 지울 중복 회원 수를 적었다" "$(secret_get dups)"
n=$(q "$DB" 'SELECT COUNT(*) - COUNT(DISTINCT email) FROM members;')
[ "$n" = 0 ] && pass "같은 이메일 회원이 남아 있지 않다" || fail "같은 이메일 회원이 남아 있지 않다 (${n:-?}명 더 지워야 해요)"
expect "이메일마다 id 가 가장 작은 회원이 남았다" test "$(q "$DB" 'SELECT * FROM members ORDER BY id;')" = "$(q "$E" 'SELECT * FROM members ORDER BY id;')"
cnt=$(q "$DB" 'SELECT COUNT(*) FROM orders;')
[ "$cnt" = "$(cat /opt/cmdlab/secret/norders)" ] && pass "주문이 한 건도 사라지지 않았다" || fail "주문이 한 건도 사라지지 않았다 (지금 ${cnt}건, 원래 $(cat /opt/cmdlab/secret/norders)건)"
orphan=$(q "$DB" 'SELECT COUNT(*) FROM orders WHERE member_id NOT IN (SELECT id FROM members);')
[ "$orphan" = 0 ] && pass "주인 없는 주문이 없다" || fail "주인 없는 주문이 없다 (${orphan}건 — 회원을 지우기 전에 주문을 옮겼나요?)"
expect "중복 계정의 주문이 원래 계정으로 옮겨졌다" test "$(q "$DB" 'SELECT * FROM orders ORDER BY id;')" = "$(q "$E" 'SELECT * FROM orders ORDER BY id;')"
T=$(mktemp); cp "$DB" "$T"
if q "$T" 'SELECT 1;' >/dev/null && ! sqlite3 "$T" "INSERT INTO members (name, email, joined) SELECT name, email, joined FROM members LIMIT 1;" 2>/dev/null; then
  pass "email 에 UNIQUE 인덱스가 있어 같은 이메일로 다시 가입할 수 없다"
else fail "email 에 UNIQUE 인덱스가 있어 같은 이메일로 다시 가입할 수 없다 (CREATE UNIQUE INDEX)"; fi
rm -f "$T"
finish
