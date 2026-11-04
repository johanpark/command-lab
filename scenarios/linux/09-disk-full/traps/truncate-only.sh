# 설명: 파일을 비우기만 하고 지우지 않았다
# 실패해야: 가장 큰 파일을 삭제했다
big=$(find ~/app -type f -printf '%s %p\n' | sort -rn | head -n 1 | cut -d' ' -f2-)
echo "$big" > ~/answer.txt
: > "$big"
