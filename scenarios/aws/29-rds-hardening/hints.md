지금 상태부터: `aws rds describe-db-instances --query "DBInstances[].[DBInstanceIdentifier,PubliclyAccessible,BackupRetentionPeriod,DeletionProtection]" --output table`
---
스냅샷: `aws rds create-db-snapshot --db-instance-identifier shop-db --db-snapshot-identifier shop-db-before-hardening`
(실제 AWS 는 몇 분 걸려요: `aws rds wait db-snapshot-available --db-snapshot-identifier shop-db-before-hardening`)
---
설정은 한 번에 바꿀 수 있어요:
`aws rds modify-db-instance --db-instance-identifier shop-db --no-publicly-accessible --backup-retention-period N --deletion-protection --apply-immediately`
