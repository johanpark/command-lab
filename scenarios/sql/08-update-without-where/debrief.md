# 해설

```sql
ATTACH DATABASE '/home/learner/backup/shop-20261027.db' AS bak;
BEGIN;
UPDATE orders SET shipped_at = NULL;                                   -- 1. 초기화
UPDATE orders SET shipped_at =                                          -- 2. 어제까지: 백업
  (SELECT b.shipped_at FROM bak.orders b WHERE b.id = orders.id)
  WHERE id IN (SELECT id FROM bak.orders);
UPDATE orders SET shipped_at =                                          -- 3. 최근: 이벤트 로그
  (SELECT MAX(e.at) FROM order_events e WHERE e.order_id = orders.id AND e.event = 'shipped')
  WHERE id IN (SELECT order_id FROM order_events WHERE event = 'shipped');
UPDATE orders SET shipped_at = '2026-10-28 14:05:00' WHERE id = 1234;   -- 4. 원래 하려던 일
SELECT status, COUNT(*), COUNT(shipped_at) FROM orders GROUP BY status; -- 확인
COMMIT;
```

## 복구 자료는 서로를 메워요
```
            ┌──── 백업 (어젯밤 23:00 까지) ────┐
과거 ──────────────────────────────────────────┼──── 오늘 ──── 사고
                       └──── 이벤트 로그 (최근 3일) ──────────────┘
```
겹치는 구간은 둘 다 같은 값이라 상관없고, **최신 자료를 나중에** 덮어쓰면 돼요. 실제 운영 DB 에서는 백업 + **트랜잭션 로그**(MySQL binlog, PostgreSQL WAL)로 "사고 1초 전" 시점까지 되돌리는 **PITR**(Point-In-Time Recovery)을 써요.

## 다시는 안 하려면
1. **트랜잭션 먼저**: `BEGIN;` → UPDATE → `SELECT changes();` 가 1 인지 확인 → `COMMIT;`. 숫자가 이상하면 `ROLLBACK;`
2. **SELECT 로 먼저**: `SELECT * FROM orders WHERE id = 1234;` 를 쳐서 대상을 확인하고, `SELECT * FROM` 을 `UPDATE ... SET` 으로 바꾸는 습관
3. **도구의 안전장치**: MySQL 클라이언트의 `--safe-updates` (WHERE 에 키가 없는 UPDATE/DELETE 거부), PostgreSQL 의 `\set AUTOCOMMIT off`
4. **운영 DB 에 직접 쓰지 않기**: 변경 쿼리는 리뷰받고, 실행 전후 행 수를 기록

## 이벤트 로그(감사 로그)의 가치
`order_events` 같은 기록이 없었다면 오늘 출고된 주문의 시각은 영영 알 수 없었어요. 중요한 상태 변화는 **덮어쓰지 말고 기록으로 쌓는** 설계(이벤트 소싱, 감사 테이블)가 이런 날 빛을 봐요.
