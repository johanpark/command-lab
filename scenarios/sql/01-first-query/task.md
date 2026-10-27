# 쇼핑몰 DB 첫 조회

마케팅팀이 몇 가지 숫자를 물어봤습니다. 쇼핑몰 데이터베이스 `~/shop.db` 에서 찾아 주세요.

## 목표
1. **서울에 사는 고객 수** → `~/answer.txt`
2. **가장 비싼 상품의 이름** → `~/expensive.txt`
3. **2026년 10월에 들어온 주문 수** (`orders.ordered_at` 이 `2026-10-...`) → `~/october.txt`

## DB 열기
```bash
sqlite3 shop.db          # sqlite3 셸로 들어가기 (나올 땐 .quit)
```
```sql
.tables                  -- 테이블 목록
.schema customers        -- 테이블 구조
SELECT * FROM customers LIMIT 5;
```
⚠️ SQL 문은 끝에 **세미콜론(`;`)** 이 있어야 실행돼요. 안 붙이면 `...>` 가 나오며 기다립니다.

## 써볼 SQL
| SQL | 하는 일 |
|---|---|
| `SELECT 열 FROM 테이블` | 조회 |
| `WHERE city = '서울'` | 조건 (문자열은 작은따옴표) |
| `COUNT(*)` | 개수 |
| `ORDER BY price DESC` | 정렬 (DESC 내림차순) |
| `LIMIT 1` | 앞에서 1개만 |
| `LIKE '2026-10-%'` | 패턴 (`%` 는 아무 글자) |

## 답 저장하기
셸(bash)에서 SQL 을 바로 실행하고 결과를 파일로 보낼 수 있어요.
```bash
sqlite3 shop.db "SELECT COUNT(*) FROM customers;" > ~/answer.txt
```
(표 모양 그대로 저장돼도 괜찮아요. 값만 맞으면 됩니다.)
