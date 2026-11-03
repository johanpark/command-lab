# DB 백업을 한 곳에서 관리하기 (AWS Backup)

백업이 서비스마다 제각각이에요. RDS 는 자동 백업, DynamoDB 는 생각날 때 손으로, EC2 는 아예 없어요. **AWS Backup** 으로 모으기로 했어요. 정책은 `~/backup-policy.md` 에 있어요.

AWS Backup 은 세 가지로 이뤄져요.
- **볼트(vault)**: 백업이 저장되는 금고
- **계획(plan)**: "언제, 어느 볼트에, 얼마나 보관" 규칙 묶음
- 대상 지정(selection): 어떤 자원을 백업할지 (이번엔 하지 않아요)

## 목표
1. 볼트 **`shop-vault`** 를 만드세요.
2. 계획 **`shop-backup`** 을 만들고 규칙 두 개를 넣으세요.
   - `daily`: **매일 03:00 (한국 시간)**, 35일 보관
   - `monthly`: **매달 1일 03:00 (한국 시간)**, 30일 뒤 콜드 스토리지, 365일 보관
   - 둘 다 `shop-vault` 에, 정해진 시각에서 **1시간 안에 시작**
3. 옛 계획 **`legacy-nightly`** 를 지우세요.

## 써볼 명령어
| 명령어 | 하는 일 |
|---|---|
| `aws backup list-backup-vaults` / `create-backup-vault --backup-vault-name 이름` | 볼트 목록 / 만들기 |
| `aws backup list-backup-plans` | 계획 목록 (이름, ID) |
| `aws backup create-backup-plan --backup-plan file://plan.json` | 계획 만들기 |
| `aws backup get-backup-plan --backup-plan-id ID` | 계획 내용 보기 |
| `aws backup update-backup-plan --backup-plan-id ID --backup-plan file://plan.json` | 계획 고치기 (통째로 바꿈) |
| `aws backup delete-backup-plan --backup-plan-id ID` | 계획 지우기 |

`plan.json` 의 모양:
```json
{"BackupPlanName": "이름",
 "Rules": [{"RuleName": "이름", "TargetBackupVaultName": "볼트",
            "ScheduleExpression": "cron(분 시 일 월 요일 연도)",
            "StartWindowMinutes": 분,
            "Lifecycle": {"MoveToColdStorageAfterDays": 일, "DeleteAfterDays": 일}}]}
```
- cron 은 기본이 **UTC** 예요. 일과 요일 중 하나는 `?`, 일 자리에 `L` 을 쓰면 "그달 마지막 날"
- 시간대를 직접 정하려면 규칙에 `"ScheduleExpressionTimezone": "Asia/Seoul"` 을 넣어도 돼요
