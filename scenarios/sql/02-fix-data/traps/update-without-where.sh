# 설명: UPDATE 에 WHERE 를 빼면 모든 고객의 도시가 제주가 된다
# 실패해야: customers 테이블의 다른 데이터
sqlite3 ~/shop.db "
UPDATE customers SET email = REPLACE(email, '@oldmail.com', '@newmail.com') WHERE email LIKE '%@oldmail.com';
DELETE FROM orders WHERE status = 'cancelled';
UPDATE customers SET city = '제주';"
