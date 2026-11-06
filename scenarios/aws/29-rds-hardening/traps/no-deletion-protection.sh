# 설명: --deletion-protection 을 빼먹는다
# 실패해야: 삭제 방지가 켜져
R=$(grep -oE '\*\*[0-9]+일' ~/db-checklist.md | grep -oE '[0-9]+')
aws rds create-db-snapshot --db-instance-identifier shop-db --db-snapshot-identifier shop-db-before-hardening >/dev/null
aws rds wait db-snapshot-available --db-snapshot-identifier shop-db-before-hardening
aws rds modify-db-instance --db-instance-identifier shop-db --no-publicly-accessible \
  --backup-retention-period "$R" --apply-immediately >/dev/null
