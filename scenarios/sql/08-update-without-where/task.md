# WHERE 없는 UPDATE 사고 복구

오후 2시, 물류팀 요청으로 주문 **하나**의 출고 시각을 넣으려고 운영 DB 에 이렇게 쳤어요.

```sql
UPDATE orders SET shipped_at = '2026-10-28 14:05:00';
-- WHERE id = ... 를 붙이기 전에 Enter 를 눌러 버렸다 😱
```

**모든 주문**의 `shipped_at` 이 `2026-10-28 14:05:00` 이 됐어요. 아직 출고도 안 된 주문까지요. 자세한 상황은 `~/incident.txt` 에 있어요.

## 쓸 수 있는 자료
| 자료 | 내용 | 한계 |
|---|---|---|
| `~/backup/shop-20261027.db` | **어젯밤 23:00** 백업 | 오늘 생긴 주문·변경은 없음 |
| `order_events` 테이블 (`~/shop.db` 안) | 앱이 남기는 이벤트 기록 (`shipped` 등) | **최근 3일치만** 보관 |

## 목표 (`~/shop.db` 의 `orders` 테이블)
1. 모든 주문의 `shipped_at` 을 **사고 직전 값**으로 되돌리세요. (출고 전 주문은 `NULL`)
2. 원래 하려던 작업도 마저 하세요: `~/incident.txt` 의 **그 주문 하나만** `shipped_at = '2026-10-28 14:05:00'`
3. 오늘 들어온 **새 주문**, 오늘 바뀐 **상태(status)** 등 다른 데이터는 **그대로** 둬야 해요.

## 써볼 SQL
| SQL | 하는 일 |
|---|---|
| `ATTACH DATABASE '경로' AS bak;` | 백업 DB 를 `bak.테이블` 로 붙이기 |
| `UPDATE orders SET 열 = (SELECT ... WHERE ... = orders.id) WHERE ...;` | 다른 테이블 값으로 고치기 |
| `BEGIN;` … `COMMIT;` / `ROLLBACK;` | 묶어서 확정 / 되돌리기 |
| `SELECT changes();` | 방금 바뀐 행 수 |
