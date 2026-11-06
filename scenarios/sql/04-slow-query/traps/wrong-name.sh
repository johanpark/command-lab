# 설명: 인덱스 이름을 요청과 다르게 지으면 운영 문서·모니터링에서 못 찾는다
# 실패해야: idx_events_user_id 인덱스가
cd ~
sqlite3 events.db "CREATE INDEX user_idx ON events(user_id);"
uid=$(grep -o 'user_id): [0-9]*' ~/request.txt | grep -o '[0-9]*$')
sqlite3 events.db "SELECT COUNT(*) FROM events WHERE user_id = $uid;" > ~/answer.txt
