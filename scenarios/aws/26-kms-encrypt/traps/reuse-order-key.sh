# 설명: 새 키 대신 주문 서비스 키에 별칭을 붙이고, 테스트 키 대신 legacy-app 키를 지운다
# 실패해야: 결제 전용 새 키
# 실패해야: 테스트 키가 7일 뒤
# 실패해야: 다른 키(legacy-app
O=$(for k in $(aws kms list-keys --query 'Keys[].KeyId' --output text); do aws kms describe-key --key-id $k --query KeyMetadata.Description --output text | grep -q 주문 && echo $k; done)
aws kms create-alias --alias-name alias/payments --target-key-id $O
aws kms enable-key-rotation --key-id $O
aws kms encrypt --key-id alias/payments --plaintext fileb://payment-config.json --query CiphertextBlob --output text | base64 -d > payment-config.json.enc
rm payment-config.json
L=$(aws kms list-aliases --query "Aliases[?AliasName=='alias/legacy-app'].TargetKeyId" --output text)
aws kms schedule-key-deletion --key-id $L --pending-window-in-days 7
