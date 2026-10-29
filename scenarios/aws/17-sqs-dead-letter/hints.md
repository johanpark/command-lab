DLQ 를 들여다보기 (지우지 않고 보기만, 바로 다시 보이게 `--visibility-timeout 0`):
`aws sqs receive-message --queue-url $(aws sqs get-queue-url --queue-name orders-dlq --query QueueUrl --output text) --max-number-of-messages 10 --message-attribute-names All --visibility-timeout 0 --query "Messages[].[MessageAttributes.error.StringValue,Body]" --output table`
---
메시지 하나를 옮기는 순서: **받기 → (종류에 따라) 보내기 또는 파일에 저장 → 지우기**.
받은 결과의 `.Messages[]` 를 `jq -c` 로 한 줄씩 꺼내 반복하면 편해요:
```
out=$(aws sqs receive-message --queue-url $D --max-number-of-messages 10 --message-attribute-names All --output json)
jq -c '.Messages[]' <<< "$out" | while read -r m; do
  jq -r '.MessageAttributes.error.StringValue, .Body, .ReceiptHandle' <<< "$m"
done
```
---
보내기: `aws sqs send-message --queue-url $O --message-body "$body"`
저장: `echo "$body" >> ~/invalid-orders.jsonl`
지우기: `aws sqs delete-message --queue-url $D --receipt-handle "$handle"` (← 이걸 빼먹으면 30초 뒤 다시 나타나요)
**실수로 두 번 보내지 않게** 한 번에 끝까지 하거나, 보낸 것은 바로 지우세요.
---
payments 의 DLQ:
```
aws sqs create-queue --queue-name payments-dlq
A=$(aws sqs get-queue-attributes --queue-url <payments-dlq URL> --attribute-names QueueArn --query Attributes.QueueArn --output text)
jq -n --arg a "$A" '{RedrivePolicy: ({deadLetterTargetArn: $a, maxReceiveCount: "5"} | tojson)}' > attr.json
aws sqs set-queue-attributes --queue-url <payments URL> --attributes file://attr.json
```
RedrivePolicy 값은 **JSON 을 문자열로 한 번 더 감싼 것**이라 `tojson` 이 필요해요.
