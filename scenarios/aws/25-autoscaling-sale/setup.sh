#!/usr/bin/env bash
source /opt/cmdlab/lib/helpers.sh
source /usr/local/lib/lab-aws.sh
set -e
wait_aws
ami=$(lab_ami)
SN=$(aws ec2 describe-subnets --filters Name=default-for-az,Values=true --query 'Subnets[0:2].SubnetId' --output text | tr '\t' ',')
for lt in web-lt batch-lt; do
  aws ec2 create-launch-template --launch-template-name $lt --launch-template-data "{\"ImageId\":\"$ami\",\"InstanceType\":\"t3.medium\"}" >/dev/null
done
aws autoscaling create-auto-scaling-group --auto-scaling-group-name web-asg --launch-template LaunchTemplateName=web-lt \
  --min-size 2 --max-size 4 --desired-capacity 2 --vpc-zone-identifier "$SN"
aws autoscaling create-auto-scaling-group --auto-scaling-group-name batch-asg --launch-template LaunchTemplateName=batch-lt \
  --min-size 1 --max-size 3 --desired-capacity 1 --vpc-zone-identifier "$SN"
aws autoscaling describe-auto-scaling-groups --auto-scaling-group-names batch-asg \
  --query 'AutoScalingGroups[0].[MinSize,MaxSize,DesiredCapacity]' --output text > /opt/cmdlab/secret/batch
N=$(rand_pick 4 5 6); X=$(rand_pick 12 15 20); C=$(rand_pick 50 60); E=$(rand_pick 01 02 03)
# 세일은 내일, 끝나는 건 모레 새벽 (한국 시간 기준, 실습하는 날에 맞춘다)
D=$(TZ=Asia/Seoul date -d "+2 day" +%F)
secret_set n "$N"; secret_set x "$X"; secret_set c "$C"; secret_set e "$E"; secret_set day "$D"
mkdir -p "$H"
cat > "$H/sale-plan.md" <<MD
# 내일 대형 세일 인프라 계획 (web-asg)

평소: 최소 2 / 원하는 2 / 최대 4

1. **지금 바로** 미리 늘려 두기 (세일 시작 순간 몰리는 트래픽 대비)
   - 최소 **$N** / 원하는 **$N** / 최대 **$X**
2. 세일 중에는 CPU 를 보고 자동으로 늘고 줄게
   - **대상 추적(Target tracking)** 정책, 이름 \`cpu-target\`
   - 그룹 평균 CPU 사용률 **$C%** 유지
3. 세일 끝나면 원래대로
   - 예약 작업 이름 \`after-sale\`
   - **한국 시간 $D $E:00** 에 최소 2 / 원하는 2 / 최대 4 로

※ batch-asg 는 이번 세일과 상관없음. 건드리지 말 것.
MD
give "$H/sale-plan.md"
