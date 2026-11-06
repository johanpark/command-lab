# 설명: 포트를 "80:8080" 그대로 두면 바깥 8080 에서 접속되지 않는다
# 실패해야: 쇼핑몰 페이지
cd ~/shop
sed -i 's/shop-web:1\.O/shop-web:1.0/' compose.yaml
docker compose up -d --quiet-pull > /dev/null 2>&1
sleep 1
