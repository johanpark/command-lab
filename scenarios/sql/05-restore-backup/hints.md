`cd ~ && sqlite3 shop.db` → `ATTACH DATABASE 'backup/shop-nightly.db' AS bak;` → `SELECT COUNT(*) FROM bak.customers WHERE city = '부산';` 로 되살릴 고객 수를 확인하세요.
---
지금 DB 에 없는 것만 넣어야 중복이 안 생겨요: `... WHERE city = '부산' AND id NOT IN (SELECT id FROM main.customers)`
---
안전하게: `BEGIN;` → `INSERT INTO customers SELECT * FROM bak.customers WHERE city = '부산' AND id NOT IN (SELECT id FROM customers);` → 확인 → `COMMIT;`
---
마지막으로 오늘 가입한 부산 고객 한 명: `INSERT INTO customers VALUES (21, '노하은', '부산', 'user21@gmail.com', '2026-10-27');` 그리고 `SELECT COUNT(*) FROM customers;` 로 확인!
