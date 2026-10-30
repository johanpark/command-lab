K=$(aws kms create-key --description "결제 설정 암호화" --query KeyMetadata.KeyId --output text)
aws kms create-alias --alias-name alias/payments --target-key-id "$K"
aws kms enable-key-rotation --key-id "$K"
aws kms encrypt --key-id alias/payments --plaintext fileb://$HOME/payment-config.json \
  --query CiphertextBlob --output text | base64 -d > ~/payment-config.json.enc
rm ~/payment-config.json
for k in $(aws kms list-keys --query 'Keys[].KeyId' --output text); do
  if aws kms list-resource-tags --key-id "$k" --query "Tags[?TagKey=='Purpose'].TagValue" --output text | grep -qx test; then
    aws kms schedule-key-deletion --key-id "$k" --pending-window-in-days 7 >/dev/null
  fi
done
