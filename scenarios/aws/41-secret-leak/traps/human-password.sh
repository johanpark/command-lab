# 설명: 사람이 정한 짧은 비밀번호를 쓴다
# 실패해야: 32자 이상
P=MyNewPassword2026
aws rds modify-db-instance --db-instance-identifier shop-db --master-user-password "$P" --apply-immediately >/dev/null
aws secretsmanager get-secret-value --secret-id prod/shop/db --query SecretString --output text | jq -c --arg p "$P" '.password = $p' > n.json
aws secretsmanager put-secret-value --secret-id prod/shop/db --secret-string file://n.json >/dev/null
