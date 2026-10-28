cd ~
id=$(grep -o '주문 [0-9]* 번' incident.txt | grep -o '[0-9]*')
sqlite3 shop.db "
ATTACH DATABASE '/home/learner/backup/shop-20261027.db' AS bak;
BEGIN;
UPDATE orders SET shipped_at = NULL;
UPDATE orders SET shipped_at = (SELECT b.shipped_at FROM bak.orders b WHERE b.id = orders.id)
  WHERE id IN (SELECT id FROM bak.orders);
UPDATE orders SET shipped_at = (SELECT MAX(e.at) FROM order_events e WHERE e.order_id = orders.id AND e.event = 'shipped')
  WHERE id IN (SELECT order_id FROM order_events WHERE event = 'shipped');
UPDATE orders SET shipped_at = '2026-10-28 14:05:00' WHERE id = $id;
COMMIT;"
