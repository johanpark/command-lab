# 설명: debug 가 들어간 줄의 true 를 모두 바꾸면 debug_sql 같은 다른 설정까지 바뀐다
# 실패해야: 그 밖의 내용은 그대로
grep -rl --include=config.ini old-db ~/services | xargs sed -i 's/old-db\.internal/new-db.internal/g'
grep -rl --include=config.ini debug ~/services | xargs sed -i '/debug/s/true/false/'
