새 비밀번호는 **변수에만** 담아요 (화면에 찍지 않기):
`P=$(aws secretsmanager get-random-password --password-length 32 --exclude-punctuation --query RandomPassword --output text)`
---
DB 쪽: `aws rds modify-db-instance --db-instance-identifier shop-db --master-user-password "$P" --apply-immediately`
---
비밀 쪽: 지금 JSON 을 받아서 password 만 바꿔 넣기
```
aws secretsmanager get-secret-value --secret-id prod/shop/db --query SecretString --output text \
  | jq -c --arg p "$P" '.password = $p' > new.json
aws secretsmanager put-secret-value --secret-id prod/shop/db --secret-string file://new.json
rm new.json
```
`put-secret-value` 를 **한 번만** 하세요. 두 번 하면 옛 값이 AWSPREVIOUS 에서도 밀려나요.
---
확인: `aws secretsmanager describe-secret --secret-id prod/shop/db --query VersionIdsToStages`
