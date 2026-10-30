잘 된 예시부터 보세요:
```
aws sns list-subscriptions-by-topic --topic-arn <토픽ARN> --output table
aws sqs get-queue-attributes --queue-url $(aws sqs get-queue-url --queue-name analytics --query QueueUrl --output text) --attribute-names Policy --query Attributes.Policy --output text | jq .
```
같은 모양의 정책을 큐 ARN 만 바꿔서 두 큐에 넣으면 돼요.
---
큐 정책·필터 정책은 **JSON 안에 JSON 문자열**이 들어가는 구조라 손으로 쓰기 어려워요. jq 의 `tojson` 으로 만들면 편해요:
```
jq -n --arg q <큐ARN> --arg t <토픽ARN> '{Policy: ({Version:"2012-10-17", Statement:[{Effect:"Allow",
  Principal:{Service:"sns.amazonaws.com"}, Action:"sqs:SendMessage", Resource:$q,
  Condition:{ArnEquals:{"aws:SourceArn":$t}}}]} | tojson)}' > policy.json
aws sqs set-queue-attributes --queue-url <큐URL> --attributes file://policy.json
```
---
구독 속성 파일:
- 재고팀: `{"RawMessageDelivery": "true"}`
- 메일팀: `jq -n '{FilterPolicy: ({event_type: ["order_paid","order_shipped"]} | tojson)}' > email.json`

`aws sns subscribe --topic-arn <토픽> --protocol sqs --notification-endpoint <큐ARN> --attributes file://email.json`
---
확인: order_cancelled 로 하나, order_paid 로 하나 발행한 뒤 `aws sqs receive-message` 로 각 큐를 보세요. 메일 큐에는 paid 만 와야 해요.
구독을 잘못 만들었다면 `aws sns unsubscribe --subscription-arn ...` 로 지우고 다시.
