# 설명: ORDER BY price 만 쓰면 오름차순이라 가장 싼 상품이 나온다
# 실패해야: 가장 비싼 상품
cd ~
sqlite3 shop.db "SELECT COUNT(*) FROM customers WHERE city = '서울';" > ~/answer.txt
sqlite3 shop.db "SELECT name FROM products ORDER BY price LIMIT 1;" > ~/expensive.txt
sqlite3 shop.db "SELECT COUNT(*) FROM orders WHERE ordered_at LIKE '2026-10-%';" > ~/october.txt
