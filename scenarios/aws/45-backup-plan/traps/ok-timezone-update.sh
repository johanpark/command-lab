# 설명: 한국 시간대(Asia/Seoul)를 지정하고 잘못 만든 계획을 update-backup-plan 으로 고쳐도 맞는 풀이다
# 통과해야
aws backup create-backup-vault --backup-vault-name shop-vault
cat > ~/plan.json <<'JSON'
{"BackupPlanName": "shop-backup", "Rules": [{"RuleName": "daily", "TargetBackupVaultName": "shop-vault", "ScheduleExpression": "cron(0 3 * * ? *)", "Lifecycle": {"DeleteAfterDays": 35}}]}
JSON
ID=$(aws backup create-backup-plan --backup-plan file://$HOME/plan.json --query BackupPlanId --output text)
cat > ~/plan.json <<'JSON'
{"BackupPlanName": "shop-backup",
 "Rules": [
  {"RuleName": "daily", "TargetBackupVaultName": "shop-vault", "ScheduleExpression": "cron(0 3 ? * * *)", "ScheduleExpressionTimezone": "Asia/Seoul", "StartWindowMinutes": 60, "Lifecycle": {"DeleteAfterDays": 35}},
  {"RuleName": "monthly", "TargetBackupVaultName": "shop-vault", "ScheduleExpression": "cron(0 3 1 * ? *)", "ScheduleExpressionTimezone": "Asia/Seoul", "StartWindowMinutes": 60, "Lifecycle": {"MoveToColdStorageAfterDays": 30, "DeleteAfterDays": 365}}]}
JSON
aws backup update-backup-plan --backup-plan-id $ID --backup-plan file://$HOME/plan.json
aws backup delete-backup-plan --backup-plan-id $(aws backup list-backup-plans --query "BackupPlansList[?BackupPlanName=='legacy-nightly'].BackupPlanId" --output text)
