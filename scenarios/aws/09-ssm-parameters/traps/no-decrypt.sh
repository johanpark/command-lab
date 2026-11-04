# 설명: --with-decryption 을 빼면 SecureString 은 암호화된 값 그대로 나온다
# 실패해야: SecureString 값이 풀린
aws ssm get-parameters-by-path --path /prod/shop --query 'Parameters[].[Name,Value]' --output text |
while read -r name value; do echo "$(basename "$name" | tr a-z A-Z)=$value"; done > ~/app/.env
