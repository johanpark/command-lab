#!/usr/bin/env bash
source /opt/cmdlab/lib/helpers.sh
set -e
DB="$H/events.db"; rm -f "$DB"
sqlite3 "$DB" <<'SQL'
CREATE TABLE events (id INTEGER PRIMARY KEY, user_id INTEGER, action TEXT, created_at TEXT);
WITH RECURSIVE n(x) AS (SELECT 1 UNION ALL SELECT x + 1 FROM n LIMIT 300000)
INSERT INTO events (user_id, action, created_at)
SELECT abs(random()) % 5000,
       CASE abs(random()) % 4 WHEN 0 THEN 'login' WHEN 1 THEN 'view' WHEN 2 THEN 'cart' ELSE 'order' END,
       datetime('2026-10-01', '+' || (x % 2592000) || ' seconds')
FROM n;
SQL
uid=$(rand_int 100 4900)
printf '고객센터 요청\n\n- 사용자 번호(user_id): %s\n- 요청: 이번 달 이벤트 개수 확인\n' "$uid" > "$H/request.txt"
give "$DB" "$H/request.txt"
sqlite3 "$DB" "SELECT COUNT(*) FROM events WHERE user_id = $uid;" > /opt/cmdlab/secret/count
