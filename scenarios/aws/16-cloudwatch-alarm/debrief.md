# 해설

```bash
T=$(aws sns list-topics --query "Topics[?ends_with(TopicArn, ':ops-alerts')].TopicArn" --output text)
aws sns subscribe --topic-arn $T --protocol email --notification-endpoint oncall@shop.example

aws ec2 describe-instances --filters Name=tag:Env,Values=prod Name=instance-state-name,Values=running \
  --query "Reservations[].Instances[?!(Tags[?Key=='Team' && Value=='db'])][].[InstanceId,Tags[?Key=='Name']|[0].Value]" --output text |
while read -r id name; do
  aws cloudwatch put-metric-alarm --alarm-name cpu-high-$name --namespace AWS/EC2 --metric-name CPUUtilization \
    --dimensions Name=InstanceId,Value=$id --statistic Average --period 300 --evaluation-periods 2 \
    --threshold 80 --comparison-operator GreaterThanThreshold --alarm-actions $T
done

aws cloudwatch delete-alarms --alarm-names cpu-high-old
```

## 알람의 구성
```
지표(Namespace + MetricName + Dimensions)  →  통계(Average) 를 Period(300초) 마다 계산
  →  Threshold(80) 과 비교  →  EvaluationPeriods(2) 번 연속이면 ALARM  →  AlarmActions(SNS) 실행
```
- **차원(Dimensions)** 이 빠지거나 틀리면 "그 서버" 가 아니라 다른 지표를 보게 돼요. 데이터가 없으면 알람은 `INSUFFICIENT_DATA` 에 머물고 울리지 않아요.
- `evaluation-periods 2` 는 잠깐 튀는 것(배포 직후 등)에 알림 폭탄을 맞지 않으려는 장치예요.
- `--ok-actions` 를 같이 걸면 "복구됨" 알림도 받을 수 있어요.

## SNS 는 "방송국"
알람은 SNS 토픽 하나에만 알리고, 메일·Slack(Chatbot)·SMS·Lambda 는 그 토픽을 **구독**해요. 받는 사람이 바뀌어도 알람은 그대로 두고 구독만 바꾸면 돼요.

## 실무 팁
- 토픽을 지우면 그 토픽을 가리키는 알람은 **조용히 아무 데도 알리지 않아요.** 오늘 같은 정리가 가끔 필요한 이유예요.
- 서버마다 손으로 만들면 새 서버를 추가할 때 빠뜨려요 → 실무에서는 Terraform/CloudFormation 이나 Auto Scaling 그룹 단위 알람으로 만들어요.
- 메모리·디스크 사용률은 EC2 기본 지표에 없어요. 서버에 **CloudWatch Agent** 를 설치해야 `CWAgent` 네임스페이스로 들어와요 (위의 disk-full 알람처럼).
