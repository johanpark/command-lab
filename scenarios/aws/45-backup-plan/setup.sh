#!/usr/bin/env bash
source /opt/cmdlab/lib/helpers.sh
source /usr/local/lib/lab-aws.sh
set -e
wait_aws
aws backup create-backup-vault --backup-vault-name Default >/dev/null
cat > /tmp/legacy.json <<'JSON'
{"BackupPlanName": "legacy-nightly",
 "Rules": [{"RuleName": "nightly", "TargetBackupVaultName": "Default", "ScheduleExpression": "cron(0 3 * * ? *)",
            "Lifecycle": {"DeleteAfterDays": 7}}]}
JSON
aws backup create-backup-plan --backup-plan file:///tmp/legacy.json --query BackupPlanId --output text > /opt/cmdlab/secret/legacy
rm -f /tmp/legacy.json
mkdir -p "$H"
cat > "$H/backup-policy.md" <<'MD'
# 백업 정책 (2026-11 개정)

지금은 RDS 는 자동 백업, DynamoDB 는 손으로 가끔, EC2 는 없음... 제각각이에요.
**AWS Backup** 계획 하나로 모읍니다. (대상 지정은 다음 주에 태그로 할 예정. 이번엔 계획까지만)

## 볼트
- 이름: `shop-vault` (백업이 저장되는 금고)

## 계획 `shop-backup`
| 규칙 이름 | 언제 (한국 시간) | 저장할 볼트 | 보관 |
|---|---|---|---|
| `daily` | **매일 03:00** | shop-vault | 35일 뒤 삭제 |
| `monthly` | **매달 1일 03:00** | shop-vault | 30일 뒤 콜드 스토리지로 옮기고, 365일 뒤 삭제 |

- 두 규칙 모두 정해진 시각에서 **1시간 안에 시작**해야 해요 (그 뒤엔 서비스 트래픽이 늘어요)
- AWS Backup 의 cron 은 기본이 **UTC** 예요

## 정리
- 옛 계획 `legacy-nightly` (Default 볼트, 7일 보관)는 새 계획으로 대체하니 **삭제**
MD
give "$H/backup-policy.md"
