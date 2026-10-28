#!/usr/bin/env bash
source /opt/cmdlab/lib/helpers.sh
set -e
DB="$H/members.db"; rm -f "$DB"
{
echo "CREATE TABLE members (id INTEGER PRIMARY KEY, name TEXT, phone TEXT, referrer_id INTEGER, points INTEGER);"
awk -v seed="$RANDOM" -v q="'" 'BEGIN {
  srand(seed)
  split("김민수 이지은 박서준 최유나 정하늘 강도윤 조수아 윤지호 장예린 임태양 한소율 오준서 서다인 신우진 권나래 황시우", nm, " ")
  n = 60 + int(rand() * 30)
  for (i = 1; i <= n; i++) {
    r = rand()
    phone = (r < 0.12) ? "NULL" : (r < 0.2) ? q q : sprintf(q "010-%04d-%04d" q, int(rand() * 10000), int(rand() * 10000))
    ref = (i > 5 && rand() < 0.55) ? 1 + int(rand() * (i - 1) * 0.4) : "NULL"
    pts = (rand() < 0.25) ? "NULL" : 100 * int(rand() * 50)
    printf "INSERT INTO members VALUES (%d, " q "%s" q ", %s, %s, %s);\n", i, nm[1 + int(rand() * 16)], phone, ref, pts
  }
}'
} | sqlite3 "$DB"
cp /opt/cmdlab/scenario/queries.sql.tmpl "$H/queries.sql"
give "$DB" "$H/queries.sql"
q() { sqlite3 -noheader -list "$DB" "$1"; }
secret_set no_phone "$(q "SELECT COUNT(*) FROM members WHERE phone IS NULL OR phone = '';")"
secret_set never "$(q "SELECT COUNT(*) FROM members m WHERE NOT EXISTS (SELECT 1 FROM members r WHERE r.referrer_id = m.id);")"
secret_set avg "$(q "SELECT ROUND(AVG(COALESCE(points, 0)), 1) FROM members;")"
