# 설명: start.sh 에 비밀번호를 직접 적으면 파일에 비밀번호가 그대로 남는다
# 실패해야: 비밀번호가 글자로 남아 있지 않다
cd ~/app
pw=$(grep '^DB_PASSWORD=' .env | cut -d= -f2-)
aws secretsmanager create-secret --name prod/shop/db --secret-string "$(jq -n --arg p "$pw" '{username: "shop", password: $p}')" > /dev/null
sed -i '/^DB_PASSWORD=/d' .env
sed -i "s|^source ./.env\$|source ./.env\nDB_PASSWORD='$pw'|" start.sh
./start.sh
