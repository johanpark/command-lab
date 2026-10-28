#!/usr/bin/env bash
source /opt/cmdlab/lib/helpers.sh
set -e
DB="$H/members.db"
rm -f "$DB"
{
cat <<'SQL'
CREATE TABLE members (id INTEGER PRIMARY KEY, name TEXT, email TEXT, joined TEXT);
CREATE TABLE orders  (id INTEGER PRIMARY KEY, member_id INTEGER, amount INTEGER, ordered_at TEXT);
SQL
awk -v seed="$RANDOM" -v q="'" 'BEGIN {
  srand(seed)
  split("김민수 이지은 박서준 최유나 정하늘 강도윤 조수아 윤지호 장예린 임태양 한소율 오준서 서다인 신우진 권나래 황시우 안채원 송민재 류하린 홍지안 문가온 배서윤 백도현 남궁별 유채린 전하람 고은우 노지성 하예준 구다은", nm, " ")
  for (i = 1; i <= 30; i++) {
    email[i] = "user" i "@" (rand() < 0.5 ? "gmail.com" : "naver.com")
    joined[i] = sprintf("2026-%02d-%02d", 1 + int(rand() * 9), 1 + int(rand() * 28))
    printf "INSERT INTO members VALUES (%d, " q "%s" q ", " q "%s" q ", " q "%s" q ");\n", i, nm[i], email[i], joined[i]
  }
  # 중복 가입 (같은 이메일, 같은 날)
  k = 3 + int(rand() * 3); id = 30
  for (j = 1; j <= k; j++) {
    o = 1 + int(rand() * 30); while (o in used) o = 1 + int(rand() * 30); used[o] = 1
    times = (j == 1) ? 2 : 1
    for (t = 1; t <= times; t++) {
      id++; dup[++nd] = id
      printf "INSERT INTO members VALUES (%d, " q "%s" q ", " q "%s" q ", " q "%s" q ");\n", id, nm[o], email[o], joined[o]
    }
  }
  oid = 0
  for (j = 1; j <= nd; j++)  # 중복 계정마다 주문 1건 이상
    printf "INSERT INTO orders VALUES (%d, %d, %d, " q "2026-10-%02d" q ");\n", ++oid, dup[j], 1000 * (5 + int(rand() * 95)), 1 + int(rand() * 27)
  for (i = 1; i <= 60; i++)
    printf "INSERT INTO orders VALUES (%d, %d, %d, " q "2026-10-%02d" q ");\n", ++oid, 1 + int(rand() * id), 1000 * (5 + int(rand() * 95)), 1 + int(rand() * 27)
}'
} | sqlite3 "$DB"
give "$DB"
q() { sqlite3 -noheader -list "$DB" "$1"; }
secret_set dups "$(q 'SELECT COUNT(*) - COUNT(DISTINCT email) FROM members;')"
q 'SELECT COUNT(*) FROM orders;' > /opt/cmdlab/secret/norders
E=/opt/cmdlab/secret/expected.db
cp "$DB" "$E"
sqlite3 "$E" "
UPDATE orders SET member_id = (SELECT MIN(m2.id) FROM members m2 WHERE m2.email = (SELECT email FROM members m1 WHERE m1.id = orders.member_id));
DELETE FROM members WHERE id NOT IN (SELECT MIN(id) FROM members GROUP BY email);"
