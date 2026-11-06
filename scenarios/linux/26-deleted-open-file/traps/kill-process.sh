# 설명: 프로세스를 죽이면 공간은 비지만 서비스가 멈춘다
# 실패해야: 종료하지 않고 그대로 실행 중
line=$(lsof +L1 2>/dev/null | grep app.log | head -n 1)
pid=$(awk '{print $2}' <<< "$line")
ps -p "$pid" -o comm= > ~/answer.txt
kill "$pid"
