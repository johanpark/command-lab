먼저 상황 파악: `SELECT status, COUNT(*), MIN(shipped_at), MAX(shipped_at) FROM orders GROUP BY status;` 그리고 `ATTACH DATABASE '/home/learner/backup/shop-20261027.db' AS bak;` 후 같은 쿼리를 `bak.orders` 에 해서 비교해 보세요. 오늘 생긴 주문(백업에 없는 id)도 있죠?
---
백업 파일을 통째로 덮어쓰면(`cp`) 오늘 들어온 주문과 오늘 바뀐 상태가 **사라져요.** `shipped_at` 열만 골라서 되돌려야 해요.
---
자료마다 아는 범위가 달라요. 하나씩 덮어 가며 채우세요 (순서 중요!):
1. 일단 전부 `NULL` 로
2. **백업**에 있는 주문은 백업 값으로 (어제까지 출고된 것)
3. **이벤트 로그**의 `shipped` 기록이 있는 주문은 그 시각으로 (오늘 출고된 것까지)
4. 원래 하려던 주문 하나
---
```sql
BEGIN;
UPDATE orders SET shipped_at = NULL;
UPDATE orders SET shipped_at = (SELECT b.shipped_at FROM bak.orders b WHERE b.id = orders.id)
  WHERE id IN (SELECT id FROM bak.orders);
UPDATE orders SET shipped_at = (SELECT MAX(e.at) FROM order_events e WHERE e.order_id = orders.id AND e.event = 'shipped')
  WHERE id IN (SELECT order_id FROM order_events WHERE event = 'shipped');
UPDATE orders SET shipped_at = '2026-10-28 14:05:00' WHERE id = <incident.txt 의 주문>;
-- 확인 쿼리를 돌려 보고 괜찮으면 COMMIT; 이상하면 ROLLBACK;
```
