aws ssm get-parameters-by-path --path /prod/shop --with-decryption \
  --query 'Parameters[].[Name,Value]' --output text |
while read -r name value; do
  echo "$(basename "$name" | tr a-z A-Z)=$value"
done > ~/app/.env
chmod 600 ~/app/.env
