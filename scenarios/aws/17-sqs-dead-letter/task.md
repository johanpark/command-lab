# 처리 못 한 주문 메시지 다시 넣기 (SQS 데드레터 큐)

어젯밤 결제 대행사(PG) 장애로 주문 메시지가 처리되지 못하고 **데드레터 큐(DLQ)** `orders-dlq` 에 쌓였어요.
장애 메모는 `~/incident.md` 에 있어요.

## 목표
1. `orders-dlq` 의 메시지 중 오류(메시지 속성 `error`)가 **`PaymentGatewayTimeout`** 인 것만 **`orders` 큐로 다시 보내세요.** (본문 그대로)
2. **`InvalidOrder`** 메시지는 다시 보내지 말고, 본문을 **`~/invalid-orders.jsonl`** 에 **한 줄에 하나씩** 저장하세요.
3. 다 옮기고 나면 **`orders-dlq` 는 비어 있어야** 해요. (같은 메시지가 두 번 들어가면 주문이 두 번 처리돼요!)
4. DLQ 가 없는 **`payments`** 큐에 **`payments-dlq`** 를 만들어 연결하세요. **5번** 실패하면 넘어가게.

## 써볼 명령어
| 명령어 | 하는 일 |
|---|---|
| `aws sqs list-queues` / `aws sqs get-queue-url --queue-name 이름` | 큐 주소(URL) |
| `aws sqs get-queue-attributes --queue-url URL --attribute-names All` | 메시지 수, RedrivePolicy 등 |
| `aws sqs receive-message --queue-url URL --max-number-of-messages 10 --message-attribute-names All` | 메시지 받기 (본문 + 속성 + ReceiptHandle) |
| `aws sqs send-message --queue-url URL --message-body '...'` | 메시지 보내기 |
| `aws sqs delete-message --queue-url URL --receipt-handle ...` | 처리 끝난 메시지 지우기 |
| `aws sqs set-queue-attributes --queue-url URL --attributes file://attr.json` | 큐 설정 바꾸기 |

> 💡 SQS 는 받은(receive) 메시지를 **지우지 않으면** 잠깐(VisibilityTimeout, 기본 30초) 숨겼다가 **다시 보여줘요.**
> 처리가 끝난 메시지는 반드시 `delete-message` 로 지워야 해요.
