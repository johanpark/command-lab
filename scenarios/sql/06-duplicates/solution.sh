cd ~
sqlite3 members.db 'SELECT COUNT(*) - COUNT(DISTINCT email) FROM members;' > answer.txt
sqlite3 members.db "
BEGIN;
UPDATE orders SET member_id = (
  SELECT MIN(m2.id) FROM members m2
  WHERE m2.email = (SELECT email FROM members m1 WHERE m1.id = orders.member_id)
);
DELETE FROM members WHERE id NOT IN (SELECT MIN(id) FROM members GROUP BY email);
CREATE UNIQUE INDEX idx_members_email ON members(email);
COMMIT;"
