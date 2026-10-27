#!/usr/bin/env bash
source /opt/cmdlab/lib/helpers.sh
DB="$H/events.db"
cols=$(sqlite3 -noheader -list "$DB" "SELECT name FROM pragma_index_info('idx_events_user_id');" 2>/dev/null)
[ "$(head -n 1 <<< "$cols")" = user_id ] && pass "idx_events_user_id 인덱스가 user_id 열에 있다" || fail "idx_events_user_id 인덱스가 user_id 열에 있다 (이름과 열을 확인하세요)"
plan=$(sqlite3 -noheader -list "$DB" "EXPLAIN QUERY PLAN SELECT * FROM events WHERE user_id = 42;" 2>/dev/null)
grep -q 'USING.*INDEX' <<< "$plan" && pass "user_id 로 찾는 쿼리가 인덱스를 쓴다" || fail "user_id 로 찾는 쿼리가 인덱스를 쓴다 (지금 계획: $(tr '\n' ' ' <<< "$plan"))"
expect "events 데이터는 그대로다 (30만 줄)" test "$(sqlite3 "$DB" 'SELECT COUNT(*) FROM events;' 2>/dev/null)" = 300000
expect_cell "answer.txt 에 요청한 사용자의 이벤트 개수를 적었다" "$(secret_get count)"
finish
