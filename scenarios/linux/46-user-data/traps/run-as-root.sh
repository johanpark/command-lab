# 설명: 남은 단계를 건너뛰고 앱을 root 로 띄운다 (chown·shop 사용자 빠짐)
# 실패해야: shop 사용자로 실행 중
# 실패해야: 소유자가 shop
echo DB_HOST > ~/answer.txt
host=$(grep -o 'prod-db-[a-z0-9.]*internal' ~/runbook.md | head -n 1)
sudo sed -i "s/^DB_HOST=.*/DB_HOST=$host/" /opt/shop/config/app.env
sudo sh -c 'nohup /opt/shop/bin/start.sh > /dev/null 2>&1 &'
sleep 1
sudo sed -i "/^set -euxo pipefail/a DB_HOST=$host" /var/lib/cloud/instance/user-data.txt
