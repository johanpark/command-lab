# 설명: s///g 의 g 를 빼면 한 줄에 두 번 나온 주소는 첫 번째만 바뀐다
# 실패해야: old-db.internal 이 남아 있지 않다
grep -rl --include=config.ini old-db ~/services | xargs sed -i 's/old-db\.internal/new-db.internal/'
grep -rlE --include=config.ini '^debug *= *true' ~/services | xargs sed -i 's/^debug *= *true$/debug = false/'
