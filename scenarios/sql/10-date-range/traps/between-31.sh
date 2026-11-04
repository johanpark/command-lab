# 설명: BETWEEN '10-01' AND '10-31' 은 31일 0시까지만 포함해 31일 낮 결제가 빠진다
# 실패해야: 10월 결제 건수
# 실패해야: 10월 결제 금액
cd ~
sqlite3 shop.db "SELECT COUNT(*) FROM payments WHERE paid_at BETWEEN '2026-10-01' AND '2026-10-31';" > count.txt
sqlite3 shop.db "SELECT SUM(amount) FROM payments WHERE paid_at BETWEEN '2026-10-01' AND '2026-10-31';" > total.txt
