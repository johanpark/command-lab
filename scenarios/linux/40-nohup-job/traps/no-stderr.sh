# 설명: 2>&1 을 빼면 에러가 로그에 남지 않는다
# 실패해야: 에러도 같은 로그로
cd ~/backup
nohup ./long-backup.sh > backup.log 2>/dev/null &
sleep 1
