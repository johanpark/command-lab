`SELECT COUNT(*) FROM payments WHERE date(paid_at) = '2026-10-31';` 로 10월 31일 결제가 실제로 있는지 보세요. 그런데 `report.sql` 의 쿼리로는 하나도 안 잡혀요. 왜일까요?
---
`paid_at` 은 **문자열**로 비교돼요. `'2026-10-31 14:22:05'` 는 `'2026-10-31'` 보다 **뒤**(더 큼)라서, `BETWEEN ... AND '2026-10-31'` 의 범위를 벗어나요. 31일 0시 0분 0초 딱 그 순간만 들어가는 셈이에요.
---
가장 안전한 방법은 **"다음 달 1일 미만"**: `WHERE paid_at >= '2026-10-01' AND paid_at < '2026-11-01'`. 시각이 몇 자리든, 월말이 30일이든 31일이든 항상 맞아요.
---
`sqlite3 ~/shop.db "SELECT COUNT(*) FROM payments WHERE paid_at >= '2026-10-01' AND paid_at < '2026-11-01';" > ~/count.txt` 그리고 `SUM(amount)` 로 `~/total.txt`. (9월 30일 밤, 11월 1일 새벽 결제도 섞여 있으니 경계 확인!)
