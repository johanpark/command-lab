# 해설

```bash
T=C-10xx
# 10월 주문 수: 파티션 키 = 고객, 정렬 키가 "2026-10" 으로 시작
aws dynamodb query --table-name orders \
  --key-condition-expression "customer_id = :c AND begins_with(order_id, :p)" \
  --expression-attribute-values '{":c":{"S":"'$T'"},":p":{"S":"2026-10"}}' --select COUNT
# 가장 최근 주문: 정렬 키 역순으로 하나
aws dynamodb query --table-name orders --key-condition-expression "customer_id = :c" \
  --expression-attribute-values '{":c":{"S":"'$T'"}}' --no-scan-index-forward --max-items 1
# 그 주문만, 아직 PAID 일 때만 환불
aws dynamodb update-item --table-name orders --key '{...}' \
  --update-expression "SET #s = :r, refunded_at = :t" --condition-expression "#s = :p" \
  --expression-attribute-names '{"#s":"status"}' \
  --expression-attribute-values '{":r":{"S":"REFUNDED"},":p":{"S":"PAID"},":t":{"S":"2026-10-29T10:00:00+09:00"}}'
```

## query vs scan
| | query | scan |
|---|---|---|
| 읽는 범위 | 파티션 키 하나 (그 안에서 정렬 키 조건) | **테이블 전체** |
| 비용·속도 | 찾는 것만 읽음 | 항목이 백만 개면 백만 개 읽음 |
| 쓸 때 | 거의 항상 | 일회성 분석, 마이그레이션 |

`scan --filter-expression` 은 **다 읽은 다음 걸러내는 것**이라 비용이 줄지 않아요.
DynamoDB 는 "어떤 질문을 할지" 를 먼저 정하고 그에 맞게 키를 설계해요. 이 테이블은 "고객별 주문을 시간순으로" 가 질문이라 `customer_id` + `날짜로 시작하는 order_id` 로 설계됐어요.

## update-item vs put-item
- `put-item` 은 **항목 전체를 교체**해요. 빠뜨린 속성(total 등)은 사라져요.
- `update-item` 의 `SET` 은 적은 속성만 바꿔요.
- `--condition-expression "#s = :p"` 를 붙이면 **이미 배송됐거나 환불된 주문을 실수로 또 환불하는 것**을 막아요. 조건이 안 맞으면 `ConditionalCheckFailedException` 으로 아무것도 안 바뀌어요.

## 예약어
`status`, `name`, `date`, `count`, `year` 같은 흔한 단어가 DynamoDB 예약어예요. 식 안에서는 `#별명` + `--expression-attribute-names` 로 써요.
