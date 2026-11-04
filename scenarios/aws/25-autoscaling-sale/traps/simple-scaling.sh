# 설명: 단순 조정(SimpleScaling) 정책으로는 평균 CPU 를 목표로 맞추지 못한다
# 실패해야: 대상 추적 정책
P=~/sale-plan.md
N=$(grep -oE '최소 \*\*[0-9]+' $P | head -1 | grep -oE '[0-9]+')
X=$(grep -oE '최대 \*\*[0-9]+' $P | head -1 | grep -oE '[0-9]+')
C=$(grep -oE '\*\*[0-9]+%' $P | grep -oE '[0-9]+')
read -r DAY T < <(grep -oE '20[0-9]{2}-[0-9]{2}-[0-9]{2} [0-9]{2}:00' $P | head -1); E=${T%%:*}
aws autoscaling update-auto-scaling-group --auto-scaling-group-name web-asg --min-size "$N" --desired-capacity "$N" --max-size "$X"
echo "{\"PredefinedMetricSpecification\":{\"PredefinedMetricType\":\"ASGAverageCPUUtilization\"},\"TargetValue\":$C}" > ~/cpu.json
aws autoscaling put-scaling-policy --auto-scaling-group-name web-asg --policy-name cpu-target \
  --policy-type SimpleScaling --adjustment-type ChangeInCapacity --scaling-adjustment 1 >/dev/null
aws autoscaling put-scheduled-update-group-action --auto-scaling-group-name web-asg --scheduled-action-name after-sale \
  --start-time "${DAY}T$E:00:00" --time-zone Asia/Seoul --min-size 2 --max-size 4 --desired-capacity 2
