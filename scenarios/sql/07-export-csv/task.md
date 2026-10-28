# 월별 매출 보고서 CSV 로 내보내기

재무팀이 매달 받던 보고서를 이제 직접 뽑아 달래요. `~/shop.db` 의 `orders` 테이블에 올해 주문이 있어요.

```
orders(id, customer, amount, status, ordered_at)
status: paid / cancelled / refunded,  ordered_at: '2026-03-14 15:22:01'
```

## 목표
`~/report.csv` 를 아래 모양으로 만드세요.
```
월,주문수,매출
2026-01,123,4567000
2026-02,...
```
1. 열 이름(머리글)은 정확히 **`월,주문수,매출`**
2. **결제 완료(`paid`)** 주문만 세고 더하기 (`cancelled`, `refunded` 는 빼요)
3. **월 오름차순**, 주문이 있는 달만
4. **CSV 형식** (쉼표로 구분, 표 테두리 없이)

## 써볼 SQL
| SQL / sqlite3 명령 | 하는 일 |
|---|---|
| `strftime('%Y-%m', ordered_at)` | 날짜에서 `2026-03` 만 |
| `SELECT ... AS 월` | 열 이름 붙이기 |
| `GROUP BY 1 ORDER BY 1` | 첫 번째 열로 묶고 정렬 |
| `.headers on` / `.mode csv` | 머리글 표시 / CSV 로 출력 (sqlite3 셸 명령) |
| `.output 파일` … `.output stdout` | 결과를 파일로 / 다시 화면으로 |
| `sqlite3 -csv -header DB "SQL" > 파일` | 셸에서 한 번에 |
