중복 확인: `SELECT email, COUNT(*), GROUP_CONCAT(id) FROM members GROUP BY email HAVING COUNT(*) > 1;` 세 번 가입된 사람도 있을 수 있어요!
---
지울 행 수 = 전체 행 수 − 서로 다른 이메일 수: `SELECT COUNT(*) - COUNT(DISTINCT email) FROM members;`
---
순서가 중요해요. 회원을 **먼저 지우면** 그 회원의 주문이 주인 없는 주문이 돼요. 주문부터 옮기세요:
```sql
UPDATE orders SET member_id = (
  SELECT MIN(m2.id) FROM members m2
  WHERE m2.email = (SELECT email FROM members m1 WHERE m1.id = orders.member_id)
);
```
---
그다음 `DELETE FROM members WHERE id NOT IN (SELECT MIN(id) FROM members GROUP BY email);` → `CREATE UNIQUE INDEX idx_members_email ON members(email);` 중복이 남아 있으면 인덱스 만들기가 실패하니 확인용으로도 좋아요.
