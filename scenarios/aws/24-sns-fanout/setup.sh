#!/usr/bin/env bash
source /opt/cmdlab/lib/helpers.sh
source /usr/local/lib/lab-aws.sh
set -e
wait_aws
T=$(aws sns create-topic --name order-events --query TopicArn --output text); secret_set topic "$T"
for q in inventory-updates email-sender analytics; do aws sqs create-queue --queue-name $q >/dev/null; done
url() { aws sqs get-queue-url --queue-name "$1" --query QueueUrl --output text; }
qarn() { echo "arn:aws:sqs:ap-northeast-2:123456789012:$1"; }
# 예시로 analytics 는 이미 제대로 연결돼 있다
jq -n --arg q "$(qarn analytics)" --arg t "$T" '{Policy: ({Version: "2012-10-17", Statement: [{Sid: "AllowOrderEvents", Effect: "Allow",
  Principal: {Service: "sns.amazonaws.com"}, Action: "sqs:SendMessage", Resource: $q, Condition: {ArnEquals: {"aws:SourceArn": $t}}}]} | tojson)}' > /tmp/p.json
aws sqs set-queue-attributes --queue-url "$(url analytics)" --attributes file:///tmp/p.json
aws sns subscribe --topic-arn "$T" --protocol sqs --notification-endpoint "$(qarn analytics)" --query SubscriptionArn --output text > /opt/cmdlab/secret/analytics-sub
rm -f /tmp/p.json
mkdir -p "$H"
cat > "$H/request.md" <<'MD'
# 주문 이벤트 구독 요청

토픽: `order-events` (주문 서비스가 이벤트마다 메시지 속성 `event_type` 을 붙여 발행함)
event_type 종류: order_created, order_paid, order_shipped, order_cancelled, order_refunded

| 팀 | 큐 | 요청 |
|---|---|---|
| 재고팀 | inventory-updates | **모든** 이벤트. SNS 포장(Type, MessageId…) 없이 **원본 JSON 그대로** 받고 싶음 |
| 메일팀 | email-sender | **order_paid, order_shipped** 만 (취소·환불 메일은 다른 시스템이 보냄) |
| 분석팀 | analytics | 이미 연결됨 (참고용) |

※ SQS 큐는 기본적으로 다른 서비스가 메시지를 넣을 수 없음 → 큐 정책에서 **이 토픽(SourceArn)** 의 SNS 만 허용할 것
MD
give "$H/request.md"
