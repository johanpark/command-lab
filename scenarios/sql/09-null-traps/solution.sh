cd ~
sqlite3 members.db "SELECT COUNT(*) FROM members WHERE phone IS NULL OR phone = '';" > no_phone.txt
sqlite3 members.db "SELECT COUNT(*) FROM members m WHERE NOT EXISTS (SELECT 1 FROM members r WHERE r.referrer_id = m.id);" > never_referrer.txt
sqlite3 members.db "SELECT ROUND(AVG(COALESCE(points, 0)), 1) FROM members;" > avg_points.txt
