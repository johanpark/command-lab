#!/usr/bin/env bash
source /opt/cmdlab/lib/helpers.sh
source /usr/local/lib/lab-aws.sh
set -e
wait_aws
S=/opt/cmdlab/secret
L=$(aws kms create-key --description "레거시 앱 DB 비밀번호 암호화" --tags TagKey=Purpose,TagValue=prod --query KeyMetadata.KeyId --output text)
aws kms create-alias --alias-name alias/legacy-app --target-key-id "$L"
T=$(aws kms create-key --description "김개발 테스트용 (2025년)" --tags TagKey=Purpose,TagValue=test --query KeyMetadata.KeyId --output text)
O=$(aws kms create-key --description "주문 서비스 (사용 중)" --tags TagKey=Purpose,TagValue=prod --query KeyMetadata.KeyId --output text)
secret_set legacy "$L"; secret_set test "$T"; secret_set orders "$O"
mkdir -p "$H"
jq -n --arg k "sk_live_$(head -c 12 /dev/urandom | od -An -tx1 | tr -d ' \n')" --arg m "M$(rand_int 100000 999999)" \
  '{pg: "toss", merchant_id: $m, secret_key: $k, webhook_url: "https://shop.example/pg/webhook"}' > "$H/payment-config.json"
sha256sum < "$H/payment-config.json" | cut -d' ' -f1 > $S/sha
give "$H/payment-config.json"
