# 설명: -csv 를 빼면 학습자 셸의 sqlite3 별칭(-box) 때문에 표 테두리가 그대로 들어간다
# 실패해야: CSV 형식이다
# 학습자 셸에서 sqlite3 는 'sqlite3 -box' 별칭이다 (이 테스트는 로그인 셸이 아니라서 직접 붙인다)
sqlite3 -box -header ~/shop.db "SELECT strftime('%Y-%m', ordered_at) AS 월, COUNT(*) AS 주문수, SUM(amount) AS 매출 FROM orders WHERE status = 'paid' GROUP BY 월 ORDER BY 월;" > ~/report.csv
