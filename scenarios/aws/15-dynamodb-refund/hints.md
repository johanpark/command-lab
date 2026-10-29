먼저 키 구조: `aws dynamodb describe-table --table-name orders --query Table.KeySchema`
→ 파티션 키 `customer_id` + 정렬 키 `order_id`. order_id 는 `2026-10-21#7F3A` 처럼 **날짜로 시작**해서, 정렬 키 순서 = 시간 순서예요.
---
한 고객의 주문을 표로:
`aws dynamodb query --table-name orders --key-condition-expression "customer_id = :c" --expression-attribute-values '{":c":{"S":"C-10xx"}}' --query "Items[].[order_id.S,status.S,total.N]" --output table`
---
10월만 세기: 조건에 `AND begins_with(order_id, :p)` 를 붙이고 `":p":{"S":"2026-10"}` 추가, 그리고 `--select COUNT`.
(9월 30일 주문은 10월이 아니에요!)
---
가장 최근 = 정렬 키가 가장 큰 것 → `--no-scan-index-forward` (역순) 로 query 하면 첫 번째예요.
바꾸기는 `put-item` 이 아니라 **`update-item`** (put 은 항목을 통째로 덮어써서 다른 속성이 사라져요):
```
aws dynamodb update-item --table-name orders \
  --key '{"customer_id":{"S":"C-10xx"},"order_id":{"S":"2026-10-26#XXXX"}}' \
  --update-expression "SET #s = :r, refunded_at = :t" \
  --expression-attribute-names '{"#s":"status"}' \
  --expression-attribute-values '{":r":{"S":"REFUNDED"},":t":{"S":"2026-10-29"}}'
```
