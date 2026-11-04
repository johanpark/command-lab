# 설명: --time-zone 없이 한국 시각을 넣으면 UTC 로 해석돼 9시간 늦게 줄어든다
# 실패해야: 한국 시간을 UTC 로 넣었어요
P=~/sale-plan.md
N=$(grep -oE '최소 \*\*[0-9]+' $P | head -1 | grep -oE '[0-9]+')
X=$(grep -oE '최대 \*\*[0-9]+' $P | head -1 | grep -oE '[0-9]+')
C=$(grep -oE '\*\*[0-9]+%' $P | grep -oE '[0-9]+')
read -r DAY T < <(grep -oE '20[0-9]{2}-[0-9]{2}-[0-9]{2} [0-9]{2}:00' $P | head -1); E=${T%%:*}
aws autoscaling update-auto-scaling-group --auto-scaling-group-name web-asg --min-size "$N" --desired-capacity "$N" --max-size "$X"
echo "{\"PredefinedMetricSpecification\":{\"PredefinedMetricType\":\"ASGAverageCPUUtilization\"},\"TargetValue\":$C}" > ~/cpu.json
aws autoscaling put-scaling-policy --auto-scaling-group-name web-asg --policy-name cpu-target \
  --policy-type TargetTrackingScaling --target-tracking-configuration file://$HOME/cpu.json >/dev/null
aws autoscaling put-scheduled-update-group-action --auto-scaling-group-name web-asg --scheduled-action-name after-sale \
  --start-time "${DAY}T$E:00:00" --min-size 2 --max-size 4 --desired-capacity 2
