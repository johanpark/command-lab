O=$(aws sqs get-queue-url --queue-name orders --query QueueUrl --output text)
D=$(aws sqs get-queue-url --queue-name orders-dlq --query QueueUrl --output text)
: > ~/invalid-orders.jsonl
while :; do
  out=$(aws sqs receive-message --queue-url "$D" --max-number-of-messages 10 --message-attribute-names All --output json)
  [ -z "$out" ] || [ "$(jq '.Messages | length' <<< "$out")" = 0 ] && break
  while read -r m; do
    body=$(jq -r .Body <<< "$m"); err=$(jq -r '.MessageAttributes.error.StringValue' <<< "$m")
    if [ "$err" = PaymentGatewayTimeout ]; then aws sqs send-message --queue-url "$O" --message-body "$body" >/dev/null
    else jq -c . <<< "$body" >> ~/invalid-orders.jsonl; fi
    aws sqs delete-message --queue-url "$D" --receipt-handle "$(jq -r .ReceiptHandle <<< "$m")"
  done < <(jq -c '.Messages[]' <<< "$out")
done
PD=$(aws sqs create-queue --queue-name payments-dlq --query QueueUrl --output text)
A=$(aws sqs get-queue-attributes --queue-url "$PD" --attribute-names QueueArn --query Attributes.QueueArn --output text)
jq -n --arg a "$A" '{RedrivePolicy: ({deadLetterTargetArn: $a, maxReceiveCount: "5"} | tojson)}' > ~/attr.json
aws sqs set-queue-attributes --queue-url "$(aws sqs get-queue-url --queue-name payments --query QueueUrl --output text)" --attributes file://$HOME/attr.json
