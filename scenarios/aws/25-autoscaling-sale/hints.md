크기는 한 번에: `aws autoscaling update-auto-scaling-group --auto-scaling-group-name web-asg --min-size N --desired-capacity N --max-size M`
(원하는 수는 최소 이상, 최대 이하여야 해요)
---
대상 추적 정책 설정 파일 `cpu.json`:
```json
{"PredefinedMetricSpecification": {"PredefinedMetricType": "ASGAverageCPUUtilization"}, "TargetValue": 50}
```
`aws autoscaling put-scaling-policy --auto-scaling-group-name web-asg --policy-name cpu-target --policy-type TargetTrackingScaling --target-tracking-configuration file://cpu.json`
---
예약 시각은 두 가지 방법 중 하나로:
- UTC 로 바꿔서: 예) 한국 11-12 02:00 → `--start-time 2026-11-11T17:00:00Z`
- 시간대를 지정: `--start-time 2026-11-12T02:00:00 --time-zone Asia/Seoul`

`aws autoscaling describe-scheduled-actions --auto-scaling-group-name web-asg` 로 확인하세요.
