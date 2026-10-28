# 해설

```sql
SELECT COUNT(*) - COUNT(DISTINCT email) FROM members;   -- 지울 행 수

BEGIN;
-- 1) 주문을 원래 계정(이메일별 가장 작은 id)으로 옮기기
UPDATE orders SET member_id = (
  SELECT MIN(m2.id) FROM members m2
  WHERE m2.email = (SELECT email FROM members m1 WHERE m1.id = orders.member_id)
);
-- 2) 중복 회원 지우기
DELETE FROM members WHERE id NOT IN (SELECT MIN(id) FROM members GROUP BY email);
-- 3) 재발 방지
CREATE UNIQUE INDEX idx_members_email ON members(email);
COMMIT;
```

## 확인 쿼리
```sql
-- 주인 없는 주문 (0건이어야 함)
SELECT COUNT(*) FROM orders WHERE member_id NOT IN (SELECT id FROM members);
-- 남은 중복 (0건이어야 함)
SELECT email FROM members GROUP BY email HAVING COUNT(*) > 1;
```

## 순서가 핵심
`members` 를 먼저 지우면 `orders.member_id` 가 존재하지 않는 회원을 가리키는 **고아 데이터**가 돼요. 외래 키(`FOREIGN KEY ... REFERENCES`)를 걸어 두면 DB 가 이런 실수를 막아 줘요. (SQLite 는 `PRAGMA foreign_keys = ON;` 을 켜야 동작)

## 다시 안 생기게
애플리케이션에서 "이미 있는 이메일인지" 확인하는 것만으로는 부족해요. 버튼을 두 번 누르면 두 요청이 **동시에** 확인을 통과할 수 있거든요. DB 의 `UNIQUE` 제약이 마지막 방어선이에요.

## 다른 DB 에서는
| DB | 방법 |
|---|---|
| PostgreSQL | `DELETE ... USING`, `ROW_NUMBER() OVER (PARTITION BY email ORDER BY id)` |
| MySQL | `DELETE m1 FROM members m1 JOIN members m2 ON m1.email = m2.email AND m1.id > m2.id` |
