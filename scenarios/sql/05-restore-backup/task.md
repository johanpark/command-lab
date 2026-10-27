# 실수로 지운 데이터 복구

정리 작업 중에 이 SQL 이 실행돼 버렸어요. 😱

```sql
DELETE FROM customers WHERE city = '부산';
```

어젯밤 백업 `~/backup/shop-nightly.db` 가 있지만, 백업 **이후에도** 새 고객이 가입했고 일부 고객 정보가 수정됐어요. 백업으로 통째로 덮으면 오늘 변경이 사라집니다. (자세한 내용: `~/incident.txt`)

## 목표
`~/shop.db` 의 `customers` 를 **사고 직전 상태**로 돌려놓으세요.
1. 백업에 있던 부산 고객을 **되살리기**
2. 오늘 새로 가입한 고객, 오늘 수정된 정보는 **그대로 유지**
3. 같은 고객이 두 번 들어가면 안 돼요 (id 중복 금지)

> 단, 오늘 가입했다가 지워진 부산 고객은 백업에도 없어요. 이 한 명은 아래 정보로 직접 다시 넣어야 해요.
> `id 21, 노하은, 부산, user21@gmail.com, 가입일 2026-10-27`

## 써볼 SQL
```sql
ATTACH DATABASE 'backup/shop-nightly.db' AS bak;   -- 백업을 bak 이라는 이름으로 붙이기
SELECT * FROM bak.customers WHERE city = '부산';    -- 백업 쪽 조회
INSERT INTO customers SELECT ... FROM bak.customers WHERE ...;   -- 골라서 넣기
DETACH DATABASE bak;
```
