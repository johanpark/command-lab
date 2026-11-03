# 설명: 한국 시간을 그대로 cron 에 넣고, 매달 1일을 UTC 1일로 쓴다 (= 한국 2일)
# 실패해야: daily 규칙이 한국 시간
# 실패해야: monthly 규칙이 한국 시간
aws backup create-backup-vault --backup-vault-name shop-vault
cat > ~/plan.json <<'JSON'
{"BackupPlanName": "shop-backup",
 "Rules": [
  {"RuleName": "daily", "TargetBackupVaultName": "shop-vault",
   "ScheduleExpression": "cron(0 3 * * ? *)", "StartWindowMinutes": 60,
   "Lifecycle": {"DeleteAfterDays": 35}},
  {"RuleName": "monthly", "TargetBackupVaultName": "shop-vault",
   "ScheduleExpression": "cron(0 18 1 * ? *)", "StartWindowMinutes": 60,
   "Lifecycle": {"MoveToColdStorageAfterDays": 30, "DeleteAfterDays": 365}}]}
JSON
aws backup create-backup-plan --backup-plan file://$HOME/plan.json
L=$(aws backup list-backup-plans --query "BackupPlansList[?BackupPlanName=='legacy-nightly'].BackupPlanId" --output text)
aws backup delete-backup-plan --backup-plan-id "$L"
