# 고객 문의 처리하기 — 주문 조회와 환불 (DynamoDB)

고객센터에서 문의가 넘어왔어요.

> 고객번호 **`~/ticket.txt` 에 적힌 고객**입니다. 10월에 주문을 몇 번 했는지 알려 주시고,
> **가장 최근 주문**은 취소하고 환불해 주세요.

주문은 DynamoDB 의 `orders` 테이블에 있어요.

## 목표
1. 그 고객의 **10월(2026-10) 주문 건수**를 숫자만 `~/answer.txt` 에 적으세요.
2. 그 고객의 **가장 최근 주문 하나만** 환불 처리하세요.
   - `status` 를 **`REFUNDED`** 로 바꾸고
   - 환불 시각을 **`refunded_at`** 속성에 기록하세요 (값은 아무 날짜 문자열이나 OK)
   - 금액(`total`) 같은 다른 속성은 그대로 둬야 해요.
3. **다른 주문은 하나도 바꾸지 마세요.**

## 써볼 명령어
| 명령어 | 하는 일 |
|---|---|
| `aws dynamodb describe-table --table-name orders --query Table.KeySchema` | 어떤 키로 찾을 수 있는지 |
| `aws dynamodb query --table-name orders --key-condition-expression "customer_id = :c" --expression-attribute-values '{":c":{"S":"C-..."}}'` | 한 고객의 주문 |
| `... AND begins_with(order_id, :p)` | 정렬 키가 특정 글자로 시작하는 것만 |
| `--select COUNT` / `--no-scan-index-forward --max-items 1` | 개수만 / 최신 하나만 |
| `aws dynamodb update-item --table-name orders --key '{...}' --update-expression "SET ..."` | 한 항목의 일부 속성만 바꾸기 |

> 💡 `status` 는 DynamoDB 예약어라 식 안에서 그대로 못 써요. `#s` 같은 별명을 `--expression-attribute-names '{"#s":"status"}'` 로 붙여요.
