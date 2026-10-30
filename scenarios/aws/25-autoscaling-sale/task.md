# 세일 이벤트 대비 서버 늘리고 줄이기 (Auto Scaling)

내일 대형 세일이 있어요. 웹 서버들은 **오토스케일링 그룹 `web-asg`** 로 운영 중이에요.
인프라 계획은 `~/sale-plan.md` 에 있어요.

## 목표
1. `web-asg` 의 크기를 계획대로 **지금 바로** 늘리세요. (최소 / 원하는 / 최대)
2. **대상 추적 정책 `cpu-target`** 을 만들어 그룹 평균 CPU 를 계획한 값으로 유지하게 하세요.
3. **예약 작업 `after-sale`** 을 만들어, 세일이 끝나는 **한국 시간** 시각에 평소 크기(2 / 2 / 4)로 돌아오게 하세요.
4. `batch-asg` 는 건드리지 마세요.

## 써볼 명령어
| 명령어 | 하는 일 |
|---|---|
| `aws autoscaling describe-auto-scaling-groups --query "AutoScalingGroups[].[AutoScalingGroupName,MinSize,DesiredCapacity,MaxSize]" --output table` | 그룹 크기 |
| `aws autoscaling update-auto-scaling-group --auto-scaling-group-name 이름 --min-size N --desired-capacity N --max-size N` | 크기 바꾸기 |
| `aws autoscaling put-scaling-policy --auto-scaling-group-name 이름 --policy-name 이름 --policy-type TargetTrackingScaling --target-tracking-configuration file://cpu.json` | 대상 추적 정책 |
| `aws autoscaling put-scheduled-update-group-action --auto-scaling-group-name 이름 --scheduled-action-name 이름 --start-time 시각 --min-size .. --max-size .. --desired-capacity ..` | 예약 작업 |

> 💡 `--start-time` 은 기본이 **UTC** 예요 (`2026-11-12T00:00:00Z` 처럼 끝에 Z). 한국 시간으로 쓰고 싶다면 `--time-zone Asia/Seoul` 을 같이 줘요.
