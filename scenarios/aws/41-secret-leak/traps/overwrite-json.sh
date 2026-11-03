# 설명: password 만 든 JSON 으로 두 번 덮어쓰고 DB 는 안 바꾼다
# 실패해야: 다른 값은 그대로
# 실패해야: AWSPREVIOUS
# 실패해야: shop-db 의 마스터 비밀번호
P=$(aws secretsmanager get-random-password --password-length 32 --exclude-punctuation --query RandomPassword --output text)
aws secretsmanager put-secret-value --secret-id prod/shop/db --secret-string "{\"password\":\"$P\"}" >/dev/null
aws secretsmanager put-secret-value --secret-id prod/shop/db --secret-string "{\"password\":\"$P\"}" >/dev/null
