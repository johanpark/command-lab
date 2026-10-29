백업 고르기: `aws dynamodb list-backups --table-name products --query "BackupSummaries[].[BackupName,BackupCreationDateTime,BackupArn]" --output table`
**20261028** 것이 어젯밤이에요 (27일 것은 가격이 하루 전이라 쓰면 안 돼요).
---
`aws dynamodb restore-table-from-backup --target-table-name products-restored --backup-arn <ARN>`
(실제 AWS 는 복원에 몇 분 걸려요: `aws dynamodb wait table-exists --table-name products-restored`)
---
두 테이블의 키 목록을 줄 단위로 만들어서 비교해요. `comm -23 A B` 는 **A 에만 있는 줄**이에요 (둘 다 정렬돼 있어야 함):
```
aws dynamodb scan --table-name products-restored --query 'Items[].sku.S' --output text | tr '\t' '\n' | sort > restored.txt
aws dynamodb scan --table-name products --query 'Items[].sku.S' --output text | tr '\t' '\n' | sort > now.txt
comm -23 restored.txt now.txt
```
---
없어진 키마다 복원 테이블에서 꺼내 그대로 넣어요. `get-item --query Item --output json` 결과는 `put-item --item` 에 바로 쓸 수 있는 모양이에요:
```
for s in $(comm -23 restored.txt now.txt); do
  aws dynamodb put-item --table-name products --item "$(aws dynamodb get-item --table-name products-restored --key '{"sku":{"S":"'$s'"}}' --query Item --output json)"
done
```
