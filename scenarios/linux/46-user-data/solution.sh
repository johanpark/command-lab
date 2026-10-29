echo DB_HOST > ~/answer.txt
host=$(grep -o 'prod-db-[a-z0-9.]*internal' ~/runbook.md | head -n 1)
sudo sed -i "s/^DB_HOST=.*/DB_HOST=$host/" /opt/shop/config/app.env
sudo chown -R shop:shop /opt/shop
sudo -u shop sh -c 'nohup /opt/shop/bin/start.sh > /dev/null 2>&1 &'
sleep 1
sudo sed -i "/^set -euxo pipefail/a DB_HOST=$host" /var/lib/cloud/instance/user-data.txt
curl -s localhost:8080/health
