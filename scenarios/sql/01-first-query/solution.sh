cd ~
sqlite3 shop.db "SELECT COUNT(*) FROM customers WHERE city = '서울';" > ~/answer.txt
sqlite3 shop.db "SELECT name FROM products ORDER BY price DESC LIMIT 1;" > ~/expensive.txt
sqlite3 shop.db "SELECT COUNT(*) FROM orders WHERE ordered_at LIKE '2026-10-%';" > ~/october.txt
