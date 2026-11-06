# 설명: find -exec ... {} + 로 해도 맞는 풀이다
# 통과해야
find ~/reports -name '*.csv' -exec cat {} + | wc -l > ~/answer.txt
find ~/reports -name '*.csv' -exec gzip {} +
