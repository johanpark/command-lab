#!/usr/bin/env bash
source /opt/cmdlab/lib/helpers.sh
source /usr/local/lib/lab-aws.sh
set -e
wait_aws
ami=$(lab_ami); S=/opt/cmdlab/secret
inst() { # 이름 Env
  aws ec2 run-instances --image-id "$ami" --instance-type t3.medium \
    --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=$1},{Key=Env,Value=$2}]" --query 'Instances[0].InstanceId' --output text
}
: > $S/prod
names="prod-web-1 prod-web-2 $(rand_pick prod-api-1 prod-worker-1)"
for n in $names; do echo "$(inst "$n" prod) $n" >> $S/prod; done
: > $S/other
for n in dev-web-1:dev staging-web-1:staging; do inst "${n%%:*}" "${n#*:}" >> $S/other; done
old=$(inst prod-web-0 prod); aws ec2 terminate-instances --instance-ids "$old" >/dev/null; echo "$old" >> $S/other
T=$(aws sns create-topic --name ops-alerts --query TopicArn --output text); secret_set topic "$T"
L=$(aws sns create-topic --name legacy-alerts --query TopicArn --output text)
db=$(inst prod-db-1 prod); echo "$db prod-db-1" > $S/db
aws cloudwatch put-metric-alarm --alarm-name disk-full-prod-db-1 --namespace CWAgent --metric-name disk_used_percent \
  --dimensions Name=InstanceId,Value="$db" --statistic Maximum --period 300 --evaluation-periods 1 --threshold 90 \
  --comparison-operator GreaterThanThreshold --alarm-actions "$T"
aws cloudwatch put-metric-alarm --alarm-name cpu-high-old --namespace AWS/EC2 --metric-name CPUUtilization \
  --dimensions Name=InstanceId,Value="$old" --statistic Average --period 300 --evaluation-periods 2 --threshold 80 \
  --comparison-operator GreaterThanThreshold --alarm-actions "$L"
aws sns delete-topic --topic-arn "$L"
# prod-db-1 은 디스크 알람이 이미 있고, CPU 알람 대상에서는 빼기로 했다 (DB 팀이 따로 관리)
aws ec2 create-tags --resources "$db" --tags Key=Env,Value=prod Key=Team,Value=db
mkdir -p "$H"
cat > "$H/runbook.md" <<MD
# 모니터링 정리

- 알림 받을 곳: SNS 토픽 \`ops-alerts\` → 당직 메일 **oncall@shop.example**
- CPU 알람 규칙: \`Env=prod\` 이고 **실행 중(running)** 인 서버마다 하나씩
  - 이름: \`cpu-high-서버이름\` (예: cpu-high-prod-web-1)
  - AWS/EC2 의 CPUUtilization, **평균(Average)** 이 **5분(300초) 간격으로 2번 연속 80 초과**면 알림
  - 예외: \`Team=db\` 서버는 DB 팀이 따로 관리하니 만들지 않음
- 알림을 보낼 토픽이 사라진 옛 알람은 지우기
MD
give "$H/runbook.md"
