# 데이터 안전하게 고치기

운영 DB `~/shop.db` 에 고칠 데이터가 생겼습니다. **엉뚱한 행을 건드리면 안 되는** 운영 DB예요.

## 목표
1. `oldmail.com` 메일 서비스가 종료됐어요. 이메일이 `@oldmail.com` 으로 끝나는 고객의 도메인을 **`@newmail.com`** 으로 바꾸세요. (앞부분 아이디는 그대로)
2. 상태가 **`cancelled`** 인 주문을 모두 **삭제**하세요.
3. `~/request.txt` 에 적힌 고객의 **도시를 `제주`** 로 바꾸세요. (그 고객 **한 명만**)
4. 그 밖의 데이터는 **하나도 바뀌면 안 됩니다.**

## 써볼 SQL
| SQL | 하는 일 |
|---|---|
| `UPDATE 테이블 SET 열 = 값 WHERE 조건;` | 수정 |
| `DELETE FROM 테이블 WHERE 조건;` | 삭제 |
| `REPLACE(email, '찾을것', '바꿀것')` | 문자열 바꾸기 |
| `BEGIN;` … `COMMIT;` / `ROLLBACK;` | 묶어서 확정 / 취소 |

> ⚠️ **WHERE 없는 UPDATE/DELETE 는 테이블 전체**를 바꿉니다. 고치기 전에 같은 WHERE 로 `SELECT` 해서 대상부터 확인하세요.
