P=~/sale-plan.md
N=$(grep -oE '최소 \*\*[0-9]+' $P | head -1 | grep -oE '[0-9]+')
X=$(grep -oE '최대 \*\*[0-9]+' $P | head -1 | grep -oE '[0-9]+')
C=$(grep -oE '\*\*[0-9]+%' $P | grep -oE '[0-9]+')
E=$(grep -oE '2026-11-12 [0-9]{2}:00' $P | cut -d' ' -f2 | cut -d: -f1)
aws autoscaling update-auto-scaling-group --auto-scaling-group-name web-asg --min-size "$N" --desired-capacity "$N" --max-size "$X"
echo "{\"PredefinedMetricSpecification\":{\"PredefinedMetricType\":\"ASGAverageCPUUtilization\"},\"TargetValue\":$C}" > ~/cpu.json
aws autoscaling put-scaling-policy --auto-scaling-group-name web-asg --policy-name cpu-target \
  --policy-type TargetTrackingScaling --target-tracking-configuration file://$HOME/cpu.json >/dev/null
aws autoscaling put-scheduled-update-group-action --auto-scaling-group-name web-asg --scheduled-action-name after-sale \
  --start-time "2026-11-12T$E:00:00" --time-zone Asia/Seoul --min-size 2 --max-size 4 --desired-capacity 2
