`sqlite3 shop.db` 로 들어가서 `.tables` → `SELECT * FROM customers LIMIT 5;` 로 데이터가 어떻게 생겼는지 보세요. `.quit` 으로 나옵니다.
---
1번: `SELECT COUNT(*) FROM customers WHERE city = '서울';`. 결과를 확인했으면 bash 에서 `sqlite3 shop.db "그 SQL" > ~/answer.txt`
---
2번: `SELECT name, price FROM products ORDER BY price DESC LIMIT 1;` 에서 이름만 저장하려면 `SELECT name` 만 남기세요.
---
3번: `SELECT COUNT(*) FROM orders WHERE ordered_at LIKE '2026-10-%';`. 날짜가 문자열이라 `ordered_at >= '2026-10-01' AND ordered_at < '2026-11-01'` 도 돼요.
