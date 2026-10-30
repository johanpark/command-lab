P=$(aws secretsmanager get-random-password --password-length 32 --exclude-punctuation --query RandomPassword --output text)
aws rds modify-db-instance --db-instance-identifier shop-db --master-user-password "$P" --apply-immediately >/dev/null
aws secretsmanager get-secret-value --secret-id prod/shop/db --query SecretString --output text \
  | jq -c --arg p "$P" '.password = $p' > ~/new.json
aws secretsmanager put-secret-value --secret-id prod/shop/db --secret-string file://$HOME/new.json >/dev/null
rm -f ~/new.json
