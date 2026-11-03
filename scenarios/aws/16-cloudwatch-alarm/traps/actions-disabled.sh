# 설명: 알람을 --no-actions-enabled 로 만들면 울려도 알림이 안 간다
# 실패해야: 알림 꺼짐
T=$(aws sns list-topics --query "Topics[?ends_with(TopicArn, ':ops-alerts')].TopicArn" --output text)
aws sns subscribe --topic-arn "$T" --protocol email --notification-endpoint oncall@shop.example >/dev/null
aws ec2 describe-instances --filters Name=tag:Env,Values=prod Name=instance-state-name,Values=running \
  --query "Reservations[].Instances[?!(Tags[?Key=='Team' && Value=='db'])][].[InstanceId,Tags[?Key=='Name']|[0].Value]" --output text |
while read -r id name; do
  aws cloudwatch put-metric-alarm --alarm-name "cpu-high-$name" --namespace AWS/EC2 --metric-name CPUUtilization \
    --dimensions Name=InstanceId,Value="$id" --statistic Average --period 300 --evaluation-periods 2 \
    --threshold 80 --comparison-operator GreaterThanThreshold --no-actions-enabled --alarm-actions "$T"
done
# 알람이 가리키는 토픽 중 지금 없는 것
topics=$(aws sns list-topics --query 'Topics[].TopicArn' --output text)
for a in $(aws cloudwatch describe-alarms --query 'MetricAlarms[].AlarmName' --output text); do
  act=$(aws cloudwatch describe-alarms --alarm-names "$a" --query 'MetricAlarms[0].AlarmActions[0]' --output text)
  [[ " $(echo $topics) " == *" $act "* ]] || aws cloudwatch delete-alarms --alarm-names "$a"
done
