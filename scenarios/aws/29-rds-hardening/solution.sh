R=$(grep -oE '\*\*[0-9]+일' ~/db-checklist.md | grep -oE '[0-9]+')
aws rds create-db-snapshot --db-instance-identifier shop-db --db-snapshot-identifier shop-db-before-hardening >/dev/null
aws rds wait db-snapshot-available --db-snapshot-identifier shop-db-before-hardening
aws rds modify-db-instance --db-instance-identifier shop-db --no-publicly-accessible \
  --backup-retention-period "$R" --deletion-protection --apply-immediately >/dev/null
