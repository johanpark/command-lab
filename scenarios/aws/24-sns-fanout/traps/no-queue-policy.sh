# 설명: 큐 정책 없이 구독만 하고, 원본 전달(Raw)과 필터 일부를 빼먹는다
# 실패해야: 원본 그대로
# 실패해야: order_paid, order_shipped 만
# 실패해야: inventory-updates 큐 정책
# 실패해야: email-sender 큐 정책
T=arn:aws:sns:ap-northeast-2:123456789012:order-events
aws sns subscribe --topic-arn $T --protocol sqs --notification-endpoint arn:aws:sqs:ap-northeast-2:123456789012:inventory-updates >/dev/null
aws sns subscribe --topic-arn $T --protocol sqs --notification-endpoint arn:aws:sqs:ap-northeast-2:123456789012:email-sender --attributes "$(jq -n '{FilterPolicy: ({event_type:["order_paid"]} | tojson)}')" >/dev/null
