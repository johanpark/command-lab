`.nullvalue NULL` 을 켜고 `SELECT * FROM members LIMIT 20;` 으로 데이터를 보세요. 빈칸처럼 보이던 것 중 **NULL** 과 **빈 문자열** 이 섞여 있어요.
---
1번: SQL 에서 `NULL = NULL` 은 참이 아니라 **알 수 없음(NULL)** 이에요. 그래서 `WHERE phone = NULL` 은 아무것도 안 걸려요. `WHERE phone IS NULL OR phone = ''`
---
2번: `NOT IN (...)` 목록에 NULL 이 하나라도 있으면 `x NOT IN (1, 2, NULL)` 은 "모름"이 돼서 **전부 걸러져요.** 추천인이 없는 회원은 `referrer_id` 가 NULL 이죠. 해결: 서브쿼리에 `WHERE referrer_id IS NOT NULL` 을 넣거나 `NOT EXISTS` 사용.
---
3번: `AVG(points)` 는 NULL 을 **빼고** 평균을 내요 (분모가 작아짐). `ROUND(AVG(COALESCE(points, 0)), 1)`. 저장은 셸에서 `sqlite3 ~/members.db "SELECT ..." > ~/avg_points.txt`
