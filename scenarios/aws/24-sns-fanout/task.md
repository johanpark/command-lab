# 주문 이벤트를 여러 팀에 나눠 보내기 (SNS → SQS 팬아웃, 필터)

주문 서비스는 이벤트를 SNS 토픽 **`order-events`** 하나에만 발행해요. 그걸 여러 팀이 **각자의 SQS 큐로** 받아 가는 구조(팬아웃)예요.
요청서는 `~/request.md` 에 있어요. `analytics` 큐는 이미 연결돼 있으니 참고하세요.

## 목표
1. **`inventory-updates`** 큐를 토픽에 구독시키고, **원본 메시지 그대로 받기(RawMessageDelivery)** 를 켜세요.
2. **`email-sender`** 큐를 토픽에 구독시키고, **`event_type` 이 `order_paid`, `order_shipped` 인 것만** 받도록 필터를 거세요.
3. 두 큐 모두 **이 토픽에서 오는 SNS 메시지만** 넣을 수 있도록 **큐 정책**을 설정하세요.
4. `analytics` 의 구독과 정책은 그대로 두세요.

## 써볼 명령어
| 명령어 | 하는 일 |
|---|---|
| `aws sns list-subscriptions-by-topic --topic-arn ARN` | 지금 구독 목록 |
| `aws sns subscribe --topic-arn ARN --protocol sqs --notification-endpoint 큐ARN --attributes file://attrs.json` | 구독 (속성 함께) |
| `aws sns get-subscription-attributes --subscription-arn ...` | 구독 속성 확인 |
| `aws sqs get-queue-attributes --queue-url URL --attribute-names Policy` | 큐 정책 보기 (analytics 참고) |
| `aws sqs set-queue-attributes --queue-url URL --attributes file://policy.json` | 큐 정책 넣기 |
| `aws sns publish --topic-arn ARN --message '{...}' --message-attributes '{"event_type":{"DataType":"String","StringValue":"order_paid"}}'` | 시험 발행 |
