# CPU 가 치솟으면 알림 받기 (CloudWatch 알람, SNS)

어젯밤 운영 서버 CPU 가 몇 시간 동안 100% 였는데 **아무도 몰랐어요.** 알람이 없었거든요.
팀에서 정한 규칙은 `~/runbook.md` 에 있어요.

## 목표
1. SNS 토픽 **`ops-alerts`** 에 당직 메일 **`oncall@shop.example`** 을 **email** 로 구독시키세요.
2. **`Env=prod` 이고 실행 중인** 서버마다 CPU 알람 `cpu-high-서버이름` 을 만드세요. (`Team=db` 서버는 제외)
   - 지표: `AWS/EC2` 의 `CPUUtilization`, 차원 `InstanceId=그 서버`
   - 조건: **평균(Average)** 이 **300초** 간격으로 **2번 연속 80 초과** (`GreaterThanThreshold`)
   - 알림: `ops-alerts` 토픽
3. 알림을 보낼 **토픽이 이미 없어진** 옛 알람을 지우세요. 다른 알람은 그대로 두세요.

## 써볼 명령어
| 명령어 | 하는 일 |
|---|---|
| `aws sns list-topics` / `aws sns subscribe --topic-arn ARN --protocol email --notification-endpoint 메일` | 토픽 목록 / 구독 |
| `aws ec2 describe-instances --filters Name=tag:Env,Values=prod Name=instance-state-name,Values=running` | 대상 서버 |
| `aws cloudwatch describe-alarms --query "MetricAlarms[].[AlarmName,AlarmActions[0]]"` | 지금 있는 알람 |
| `aws cloudwatch put-metric-alarm --alarm-name ... --namespace AWS/EC2 --metric-name CPUUtilization --dimensions Name=InstanceId,Value=i-... --statistic Average --period 300 --evaluation-periods 2 --threshold 80 --comparison-operator GreaterThanThreshold --alarm-actions ARN` | 알람 만들기 |
| `aws cloudwatch delete-alarms --alarm-names 이름` | 알람 지우기 |
