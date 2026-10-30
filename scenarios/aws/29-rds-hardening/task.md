# 운영 DB 점검 — 공개 접속 끄고 백업 켜기 (RDS)

서비스 오픈 때 급하게 만든 운영 DB **`shop-db`** 를 점검했더니 상태가 아찔해요.
체크리스트는 `~/db-checklist.md` 에 있어요.

## 목표
1. 설정을 바꾸기 **전에** 수동 스냅샷 **`shop-db-before-hardening`** 을 만드세요.
2. `shop-db` 의 **인터넷 공개 접속을 끄세요.**
3. **자동 백업 보존 기간**을 체크리스트대로 설정하세요.
4. **삭제 방지**를 켜세요.
5. 다른 DB(`analytics-db`, `dev-db`)는 건드리지 마세요.

## 써볼 명령어
| 명령어 | 하는 일 |
|---|---|
| `aws rds describe-db-instances --query "DBInstances[].[DBInstanceIdentifier,Engine,PubliclyAccessible,BackupRetentionPeriod,DeletionProtection]" --output table` | DB 목록과 설정 |
| `aws rds create-db-snapshot --db-instance-identifier DB --db-snapshot-identifier 이름` | 수동 스냅샷 |
| `aws rds describe-db-snapshots --db-instance-identifier DB` | 스냅샷 확인 |
| `aws rds modify-db-instance --db-instance-identifier DB --no-publicly-accessible --backup-retention-period N --deletion-protection --apply-immediately` | 설정 바꾸기 |
