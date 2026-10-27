id=$(grep -o 'id): [0-9]*' ~/request.txt | grep -o '[0-9]*$')
sqlite3 ~/shop.db "
BEGIN;
UPDATE customers SET email = REPLACE(email, '@oldmail.com', '@newmail.com') WHERE email LIKE '%@oldmail.com';
DELETE FROM orders WHERE status = 'cancelled';
UPDATE customers SET city = '제주' WHERE id = $id;
COMMIT;"
