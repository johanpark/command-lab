# 설명: setsid 로 터미널과 떼어 내도 맞는 풀이다
# 통과해야
cd ~/backup
setsid ./long-backup.sh > backup.log 2>&1 < /dev/null &
sleep 1
