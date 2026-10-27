# 테이블 합쳐서 분석하기

`~/shop.db` 의 주문(`orders`)에는 고객 **번호**와 상품 **번호**만 있어요. 이름이나 가격을 보려면 다른 테이블과 **합쳐야(JOIN)** 합니다.

```
orders.customer_id  →  customers.id
orders.product_id   →  products.id
```

## 목표 (취소된 주문 `status = 'cancelled'` 은 매출에서 빼세요)
1. **총 구매액**(가격 × 수량의 합)이 가장 큰 **고객의 이름** → `~/answer.txt`
2. 주문을 **한 번도 하지 않은 고객 수** → `~/never.txt`
3. 매출이 가장 큰 **상품 카테고리** → `~/category.txt`

## 써볼 SQL
```sql
-- 주문에 고객 이름과 상품 가격 붙이기
SELECT o.id, c.name, p.name, p.price, o.qty
FROM orders o
JOIN customers c ON c.id = o.customer_id
JOIN products  p ON p.id = o.product_id
LIMIT 5;
```
| SQL | 하는 일 |
|---|---|
| `JOIN 테이블 ON 조건` | 조건이 맞는 행끼리 합치기 |
| `LEFT JOIN` | 왼쪽 테이블은 짝이 없어도 남기기 (짝 없는 쪽은 NULL) |
| `GROUP BY c.id` + `SUM(...)` | 고객별 합계 |
| `WHERE ... IS NULL` | 짝이 없는 행 찾기 |
