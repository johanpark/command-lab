# 설명: sort 없이 uniq -c 를 하면 붙어 있는 줄만 세서 횟수가 틀린다
# 실패해야: 상위 5개 IP
awk '{print $1}' ~/access.log | uniq -c | sort -rn | head -n 5 > ~/top5.txt
head -n 1 ~/top5.txt | awk '{print $2}' > ~/answer.txt
