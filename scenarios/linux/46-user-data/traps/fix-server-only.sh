# 설명: 지금 서버만 고치고 user-data 는 그대로 두면 다음에 만드는 서버에서 또 멈춘다
# 실패해야: 고친 user-data 는
echo DB_HOST > ~/answer.txt
host=$(grep -o 'prod-db-[a-z0-9.]*internal' ~/runbook.md | head -n 1)
sudo sed -i "s/^DB_HOST=.*/DB_HOST=$host/" /opt/shop/config/app.env
sudo chown -R shop:shop /opt/shop
sudo -u shop sh -c 'nohup /opt/shop/bin/start.sh > /dev/null 2>&1 &'
sleep 1
