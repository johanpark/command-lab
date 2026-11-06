# 설명: INNER JOIN 으로는 주문 없는 고객이 아예 빠져서 0 명이 된다 (LEFT JOIN 필요)
# 실패해야: 주문한 적 없는 고객 수
cd ~
sqlite3 shop.db "SELECT c.name FROM orders o JOIN customers c ON c.id = o.customer_id JOIN products p ON p.id = o.product_id WHERE o.status != 'cancelled' GROUP BY c.id ORDER BY SUM(p.price * o.qty) DESC LIMIT 1;" > ~/answer.txt
sqlite3 shop.db "SELECT COUNT(*) FROM customers c JOIN orders o ON o.customer_id = c.id WHERE o.id IS NULL;" > ~/never.txt
sqlite3 shop.db "SELECT p.category FROM orders o JOIN products p ON p.id = o.product_id WHERE o.status != 'cancelled' GROUP BY p.category ORDER BY SUM(p.price * o.qty) DESC LIMIT 1;" > ~/category.txt
