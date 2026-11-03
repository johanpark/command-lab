# 설명: 새 키를 만들고도 다른 키로 암호화하고, 회전·평문 삭제를 빼먹고, 삭제 대기 기간을 기본(30일)으로 둔다
# 실패해야: 자동 키 교체
# 실패해야: alias/payments 키로 풀면
# 실패해야: 평문 payment-config.json
# 실패해야: 7일 뒤 삭제
K=$(aws kms create-key --description pay --query KeyMetadata.KeyId --output text)
aws kms create-alias --alias-name alias/payments --target-key-id $K
aws kms encrypt --key-id alias/legacy-app --plaintext fileb://payment-config.json --query CiphertextBlob --output text > payment-config.json.enc
T=$(for k in $(aws kms list-keys --query 'Keys[].KeyId' --output text); do aws kms list-resource-tags --key-id $k --query "Tags[?TagValue=='test']" --output text | grep -q . && echo $k; done)
aws kms schedule-key-deletion --key-id $T
