#!/usr/bin/env bash
source /opt/cmdlab/lib/helpers.sh
set -e
DB="$H/shop.db"
rm -f "$DB"
{
cat <<'SQL'
CREATE TABLE customers (id INTEGER PRIMARY KEY, name TEXT, city TEXT, email TEXT, joined TEXT);
CREATE TABLE products  (id INTEGER PRIMARY KEY, name TEXT, category TEXT, price INTEGER);
CREATE TABLE orders    (id INTEGER PRIMARY KEY, customer_id INTEGER, product_id INTEGER, qty INTEGER, status TEXT, ordered_at TEXT);
SQL
awk -v seed="$RANDOM" -v q="'" 'BEGIN {
  srand(seed)
  split("김민수 이지은 박서준 최유나 정하늘 강도윤 조수아 윤지호 장예린 임태양 한소율 오준서 서다인 신우진 권나래 황시우 안채원 송민재 류하린 홍지안", nm, " ")
  split("서울 서울 서울 부산 대구 인천 광주 대전 서울 부산", city, " ")
  split("gmail.com naver.com oldmail.com daum.net", dom, " ")
  for (i = 1; i <= 20; i++)
    printf "INSERT INTO customers VALUES (%d, " q "%s" q ", " q "%s" q ", " q "user%d@%s" q ", " q "2025-%02d-%02d" q ");\n", i, nm[i], city[1 + int(rand() * 10)], i, dom[1 + int(rand() * 4)], 1 + int(rand() * 12), 1 + int(rand() * 28)
  n = split("노트북:전자기기:1290000 모니터:전자기기:329000 키보드:전자기기:89000 마우스:전자기기:39000 USB케이블:전자기기:9900 텀블러:생활:25000 우산:생활:18000 수첩:문구:6500 볼펜세트:문구:12000 백팩:패션:79000", pr, " ")
  for (i = 1; i <= n; i++) {
    split(pr[i], p, ":")
    price = p[3] + int(rand() * 10) * 1000
    printf "INSERT INTO products VALUES (%d, " q "%s" q ", " q "%s" q ", %d);\n", i, p[1], p[2], price
  }
  split("paid paid paid shipped shipped cancelled", st, " ")
  for (i = 1; i <= 80; i++)
    printf "INSERT INTO orders VALUES (%d, %d, %d, %d, " q "%s" q ", " q "2026-%02d-%02d" q ");\n", i, 1 + int(rand() * 20), 1 + int(rand() * n), 1 + int(rand() * 3), st[1 + int(rand() * 6)], 8 + int(rand() * 3), 1 + int(rand() * 28)
}'
} | sqlite3 "$DB"
give "$DB"
q() { sqlite3 -noheader -list "$DB" "$1"; }
# 어젯밤 백업
mkdir -p "$H/backup"; sqlite3 "$DB" ".backup '$H/backup/shop-nightly.db'"
# 오늘 낮: 새 고객 가입 + 기존 고객 정보 수정
sqlite3 "$DB" "
INSERT INTO customers VALUES (21, '노하은', '부산', 'user21@gmail.com', '2026-10-27');
INSERT INTO customers VALUES (22, '문지성', '서울', 'user22@naver.com', '2026-10-27');
INSERT INTO customers VALUES (23, '배서연', '대구', 'user23@daum.net', '2026-10-27');
UPDATE customers SET email = 'new_' || email WHERE id = (SELECT MIN(id) FROM customers WHERE city = '서울');"
# 사고: 부산 고객을 지워 버림 (오늘 가입한 부산 고객까지)
cp "$DB" /opt/cmdlab/secret/before.db
sqlite3 "$DB" "DELETE FROM customers WHERE city = '부산';"
# 정답: 사고 직전 상태
sqlite3 /opt/cmdlab/secret/before.db "SELECT * FROM customers ORDER BY id;" > /opt/cmdlab/secret/expected
give "$H/backup"
cat > "$H/incident.txt" <<'TXT'
장애 보고 (오늘 14:05)

- 정리 작업 중 실수로 실행된 SQL:
    DELETE FROM customers WHERE city = '부산';
- 백업: ~/backup/shop-nightly.db (어젯밤 0시)
- 백업 이후에도 가입·수정이 있었으니, 지금 DB 를 백업으로 통째로 덮어쓰면 안 됩니다.
TXT
give "$H/incident.txt"
