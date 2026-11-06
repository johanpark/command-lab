# 설명: sort -n (오름차순)이면 가장 적은 IP 가 위로 온다
# 실패해야: 가장 많은 IP
# 실패해야: 상위 5개 IP
awk '{print $1}' ~/access.log | sort | uniq -c | sort -n | head -n 5 > ~/top5.txt
head -n 1 ~/top5.txt | awk '{print $2}' > ~/answer.txt
