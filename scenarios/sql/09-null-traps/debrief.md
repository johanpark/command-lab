# 해설

```sql
SELECT COUNT(*) FROM members WHERE phone IS NULL OR phone = '';                          -- 1
SELECT COUNT(*) FROM members m
 WHERE NOT EXISTS (SELECT 1 FROM members r WHERE r.referrer_id = m.id);                  -- 2
SELECT ROUND(AVG(COALESCE(points, 0)), 1) FROM members;                                  -- 3
```

## NULL 은 "값이 없음"이 아니라 "모름"
SQL 은 참/거짓 말고 **모름(UNKNOWN)** 이 있는 3값 논리를 써요. NULL 과 비교하면 결과가 모름이 되고, `WHERE` 는 **참인 행만** 통과시켜요.

| 식 | 결과 |
|---|---|
| `NULL = NULL` | 모름 → 걸러짐 |
| `5 NOT IN (1, 2, NULL)` | `5<>1 AND 5<>2 AND 5<>NULL` → 모름 → 걸러짐 |
| `NULL IS NULL` | 참 |
| `COUNT(phone)` | NULL 아닌 것만 셈 |
| `AVG(points)`, `SUM(points)` | NULL 은 빼고 계산 (`SUM` 은 전부 NULL 이면 NULL) |

## NOT IN 은 특히 위험
`NOT IN (SELECT ...)` 은 서브쿼리에 NULL 이 **한 줄이라도 생기는 순간** 결과가 통째로 비어요. 데이터가 바뀌면서 갑자기 0이 나오기 때문에 버그를 찾기도 어려워요. **"없는 것 찾기"는 `NOT EXISTS` 또는 `LEFT JOIN ... WHERE x.id IS NULL`** 을 습관으로 쓰세요.

## NULL vs 빈 문자열
"전화번호 없음"을 어떤 화면은 NULL 로, 어떤 화면은 `''` 로 저장했어요. 테이블 설계 때 하나로 정하고 (`CHECK (phone <> '')`), 이미 섞였다면 `NULLIF(phone, '')` 로 빈 문자열을 NULL 로 바꿔 다루면 편해요.
