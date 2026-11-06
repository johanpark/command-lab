# 설명: strftime 으로 '2026-10' 인 것만 골라도 맞는 풀이다 (대신 인덱스는 못 씀)
# 통과해야
cd ~
sqlite3 shop.db "SELECT COUNT(*) FROM payments WHERE strftime('%Y-%m', paid_at) = '2026-10';" > count.txt
sqlite3 shop.db "SELECT SUM(amount) FROM payments WHERE strftime('%Y-%m', paid_at) = '2026-10';" > total.txt
