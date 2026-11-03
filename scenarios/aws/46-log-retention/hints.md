먼저 전체를 보세요: `aws logs describe-log-groups --query 'logGroups[].[logGroupName,retentionInDays]' --output table`
그리고 살아 있는 함수: `aws lambda list-functions --query 'Functions[].FunctionName' --output text`
---
`/shop/app/` 는 반복문 하나면 돼요:
`for g in $(aws logs describe-log-groups --log-group-name-prefix /shop/app/ --query 'logGroups[].logGroupName' --output text); do aws logs put-retention-policy --log-group-name $g --retention-in-days 30; done`
---
람다 로그 그룹 이름은 `/aws/lambda/함수이름` 이에요. 그룹마다 함수가 있는지 **이름 전체가 똑같은지** 비교하세요.
⚠️ `order-api-old` 는 `order-api` 로 **시작**하지만 다른 함수예요. `grep order-api` 처럼 일부만 비교하면 헷갈려요 (`grep -x` 는 줄 전체 비교).
있으면 `put-retention-policy ... 14`, 없으면 `delete-log-group`.
---
감사 로그: payment 는 이미 731일(2년)이에요. 400 으로 바꾸면 **줄이는** 거라 안 돼요. 보존 기간이 없거나(`None`) 400 보다 짧은 것만 400 으로:
```
aws logs describe-log-groups --log-group-name-prefix /shop/audit/ \
  --query 'logGroups[?!retentionInDays || retentionInDays < `400`].logGroupName' --output text
```
