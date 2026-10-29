# 해설

```bash
K=$(aws kms create-key --description "결제 설정 암호화" --query KeyMetadata.KeyId --output text)
aws kms create-alias --alias-name alias/payments --target-key-id $K
aws kms enable-key-rotation --key-id $K
aws kms encrypt --key-id alias/payments --plaintext fileb://payment-config.json \
  --query CiphertextBlob --output text | base64 -d > payment-config.json.enc
aws kms decrypt --ciphertext-blob fileb://payment-config.json.enc --query Plaintext --output text | base64 -d   # 확인
rm payment-config.json
aws kms schedule-key-deletion --key-id <테스트 키> --pending-window-in-days 7
```

## KMS 가 하는 일
- 키 자체는 **KMS 밖으로 절대 나오지 않아요.** 암호화·복호화 요청을 보내면 KMS 안에서 처리해서 결과만 돌려줘요.
- 그래서 "누가 이 파일을 풀 수 있나" = "누가 이 키에 `kms:Decrypt` 권한이 있나" 로 IAM·키 정책으로 관리돼요. 모든 사용 기록은 CloudTrail 에 남아요.
- 암호문 안에 **어느 키로 암호화했는지**가 들어 있어서, `decrypt` 할 때 키를 따로 안 알려 줘도 돼요.

## 별칭과 자동 교체
- 코드에는 키 ID 대신 **별칭(alias/payments)** 을 써요. 나중에 키를 바꿔도 별칭만 옮기면 코드는 그대로예요.
- **자동 교체**를 켜면 1년마다 키의 내부 재료가 새로 만들어져요. 옛 재료도 보관돼서 **예전 암호문도 계속 풀려요.** 다시 암호화할 필요가 없어요.

## 키 삭제는 왜 바로 안 되나
- KMS 키를 지우면 그 키로 암호화한 데이터는 **영원히 못 풀어요.** 그래서 최소 7일 ~ 최대 30일의 대기 기간이 강제돼요.
- 대기 중에는 `aws kms cancel-key-deletion` 으로 취소할 수 있어요. 대기 기간 동안 그 키를 쓰려는 시도가 있는지 CloudTrail·CloudWatch 알람으로 지켜보는 게 안전해요.
- 확신이 없으면 지우는 대신 `disable-key` 로 꺼 두는 방법도 있어요.

## 실무 팁
- KMS `encrypt` 는 **4KB 까지만** 암호화할 수 있어요. 큰 파일은 `generate-data-key` 로 데이터 키를 받아 그 키로 파일을 암호화하는 **봉투 암호화(envelope encryption)** 를 써요. S3·EBS·RDS 의 KMS 암호화가 내부적으로 이 방식이에요.
- 사실 이런 비밀 값은 파일 대신 **Secrets Manager / Parameter Store SecureString** 에 두는 게 더 편해요. 둘 다 내부적으로 KMS 를 써요.
