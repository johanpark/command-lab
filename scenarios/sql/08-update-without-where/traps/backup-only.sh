# 설명: 백업만으로 되돌리면 오늘 출고된 주문(이벤트 로그에만 있음)의 시각이 비어 있다
# 실패해야: 오늘 출고된 주문의 출고 시각
cd ~
id=$(grep -o '주문 [0-9]* 번' incident.txt | grep -o '[0-9]*')
sqlite3 shop.db "
ATTACH DATABASE '/home/learner/backup/shop-20261027.db' AS bak;
UPDATE orders SET shipped_at = NULL;
UPDATE orders SET shipped_at = (SELECT b.shipped_at FROM bak.orders b WHERE b.id = orders.id) WHERE id IN (SELECT id FROM bak.orders);
UPDATE orders SET shipped_at = '2026-10-28 14:05:00' WHERE id = $id;"
