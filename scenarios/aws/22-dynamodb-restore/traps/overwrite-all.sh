# 설명: 백업 전체를 덮어쓰면 오늘 바꾼 가격까지 어젯밤 값으로 돌아간다 (PITR 도 안 켬)
# 실패해야: 오늘 바꾼 가격
# 실패해야: 시점 복구(PITR)
B=$(aws dynamodb list-backups --table-name products --query "BackupSummaries[?BackupName=='products-nightly-20261028'].BackupArn" --output text)
aws dynamodb restore-table-from-backup --target-table-name rst --backup-arn "$B" >/dev/null
aws dynamodb scan --table-name rst --output json | jq -c '.Items[]' | while read -r it; do aws dynamodb put-item --table-name products --item "$it"; done
