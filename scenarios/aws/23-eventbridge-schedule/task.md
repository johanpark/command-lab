# 새벽 배치가 오후에 돌아요 (EventBridge 예약 규칙, UTC)

"매일 새벽 4시" 에 돌아야 할 로그 정리 작업이 **오후 1시**에 돌면서, 손님이 많은 시간에 서비스가 느려졌어요.
예약 작업 목록은 `~/schedule.md` 에 있어요.

## 목표
1. `log-cleanup` 규칙이 **한국 시간 매일 04:00** 에 돌도록 고치세요. (대상은 그대로)
2. 새 규칙 **`nightly-sales-report`** 를 만드세요.
   - **한국 시간 평일(월~금) 03:XX** (분은 `~/schedule.md` 참고)
   - 대상: SQS 큐 `report-jobs`
3. `weekly-invoice` 는 이미 맞게 돼 있으니 건드리지 마세요.

## 써볼 명령어
| 명령어 | 하는 일 |
|---|---|
| `aws events list-rules --query "Rules[].[Name,ScheduleExpression,State]" --output table` | 규칙 목록 |
| `aws events list-targets-by-rule --rule 이름` | 규칙이 깨우는 대상 |
| `aws events put-rule --name 이름 --schedule-expression "cron(분 시 일 월 요일 연도)"` | 규칙 만들기 / 바꾸기 |
| `aws events put-targets --rule 이름 --targets Id=아무거나,Arn=대상ARN` | 대상 연결 |
| `aws sqs get-queue-attributes --queue-url URL --attribute-names QueueArn` | 큐의 ARN |

> 💡 한국 시간에서 9시간을 빼면 UTC 예요. **날짜(요일)가 바뀌는지** 꼭 확인하세요.
