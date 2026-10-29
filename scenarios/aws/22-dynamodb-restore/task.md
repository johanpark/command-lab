# 지워진 상품만 백업에서 되살리기 (DynamoDB 백업 복원)

정리 스크립트 버그로 `products` 테이블에서 상품 몇 개가 지워졌어요. 상황은 `~/incident.txt` 에 있어요.

DynamoDB 백업은 **기존 테이블에 덮어쓸 수 없고, 항상 새 테이블로 복원**돼요.
그래서 백업을 새 테이블로 복원한 뒤 지금 테이블과 **비교해서, 없어진 것만 다시 넣어야** 해요.

## 목표
1. **어젯밤(20261028) 백업**을 새 테이블로 복원하세요. (이름은 자유, 예: `products-restored`)
2. 백업에는 있는데 지금 `products` 에는 **없는 상품만** `products` 에 다시 넣으세요.
3. **오늘 바뀐 가격**과 **오늘 등록된 신상품**은 그대로 지켜야 해요.
4. 다음엔 몇 분 전 상태로도 되돌릴 수 있게 `products` 에 **시점 복구(Point-in-time recovery)** 를 켜세요.

## 써볼 명령어
| 명령어 | 하는 일 |
|---|---|
| `aws dynamodb list-backups --table-name products` | 백업 목록과 ARN |
| `aws dynamodb restore-table-from-backup --target-table-name 새이름 --backup-arn ARN` | 백업을 새 테이블로 복원 |
| `aws dynamodb scan --table-name 테이블 --query 'Items[].sku.S' --output text` | 모든 키 보기 |
| `aws dynamodb get-item` / `put-item --item '{...}'` | 항목 하나 읽기 / 넣기 |
| `aws dynamodb update-continuous-backups --table-name products --point-in-time-recovery-specification PointInTimeRecoveryEnabled=true` | PITR 켜기 |
