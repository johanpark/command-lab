# 설명: 그저께 백업에서 복원하면 되살린 상품 값이 어젯밤과 다르다
# 실패해야: 어젯밤 백업과 같다
B=$(aws dynamodb list-backups --table-name products --query "BackupSummaries[?BackupName=='products-nightly-20261027'].BackupArn" --output text)
aws dynamodb restore-table-from-backup --target-table-name rst --backup-arn "$B" >/dev/null
comm -23 <(aws dynamodb scan --table-name rst --query 'Items[].sku.S' --output text | tr '\t' '\n' | sort) <(aws dynamodb scan --table-name products --query 'Items[].sku.S' --output text | tr '\t' '\n' | sort) | while read -r s; do
  aws dynamodb put-item --table-name products --item "$(aws dynamodb get-item --table-name rst --key '{"sku":{"S":"'$s'"}}' --query Item --output json)"; done
aws dynamodb update-continuous-backups --table-name products --point-in-time-recovery-specification PointInTimeRecoveryEnabled=true >/dev/null
