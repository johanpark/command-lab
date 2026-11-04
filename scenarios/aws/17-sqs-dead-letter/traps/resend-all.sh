# 설명: 에러 종류를 보지 않고 다 다시 보내면 InvalidOrder 까지 다시 실패한다
# 실패해야: InvalidOrder 메시지는 다시 넣지 않았다
O=$(aws sqs get-queue-url --queue-name orders --query QueueUrl --output text)
D=$(aws sqs get-queue-url --queue-name orders-dlq --query QueueUrl --output text)
: > ~/invalid-orders.jsonl
while :; do
  out=$(aws sqs receive-message --queue-url "$D" --max-number-of-messages 10 --message-attribute-names All --output json)
  [ -z "$out" ] || [ "$(jq '.Messages | length' <<< "$out")" = 0 ] && break
  while read -r m; do
    body=$(jq -r .Body <<< "$m"); err=$(jq -r '.MessageAttributes.error.StringValue' <<< "$m")
    aws sqs send-message --queue-url "$O" --message-body "$body" >/dev/null
    aws sqs delete-message --queue-url "$D" --receipt-handle "$(jq -r .ReceiptHandle <<< "$m")"
  done < <(jq -c '.Messages[]' <<< "$out")
done
PD=$(aws sqs create-queue --queue-name payments-dlq --query QueueUrl --output text)
A=$(aws sqs get-queue-attributes --queue-url "$PD" --attribute-names QueueArn --query Attributes.QueueArn --output text)
jq -n --arg a "$A" '{RedrivePolicy: ({deadLetterTargetArn: $a, maxReceiveCount: "5"} | tojson)}' > ~/attr.json
aws sqs set-queue-attributes --queue-url "$(aws sqs get-queue-url --queue-name payments --query QueueUrl --output text)" --attributes file://$HOME/attr.json

