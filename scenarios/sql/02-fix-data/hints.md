`cat ~/request.txt` 로 요청을 확인하고, `sqlite3 shop.db` 에서 대상부터 조회하세요: `SELECT * FROM customers WHERE email LIKE '%@oldmail.com';`
---
안전장치: `BEGIN;` 으로 시작하면, 실수했을 때 `ROLLBACK;` 으로 전부 취소할 수 있어요. 확인이 끝나면 `COMMIT;`
---
1번: `UPDATE customers SET email = REPLACE(email, '@oldmail.com', '@newmail.com') WHERE email LIKE '%@oldmail.com';`  2번: `DELETE FROM orders WHERE status = 'cancelled';`
---
3번은 이름이 같은 사람이 있을 수도 있으니 **id** 로 좁히는 게 안전해요: `SELECT id, name, city FROM customers WHERE name = '...';` → `UPDATE customers SET city = '제주' WHERE id = 번호;`
