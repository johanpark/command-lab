#!/usr/bin/env bash
source /opt/cmdlab/lib/helpers.sh
source /usr/local/lib/lab-aws.sh
set -e
wait_aws
S=/opt/cmdlab/secret
url() { aws sqs get-queue-url --queue-name "$1" --query QueueUrl --output text; }
arn() { aws sqs get-queue-attributes --queue-url "$(url "$1")" --attribute-names QueueArn --query Attributes.QueueArn --output text; }
redrive() { jq -n --arg a "$(arn "$1")" --arg n "$2" '{RedrivePolicy: ({deadLetterTargetArn: $a, maxReceiveCount: $n} | tojson)}'; }
aws sqs create-queue --queue-name orders-dlq >/dev/null
aws sqs create-queue --queue-name orders --attributes "$(redrive orders-dlq 5)" >/dev/null
aws sqs create-queue --queue-name emails-dlq >/dev/null
aws sqs create-queue --queue-name emails --attributes "$(redrive emails-dlq 3)" >/dev/null
aws sqs create-queue --queue-name payments >/dev/null
D=$(url orders-dlq)
: > $S/retry; : > $S/invalid
n=$(rand_int 5 7); bad=$(rand_int 2 3); total=$((n + bad))
order=$(shuf -e $(seq "$total"))   # 섞어서 보냄
for i in $order; do
  id="ORD-2026-$(rand_int 10000 99999)"
  if [ "$i" -le "$n" ]; then
    body=$(jq -cn --arg id "$id" --argjson amt "$(( $(rand_int 10 300) * 1000 ))" '{order_id: $id, amount: $amt, currency: "KRW"}')
    err=PaymentGatewayTimeout; echo "$body" >> $S/retry
  else
    body=$(jq -cn --arg id "$id" '{order_id: $id, amount: -1, currency: "KRW"}')
    err=InvalidOrder; echo "$body" >> $S/invalid
  fi
  aws sqs send-message --queue-url "$D" --message-body "$body" \
    --message-attributes "{\"error\":{\"DataType\":\"String\",\"StringValue\":\"$err\"}}" >/dev/null
done
mkdir -p "$H"
cat > "$H/incident.md" <<'MD'
# 장애 메모 (결제 연동 타임아웃)

- 어젯밤 PG(결제 대행사) 응답이 느려서 주문 처리 워커가 계속 실패 → 5번 실패한 메시지가 `orders-dlq` 로 이동함
- PG 쪽 문제는 해결됨. **오류가 `PaymentGatewayTimeout` 인 메시지는 다시 `orders` 큐에 넣으면 정상 처리됨**
- 그런데 DLQ 에 **`InvalidOrder`** (금액이 -1) 메시지도 섞여 있음 → 다시 넣으면 또 실패하니 넣지 말 것.
  본문을 `~/invalid-orders.jsonl` 에 한 줄에 하나씩 보관해서 개발팀에 넘기고, 큐에서는 지울 것
- 끝나면 DLQ 는 비어 있어야 함
- 덤: `payments` 큐에는 DLQ 가 아예 없음 → 실패 메시지가 무한 반복될 수 있음. `payments-dlq` 를 만들고 5번 실패하면 넘어가게 할 것
MD
give "$H/incident.md"
