# 설명: 정리만 하고 UNIQUE 인덱스를 걸지 않으면 같은 이메일로 또 가입된다
# 실패해야: UNIQUE 인덱스가 있어
cd ~
sqlite3 members.db 'SELECT COUNT(*) - COUNT(DISTINCT email) FROM members;' > answer.txt
sqlite3 members.db "
UPDATE orders SET member_id = (SELECT MIN(m2.id) FROM members m2 WHERE m2.email = (SELECT email FROM members m1 WHERE m1.id = orders.member_id));
DELETE FROM members WHERE id NOT IN (SELECT MIN(id) FROM members GROUP BY email);"
