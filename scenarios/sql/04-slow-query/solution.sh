cd ~
sqlite3 events.db "CREATE INDEX idx_events_user_id ON events(user_id);"
uid=$(grep -o 'user_id): [0-9]*' ~/request.txt | grep -o '[0-9]*$')
sqlite3 events.db "SELECT COUNT(*) FROM events WHERE user_id = $uid;" > ~/answer.txt
