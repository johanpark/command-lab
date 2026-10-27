cd ~
sqlite3 shop.db "SELECT c.name FROM orders o JOIN customers c ON c.id = o.customer_id JOIN products p ON p.id = o.product_id WHERE o.status != 'cancelled' GROUP BY c.id ORDER BY SUM(p.price * o.qty) DESC LIMIT 1;" > ~/answer.txt
sqlite3 shop.db "SELECT COUNT(*) FROM customers c LEFT JOIN orders o ON o.customer_id = c.id WHERE o.id IS NULL;" > ~/never.txt
sqlite3 shop.db "SELECT p.category FROM orders o JOIN products p ON p.id = o.product_id WHERE o.status != 'cancelled' GROUP BY p.category ORDER BY SUM(p.price * o.qty) DESC LIMIT 1;" > ~/category.txt
