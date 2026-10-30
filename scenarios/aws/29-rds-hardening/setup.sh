#!/usr/bin/env bash
source /opt/cmdlab/lib/helpers.sh
source /usr/local/lib/lab-aws.sh
set -e
wait_aws
db() { # 이름 엔진 공개 백업일 삭제방지
  aws rds create-db-instance --db-instance-identifier "$1" --engine "$2" --db-instance-class db.t3.micro \
    --master-username admin --master-user-password "Lab-$RANDOM-pass" --allocated-storage 20 \
    $([ "$3" = yes ] && echo --publicly-accessible || echo --no-publicly-accessible) \
    --backup-retention-period "$4" $([ "$5" = yes ] && echo --deletion-protection || echo --no-deletion-protection) >/dev/null
}
db shop-db postgres yes 0 no
db analytics-db postgres no 14 yes
db dev-db mysql yes 1 no
for d in analytics-db dev-db; do
  aws rds describe-db-instances --db-instance-identifier $d \
    --query 'DBInstances[0].[PubliclyAccessible,BackupRetentionPeriod,DeletionProtection]' --output text > /opt/cmdlab/secret/$d
done
R=$(rand_pick 7 14); secret_set days "$R"
mkdir -p "$H"
cat > "$H/db-checklist.md" <<MD
# 운영 DB(shop-db) 점검 체크리스트

작업 전
- [ ] 수동 스냅샷 \`shop-db-before-hardening\` 만들기 (문제 생기면 되돌릴 수 있게)

설정
- [ ] 인터넷 공개 접속(Publicly accessible) **끄기** (앱 서버는 VPC 안에서 접속함)
- [ ] 자동 백업 보존 기간 **${R}일**
- [ ] 삭제 방지(Deletion protection) **켜기**
- [ ] 바로 적용 (다음 유지 관리 시간까지 기다리지 않기)

※ analytics-db, dev-db 는 다른 팀 담당. 손대지 말 것.
MD
give "$H/db-checklist.md"
