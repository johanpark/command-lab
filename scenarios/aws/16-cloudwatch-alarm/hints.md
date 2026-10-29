토픽 ARN: `aws sns list-topics` → `...:ops-alerts` 로 끝나는 것.
구독: `aws sns subscribe --topic-arn ARN --protocol email --notification-endpoint oncall@shop.example`
(진짜 AWS 라면 메일로 "구독 확인" 링크가 와요. 누르기 전엔 `PendingConfirmation` 상태예요)
---
대상 서버 표: `aws ec2 describe-instances --filters Name=tag:Env,Values=prod --query "Reservations[].Instances[].[InstanceId,State.Name,Tags[?Key=='Name']|[0].Value,Tags[?Key=='Team']|[0].Value]" --output table`
종료된(terminated) 서버와 `Team=db` 서버를 빼야 해요.
---
서버마다 반복:
```
aws ec2 describe-instances ... --output text | while read -r id name; do
  aws cloudwatch put-metric-alarm --alarm-name "cpu-high-$name" ... --dimensions Name=InstanceId,Value="$id" ...
done
```
---
옛 알람 찾기: `aws cloudwatch describe-alarms --query "MetricAlarms[].[AlarmName,AlarmActions[0]]" --output table` 의 토픽을
`aws sns list-topics` 와 비교해 보세요. 목록에 없는 토픽을 가리키는 알람이 지울 대상이에요.
