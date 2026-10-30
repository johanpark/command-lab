B=$(aws dynamodb list-backups --table-name products --query "BackupSummaries[?BackupName=='products-nightly-20261028'].BackupArn" --output text)
aws dynamodb restore-table-from-backup --target-table-name products-restored --backup-arn "$B" >/dev/null
aws dynamodb wait table-exists --table-name products-restored
comm -23 <(aws dynamodb scan --table-name products-restored --query 'Items[].sku.S' --output text | tr '\t' '\n' | sort) \
         <(aws dynamodb scan --table-name products --query 'Items[].sku.S' --output text | tr '\t' '\n' | sort) |
while read -r s; do
  item=$(aws dynamodb get-item --table-name products-restored --key "{\"sku\":{\"S\":\"$s\"}}" --query Item --output json)
  aws dynamodb put-item --table-name products --item "$item"
done
aws dynamodb update-continuous-backups --table-name products \
  --point-in-time-recovery-specification PointInTimeRecoveryEnabled=true >/dev/null
