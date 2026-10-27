# 해설

```sql
SELECT COUNT(*) FROM customers WHERE city = '서울';
SELECT name FROM products ORDER BY price DESC LIMIT 1;
SELECT COUNT(*) FROM orders WHERE ordered_at LIKE '2026-10-%';
```
```bash
sqlite3 shop.db "SELECT COUNT(*) FROM customers WHERE city = '서울';" > ~/answer.txt
```

## SQL 문의 순서
```sql
SELECT 열들          -- 무엇을
FROM 테이블          -- 어디서
WHERE 조건           -- 어떤 행만
GROUP BY 열          -- 무엇별로 묶어서
ORDER BY 열 DESC     -- 어떤 순서로
LIMIT 개수;          -- 몇 개만
```

## 더 해 보기
```sql
SELECT city, COUNT(*) AS n FROM customers GROUP BY city ORDER BY n DESC;    -- 도시별 고객 수
SELECT category, AVG(price) FROM products GROUP BY category;                -- 카테고리별 평균가
SELECT c.name, SUM(p.price * o.qty) AS total                                -- 고객별 구매액 (JOIN)
FROM orders o JOIN customers c ON c.id = o.customer_id JOIN products p ON p.id = o.product_id
GROUP BY c.id ORDER BY total DESC LIMIT 3;
```

## sqlite3 출력 모양
이 환경은 `sqlite3` 가 `sqlite3 -box` 의 별칭이라 결과가 표로 보여요 (`alias` 로 확인). sqlite3 셸 안에서는 `.mode box`, `.mode list`, `.headers on` 으로 바꿀 수 있고, 스크립트에서 값만 필요하면 `sqlite3 -noheader -list shop.db "..."` 처럼 씁니다.
