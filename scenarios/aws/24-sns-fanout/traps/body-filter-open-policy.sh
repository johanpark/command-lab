# 설명: 필터를 메시지 본문 기준으로 걸고, 큐 정책을 Principal * 로 아무나 열어 둔다
# 실패해야: 메시지 속성
# 실패해야: inventory-updates 큐 정책
# 실패해야: email-sender 큐 정책
T=arn:aws:sns:ap-northeast-2:123456789012:order-events
for q in inventory-updates email-sender; do
  jq -n --arg q "arn:aws:sqs:ap-northeast-2:123456789012:$q" '{Policy: ({Version:"2012-10-17", Statement:[{Effect:"Allow", Principal:"*", Action:"sqs:SendMessage", Resource:$q}]} | tojson)}' > p.json
  aws sqs set-queue-attributes --queue-url http://127.0.0.1:5000/123456789012/$q --attributes file://p.json
done
aws sns subscribe --topic-arn $T --protocol sqs --notification-endpoint arn:aws:sqs:ap-northeast-2:123456789012:inventory-updates --attributes '{"RawMessageDelivery":"true"}' >/dev/null
aws sns subscribe --topic-arn $T --protocol sqs --notification-endpoint arn:aws:sqs:ap-northeast-2:123456789012:email-sender --attributes "$(jq -n '{FilterPolicy: ({event_type:["order_shipped","order_paid"]} | tojson), FilterPolicyScope: "MessageBody"}')" >/dev/null
