# 설명: status 를 거르지 않으면 취소·환불 주문까지 매출에 들어간다
# 실패해야: cancelled, refunded
sqlite3 -csv -header ~/shop.db "SELECT strftime('%Y-%m', ordered_at) AS 월, COUNT(*) AS 주문수, SUM(amount) AS 매출 FROM orders GROUP BY 월 ORDER BY 월;" > ~/report.csv
