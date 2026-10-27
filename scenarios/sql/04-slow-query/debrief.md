# 해설

```sql
.timer on
EXPLAIN QUERY PLAN SELECT * FROM events WHERE user_id = 42;
-- SCAN events                                   ← 30만 줄 전부
CREATE INDEX idx_events_user_id ON events(user_id);
EXPLAIN QUERY PLAN SELECT * FROM events WHERE user_id = 42;
-- SEARCH events USING INDEX idx_events_user_id (user_id=?)
```
시간이 수십 ms → 1 ms 이하로 줄어드는 걸 `.timer` 로 볼 수 있어요.

## 인덱스는 언제?
- `WHERE`, `JOIN ... ON`, `ORDER BY` 에 **자주** 쓰는 열
- 값의 종류가 많은 열 (user_id 처럼). 성별처럼 값이 2~3개뿐이면 효과가 적어요.

## 공짜는 아니에요
| 장점 | 비용 |
|---|---|
| 조회가 빨라짐 | 디스크 공간을 더 씀 |
| | INSERT/UPDATE 때마다 인덱스도 고쳐야 해서 **쓰기가 느려짐** |

그래서 "모든 열에 인덱스"는 답이 아니에요. **느린 쿼리를 실행 계획으로 확인 → 필요한 인덱스만** 이 순서가 정석입니다.

## 다른 DB 에서는
- PostgreSQL / MySQL: `EXPLAIN SELECT ...` (실제 실행까지 보려면 `EXPLAIN ANALYZE`)
- 여러 열로 찾는다면 복합 인덱스: `CREATE INDEX ... ON events(user_id, created_at);`
