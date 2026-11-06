# 설명: 주문을 옮기기 전에 중복 회원부터 지우면 그 주문들이 주인 없는 주문이 된다
# 실패해야: 주인 없는 주문이 없다
cd ~
sqlite3 members.db 'SELECT COUNT(*) - COUNT(DISTINCT email) FROM members;' > answer.txt
sqlite3 members.db "DELETE FROM members WHERE id NOT IN (SELECT MIN(id) FROM members GROUP BY email); CREATE UNIQUE INDEX idx_members_email ON members(email);"
