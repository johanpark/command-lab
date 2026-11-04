# 설명: nohup 으로 띄우면 터미널이 닫힐 때 오는 SIGHUP 을 받아도 살아 있다
# 통과해야
cd ~/backup
setsid bash -c 'nohup ./long-backup.sh > backup.log 2>&1 & sleep 1; kill -HUP 0' > /dev/null 2>&1
sleep 1
