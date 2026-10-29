# 해설

```bash
B=$(aws dynamodb list-backups --table-name products --query "BackupSummaries[?BackupName=='products-nightly-20261028'].BackupArn" --output text)
aws dynamodb restore-table-from-backup --target-table-name products-restored --backup-arn $B
aws dynamodb wait table-exists --table-name products-restored

# 백업에만 있는 키 = 지워진 상품
comm -23 <(aws dynamodb scan --table-name products-restored --query 'Items[].sku.S' --output text | tr '\t' '\n' | sort) \
         <(aws dynamodb scan --table-name products --query 'Items[].sku.S' --output text | tr '\t' '\n' | sort) |
while read -r s; do
  aws dynamodb put-item --table-name products \
    --item "$(aws dynamodb get-item --table-name products-restored --key '{"sku":{"S":"'$s'"}}' --query Item --output json)"
done

aws dynamodb update-continuous-backups --table-name products --point-in-time-recovery-specification PointInTimeRecoveryEnabled=true
```

## 왜 "통째로 되돌리기" 가 아닌가
| 방법 | 결과 |
|---|---|
| 백업 테이블로 앱을 돌려 버리기 | 오늘 가격 변경·신상품 **유실** |
| 백업에 있는 걸 전부 put-item | 오늘 바뀐 가격 3건이 어젯밤 값으로 **덮어써짐** |
| **없어진 키만** put-item | 지워진 것만 돌아오고 오늘 변경은 유지 ✅ |

SQL 의 "WHERE 없는 UPDATE 복구" 문제와 같은 원리예요. **복구용 사본을 따로 만들고, 필요한 차이만 골라서** 옮겨요.

## DynamoDB 백업 두 가지
| | 온디맨드 백업 | 시점 복구 (PITR) |
|---|---|---|
| 언제 | 내가 만들 때 (또는 AWS Backup 스케줄) | 켜 두면 **최근 35일 중 아무 초**로나 |
| 복원 | 항상 **새 테이블** | 항상 **새 테이블** |
| 오늘 같은 사고 | 어젯밤 이후 변경은 백업에 없음 | **사고 1분 전** 상태로 복원 가능 |

PITR 이 켜져 있었다면 `restore-table-to-point-in-time --restore-date-time <사고 직전>` 으로 오늘 낮 변경까지 포함된 사본을 얻을 수 있었어요.

## 실무 팁
- 복원 테이블에는 **오토스케일링, TTL, 스트림, 태그, IAM 정책이 따라오지 않아요.** 복원 테이블로 앱을 전환할 거라면 다시 설정해야 해요.
- 일이 끝나면 복원 테이블(`products-restored`)은 지워도 돼요. 그대로 두면 저장 요금이 나가요.
- 항목이 수천 개라면 하나씩 put-item 대신 `batch-write-item`(25개씩)을 쓰세요.
