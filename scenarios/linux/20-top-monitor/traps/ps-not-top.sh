# 설명: top 화면 대신 ps 결과를 저장하면 요약(load average)이 없다
# 실패해야: top 화면(요약 + 프로세스 목록)
sleep 3
ps -eo comm --sort=-rss | sed -n 2p > ~/mem.txt
ps -eo comm,time --sort=-time | awk 'NR == 2 { print $1 }' > ~/cpu.txt
ps aux > ~/top-report.txt
