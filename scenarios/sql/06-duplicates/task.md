# 중복 가입 정리하기

가입 버튼을 두 번 누르면 회원이 **두 번 만들어지는 버그**가 있었어요. 버그는 고쳤지만 `~/members.db` 에 같은 이메일로 된 회원이 여러 명 남아 있어요. 게다가 중복 계정으로 들어간 **주문**도 있어요.

## 목표
1. **지워야 할 중복 회원 수**(같은 이메일 중 하나만 남긴다고 할 때 지울 행 수)를 `~/answer.txt` 에 저장하세요.
2. 중복 계정의 **주문을 원래 계정**(같은 이메일 중 **id 가 가장 작은** 회원)으로 옮기세요.
3. 중복 회원을 **지우세요.** (이메일마다 id 가 가장 작은 회원만 남김)
4. 다시는 같은 이메일로 가입할 수 없도록 `email` 에 **UNIQUE 인덱스**를 만드세요.

주문은 한 건도 사라지면 안 되고, 주인 없는 주문이 생겨도 안 돼요.

## 써볼 SQL
| SQL | 하는 일 |
|---|---|
| `SELECT email, COUNT(*) FROM members GROUP BY email HAVING COUNT(*) > 1;` | 중복 찾기 |
| `SELECT MIN(id) FROM members GROUP BY email;` | 이메일마다 남길 회원 |
| `UPDATE 테이블 SET 열 = (서브쿼리) WHERE ...;` | 다른 표를 보고 고치기 |
| `DELETE FROM members WHERE id NOT IN (...);` | 남길 것만 빼고 지우기 |
| `CREATE UNIQUE INDEX 이름 ON 테이블(열);` | 중복 금지 |
| `BEGIN;` … `COMMIT;` | 묶어서 확정 |

> 💡 결과를 파일로: 셸에서 `sqlite3 ~/members.db "SELECT ..." > ~/answer.txt`
