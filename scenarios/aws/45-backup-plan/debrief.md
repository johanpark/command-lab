# 해설

```bash
aws backup create-backup-vault --backup-vault-name shop-vault
cat > plan.json <<'JSON'
{"BackupPlanName": "shop-backup",
 "Rules": [
  {"RuleName": "daily", "TargetBackupVaultName": "shop-vault",
   "ScheduleExpression": "cron(0 18 * * ? *)", "StartWindowMinutes": 60,
   "Lifecycle": {"DeleteAfterDays": 35}},
  {"RuleName": "monthly", "TargetBackupVaultName": "shop-vault",
   "ScheduleExpression": "cron(0 18 L * ? *)", "StartWindowMinutes": 60,
   "Lifecycle": {"MoveToColdStorageAfterDays": 30, "DeleteAfterDays": 365}}]}
JSON
aws backup create-backup-plan --backup-plan file://plan.json
aws backup delete-backup-plan --backup-plan-id $(aws backup list-backup-plans \
  --query "BackupPlansList[?BackupPlanName=='legacy-nightly'].BackupPlanId" --output text)
```

## "매달 1일 새벽" 의 함정
| 한국 시간 | UTC | cron (UTC) |
|---|---|---|
| 매일 03:00 | 전날 18:00 | `cron(0 18 * * ? *)` |
| 매달 1일 03:00 | **전달 말일** 18:00 | `cron(0 18 L * ? *)` |
| ❌ `cron(0 18 1 * ? *)` | 1일 18:00 | = 한국 **2일** 03:00 |

시간만 바꾸고 날짜를 안 바꾸는 실수가 정말 흔해요. 요즘은 규칙에 `ScheduleExpressionTimezone: Asia/Seoul` 을 넣고 **한국 시간 그대로** `cron(0 3 1 * ? *)` 로 쓰는 게 덜 헷갈려요. 서머타임이 있는 나라라면 더더욱.

## 시작 창(StartWindowMinutes)
백업은 정확히 그 시각에 시작하지 않고 "창" 안에서 시작해요. 기본은 **8시간**이라, 03시 백업이 오전 11시에 시작될 수도 있어요. 트래픽이 많은 시간에 백업이 돌면 DB 가 느려져요.

## 콜드 스토리지
- 싸지만(웜의 약 1/4) **최소 90일** 보관해야 하고, 복원이 느려요 → 자주 꺼낼 일 없는 월간 백업에 적당
- 그래서 `DeleteAfterDays ≥ MoveToColdStorageAfterDays + 90`. 예: 30일 뒤 콜드면 최소 120일 보관
- 일간 백업을 콜드로 보내는 건 손해예요 (35일 보관인데 최소 90일 요금을 내요)

## 다음 단계: 대상 지정
```bash
aws backup create-backup-selection --backup-plan-id ID --backup-selection \
  '{"SelectionName":"tagged","IamRoleArn":"arn:aws:iam::...:role/service-role/AWSBackupDefaultServiceRole",
    "ListOfTags":[{"ConditionType":"STRINGEQUALS","ConditionKey":"backup","ConditionValue":"daily"}]}'
```
태그(`backup=daily`)가 붙은 자원은 새로 만들어져도 자동으로 백업돼요. "새 DB 를 만들고 백업 설정을 깜빡함" 이 사라져요.
