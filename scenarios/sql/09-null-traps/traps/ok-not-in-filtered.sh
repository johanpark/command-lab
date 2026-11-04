# 설명: NOT IN 서브쿼리에서 NULL 을 걸러 내면 맞는 풀이다
# 통과해야
cd ~
sqlite3 members.db "SELECT COUNT(*) FROM members WHERE COALESCE(phone, '') = '';" > no_phone.txt
sqlite3 members.db "SELECT COUNT(*) FROM members WHERE id NOT IN (SELECT referrer_id FROM members WHERE referrer_id IS NOT NULL);" > never_referrer.txt
sqlite3 members.db "SELECT ROUND(SUM(COALESCE(points, 0)) * 1.0 / COUNT(*), 1) FROM members;" > avg_points.txt
