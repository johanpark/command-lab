# 설명: & 만 붙이면 터미널이 닫힐 때 오는 SIGHUP 에 같이 죽는다 (세션 전체에 SIGHUP 을 보내 재현)
# 실패해야: long-backup.sh 가 실행 중이다
cd ~/backup
setsid bash -c './long-backup.sh > backup.log 2>&1 & sleep 1; kill -HUP 0' > /dev/null 2>&1
sleep 1
