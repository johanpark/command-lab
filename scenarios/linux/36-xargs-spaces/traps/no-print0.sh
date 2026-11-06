# 설명: -print0 / -0 없이 xargs 로 넘기면 이름에 공백이 있는 파일이 쪼개져 남는다
# 실패해야: .csv 가 남아 있지 않다
find ~/reports -name '*.csv' -print0 | xargs -0 cat | wc -l > ~/answer.txt
find ~/reports -name '*.csv' | xargs gzip 2>/dev/null
