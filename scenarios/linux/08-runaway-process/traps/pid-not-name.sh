# 설명: 답에 이름 대신 PID 를 적고, 죽이지도 않는다
# 실패해야: 범인 프로세스 이름
# 실패해야: 프로세스가 종료됐다
ps -eo pid --sort=-%cpu | sed -n 2p | tr -d ' ' > ~/answer.txt
