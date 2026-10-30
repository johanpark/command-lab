# 해설

```bash
aws logs put-metric-filter --log-group-name /shop/api --filter-name api-errors \
  --filter-pattern '{ $.level = "ERROR" }' \
  --metric-transformations metricName=ApiErrors,metricNamespace=Shop,metricValue=1,defaultValue=0
aws cloudwatch put-metric-alarm --alarm-name api-errors-high --namespace Shop --metric-name ApiErrors \
  --statistic Sum --period 60 --evaluation-periods 3 --threshold 10 \
  --comparison-operator GreaterThanOrEqualToThreshold --treat-missing-data notBreaching --alarm-actions <ops-alerts ARN>
```

## 로그 → 지표 → 알람
```
로그 줄 ──(지표 필터: 패턴에 걸리면 +1)──▶ Shop/ApiErrors ──(알람: 1분 합계 ≥ 10, 3번 연속)──▶ SNS
```
- 지표 필터는 **만든 뒤에 들어오는 로그부터** 세요. 지난 로그를 다시 세지는 않아요.
- `defaultValue=0` 이 없으면 에러가 없는 시간엔 데이터가 아예 없어서, 그래프가 끊기고 알람이 `INSUFFICIENT_DATA` 가 돼요.

## 글자 검색 vs JSON 필터
| 패턴 | 결과 |
|---|---|
| `ERROR` | "user typed ERROR", "retry after ERROR_TIMEOUT" 같은 **정상 줄까지** 셈 → 거짓 알람 |
| `{ $.level = "ERROR" }` | level 필드만 봄 → 정확 |

로그를 **JSON 으로 남기는 습관**이 이래서 중요해요. 필드로 거르고, 숫자 필드(`$.ms > 1000`)로 느린 요청도 셀 수 있어요.

## TreatMissingData
- `missing`(기본): 데이터가 없으면 판단 보류 → 알람 상태가 애매하게 남음
- `notBreaching`: 데이터가 없으면 정상 → 에러 개수처럼 "없으면 좋은 것" 에 맞음
- `breaching`: 데이터가 없으면 위험 → 하트비트(살아 있음 신호) 지표에 맞음

## 실무 팁
- 실제 AWS 에서는 `aws logs test-metric-filter --filter-pattern ... --log-event-messages ...` 로 패턴을 미리 시험할 수 있어요. (이 실습 환경에서는 지원 안 됨)
- 같은 일을 **CloudWatch Logs Insights** 쿼리(`filter level = "ERROR" | stats count() by bin(1m)`)로 먼저 분석해 보고 필터를 만들면 좋아요.
