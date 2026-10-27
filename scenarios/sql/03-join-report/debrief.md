# 해설

```sql
-- 1. VIP 고객
SELECT c.name, SUM(p.price * o.qty) AS total
FROM orders o
JOIN customers c ON c.id = o.customer_id
JOIN products  p ON p.id = o.product_id
WHERE o.status != 'cancelled'
GROUP BY c.id
ORDER BY total DESC
LIMIT 3;

-- 2. 주문한 적 없는 고객
SELECT COUNT(*)
FROM customers c LEFT JOIN orders o ON o.customer_id = c.id
WHERE o.id IS NULL;

-- 3. 효자 카테고리
SELECT p.category, SUM(p.price * o.qty) AS total
FROM orders o JOIN products p ON p.id = o.product_id
WHERE o.status != 'cancelled'
GROUP BY p.category ORDER BY total DESC;
```

## JOIN 한 장 정리
```
customers ◯ orders
INNER JOIN : 양쪽에 짝이 있는 것만         (주문한 고객만)
LEFT JOIN  : 왼쪽은 전부 + 오른쪽 짝(없으면 NULL)  (모든 고객, 주문 없으면 NULL)
```

## 함정 포인트
- `GROUP BY c.name` 으로 묶으면 **동명이인**이 한 사람으로 합쳐져요. 항상 고유한 `id` 로 묶으세요.
- 취소 주문을 빼지 않으면 1위가 바뀔 수 있어요. 집계 전에 **무엇을 셀지** 먼저 정하기!
- `COUNT(*)` 와 `COUNT(o.id)` 는 다릅니다. LEFT JOIN 결과에서 `COUNT(o.id)` 는 NULL 을 세지 않아요.
