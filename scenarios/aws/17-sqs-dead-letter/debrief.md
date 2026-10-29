# 해설

```bash
O=$(aws sqs get-queue-url --queue-name orders --query QueueUrl --output text)
D=$(aws sqs get-queue-url --queue-name orders-dlq --query QueueUrl --output text)
while :; do
  out=$(aws sqs receive-message --queue-url $D --max-number-of-messages 10 --message-attribute-names All --output json)
  [ -z "$out" ] && break                                    # 더 없으면 빈 출력
  jq -c '.Messages[]' <<< "$out" | while read -r m; do
    body=$(jq -r .Body <<< "$m")
    if [ "$(jq -r .MessageAttributes.error.StringValue <<< "$m")" = PaymentGatewayTimeout ]; then
      aws sqs send-message --queue-url $O --message-body "$body"
    else
      jq -c . <<< "$body" >> ~/invalid-orders.jsonl
    fi
    aws sqs delete-message --queue-url $D --receipt-handle "$(jq -r .ReceiptHandle <<< "$m")"
  done
done
```

## DLQ (Dead-Letter Queue) 가 하는 일
```
orders ──(처리 실패가 maxReceiveCount 번 반복)──▶ orders-dlq
```
- DLQ 가 없으면 고칠 수 없는 메시지(InvalidOrder 같은 **독 메시지**)가 영원히 재시도되면서 워커를 붙잡고, 다른 정상 메시지까지 늦어져요.
- 그래서 **모든 처리 큐에는 DLQ 를 붙이고**, DLQ 에 메시지가 1개라도 생기면 알람(CloudWatch `ApproximateNumberOfMessagesVisible > 0`)을 거는 게 기본이에요.

## 다시 넣을 때 조심할 것
- 받고 → 보내고 → **지우기** 순서. 지우기를 빼먹으면 VisibilityTimeout 뒤 다시 나타나서 **두 번 보내게** 돼요.
- 그래도 중복은 생길 수 있어요 (네트워크 오류 등). 그래서 소비자(워커)는 같은 `order_id` 를 두 번 받아도 한 번만 처리하도록 **멱등성**을 갖춰야 해요.
- 무작정 전부 다시 넣지 말고, **왜 실패했는지 확인한 뒤** 고쳐진 원인의 메시지만 넣으세요.

## 실무 팁
- 실제 AWS 에서는 콘솔의 **"DLQ redrive"** 버튼이나 `aws sqs start-message-move-task` 로 DLQ → 원래 큐 이동을 한 번에 할 수 있어요. 다만 오늘처럼 **골라서** 옮겨야 하면 직접 반복문을 써야 해요.
- DLQ 의 메시지 보관 기간(`MessageRetentionPeriod`, 기본 4일)이 지나면 사라져요. DLQ 는 원래 큐보다 길게(최대 14일) 잡아 두세요.
