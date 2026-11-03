한국 시간(KST)은 UTC 보다 9시간 빨라요. **한국 03:00 = UTC 전날 18:00**.
매일 한국 03시 → `cron(0 18 * * ? *)` (매일 UTC 18시)
---
매달 1일 한국 03시는 UTC 로 **전달 마지막 날 18시**예요. `cron(0 18 1 * ? *)` 는 UTC 1일 18시 = **한국 2일 03시**가 돼요!
마지막 날은 달마다 다르니(28·30·31일) 일 자리에 `L`: `cron(0 18 L * ? *)`
(또는 규칙에 `"ScheduleExpressionTimezone": "Asia/Seoul"` 을 넣고 한국 시간 그대로 `cron(0 3 1 * ? *)`)
---
"1시간 안에 시작" 은 `"StartWindowMinutes": 60` (기본값은 480분 = 8시간).
보관: daily 는 `{"DeleteAfterDays": 35}`, monthly 는 `{"MoveToColdStorageAfterDays": 30, "DeleteAfterDays": 365}`.
콜드 스토리지는 **최소 90일** 머물러야 해서 `DeleteAfterDays` 는 `MoveToColdStorageAfterDays + 90` 이상이어야 해요 (365 는 OK).
---
`aws backup create-backup-vault --backup-vault-name shop-vault` → `plan.json` 작성 → `aws backup create-backup-plan --backup-plan file://plan.json`.
틀렸으면 `update-backup-plan` 으로 통째로 다시 넣어요. 옛 계획은 `list-backup-plans` 로 ID 를 찾아 `delete-backup-plan`.
