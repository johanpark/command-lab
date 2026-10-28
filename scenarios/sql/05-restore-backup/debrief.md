# 해설

```sql
ATTACH DATABASE 'backup/shop-nightly.db' AS bak;
SELECT COUNT(*) FROM bak.customers WHERE city = '부산';   -- 되살릴 대상
BEGIN;
INSERT INTO customers
  SELECT * FROM bak.customers
  WHERE city = '부산' AND id NOT IN (SELECT id FROM main.customers);
INSERT INTO customers VALUES (21, '노하은', '부산', 'user21@gmail.com', '2026-10-27');
SELECT COUNT(*) FROM customers;
COMMIT;
DETACH DATABASE bak;
```

## 왜 통째로 덮으면 안 될까?
| 방법 | 결과 |
|---|---|
| `cp backup/shop-nightly.db shop.db` | 부산 고객 ✅, **오늘 가입 2명 ❌, 오늘 수정 ❌** |
| 지워진 행만 골라 INSERT | 전부 ✅ |
백업 시점 이후의 변경을 지키는 "부분 복구"가 실무에서 훨씬 흔해요.

## 백업에도 없는 데이터
오늘 가입했다가 바로 지워진 21번 고객은 백업에 없어요. 실무에서는 이런 건 **트랜잭션 로그(WAL, binlog)** 로 시점 복구하거나, 애플리케이션 로그·다른 시스템에서 다시 맞춰요. 백업 주기와 로그 보관이 왜 중요한지 보여주는 부분이에요.

## 사고를 줄이는 습관
- 지우기 전에 `SELECT COUNT(*) ... WHERE 같은조건` 으로 개수 확인
- `BEGIN` 안에서 실행하고, 결과 확인 후 `COMMIT`
- 큰 작업 전엔 `.backup before-cleanup.db`
