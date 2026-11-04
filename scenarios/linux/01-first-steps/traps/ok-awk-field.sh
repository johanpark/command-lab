# 설명: awk -F 로 콜론 뒤만 잘라도 맞는 풀이다
# 통과해야
awk -F': ' '/암호/ {print $2}' ~/projects/beta/docs/memo.txt > ~/answer.txt
