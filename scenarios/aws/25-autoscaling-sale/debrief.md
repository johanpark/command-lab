# 해설

```bash
aws autoscaling update-auto-scaling-group --auto-scaling-group-name web-asg --min-size 4 --desired-capacity 4 --max-size 12
aws autoscaling put-scaling-policy --auto-scaling-group-name web-asg --policy-name cpu-target --policy-type TargetTrackingScaling \
  --target-tracking-configuration '{"PredefinedMetricSpecification":{"PredefinedMetricType":"ASGAverageCPUUtilization"},"TargetValue":50}'
aws autoscaling put-scheduled-update-group-action --auto-scaling-group-name web-asg --scheduled-action-name after-sale \
  --start-time 2026-11-12T02:00:00 --time-zone Asia/Seoul --min-size 2 --max-size 4 --desired-capacity 2
```

## 세 숫자의 의미
| | 뜻 | 세일 때 |
|---|---|---|
| 최소(min) | 아무리 한가해도 이만큼은 유지 | 미리 높여서 **콜드 스타트** 방지 |
| 원하는(desired) | 지금 목표 대수 (정책이 이 값을 움직임) | |
| 최대(max) | 아무리 바빠도 이 이상은 안 늘림 (비용 상한) | 여유 있게 |

## 왜 미리 늘려 두나
대상 추적 정책은 CPU 가 오른 **뒤에** 서버를 추가해요. 새 서버가 부팅하고 헬스 체크를 통과하기까지 몇 분이 걸려서, 세일 시작 순간처럼 **트래픽이 한꺼번에 몰릴 때는 늦어요.** 예상되는 피크는 미리(또는 예약 작업으로) 키워 두고, 예상 못 한 부분만 정책에 맡기는 게 정석이에요.

## 예약 작업과 시간대
- `--start-time` 에 시간대 표시가 없으면 **UTC** 로 해석돼요. 한국 02:00 을 그냥 쓰면 한국 11:00 에 줄어들어서 **세일 한가운데 서버가 반으로** 줄어요.
- `--time-zone Asia/Seoul` 을 쓰면 한국 시각 그대로 쓸 수 있고, 반복 예약(`--recurrence "0 9 * * MON-FRI"`)도 그 시간대 기준이 돼요.

## 실무 팁
- 매일 비슷한 패턴이면 **예측 스케일링(Predictive scaling)** 이 지난 2주 데이터를 보고 미리 늘려 줘요.
- 서버를 늘려도 **DB 연결 수, 외부 API 한도**가 병목이 될 수 있어요. 세일 전엔 그쪽 한도도 같이 확인하세요.
