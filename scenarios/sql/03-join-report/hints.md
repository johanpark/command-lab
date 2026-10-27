`sqlite3 shop.db` 에서 위의 JOIN 예시를 그대로 실행해 보세요. 주문마다 고객 이름과 가격이 붙어 나오면 절반은 온 거예요.
---
1번: 예시에 `WHERE o.status != 'cancelled'` 를 넣고, `GROUP BY c.id` 로 묶은 뒤 `ORDER BY SUM(p.price * o.qty) DESC LIMIT 1`. SELECT 에는 `c.name` 만.
---
2번: 고객 기준으로 주문을 LEFT JOIN 하면 주문 없는 고객은 o.id 가 NULL 이에요: `SELECT COUNT(*) FROM customers c LEFT JOIN orders o ON o.customer_id = c.id WHERE o.id IS NULL;` (또는 `WHERE id NOT IN (SELECT customer_id FROM orders)`)
---
3번은 1번과 같은 모양에서 `GROUP BY p.category`, SELECT 에 `p.category`. 결과는 bash 에서 `sqlite3 shop.db "..." > ~/파일` 로 저장!
