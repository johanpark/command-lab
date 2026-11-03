aws backup create-backup-vault --backup-vault-name shop-vault
cat > ~/plan.json <<'JSON'
{"BackupPlanName": "shop-backup",
 "Rules": [
  {"RuleName": "daily", "TargetBackupVaultName": "shop-vault",
   "ScheduleExpression": "cron(0 18 * * ? *)", "StartWindowMinutes": 60,
   "Lifecycle": {"DeleteAfterDays": 35}},
  {"RuleName": "monthly", "TargetBackupVaultName": "shop-vault",
   "ScheduleExpression": "cron(0 18 L * ? *)", "StartWindowMinutes": 60,
   "Lifecycle": {"MoveToColdStorageAfterDays": 30, "DeleteAfterDays": 365}}]}
JSON
aws backup create-backup-plan --backup-plan file://$HOME/plan.json
L=$(aws backup list-backup-plans --query "BackupPlansList[?BackupPlanName=='legacy-nightly'].BackupPlanId" --output text)
aws backup delete-backup-plan --backup-plan-id "$L"
