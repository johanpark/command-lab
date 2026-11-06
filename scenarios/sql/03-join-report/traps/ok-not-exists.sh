# 설명: 주문 없는 고객을 NOT EXISTS 로 세도 맞는 풀이다
# 통과해야
cd ~
sqlite3 shop.db "SELECT c.name FROM orders o JOIN customers c ON c.id = o.customer_id JOIN products p ON p.id = o.product_id WHERE o.status != 'cancelled' GROUP BY c.id ORDER BY SUM(p.price * o.qty) DESC LIMIT 1;" > ~/answer.txt
sqlite3 shop.db "SELECT COUNT(*) FROM customers c WHERE NOT EXISTS (SELECT 1 FROM orders o WHERE o.customer_id = c.id);" > ~/never.txt
sqlite3 shop.db "SELECT p.category FROM orders o JOIN products p ON p.id = o.product_id WHERE o.status != 'cancelled' GROUP BY p.category ORDER BY SUM(p.price * o.qty) DESC LIMIT 1;" > ~/category.txt
