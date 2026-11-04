# 설명: 비밀을 JSON 이 아니라 비밀번호 글자 하나로 저장하면 username 이 없다
# 실패해야: username, password 를 가진 JSON
cd ~/app
pw=$(grep '^DB_PASSWORD=' .env | cut -d= -f2-)
aws secretsmanager create-secret --name prod/shop/db --secret-string "$pw" > /dev/null
sed -i '/^DB_PASSWORD=/d' .env
sed -i 's|^source ./.env$|source ./.env\nDB_PASSWORD=$(aws secretsmanager get-secret-value --secret-id prod/shop/db --query SecretString --output text)|' start.sh
./start.sh
