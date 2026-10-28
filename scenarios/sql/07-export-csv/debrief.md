# 해설

```bash
sqlite3 -csv -header ~/shop.db "
SELECT strftime('%Y-%m', ordered_at) AS 월,
       COUNT(*)                      AS 주문수,
       SUM(amount)                   AS 매출
FROM orders
WHERE status = 'paid'
GROUP BY 월
ORDER BY 월;" > ~/report.csv
```

## 날짜를 묶는 방법
| 단위 | SQLite | PostgreSQL | MySQL |
|---|---|---|---|
| 월 | `strftime('%Y-%m', d)` | `to_char(d, 'YYYY-MM')` / `date_trunc('month', d)` | `DATE_FORMAT(d, '%Y-%m')` |
| 일 | `date(d)` | `d::date` | `DATE(d)` |
| 요일 | `strftime('%w', d)` (0=일) | `extract(dow from d)` | `DAYOFWEEK(d)` |

## sqlite3 출력 모드
| 모드 | 용도 |
|---|---|
| `.mode box` / `table` | 사람이 보기 좋게 |
| `.mode csv` | 엑셀·다른 프로그램으로 |
| `.mode json` | API·스크립트로 |
| `.mode markdown` | 문서·위키에 붙여넣기 |
| `.once 파일` | **다음 쿼리 하나만** 파일로 (`.output` 처럼 되돌릴 필요 없음) |

## 별칭(alias) 함정
`alias sqlite3='sqlite3 -box'` 처럼 별칭에 옵션이 들어 있으면 스크립트·파일 출력에도 그 모양이 섞여요. `type 명령` 으로 별칭인지 확인하고, 원래 명령을 쓰려면 `\sqlite3` 또는 `command sqlite3`. (셸 스크립트 안에서는 별칭이 기본적으로 꺼져 있어요)

## 엑셀로 열 때
한글 머리글이 깨지면 BOM 을 붙이세요: `{ printf '\xef\xbb\xbf'; cat report.csv; } > report_excel.csv` (Python · Node.js 환경의 인코딩 시나리오 참고)
