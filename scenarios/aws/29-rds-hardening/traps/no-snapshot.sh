# 설명: 바꾸기 전에 수동 스냅샷을 뜨지 않으면 되돌릴 지점이 없다
# 실패해야: 수동 스냅샷 shop-db-before-hardening
R=$(grep -oE '\*\*[0-9]+일' ~/db-checklist.md | grep -oE '[0-9]+')
aws rds modify-db-instance --db-instance-identifier shop-db --no-publicly-accessible \
  --backup-retention-period "$R" --deletion-protection --apply-immediately >/dev/null
