키 만들기 → 별칭 → 교체:
```
K=$(aws kms create-key --description "결제 설정 암호화" --query KeyMetadata.KeyId --output text)
aws kms create-alias --alias-name alias/payments --target-key-id $K
aws kms enable-key-rotation --key-id $K
```
(`enable-key-rotation` 은 별칭을 받지 않아요. 키 ID 로!)
---
`encrypt` 결과(CiphertextBlob)는 **base64 글자**로 나와요. 파일로는 원래 바이트로 저장해요:
`aws kms encrypt --key-id alias/payments --plaintext fileb://payment-config.json --query CiphertextBlob --output text | base64 -d > payment-config.json.enc`
`fileb://` 는 "파일을 바이트 그대로" 라는 뜻이에요. (`file://` 은 글자로 읽어요)
---
지우기 전에 풀리는지 꼭 확인:
`aws kms decrypt --ciphertext-blob fileb://payment-config.json.enc --query Plaintext --output text | base64 -d`
원래 내용이 나오면 `rm payment-config.json`
---
테스트 키 찾기: 키마다 태그를 봐요.
`for k in $(aws kms list-keys --query 'Keys[].KeyId' --output text); do echo "$k $(aws kms list-resource-tags --key-id $k --query 'Tags[0].TagValue' --output text) $(aws kms describe-key --key-id $k --query KeyMetadata.Description --output text)"; done`
→ `aws kms schedule-key-deletion --key-id <ID> --pending-window-in-days 7`
