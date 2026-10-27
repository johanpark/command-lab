# 느린 쿼리 빠르게 만들기

`~/events.db` 의 `events` 테이블에는 사용자 행동 기록이 **30만 줄** 있어요. 고객센터 화면이 "특정 사용자의 기록"을 조회할 때마다 느리다는 불만이 들어왔습니다.

```sql
SELECT * FROM events WHERE user_id = 42;
```

## 목표
1. 위 쿼리의 **실행 계획**을 보고, 테이블 전체를 훑는지(`SCAN`) 확인하세요.
2. `user_id` 로 찾는 쿼리가 빨라지도록 **인덱스**를 만드세요. 이름은 **`idx_events_user_id`**
3. 실행 계획이 인덱스를 쓰는지(`USING INDEX`) 확인하세요.
4. 사용자 **`~/request.txt` 에 적힌 번호**의 이벤트 개수를 `~/answer.txt` 에 저장하세요.

## 써볼 SQL
| SQL | 하는 일 |
|---|---|
| `EXPLAIN QUERY PLAN SELECT ...;` | 쿼리를 어떻게 실행할지 계획만 보기 |
| `.timer on` | 쿼리마다 걸린 시간 표시 (sqlite3 셸 명령) |
| `CREATE INDEX 이름 ON 테이블(열);` | 인덱스 만들기 |
| `.indexes events` | 테이블의 인덱스 목록 |
