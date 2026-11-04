# 설명: = NULL, NOT IN(NULL 섞인 목록), AVG(NULL 제외) 세 가지 NULL 함정에 모두 빠진다
# 실패해야: 전화번호가 없는 회원 수
# 실패해야: 추천인으로 한 번도 안 뽑힌
# 실패해야: NULL 을 0점으로
cd ~
sqlite3 members.db "SELECT COUNT(*) FROM members WHERE phone = NULL OR phone = '';" > no_phone.txt
sqlite3 members.db "SELECT COUNT(*) FROM members WHERE id NOT IN (SELECT referrer_id FROM members);" > never_referrer.txt
sqlite3 members.db "SELECT ROUND(AVG(points), 1) FROM members;" > avg_points.txt
