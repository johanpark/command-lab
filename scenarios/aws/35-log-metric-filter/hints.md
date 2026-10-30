로그부터 보세요: `aws logs filter-log-events --log-group-name /shop/api --limit 20 --query 'events[].message' --output text`
그리고 단순 글자 검색이 몇 줄 걸리는지: `aws logs filter-log-events --log-group-name /shop/api --filter-pattern ERROR --query 'length(events)'`
→ msg 에 ERROR 글자가 들어간 INFO 줄까지 걸려요.
---
JSON 로그는 필드로 거를 수 있어요: `--filter-pattern '{ $.level = "ERROR" }'`
(작은따옴표로 감싸야 셸이 `$.level` 을 변수로 바꾸지 않아요) 걸리는 줄 수가 달라지는지 비교해 보세요.
---
```
aws logs put-metric-filter --log-group-name /shop/api --filter-name api-errors \
  --filter-pattern '{ $.level = "ERROR" }' \
  --metric-transformations metricName=ApiErrors,metricNamespace=Shop,metricValue=1,defaultValue=0
```
---
"10 이상" 은 `GreaterThanOrEqualToThreshold` (GreaterThanThreshold 는 10 초과).
`--statistic Sum --period 60 --evaluation-periods 3 --threshold 10 --treat-missing-data notBreaching --alarm-actions <ops-alerts ARN>`
