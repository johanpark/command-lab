`aws ssm get-parameters-by-path --path /prod/shop --query 'Parameters[].[Name,Type,Value]' --output table` 로 먼저 보세요. SecureString 인 값이 이상하게 보이죠? 암호화된 상태 그대로예요.
---
`--with-decryption` 을 붙이면 실제 값이 나와요. (진짜 AWS 에서는 KMS 키 사용 권한도 있어야 해요)
---
한 줄씩 `이름=값` 으로 바꾸기:
```
aws ssm get-parameters-by-path --path /prod/shop --with-decryption \
  --query 'Parameters[].[Name,Value]' --output text |
while read -r name value; do
  echo "$(basename "$name" | tr a-z A-Z)=$value"
done > ~/app/.env
```
---
`cat ~/app/.env` 로 확인. `kms:alias/...` 같은 글자가 보이면 `--with-decryption` 을 빼먹은 거예요. 비밀번호가 담긴 파일이니 `chmod 600 ~/app/.env` 도 해 두면 좋아요.
