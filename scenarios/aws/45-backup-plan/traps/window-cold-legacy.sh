# 설명: 시작 창을 빼고(기본 8시간), 콜드 30일인데 90일 뒤 삭제, 옛 계획도 남긴다
# 실패해야: daily: shop-vault 에, 1시간 안에 시작
# 실패해야: 콜드 30일·삭제 90일
# 실패해야: legacy-nightly
aws backup create-backup-vault --backup-vault-name shop-vault
cat > ~/plan.json <<'JSON'
{"BackupPlanName": "shop-backup",
 "Rules": [
  {"RuleName": "daily", "TargetBackupVaultName": "shop-vault",
   "ScheduleExpression": "cron(0 18 * * ? *)",
   "Lifecycle": {"DeleteAfterDays": 35}},
  {"RuleName": "monthly", "TargetBackupVaultName": "shop-vault",
   "ScheduleExpression": "cron(0 18 L * ? *)",
   "Lifecycle": {"MoveToColdStorageAfterDays": 30, "DeleteAfterDays": 90}}]}
JSON
aws backup create-backup-plan --backup-plan file://$HOME/plan.json
L=$(aws backup list-backup-plans --query "BackupPlansList[?BackupPlanName=='legacy-nightly'].BackupPlanId" --output text)
