# 설명: 분까지가 아니라 시(HH)만 잘라 답하면 몇 시 몇 분인지 알 수 없다
# 실패해야: 가장 많았던 1분
L=~/logs/access.log
awk '$4 >= 500' $L | cut -c12-13 | sort | uniq -c | sort -rn | head -n 1 | awk '{print $2}' > ~/answer.txt
awk '$4 >= 500' $L | cut -c12-13 | sort | uniq -c | awk '{print $2, $1}' > ~/by_hour.txt
