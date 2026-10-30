# 해설

```bash
aws events put-rule --name log-cleanup --schedule-expression "cron(0 19 * * ? *)"          # KST 04:00 = UTC 전날 19:00
aws events put-rule --name nightly-sales-report --schedule-expression "cron(30 18 ? * SUN-THU *)"  # KST 월~금 03:30
aws events put-targets --rule nightly-sales-report --targets Id=report,Arn=arn:aws:sqs:ap-northeast-2:123456789012:report-jobs
```

## KST ↔ UTC 변환표
| 한국 (KST) | UTC | cron |
|---|---|---|
| 매일 04:00 | 전날 19:00 | `cron(0 19 * * ? *)` |
| 월~금 03:30 | **일~목** 18:30 | `cron(30 18 ? * SUN-THU *)` |
| 월 09:00 | 월 00:00 | `cron(0 0 ? * MON *)` (날짜 안 넘어감) |

- 한국 시간 **00:00~08:59** 는 UTC 로 **전날**이에요. 요일·날짜가 들어간 규칙은 이때 꼭 하루를 당겨야 해요.
- `MON-FRI` 를 그대로 쓰면 한국 시간 **화~토** 새벽에 돌아요. 월요일 보고서가 안 나오고 토요일에 엉뚱하게 나와요.

## EventBridge cron 의 특이한 점
- 필드가 **6개** (마지막에 연도). 리눅스 crontab 은 5개.
- **일(day-of-month)과 요일 중 하나는 반드시 `?`**. 둘 다 `*` 면 에러.
- 요일 숫자는 **1=일요일 ~ 7=토요일** (리눅스는 0=일요일).

## 실무 팁
- 새로 만든다면 **EventBridge Scheduler**(`aws scheduler create-schedule`)를 쓰세요. `--schedule-expression-timezone Asia/Seoul` 로 **시간대를 지정**할 수 있어서 이런 변환이 필요 없어요.
- 서버(리눅스 cron), DB, 로그는 UTC 로 통일하고 화면에 보여줄 때만 KST 로 바꾸는 팀이 많아요. 어느 쪽이든 **문서에 기준 시간대를 꼭 적어 두세요.**
