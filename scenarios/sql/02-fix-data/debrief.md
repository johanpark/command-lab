# 해설

```sql
BEGIN;
SELECT id, email FROM customers WHERE email LIKE '%@oldmail.com';     -- 대상 확인
UPDATE customers SET email = REPLACE(email, '@oldmail.com', '@newmail.com')
  WHERE email LIKE '%@oldmail.com';
SELECT COUNT(*) FROM orders WHERE status = 'cancelled';               -- 몇 건 지워질지
DELETE FROM orders WHERE status = 'cancelled';
UPDATE customers SET city = '제주' WHERE id = 7;                      -- request.txt 의 id
SELECT changes();                                                     -- 방금 바뀐 행 수: 1
COMMIT;
```

## 운영 DB 를 고칠 때의 습관
1. **SELECT 먼저**: 수정할 WHERE 그대로 SELECT 해서 대상과 개수를 확인
2. **트랜잭션**: `BEGIN` 으로 감싸고, 결과를 확인한 뒤 `COMMIT`. 이상하면 `ROLLBACK`
3. **기본 키(id)로 좁히기**: 이름은 겹칠 수 있어요
4. **백업**: 큰 작업 전엔 `.backup shop-backup.db` (sqlite3) 또는 `cp shop.db shop.db.bak`

## 가장 유명한 사고
```sql
UPDATE customers SET city = '제주';      -- WHERE 를 빼먹음 → 고객 전원이 제주로 이사
```
실무 DB 도구 중에는 이걸 막으려고 "WHERE 없는 UPDATE/DELETE 금지" 옵션(MySQL 의 `--safe-updates`)을 켜 두는 곳이 많아요.
