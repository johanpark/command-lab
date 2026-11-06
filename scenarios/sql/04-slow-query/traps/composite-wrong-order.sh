# 설명: 복합 인덱스의 첫 열이 user_id 가 아니면 user_id 로 찾을 때 쓰이지 않는다
# 실패해야: 인덱스가 user_id 열에
# 실패해야: 인덱스를 쓴다
cd ~
sqlite3 events.db "CREATE INDEX idx_events_user_id ON events(created_at, user_id);" 2>/dev/null || sqlite3 events.db "CREATE INDEX idx_events_user_id ON events(id, user_id);"
uid=$(grep -o 'user_id): [0-9]*' ~/request.txt | grep -o '[0-9]*$')
sqlite3 events.db "SELECT COUNT(*) FROM events WHERE user_id = $uid;" > ~/answer.txt
