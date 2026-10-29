# 월말 매출이 사라졌어요 (날짜 범위)

재무팀이 10월 매출 보고서를 받아 보고는 숫자가 이상하대요. 특히 **10월 31일 할인 행사** 매출이 하나도 안 잡혔대요. 보고서를 만든 쿼리는 `~/report.sql` 에 있어요.

```sql
SELECT COUNT(*), SUM(amount) FROM payments
WHERE paid_at BETWEEN '2026-10-01' AND '2026-10-31';
```

`payments` 테이블의 `paid_at` 은 `'2026-10-31 14:22:05'` 처럼 **시각까지** 들어 있어요.

## 목표
**2026년 10월 한 달**(1일 0시 ~ 31일 23:59:59) 결제를 정확히 집계해서
1. 결제 **건수** → `~/count.txt`
2. 결제 **금액 합계** → `~/total.txt`

## 써볼 SQL
| SQL | 하는 일 |
|---|---|
| `SELECT MIN(paid_at), MAX(paid_at) FROM payments;` | 데이터의 날짜 범위 |
| `WHERE paid_at >= '시작' AND paid_at < '끝'` | 시작은 포함, 끝은 미포함 (반열린 구간) |
| `date(paid_at)` | 시각을 떼고 날짜만 |
| `strftime('%Y-%m', paid_at)` | `2026-10` 처럼 연-월만 |

> 💡 결과를 파일로: 셸에서 `sqlite3 ~/shop.db "SELECT ..." > ~/count.txt`
