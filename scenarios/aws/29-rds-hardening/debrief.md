# 해설

```bash
aws rds create-db-snapshot --db-instance-identifier shop-db --db-snapshot-identifier shop-db-before-hardening
aws rds wait db-snapshot-available --db-snapshot-identifier shop-db-before-hardening
aws rds modify-db-instance --db-instance-identifier shop-db \
  --no-publicly-accessible --backup-retention-period 7 --deletion-protection --apply-immediately
```

## 각 설정의 의미
| 설정 | 꺼져 있으면 |
|---|---|
| **PubliclyAccessible** | DB 에 공인 IP·공개 DNS 가 붙어서, 보안 그룹만 잘못 열려도 인터넷에서 바로 접속 시도가 들어와요 |
| **BackupRetentionPeriod** (0 = 꺼짐) | 자동 백업도, **시점 복구(PITR)** 도 안 돼요. 실수로 데이터를 지우면 끝 |
| **DeletionProtection** | 콘솔·CLI·Terraform 실수 한 번에 DB 가 통째로 지워질 수 있어요 |

- `--apply-immediately` 를 빼면 변경이 **다음 유지 관리 시간**(보통 새벽)까지 미뤄져요. 보안 설정은 바로 적용하는 게 좋아요. (일부 변경은 재시작이 필요하니 실제로는 영향 범위를 확인하세요)
- 자동 백업을 처음 켤 때(0 → 1 이상)는 잠깐 I/O 가 멈출 수 있어요 (단일 AZ 인 경우).

## 나중에 바꿀 수 없는 것
- **저장소 암호화**는 만들 때만 정할 수 있어요. 암호화 안 된 DB 를 암호화하려면 **스냅샷 → 암호화해서 복사 → 그 스냅샷으로 새 DB 복원** 순서로 갈아타야 해요.
- 그래서 운영 DB 는 처음부터 암호화·다중 AZ·삭제 방지를 켜고 만드는 템플릿(Terraform 등)을 쓰는 게 안전해요.

## 실무 팁
- 수동 스냅샷은 DB 를 지워도 남아요 (자동 백업은 DB 와 함께 사라질 수 있음). 큰 작업 전엔 오늘처럼 수동 스냅샷을 먼저.
- 다른 리전·계정으로 스냅샷을 복사해 두면 리전 장애나 계정 사고에도 대비할 수 있어요.
