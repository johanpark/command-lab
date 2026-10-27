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
q "SELECT COUNT(*) FROM customers WHERE city = '서울';" > /opt/cmdlab/secret/seoul
q "SELECT name FROM products ORDER BY price DESC LIMIT 1;" > /opt/cmdlab/secret/expensive
q "SELECT COUNT(*) FROM orders WHERE ordered_at LIKE '2026-10-%';" > /opt/cmdlab/secret/october
# 정답 상태: 원본 DB 사본에 올바른 수정을 적용해 둔다
target=$(q "SELECT id FROM customers ORDER BY RANDOM() LIMIT 1;")
secret_set target "$target"
secret_set target_name "$(q "SELECT name FROM customers WHERE id = $target;")"
cp "$DB" /opt/cmdlab/secret/expected.db
sqlite3 /opt/cmdlab/secret/expected.db "
  UPDATE customers SET email = REPLACE(email, '@oldmail.com', '@newmail.com') WHERE email LIKE '%@oldmail.com';
  DELETE FROM orders WHERE status = 'cancelled';
  UPDATE customers SET city = '제주' WHERE id = $target;"
printf '고객 이사 요청\n\n- 고객 번호(id): %s\n- 이름: %s\n- 새 주소: 제주\n' "$target" "$(secret_get target_name)" > "$H/request.txt"
give "$H/request.txt"
