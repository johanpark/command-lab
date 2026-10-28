먼저 화면에서 집계부터 맞춰 보세요:
```sql
SELECT strftime('%Y-%m', ordered_at) AS 월, COUNT(*) AS 주문수, SUM(amount) AS 매출
FROM orders WHERE status = 'paid'
GROUP BY 월 ORDER BY 월;
```
---
sqlite3 셸 안에서 파일로 내보내기:
```
.headers on
.mode csv
.output /home/learner/report.csv
(위 SELECT 실행)
.output stdout
```
---
셸에서 `sqlite3 ~/shop.db "SELECT ..." > ~/report.csv` 로 하면 **표 테두리(┌─┐)** 가 파일에 들어가요. 이 실습 환경은 `sqlite3` 가 `sqlite3 -box` 별칭이라서요(`type sqlite3` 로 확인). `-csv -header` 를 붙이면 뒤에 붙은 옵션이 이겨요: `sqlite3 -csv -header ~/shop.db "SELECT ..." > ~/report.csv`
---
`cat ~/report.csv` 로 첫 줄이 `월,주문수,매출` 인지, 테두리 없이 쉼표로만 구분됐는지 확인하세요.
