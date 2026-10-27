cd ~/shop
sed -i 's/shop-web:1\.O/shop-web:1.0/; s/"80:8080"/"8080:80"/' compose.yaml
docker compose up -d --quiet-pull 2>&1 | tail -n 2
sleep 1
