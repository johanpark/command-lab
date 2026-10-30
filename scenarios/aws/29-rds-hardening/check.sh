#!/usr/bin/env bash
source /opt/cmdlab/lib/helpers.sh
R=$(secret_get days)
s=$(aws rds describe-db-snapshots --db-snapshot-identifier shop-db-before-hardening --query 'DBSnapshots[0].[DBInstanceIdentifier,SnapshotType]' --output text 2>/dev/null)
[ "$s" = "shop-db	manual" ] && pass "shop-db 의 수동 스냅샷 shop-db-before-hardening 이 있다" || fail "shop-db 의 수동 스냅샷 shop-db-before-hardening 이 있다${s:+ (지금: $s)}"
read -r pub ret del < <(aws rds describe-db-instances --db-instance-identifier shop-db --query 'DBInstances[0].[PubliclyAccessible,BackupRetentionPeriod,DeletionProtection]' --output text 2>/dev/null)
if [ -z "$pub" ]; then fail "shop-db 가 있다 (지워졌어요!)"; finish; fi
[ "$pub" = False ] && pass "shop-db 의 인터넷 공개 접속이 꺼져 있다" || fail "shop-db 의 인터넷 공개 접속이 꺼져 있다"
[ "$ret" = "$R" ] && pass "자동 백업 보존 기간이 ${R}일이다" || fail "자동 백업 보존 기간이 ${R}일이다 (지금: ${ret}일)"
[ "$del" = True ] && pass "삭제 방지가 켜져 있다" || fail "삭제 방지가 켜져 있다"
bad=""; for d in analytics-db dev-db; do
  [ "$(aws rds describe-db-instances --db-instance-identifier $d --query 'DBInstances[0].[PubliclyAccessible,BackupRetentionPeriod,DeletionProtection]' --output text 2>/dev/null)" = "$(cat /opt/cmdlab/secret/$d)" ] || bad+="$d "
done
[ -z "$bad" ] && pass "다른 DB 는 그대로다" || fail "다른 DB 는 그대로다 (바뀜: ${bad% })"
finish
