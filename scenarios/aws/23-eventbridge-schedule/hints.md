지금 규칙들: `aws events list-rules --query "Rules[].[Name,ScheduleExpression,Description]" --output table`
`log-cleanup` 의 `cron(0 4 * * ? *)` 는 **UTC 04:00** = 한국 시간 **13:00** 이에요.
---
KST → UTC 는 **9시간 빼기**. 한국 04:00 → UTC 전날 19:00 → `cron(0 19 * * ? *)`
`put-rule` 을 같은 이름으로 다시 실행하면 그 규칙이 바뀌어요 (대상은 그대로 유지).
---
한국 **월요일 03:XX** 는 UTC 로 **일요일 18:XX** 예요. 요일도 하루씩 당겨져요: 한국 월~금 → UTC **일~목**.
`cron(XX 18 ? * SUN-THU *)` (일은 `?`, 요일은 `SUN-THU`)
---
대상 연결: 큐 ARN 은 `arn:aws:sqs:ap-northeast-2:123456789012:report-jobs` 모양이에요.
`aws events put-targets --rule nightly-sales-report --targets Id=report,Arn=<큐 ARN>`
