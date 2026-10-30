# 에러 로그가 쌓이면 알람 받기 (CloudWatch Logs 지표 필터)

어젯밤 API 에러가 한 시간 동안 쏟아졌는데 아무도 몰랐어요. 로그는 CloudWatch Logs 의 `/shop/api` 에 잘 쌓이고 있었는데 말이죠.
로그를 **지표로 바꾸는 "지표 필터"** 를 걸면, 그 지표에 알람을 달 수 있어요. 규칙은 `~/alert-rule.md` 에 있어요.

## 목표
1. `/shop/api` 에 지표 필터 **`api-errors`** 를 만드세요. **`level` 이 `ERROR` 인 줄만** 세야 해요.
   - 지표: 네임스페이스 `Shop`, 이름 `ApiErrors`, 값 `1`, 기본값 `0`
2. 알람 **`api-errors-high`** 를 만드세요: 1분 합계가 10 이상인 상태가 3번 연속이면 `ops-alerts` 로 알림, 데이터 없음은 정상 처리.

## 써볼 명령어
| 명령어 | 하는 일 |
|---|---|
| `aws logs filter-log-events --log-group-name /shop/api --filter-pattern '패턴' --query 'events[].message'` | 패턴에 걸리는 줄 미리 보기 |
| `aws logs put-metric-filter --log-group-name 그룹 --filter-name 이름 --filter-pattern '패턴' --metric-transformations metricName=..,metricNamespace=..,metricValue=1,defaultValue=0` | 지표 필터 |
| `aws logs describe-metric-filters --log-group-name 그룹` | 확인 |
| `aws cloudwatch put-metric-alarm --alarm-name .. --namespace .. --metric-name .. --statistic Sum --period 60 --evaluation-periods 3 --threshold 10 --comparison-operator .. --treat-missing-data notBreaching --alarm-actions ARN` | 알람 |

**필터 패턴 문법** (일부)
| 패턴 | 걸리는 줄 |
|---|---|
| `ERROR` | `ERROR` 라는 글자가 **어디든** 있는 줄 |
| `"ERROR" -retry` | ERROR 가 있고 retry 는 없는 줄 |
| `{ $.level = "ERROR" }` | **JSON** 로그에서 `level` 필드가 `ERROR` 인 줄 |
