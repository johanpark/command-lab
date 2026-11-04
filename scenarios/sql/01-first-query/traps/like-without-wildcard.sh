# 설명: LIKE '2026-10' 처럼 % 를 빼면 정확히 그 글자만 찾아 0 건이 된다
# 실패해야: 2026년 10월 주문 수
cd ~
sqlite3 shop.db "SELECT COUNT(*) FROM customers WHERE city = '서울';" > ~/answer.txt
sqlite3 shop.db "SELECT name FROM products ORDER BY price DESC LIMIT 1;" > ~/expensive.txt
sqlite3 shop.db "SELECT COUNT(*) FROM orders WHERE ordered_at LIKE '2026-10';" > ~/october.txt
