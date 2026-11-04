# 설명: REPLACE 는 바꿀 글자가 없으면 그대로라 WHERE 없이 이메일을 바꿔도 결과는 같다
# 통과해야
id=$(grep -o 'id): [0-9]*' ~/request.txt | grep -o '[0-9]*$')
sqlite3 ~/shop.db "
UPDATE customers SET email = REPLACE(email, '@oldmail.com', '@newmail.com');
DELETE FROM orders WHERE status = 'cancelled';
UPDATE customers SET city = '제주' WHERE id = $id;"
