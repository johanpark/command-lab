# 설명: 상태 코드를 거르지 않으면 전체 요청 수를 세게 된다
# 실패해야: 5xx 만 셌나요
L=~/logs/access.log
awk '$4 >= 500' $L | cut -c12-16 | sort | uniq -c | sort -rn | head -n 1 | awk '{print $2}' > ~/answer.txt
cut -c12-13 $L | sort | uniq -c | awk '{print $2, $1}' > ~/by_hour.txt
