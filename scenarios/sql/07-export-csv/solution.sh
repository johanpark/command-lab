sqlite3 -csv -header ~/shop.db "
SELECT strftime('%Y-%m', ordered_at) AS 월, COUNT(*) AS 주문수, SUM(amount) AS 매출
FROM orders WHERE status = 'paid'
GROUP BY 월 ORDER BY 월;" > ~/report.csv
cat ~/report.csv
