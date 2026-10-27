`sqlite3 events.db` → `.timer on` → `SELECT COUNT(*) FROM events WHERE user_id = 42;` 로 시간을 재 보세요. 그리고 `EXPLAIN QUERY PLAN SELECT * FROM events WHERE user_id = 42;`
---
`SCAN events` = 30만 줄을 처음부터 끝까지 다 본다는 뜻이에요. 책에 **색인(찾아보기)** 이 없어서 첫 장부터 넘기는 것과 같아요.
---
`CREATE INDEX idx_events_user_id ON events(user_id);` 를 실행하고, 같은 EXPLAIN 을 다시 보세요. `SEARCH events USING INDEX idx_events_user_id (user_id=?)` 로 바뀌었나요? 시간도 다시 재 보세요.
---
`cat ~/request.txt` 로 사용자 번호를 확인하고, bash 에서 `sqlite3 events.db "SELECT COUNT(*) FROM events WHERE user_id = 번호;" > ~/answer.txt`
