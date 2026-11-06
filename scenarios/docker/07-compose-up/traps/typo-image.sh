# 설명: 이미지 이름의 오타(1.O)를 못 찾으면 web 이 뜨지 않는다
# 실패해야: web 이미지가 shop-web:1.0
# 실패해야: web 서비스가 실행 중
cd ~/shop
sed -i 's/"80:8080"/"8080:80"/' compose.yaml
docker compose up -d --quiet-pull > /dev/null 2>&1
sleep 1
