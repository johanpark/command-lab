# NULL 때문에 숫자가 이상해요

마케팅팀이 `~/members.db` 로 회원 통계를 뽑았는데, 결과가 다 이상하대요. 동료가 쓴 쿼리는 `~/queries.sql` 에 있어요.

```
전화번호 없는 회원: 0명?        ← 분명 있는데
추천인으로 한 번도 안 뽑힌 회원: 0명?   ← 말이 안 되는데
평균 포인트: 왜 이렇게 높지?
```

`members` 테이블: `id, name, phone, referrer_id(나를 추천한 회원 id), points`

## 목표
각 답을 숫자 하나로 저장하세요.
1. **전화번호가 없는 회원 수** → `~/no_phone.txt`
   (전화번호가 `NULL` 이거나 **빈 문자열** `''` 인 회원)
2. **다른 회원의 추천인으로 한 번도 등록되지 않은 회원 수** → `~/never_referrer.txt`
   (어떤 회원의 `referrer_id` 에도 나오지 않는 회원)
3. **전체 회원의 평균 포인트** → `~/avg_points.txt`
   (포인트가 `NULL` 인 회원은 **0점**으로 쳐서, **소수점 첫째 자리**까지: `ROUND(값, 1)`)

## 써볼 SQL
| SQL | 하는 일 |
|---|---|
| `열 IS NULL` / `열 IS NOT NULL` | NULL 인지 (`= NULL` 은 항상 거짓!) |
| `COALESCE(열, 0)` | NULL 이면 0 으로 |
| `NOT EXISTS (SELECT 1 FROM ... WHERE ...)` | 없는 것 찾기 (NULL 에 안전) |
| `COUNT(*)` / `COUNT(열)` | 모든 행 / NULL 이 아닌 행만 |
| `.nullvalue NULL` | sqlite3 화면에서 NULL 을 보이게 (셸 명령) |
