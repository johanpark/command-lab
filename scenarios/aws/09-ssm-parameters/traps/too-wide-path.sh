# 설명: /prod 처럼 넓게 + --recursive 로 가져오면 다른 서비스 값이 섞인다
# 실패해야: 다른 것 없이
aws ssm get-parameters-by-path --path /prod --recursive --with-decryption --query 'Parameters[].[Name,Value]' --output text |
while read -r name value; do echo "$(basename "$name" | tr a-z A-Z)=$value"; done > ~/app/.env
