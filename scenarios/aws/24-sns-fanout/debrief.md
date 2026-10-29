# 해설

```bash
T=arn:aws:sns:ap-northeast-2:123456789012:order-events
for q in inventory-updates email-sender; do
  Q=arn:aws:sqs:ap-northeast-2:123456789012:$q
  # 1) 큐 정책: 이 토픽의 SNS 만 SendMessage 허용
  jq -n --arg q $Q --arg t $T '{Policy: ({Version:"2012-10-17", Statement:[{Effect:"Allow",
    Principal:{Service:"sns.amazonaws.com"}, Action:"sqs:SendMessage", Resource:$q,
    Condition:{ArnEquals:{"aws:SourceArn":$t}}}]} | tojson)}' > policy.json
  aws sqs set-queue-attributes --queue-url $(aws sqs get-queue-url --queue-name $q --query QueueUrl --output text) --attributes file://policy.json
done
# 2) 구독
aws sns subscribe --topic-arn $T --protocol sqs --notification-endpoint arn:...:inventory-updates \
  --attributes '{"RawMessageDelivery":"true"}'
aws sns subscribe --topic-arn $T --protocol sqs --notification-endpoint arn:...:email-sender \
  --attributes "$(jq -n '{FilterPolicy: ({event_type:["order_paid","order_shipped"]} | tojson)}')"
```

## 팬아웃 구조
```
주문 서비스 ──publish──▶ SNS order-events ─┬─▶ SQS inventory-updates (전부, raw)
                                          ├─▶ SQS email-sender     (paid·shipped 만)
                                          └─▶ SQS analytics
```
- 발행하는 쪽은 **받는 팀이 몇 개인지 몰라도** 돼요. 새 팀이 생기면 구독만 추가하면 끝.
- 각 팀은 자기 큐에서 자기 속도로 처리하고, 한 팀이 장애가 나도 다른 팀은 영향이 없어요.

## 놓치기 쉬운 세 가지
| | 없으면 |
|---|---|
| **큐 정책** (SNS → SQS 허용) | 구독은 "확인됨" 으로 보이는데 메시지가 **조용히 안 들어와요** (가장 흔한 실수) |
| **RawMessageDelivery** | 메시지가 `{"Type":"Notification","Message":"<원본을 문자열로>",...}` 로 한 번 더 감싸져 와요 |
| **FilterPolicy** | 모든 이벤트가 와서 소비자가 직접 걸러야 하고, 필요 없는 메시지에도 요금이 나가요 |

- 큐 정책의 `aws:SourceArn` 조건이 없으면 **아무 SNS 토픽이나**(다른 계정 것도) 이 큐에 메시지를 넣을 수 있어요.
- 필터는 기본으로 **메시지 속성** 기준이에요. 본문(JSON) 기준으로 거르려면 `FilterPolicyScope=MessageBody` 를 써요.

## 실무 팁
- 큐가 KMS 로 암호화돼 있으면 SNS 가 그 키를 쓸 수 있게 **KMS 키 정책**에도 sns.amazonaws.com 을 허용해야 해요.
- 각 구독에도 DLQ(`RedrivePolicy`)를 붙일 수 있어요. 큐 정책 실수 같은 전달 실패를 잡아내요.
